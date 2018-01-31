package ducttape::git;

use v5.10;
use strict;
use warnings;

use VIMx::Symbiont;
use Git::Raw;
use Git::Raw::Blob;
use Git::Raw::Commit;
use Git::Raw::Config;
use Git::Raw::Graph;
use Git::Raw::Repository;
use Git::Raw::Reference;
use Git::Raw::Signature;
use Path::Tiny;

sub bufrepo {
    # FIXME ARRGH
    return Git::Raw::Repository->open($b{git_dir});

    return unless $b{git_dir};
    my $start = path(shift // $main::curbuf->Name || q{.})->absolute->parent;
    return Git::Raw::Repository->discover($start);
}

function config_str => sub { Git::Raw::Config->default->str(shift) };

fun args => 'key', config => sub {
    return bufrepo($main::curbuf->Number)->config->str($a{key});
};

function is_bare          => sub { bufrepo->is_bare             };
function is_empty         => sub { bufrepo->is_empty            };
function is_shallow       => sub { bufrepo->is_shallow          };
function is_head_detached => sub { bufrepo->is_head_detached    };
function is_worktree      => sub { bufrepo->is_worktree         };
function branches         => sub { bufrepo->branches(@_)        };
function state            => sub { bufrepo->state               };
function path             => sub { bufrepo->path                };
function commondir        => sub { bufrepo->commondir           };
function workdir          => sub { bufrepo->workdir(@_)         };
function ignore           => sub { bufrepo->ignore(@_)          };
function path_is_ignored  => sub { bufrepo->path_is_ignored(@_) };
function merge_base       => sub { bufrepo->merge_base(@_)      };
function status           => sub { bufrepo->status              };
function id_for           => sub { bufrepo->revparse(shift)     };

fun revparse => sub { [ bufrepo->revparse(@_) ] };

function index_add => sub { my $i = bufrepo->index; $i->add($main::curbuf->Name); $i->write };

function revlist       => sub { [ map { $_->id } bufrepo->walker->push_range(bufrepo->revparse(@_))->all ] };
function revlist_count => sub { scalar bufrepo->walker->push_range(bufrepo->revparse(@_))->all             };

function fixup => sub {
    my ($id_to_fixup) = @_;

    my $repo = bufrepo;

    ### get our index and its corresponding tree...
    my $index = $repo->index;
    $index->read(1);
    my $tree_id = $index->write_tree($repo);
    my $tree = $repo->lookup($tree_id);

    ### get head for the fixup message...
    my $head = $repo->head;
    my $head_commit = $head->peel('commit');
    ### head: $head_commit->id
    my $summary = $head_commit->summary;

    ### commit the fixup...
    my $who = Git::Raw::Signature->default($repo);
    # my $fixup = $repo->commit(
    my $fixup = Git::Raw::Commit->create($repo,
        "fixup! $summary",
        $who,
        $who,
        [$head_commit],
        # [$repo->head->target],
        $tree,
    );

    ### done: $fixup->id
    return $fixup->id;
};

fun args => 'id', type_of => sub {
    # FIXME probably not ideal
    # return bufrepo->lookup($a{id})->is_blob ? 'blob' : 'tree';

    my $thing = bufrepo->lookup($a{id});
    (my $type = lc ref $thing) =~ s/^.*:://;

    return $type;
};

fun args => 'id', lookup => sub {
    my $r = bufrepo;

    # lookup() returns blessed to type of thing found
    my $thing = $r->lookup($a{id});

    if ($thing->is_blob) {
        return {
            id      => $thing->id,
            type    => 'blob',
            content => $thing->content,
            size    => $thing->size,
        };
    }
    elsif ($thing->is_tree) {
        ...;
        return {
            id      => $thing->id,
            type    => 'tree',
            # content => $thing->content,
            size    => 0, # undef?
        };
    }
    ...;
};

fun args => 'id', blob_read => sub {
    my $r = bufrepo;

    # lookup() returns blessed to type of thing found
    return [ split(/\n/, $r->lookup($a{id})->content) ];
};

# somewhat a misnomer -- write the contents of the current file to the object
# store, then return the blob's id
function curbuf_to_blob => sub {
    my ($fn) = @_;

    my $repo = bufrepo;
    my $blob = _cbuf_to_blob($repo);

    ### id: $blob->id
    return $blob->id;
};

function wip => sub {

    my $name = $cbuf->Name;
    return
        if $name =~ m!^(\.git/|fugitive://)!;

    my $repo = bufrepo;
    my $blob = _cbuf_to_blob($repo);

    my $wip_ref  = _wip_ref_for($repo);
    my $wip_tree = new_tree_with($repo, $wip_ref->peel('tree'), $name => $blob);

    ### $wip_tree
    my $who = Git::Raw::Signature->default($repo);
    my $wip = Git::Raw::Commit->create($repo,
        'wip of ' . $name,
        $who,
        $who,
        [$wip_ref->peel('commit')],
        $wip_tree,
        $wip_ref->name,
    );

    ### $wip
    return $wip->id;
};

sub new_tree_with {
    my ($repo, $tree, $name, $blob) = @_;

    my @path_parts = split /\//, $name;

    return _new_tree_with($repo, $tree, $blob, @path_parts);
}

# returns the replacement for $tree
sub _new_tree_with {
    my ($repo, $tree, $blob, $our_part, @path_parts) = @_;

    ### $our_part
    ### @path_parts
    my $entry = $tree->entry_byname($our_part);
    ### $entry

    # FIXME TODO handle DNE $entry

    my $thing
        = @path_parts > 0
        ? _new_tree_with($repo, $entry->object, $blob, @path_parts)
        : $blob
        ;

    ### out of recursion...
    my $mode = !!$entry ? $entry->file_mode : 0100644;
    my $tb = Git::Raw::Tree::Builder->new($repo, $tree);
    $tb->insert($our_part, $thing, $mode);
    return $tb->write;
}

sub _wip_ref_for {
    my ($repo) = @_;

    my $head = $repo->head;
    my $refname = $head->name;
    ( my $wip_refname = $refname ) =~ s!^refs/heads/!refs/wip/!;

    if (my $wip_ref = Git::Raw::Reference->lookup($wip_refname, $repo)) {

        ### wip ref exists: $wip_ref->name
        if (Git::Raw::Graph->is_descendant_of($repo, $wip_ref, $head)) {

            ### is a descendant...
            return $wip_ref;
        }
        else {
            ### not a descendant; repointing wip ref at master...
            $wip_ref = $wip_ref->target($head->peel('commit'));

            ### $wip_ref
            return $wip_ref;
        }
    }

    ### no existing wip ref found; creating...
    return Git::Raw::Reference->create($wip_refname, $repo, $head->peel('commit'));
}

sub _cbuf_to_blob {
    my ($repo) = @_;

    my $contents = join("\n", @$cbuf);
    my $blob = Git::Raw::Blob->create($repo, $contents);

    ### id: $blob->id
    return $blob;
}


function huh => sub {
    my $head = bufrepo->head;
    warn "$_: " . $head->$_() . "\n"
        for qw{ name shorthand type is_branch };
    my $wip_ref = _wip_ref_for(bufrepo);
    ### $wip_ref
    return;
};

!!42;
__END__

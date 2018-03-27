package VIMx::autoload::ducttape::git;

use v5.10;
use strict;
use warnings;

use VIMx::Symbiont;

use Carp qw{ croak confess };
use Data::Section::Simple 'get_data_section';
use Git::Raw;
use Git::Raw::Blob;
use Git::Raw::Commit;
use Git::Raw::Config;
use Git::Raw::Graph;
use Git::Raw::Note;
use Git::Raw::Repository;
use Git::Raw::Reference;
use Git::Raw::Signature;
use Path::Tiny;
use Template::Tiny;

# poor man's aliased
use constant Note => 'Git::Raw::Note';
use constant TreeBuilder => 'Git::Raw::Tree::Builder';

sub bufrepo {

    my ( $name, $discover_path ) = ( "$BUFFER", undef );

    ### looking for repo for buffer: $name
    if ($VIMx::LOPTIONS{buftype} eq 'nofile') {

        ### buftype nofile: $name
        $discover_path = Path::Tiny->cwd->realpath;
    }
    elsif (( "$name" =~ m!^fugitive:/! ) || ($name eq q{})) {

        # for now, just use the current directory; probably better to parse
        # out from the fugitive url, however.  This will only occurr in
        # fugitive buffers, after all, and they tend to be fairly worktree
        # agnostic.
        #
        # Kinda.

        ### fugitive or blank: $name
        $discover_path = Path::Tiny->cwd->realpath;
    }
    elsif ("$name" =~ /\.fugitiveblame/) {

        ### uhh, just trying cwd again: $name
        $discover_path = Path::Tiny->cwd->realpath;
    }
    else {
        $name = path($name);

        # FIXME this barfs horribly if $name->parent doesn't exist

        ### check to see if exists: $name
        $discover_path
            = $name->exists
            ? $name->realpath
            : $name->parent->realpath
            ;
    }

    ### $discover_path
    # no warnings 'precedence';
    return Git::Raw::Repository->discover($discover_path)
        || confess "Cannot find a git repo for buffer $name at path $discover_path";
}

function config_str => sub { bufrepo->config->str(shift) };

fun args => 'key', config => sub {
    return bufrepo($BUFFER->Number)->config->str($a{key});
};

function is_bare          => sub { bufrepo->is_bare             };
function is_empty         => sub { bufrepo->is_empty            };
function is_shallow       => sub { bufrepo->is_shallow          };
function is_head_detached => sub { bufrepo->is_head_detached    };
function is_worktree      => sub { bufrepo->is_worktree         };
function is_annex         => sub { defined bufrepo->config->int('annex.version') };
function branches         => sub { bufrepo->branches(@_)        };
function path             => sub { bufrepo->path                };
function commondir        => sub { bufrepo->commondir           };
function workdir          => sub { bufrepo->workdir(@_)         };
function ignore           => sub { bufrepo->ignore(@_)          };
function path_is_ignored  => sub { bufrepo->path_is_ignored(@_) };

function args => q{}, state         => sub { my $st = bufrepo->state; return ($st eq 'none' ? q{} : $st) };
function args => q{}, has_staged    => sub { scalar keys %{ bufrepo->status({ show => 'index' }) } };
function args => q{}, has_modified  => sub { scalar keys %{ bufrepo->status({ show => 'worktree' }) } };
function args => q{}, has_stash     => sub { ... };
function args => q{}, has_untracked => sub { ... };

function id_for   => sub { bufrepo->revparse(shift)  };
function revparse => sub { [ bufrepo->revparse(@_) ] };

function index_add => sub { my $i = bufrepo->index; $i->add($BUFFER->Name); $i->write };

# TODO rejigger to use the ::Graph functions instead
function revlist       => sub { [ map { $_->id } bufrepo->walker->push_range(bufrepo->revparse(@_))->all ] };
function revlist_count => sub { scalar bufrepo->walker->push_range(bufrepo->revparse(@_))->all             };

function merge_base => sub {
    my (@objs) = @_;

    my $repo = bufrepo;

    my @commits =
        map { $repo->lookup($_)   }
        map { $repo->revparse($_) }
        @objs;

    return $repo->merge_base(@commits);
};

function fixup  => sub { _special_commit(fixup  => @_) };
function squash => sub { _special_commit(squash => @_) };

function args => 'command, ...', special_commit => sub { _special_commit($a{command}, @_) };

sub _special_commit {
    my ($cmd, $id_to_fixup) = @_;

    my $repo = bufrepo;

    ### $id_to_fixup
    ($id_to_fixup) = $repo->revparse($id_to_fixup // 'HEAD');

    ### get our index and its corresponding tree...
    my $index = $repo->index;
    $index->read(1);
    my $tree_id = $index->write_tree($repo);
    my $tree = $repo->lookup($tree_id);

    my $head = $repo->head;
    my $head_commit = $head->peel('commit');

    ### get commit for the fixup message: $id_to_fixup
    my $target = $repo->lookup($id_to_fixup);
    my $summary = $target->summary;

    ### commit the fixup...
    my $who = Git::Raw::Signature->default($repo);
    my $fixup = Git::Raw::Commit->create($repo,
        "$cmd! $summary",
        $who,
        $who,
        [$head_commit],
        $tree,
    );

    ### done: $fixup->id
    return $fixup->id;
};

fun args => 'id', type_of => sub {
    # FIXME probably not ideal
    # return bufrepo->lookup($a{id})->is_blob ? 'blob' : 'tree';

    my $r = bufrepo;
    my $thing = $r->lookup($r->revparse($a{id}));
    (my $type = lc ref $thing) =~ s/^.*:://;

    return $type;
};

fun args => 'id', blob_read => sub {
    my $r = bufrepo;

    # lookup() returns blessed to type of thing found
    return [ split(/\n/, $r->lookup($a{id})->content) ];
};

fun args => 'id', blob_read_into_buf => sub {
    my $r = bufrepo;

    # lookup() returns blessed to type of thing found
    @$BUFFER = split(/\n/, $r->lookup($a{id})->content);
    return;
};

# somewhat a misnomer -- write the contents of the current file to the object
# store, then return the blob's id
function curbuf_to_blob => sub {
    my ($fn) = @_;

    my $repo = bufrepo;
    my $blob = cbuf_to_blob($repo);

    ### id: $blob->id
    return $blob->id;
};

function wip => sub {

    # check these before resolving the path
    return
        if $BUFFER->Name =~ m!^(\.git/|fugitive://)!;

    return
        if $OPTIONS{previewwindow} || ($OPTIONS{buftype} ne q{});

    ### skip files in a git-annex repository...
    my $repo = bufrepo;
    return
        if $repo->config->int('annex.version');

    my $name = resolve_relative_path($repo => $BUFFER->Name);
    my $blob = cbuf_to_blob($repo);

    ### $name
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

# resolves a file's path relative to the repo path; necessary when working
# with files symlinked outside of a repository
sub resolve_relative_path {
    my ($repo, $path) = @_;

    ### $path
    ### workdir: $repo->workdir
    my $relative = path($path)->realpath->relative($repo->workdir);

    ### $relative
    return $relative;
}

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
    ### $tree
    my $entry
        = ref $tree eq 'Git::Raw::Tree'
        ? $tree->entry_byname($our_part)
        : $tree->get($our_part)
        ;

    ### $entry
    my $child_tree
        = !!$entry ? $entry->object : TreeBuilder->new($repo)->write;

    # FIXME TODO handle DNE $entry

    my $thing
        = @path_parts > 0
        ? _new_tree_with($repo, $child_tree, $blob, @path_parts)
        : $blob
        ;

    ### out of recursion...
    my $mode
        = !!$entry        ? $entry->file_mode # use existing
        : @path_parts > 0 ? 0040000           # directory
        :                   0100644           # file
        ;

    my $tb = TreeBuilder->new($repo, $tree);
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

sub cbuf_to_blob {
    my ($repo) = @_;

    # trailing empty string forces a blob to end with a newline, which keeps
    # git from complaining
    my $contents = join("\n", @$BUFFER, q{});
    my $blob = Git::Raw::Blob->create($repo, $contents);

    ### id: $blob->id
    return $blob;
}

function status => sub { bufrepo->status({ flags => { include_untracked => 1 } }) };

function status_msg => sub {
    my $repo = bufrepo;

    my $status = $repo->status({ flags => { include_untracked => 1 } });

    $status->{$_}->{flags} = +{ map { $_ => 1 } @{ $status->{$_}->{flags} } }
        for keys %$status;

    my $lists = {
        untracked => [ grep { $status->{$_}->{flags}->{worktree_new}      } sort keys %$status ],
        modified  => [ grep { $status->{$_}->{flags}->{worktree_modified} } sort keys %$status ],
        staged    => [ grep { $status->{$_}->{flags}->{index_modified}    } sort keys %$status ],
    };

    my $tmpl = get_data_section('status.tt2');
    my $msg = q{};
    my $tt = Template::Tiny->new(
        # TRIM => 1
    )->process(\$tmpl, $lists, \$msg);

    return $msg;
};

function args => 'hash', get_commit => sub {
    my $repo = bufrepo;

    my $commit = $repo->lookup($a{hash})
        || die "Cannot find commit $a{hash}";

    my $spew = 'tree ' . $commit->tree->id . "\n";
    $spew .= "parent $_\n"
        for $commit->parents;

    my $_sig = sub {
        my ($sig) = @_;
        my $offset_min = $sig->offset % 60;
        my $offset_hr = ($sig->offset - $offset_min) / 60;
        return $sig->name . q{ <} . $sig->email . q{> }
            . localtime($sig->time) . q{ }
            . sprintf(($offset_hr < 0 ? '-' : q{} ) . '%02d%02d', abs($offset_hr), $offset_min)
        ;
    };

    $spew .= 'author '   .$_sig->($commit->author)   ."\n";
    $spew .= 'committer '.$_sig->($commit->committer)."\n";
    $spew .= "\n" . $commit->message . "\n";

    # TODO need to find/display other notes, maybe
    if (my $note = Note->read($repo, $commit)) {
        $spew .= "Notes (__default__):\n\n" . $note->message . "\n";
    }

    my $diff = $commit->diff;

    if (!$g{dt_git_no_diffstats}) {
        # this is super slow when a single commit is Quite Large.
        #
        # ...maybe conditionalize it with a g:/b: combo? TODO
        my $stats = $diff->stats;
        if ($stats->files_changed < 100) {
            $spew .= q{}
            . $diff->stats->buffer({ flags => { full => 1} }) . "\n"
            # . "full stats:\n" . $diff->stats->buffer({ flags => { full => 1} }) . "\n"
            # . "summary stats:\n" . $diff->stats->buffer({ flags => { summary => 1} }) . "\n\n"
            # . $diff->buffer('patch')
            ;
        }
        else {
            $spew .= q{}
                . '+' . $stats->insertions . '/'
                . '-' . $stats->deletions . q{, }
                . $stats->files_changed . ' files changed'
        }
    }

    # this -- and the above stats -- fails for some commits.
    $spew .= $diff->buffer('patch');

    ### $spew
    @$BUFFER = ( split /\n/, $spew );
    return;
};

function args => q{id}, author_timestamp => sub {
    my $r = bufrepo;
    return $r->lookup($r->revparse($a{id}))->author->time;
};

function interesting_refs => sub {
    my $r = bufrepo;

    return [
        map  { $_->shorthand                                }
        grep { $_->is_branch || $_->is_remote || $_->is_tag }
        $r->refs
    ];
};


!!42;
__DATA__
@@ status.tt2
# On branch [% branch %]
# Your branch is ahead of 'origin/master' by 8 commits.
#   (use "git push" to publish your local commits)
#
# Changes to be committed:
#   (use "git reset HEAD <file>..." to unstage)
#
[% FOREACH file IN staged -%]
#	modified:   [% file %]
[% END -%]
#
# Changes not staged for commit:
#   (use "git add <file>..." to update what will be committed)
#   (use "git checkout -- <file>..." to discard changes in working directory)
#
[% FOREACH file IN modified -%]
#	modified:   [% file %]
[% END -%]
#
# Untracked files:
#   (use "git add <file>..." to include in what will be committed)
#
[% FOREACH file IN untracked -%]
#       [% file %]
[% END -%]
#

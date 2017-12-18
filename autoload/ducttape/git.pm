package ducttape::git;

use v5.10;
use strict;
use warnings;

use VIMx::Symbiont;
use Git::Raw;
use Git::Raw::Blob;
use Git::Raw::Commit;
use Git::Raw::Config;
use Git::Raw::Repository;
use Git::Raw::Signature;
use Path::Tiny;

# debugging...
use Smart::Comments '###';

sub repo_for_bufno {
    my ($bufnr) = @_;

    state $repos = {};

    return $repos->{$bufnr}
        if defined $repos->{$bufnr};

    # $repos->{$bufnr} = path($curbuf->Name)->absolute->parent;
    return $repos->{$bufnr} = Git::Raw::Repository->open($B{git_commondir});
}

sub bufrepo { repo_for_bufno($main::curbuf->Number) }

function config_str => sub { Git::Raw::Config->default->str(shift) };

function config => sub {
    my ($key) = @_;

    return repo_for_bufno($main::curbuf->Number)->config->str($key);
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
function revparse         => sub { [ bufrepo->revparse(@_) ]    };
function revparse_count   => sub { scalar bufrepo->revparse(@_) };

function fixup => sub {
    my ($fn) = @_;

    # FIXME symlinks!
    # my $repo = Git::Raw::Repository->discover(path($main::curbuf->Name)->absolute->parent);
    my $repo = Git::Raw::Repository->open($B{git_dir});
    ### git dir: $B{git_commondir}
    # my $repo = Git::Raw::Repository->open($B{git_commondir});

    ### get our index and its corresponding tree...
    my $index = $repo->index;
    ### count: $index->entry_count
    ### version: $index->version
    ### index path: $index->path
    ### index checksum: $index->checksum
    $index->read(1);
    ### count: $index->entry_count
    ### index path: $index->path
    ### index checksum: $index->checksum
    my $tree_id = $index->write_tree($repo);
    my $tree = $repo->lookup($tree_id);
    # return;
    # return;

    ### $tree_id
    ### tree is: $tree->id
    ### tree: ref $tree
    # return $tree->id;

    # return;

    ### owning path: $tree->owner->path
    say $_->name for $tree->entries;

    # return;

    ### get head for the fixup message...
    my $head = $repo->head;
    my $head_commit = $head->peel('commit');
    ### head: $head_commit->id
    my $summary = $head_commit->summary;

    # return;

    ### commit the fixup...
    my $who = Git::Raw::Signature->default($repo);
    ### name: $who->name
    ### email: $who->email
    ### time: $who->time
    ### $summary
    # return;
    # sleep 5;
    # my $fixup = $repo->commit(
    my $fixup = Git::Raw::Commit->create($repo,
        "fixup! $summary",
        $who,
        $who,
        [$head_commit],
        # [$repo->head->target],
        $tree,
        # 'refs/heads/test'
    );
    # sleep 5;

    return;
    ### done: $fixup->id
    # return $fixup->id;
};

function cat_file => sub {
    my ($fn) = @_;

    # FIXME symlinks!
    # my $repo = Git::Raw::Repository->discover(path($main::curbuf->Name)->absolute->parent);
    # my $repo = Git::Raw::Repository->open($B{git_dir});
    ### git dir: $B{git_commondir}
    my $repo = Git::Raw::Repository->open($B{git_commondir});

    my $contents = join("\n", $main::curbuf->Get(1..$main::curbuf->Count));

    my $blob = Git::Raw::Blob->create($repo, $contents);

    ### id: $blob->id
    return $blob->id;
};

!!42;
__END__

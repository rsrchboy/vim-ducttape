package VIMx::autoload::ducttape::git::head;

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

# use ducttape::git;

# debugging...
use Smart::Comments '###';

sub bufrepo { goto \&VIMx::autoload::ducttape::git::bufrepo }

function subject        => sub { bufrepo->head->peel('commit')->summary };
function target_subject => sub { bufrepo->head->target->summary         };

!!42;
__END__

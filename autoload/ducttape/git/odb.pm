package VIMx::autoload::ducttape::git::odb;

use v5.10;
use strict;
use warnings;

use VIMx::Symbiont;
use Git::Raw;
use Git::Raw::Repository;

use Smart::Comments;

sub bufrepo {
    # FIXME ARRGH
    return Git::Raw::Repository->open($b{git_dir});

    return unless $b{git_dir};
    my $start = path(shift // $main::curbuf->Name || q{.})->absolute->parent;
    return Git::Raw::Repository->discover($start);
}

fun args => 'id', read => sub {

    my $obj = bufrepo->odb->read($a{id});

    die "$a{id} was not found in the object database!"
        unless !!$obj;

    return {
        map { $_ => $obj->$_() } qw{ id type size data },
    };
};



!!42;
__END__

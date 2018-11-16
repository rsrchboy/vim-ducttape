package VIMx::autoload::ducttape::path;

use v5.10;
use strict;
use warnings;

use VIMx::Symbiont;

# Create a tempdir, with all the bells and whistles.

function tempdir => sub {
    return Path::Tiny
        ->tempdir(CLEANUP => 0, %{$a{000} ? $a{1} : {}})
        ->stringify;
};

function args => q{dir}, rmtree => sub {
    path($a{dir})->remove_tree({ safe => 0 });
    return;
};

function args => q{path}, mkpath => sub {
    path($a{path})->mkpath;
    return $a{path};
};

!!42;

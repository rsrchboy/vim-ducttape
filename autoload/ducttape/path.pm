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

!!42;

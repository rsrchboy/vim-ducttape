package ducttape::perl;

# ABSTRACT: Perly things one might need

use v5.10;
use strict;
use warnings;

use VIMx::Symbiont;
use Module::Info;

# the VIMx::Symbiont-generated sub functions handles turning the parameters
# JSON into Perl values -- and the other way around on return.

function args => q{}, version => sub { "$^V" };

function version_gt => sub { $^V gt shift ? 1 : 0 };
function version_ge => sub { $^V ge shift ? 1 : 0 };
function version_lt => sub { $^V lt shift ? 1 : 0 };
function version_le => sub { $^V le shift ? 1 : 0 };

!!42;
__END__

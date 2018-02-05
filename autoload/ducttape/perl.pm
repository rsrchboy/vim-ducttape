package ducttape::perl;

# ABSTRACT: Perly things one might need

use v5.10;
use strict;
use warnings;

use VIMx::Symbiont;

# the VIMx::Symbiont-generated sub functions handles turning the parameters
# JSON into Perl values -- and the other way around on return.

function args => q{}, version => sub { "$^V" };

function args => 'ver', version_gt => sub { $^V gt $a{ver} ? 1 : 0 };
function args => 'ver', version_ge => sub { $^V ge $a{ver} ? 1 : 0 };
function args => 'ver', version_lt => sub { $^V lt $a{ver} ? 1 : 0 };
function args => 'ver', version_le => sub { $^V le $a{ver} ? 1 : 0 };

!!42;
__END__

package t::one;

use v5.10;
use strict;
use warnings;

use VIMx::Symbiont;

# use Smart::Comments;

fun args => q{}, hello => sub { 'world!' };

fun scalar     => sub { ($_[0] // 0) + 2 };
fun scalar_ref => sub { \'2 + 2' };
fun hash_ref   => sub { { a => 1, b => 2 } };
fun array_ref  => sub { [ 1, 2, 3 ] };
fun nested     => sub { { a => [ 1, 2 ], b => { rainbow => 'dash' } } };
fun round_trip => sub { @_ };

!!42;
__END__

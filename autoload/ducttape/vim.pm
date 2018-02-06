package ducttape::vim;

# ABSTRACT: Useful things about VIM

# ...aka "why is it so hard to get a list of buffers?!

use v5.10;
use strict;
use warnings;

use VIMx::Symbiont;

# the VIMx::Symbiont-generated sub functions handles turning the parameters
# JSON into Perl values -- and the other way around on return.

function args => q{}, buffers => sub { [ sort keys %VIMx::BUFFERS ] };

!!42;
__END__

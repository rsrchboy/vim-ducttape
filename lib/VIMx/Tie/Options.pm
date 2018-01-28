package VIMx::Tie::Options;

use strict;
use warnings;

use base 'VIMx::Tie::Dict';

# # debugging...
# use Smart::Comments '###';

# NOTE right now we only handle simple cases, where the value of the slot to
# be set/read is a plain scalar, a string or number.  We should probably
# refactor this to do the whole json {en,de}coding bit we're doing to handle
# @_ and a:000.

sub _make_target {
    my ($this, $key) = @_;
    my $dict = $this->{thing};

    return "$dict$key";
}

!!42;
__END__

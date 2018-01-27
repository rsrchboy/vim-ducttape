package VIMx::AutoLoadFor::Tie;

use v5.10;
use strict;
use warnings;

# # debugging...
# use Smart::Comments '###';

our $AUTOLOAD;

sub AUTOLOAD {
    my ($self, @args) = @_;
    ( my $method = $AUTOLOAD ) =~ s/^.*:://;

    ### $self
    ### $AUTOLOAD
    ### $method
    ### @args
    return tied(@$self)->buffer->$method(@args);
}

!!42;
__END__

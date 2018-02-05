package VIMx::AutoLoadFor::Tie;

use v5.10;
use strict;
use warnings;

use overload
    '""' => sub { q{} . tied(@{$_[0]}) },
    '0+' => sub {   0 + tied(@{$_[0]}) },
    fallback => 1,
    ;

# # debugging...
# use Smart::Comments '###';

our $AUTOLOAD;

sub AUTOLOAD {
    my ($self, @args) = @_;
    ( my $method = $AUTOLOAD ) =~ s/^.*:://;

    return
        if $method eq 'DESTROY';

    ### $self
    ### $AUTOLOAD
    ### $method
    ### @args
    return tied(@$self)->buffer->$method(@args);
}

!!42;
__END__

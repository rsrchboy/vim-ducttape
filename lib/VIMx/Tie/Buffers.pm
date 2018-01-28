package VIMx::Tie::Buffers;

# ABSTRACT: Tied hash access to vim's buffers

use v5.10;
use strict;
use warnings;

use Carp 'croak';

use base 'Tie::Hash';


sub TIEHASH {
    my ($class) = @_;
    # ensure we exist
    return bless { }, $class;
}

# changing the buffer list is unimplemented at this point
sub STORE  { ... }
sub DELETE { ... }
sub CLEAR  { ... }

# FIXME TODO
sub FIRSTKEY { ... }
sub NEXTKEY  { ... }

sub EXISTS {
    my ($this, $bufid) = @_;

    my $buf = VIM::Buffers($bufid);

    return !!$buf;
}

sub FETCH {
    my ($this, $bufid) = @_;

    # for efficiency, we don't use EXISTS() here.
    # of course, you know what they say about premature optimization...
    my $buf = VIM::Buffers($bufid);
    croak "No such buffer ($bufid)"
        if !$buf;

    return VIMx::buffer($bufid);
    # return $buf;
}

sub SCALAR { scalar VIM::Buffers() }

!!42;
__END__

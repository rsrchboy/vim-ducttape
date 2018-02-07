package VIMx::Tie::Buffers;

# ABSTRACT: Tied hash access to vim's buffers

use v5.10;
use strict;
use warnings;

use Carp 'croak';

use base 'Tie::Hash';

sub TIEHASH {
    my ($class) = @_;
    return bless { }, $class;
}

# changing the buffer list is unimplemented at this point
sub STORE  { ... }
sub DELETE { ... }
sub CLEAR  { ... }

sub FIRSTKEY { [ VIM::Buffers() ]->[0]->Name }

sub NEXTKEY  {
    my ($this, $prevkey) = @_;
    my @bufs = VIM::Buffers();
    for my $i (0..$#bufs-1) {
        return $bufs[$i+1]->Name
            if $bufs[$i]->Name eq $prevkey;
    }

    # no more keys!
    return;
}

sub EXISTS {
    my ($this, $bufid) = @_;

    ### EXISTS(): $bufid
    my $buf = VIM::Buffers($bufid);

    ### $buf
    ### defined: defined $buf
    return defined $buf;
}

sub FETCH {
    my ($this, $bufid) = @_;

    # for efficiency, we don't use EXISTS() here.
    # of course, you know what they say about premature optimization...

    ### FETCH(): $bufid
    my $buf = VIM::Buffers($bufid);

    ### $buf
    croak "No such buffer ($bufid)"
        unless defined $buf;

    return VIMx::buffer($bufid);
}

sub SCALAR { scalar VIM::Buffers() }

!!42;
__END__

package VIMx::Tie::Buffers;

# ABSTRACT: Tied hash access to vim's buffers

use v5.10;
use strict;
use warnings;

use Carp 'croak';
use VIMx::Util;

use base 'Tie::Hash';

sub TIEHASH {
    my ($class) = @_;
    return bless { }, $class;
}

# changing the buffer list is unimplemented at this point
sub DELETE { ... }
sub CLEAR  { ... }

sub STORE  {
    ...;

    # my ($this, $fn, $content) = @_;
    # # TODO when $content is defined, spew it into the new buffer
}

sub FIRSTKEY {
    my ($this) = @_;
    ### FIRSTKEY()...
    $this->{keys} = [
        sort
        map { $_->Name }
        grep { vim_eval_raw(q{buflisted(}.$_->Number.q{)})  }
        VIM::Buffers()
    ];
    return pop @{ $this->{keys} };
}

sub NEXTKEY {
    my ($this, $lastkey) = @_;
    ### NEXTKEY(): $lastkey
    return pop @{ $this->{keys} };
}

sub EXISTS {
    my ($this, $bufid) = @_;

    ### EXISTS(): $bufid

    return defined VIM::Buffers(0+$bufid)
        if $bufid =~ /^\d+/;

    # We need to check twice if the first returns undefined, as
    # VIM::Buffers() returns undef for unlisted buffers if asked for by name.
    #
    # see https://github.com/vim/vim/pull/2692
    my $buf_exists = !!VIM::Buffers($bufid) || vim_eval_raw("bufnr('$bufid')") >= 0;

    ### $buf_exists
    return $buf_exists;
}

sub FETCH {
    my ($this, $bufid) = @_;

    # for efficiency, we don't use EXISTS() here.
    # of course, you know what they say about premature optimization...

    ### FETCH(): $bufid

    # same bit as in EXISTS() about unlisted buffers
    my $buf
        = $bufid =~ /^\d+/
        ? VIM::Buffers(0+$bufid)
        : VIM::Buffers($bufid) || VIM::Buffers(0+vim_eval_raw("bufnr('$bufid')"))
        ;

    ### $buf
    return !!$buf ? VIMx::buffer($bufid) : undef;
}

sub SCALAR { scalar VIM::Buffers() }

!!42;
__END__

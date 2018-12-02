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

sub DELETE {
    my ($this, $bufid) = @_;

    #### DELETE(): $bufid
    my $buf = $this->FETCH($bufid);

    return unless !!$buf;

    vim_do(':bdelete ' . $buf->Number);

    # note we don't return $buf, as that somewhat defeats the point: it's not
    # supposed to exist anymore.  (kinda)  This is in contrast to your typical
    # hash, where the value continues to exist even once deleted.  (kinda)
    #
    # ...well, in a sense I guess this means that our behaviour isn't that
    # different; we're returning an explicit undef on purpose to match.
    return undef;
}

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

    $bufid = _int_or_escape($bufid);

    return defined VIM::Buffers(0+$bufid)
        if $bufid =~ /^\d+/;

    # We need to check twice if the first returns undefined, as
    # VIM::Buffers() returns undef for unlisted buffers if asked for by name.
    #
    # Fixed in 8.0-1576
    return defined VIM::Buffers($bufid)
        if vim_has_patch('8.0-1576');

    return !!VIM::Buffers($bufid) || vim_eval_raw("bufnr('$bufid')") >= 0;
}

sub FETCH {
    my ($this, $bufid) = @_;

    # for efficiency, we don't use EXISTS() here.
    # of course, you know what they say about premature optimization...

    ### FETCH(): $bufid

    $bufid = _int_or_escape($bufid);

    # same bit as in EXISTS() about unlisted buffers
    my $buf
        = $bufid =~ /^\d+/
        ? VIM::Buffers(0+$bufid)
        : (VIM::Buffers($bufid) || VIM::Buffers(0+vim_eval_raw("bufnr('$bufid')")))
        ;

    ### $buf
    return !!$buf ? VIMx::buffer($bufid) : undef;
}

sub SCALAR { scalar VIM::Buffers() }

sub _int_or_escape {
    my $id = shift;

    return 0+$id
        if $id =~ /^\d+$/;

    # $id =~ s/\[/\\[/g;
    $id =~ s/([[\]])/\\$1/g;
    return $id;
}

!!42;
__END__

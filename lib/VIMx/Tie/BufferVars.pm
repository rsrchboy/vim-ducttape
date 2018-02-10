package VIMx::Tie::BufferVars;

use v5.10;
use strict;
use warnings;

use VIMx::Util;

use base 'Tie::Hash';

sub TIEHASH {
    my ($class, $bufnr, @tie_opts) = @_;

    my $thing = {
        prefix => q{},
        set    => 'setbufvar',
        get    => 'getbufvar',
        @tie_opts,
        bufnr  => $bufnr,
    };

    ### TIEHASH(): $thing
    return bless $thing, $class;
}

sub EXISTS {
    my ($this, $key) = @_;
    ### EXISTS(): $key
    my %bufvars =
        map { $_ => 1 }
        @{ vim_eval("keys(getbufvar($this->{bufnr}, '$this->{prefix}'))") }
        ;

    ### %bufvars
    return exists $bufvars{$key};
}

sub FETCH {
    my ($this, $key) = @_;
    ### FETCH(): $key

    # vim isn't very clear about buffer variables existing when you're not
    # dealing with the current buffer
    return undef
        unless $this->EXISTS($key);

    ### fetched: vim_eval("getbufvar($this->{bufnr}, '$key')")
    return vim_eval("getbufvar($this->{bufnr}, '$this->{prefix}$key')")
}

sub STORE {
    my ($this, $key, $value) = @_;
    ### STORE(): "$key => $value"

    vim_eval("setbufvar($this->{bufnr}, '$this->{prefix}$key', '$value')");
    return $value;
}

# this can be done with `:bufdo`, but...
sub DELETE { ... }

# FIXME need tests for the following

sub FIRSTKEY {
    my ($this) = @_;
    ### FIRSTKEY()...
    $this->{keys} = [ $this->_buf_vars ];
    return pop @{ $this->{keys} };
}

sub NEXTKEY {
    my ($this, $lastkey) = @_;
    ### NEXTKEY(): $lastkey
    return pop @{ $this->{keys} };
}

sub _buf_vars { @{ vim_eval("keys(getbufvar($_[0]->{bufnr}, '$_[0]->{prefix}'))") } }

!!42;
__END__

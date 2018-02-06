package VIMx::Tie::BufferVars;

use strict;
use warnings;

use base 'Tie::Hash';

use Role::Tiny::With;

with 'VIMx::Role::Eval';

sub TIEHASH {
    my ($class, $bufnr) = @_;
    ### TIEHASH(): $bufnr
    return bless { bufnr => $bufnr }, $class;
}

sub EXISTS {
    my ($this, $key) = @_;
    ### EXISTS(): $key
    my %bufvars =
        map { $_ => 1 }
        @{ $this->_eval("keys(getbufvar($this->{bufnr}, ''))") }
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

    ### fetched: $this->_eval("getbufvar($this->{bufnr}, '$key')")
    return $this->_eval("getbufvar($this->{bufnr}, '$key')")
}

sub STORE {
    my ($this, $key, $value) = @_;
    ### STORE(): "$key => $value"

    $this->_eval("setbufvar($this->{bufnr}, '$key', '$value')");
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

sub _buf_vars { @{ $_[0]->_eval("keys(getbufvar($_[0]->{bufnr}, ''))") } }

!!42;
__END__

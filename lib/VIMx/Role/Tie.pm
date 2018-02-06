package VIMx::Role::Tie;

# ABSTRACT: bits common between our tie modules

use v5.10;
use strict;
use warnings;

use Carp 'confess';
use Role::Tiny;
use JSON::Tiny qw{ encode_json decode_json };

with 'VIMx::Role::Eval';

sub STORE {
    my ($this, $key, $value) = @_;
    my $thing = $this->{thing};

    my $target = $this->_make_target($key);

    if ((ref $value // q{}) eq 'SCALAR') {
        # we've been passed a reference to a scalar
        # much like DBIC, this means "execute this literally"
        VIM::DoCommand("let $target = $$value");
        return $this->FETCH($key);
    }

    my $viml_value = $this->_escape(encode_json($value));

    #### STORE: "$target = json_decode('$viml_value')"
    # VIM::DoCommand("let $target = json_decode('$viml_value')");
    $this->_or_throw("let $target = json_decode('$viml_value')");
    return $value;
}

sub FETCH {
    my ($this, $key) = @_;
    my $thing = $this->{thing};

    # conform to expected behaviour: vim will complain if a slot that does not
    # exist is accessed, while Perl will simply return undef.  Here we
    # short-circuit to return undef.
    return
        unless $this->EXISTS($key);

    my $target = $this->_make_target($key);
    my ($success, $v) = VIM::Eval("json_encode($target)");
    return decode_json($v);
}

sub EXISTS {
    my ($this, $key) = @_;
    my $thing = $this->{thing};
    my $target = $this->_escape($this->_make_target($key));
    my ($success, $v) = VIM::Eval("exists('$target')");
    return !!$v;
}

sub DELETE {
    my ($this, $key) = @_;
    my $dict = $this->{thing};
    my $value = $this->FETCH($key);
    my $target = $this->_make_target($key);
    VIM::DoCommand("unlet! $target");
    return $value;
}

!!42;

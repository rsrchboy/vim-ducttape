package VIMx::Role::Tie;

# ABSTRACT: bits common between our tie modules

use v5.10;
use strict;
use warnings;

use Carp 'confess';
use Role::Tiny;
use JSON::Tiny qw{ encode_json decode_json };
use VIMx::Util;

sub STORE {
    my ($this, $key, $value) = @_;
    my $thing = $this->{thing};

    my $target = $this->_make_target($key);

    if (ref $value eq 'SCALAR') {
        # we've been passed a reference to a scalar
        # much like DBIC, this means "execute this literally"
        vim_do("let $target = $$value");
        return $this->FETCH($key);
    }

    my $viml_value = vim_escape(encode_json($value));

    #### STORE: "$target = json_decode('$viml_value')"
    # VIM::DoCommand("let $target = json_decode('$viml_value')");
    vim_do("let $target = json_decode('$viml_value')");
    return $value;
}

sub FETCH {
    my ($this, $key) = @_;
    my $thing = $this->{thing};

    ### FETCH(): "$thing, $key"

    # conform to expected behaviour: vim will complain if a slot that does not
    # exist is accessed, while Perl will simply return undef.  Here we
    # short-circuit to return undef.
    return
        unless $this->EXISTS($key);

    my $target = $this->_make_target($key);

    ### $target
    return vim_eval("$target")
        unless $this->{turtles};

    my $type = vim_typeof($target);

    ### $type
    if ($type eq 'dict') {
        tie my %dict, 'VIMx::Tie::Dict', $target, turtles => 1;
        return \%dict;
    }
    elsif ($type eq 'list') {
        require VIMx::Tie::List;
        tie my @list, 'VIMx::Tie::List', $target, turtles => 1;
        return \@list;
    }

    ### FETCH() doing eval on: $target
    return vim_eval($target);
}

sub EXISTS {
    my ($this, $key) = @_;
    my $thing = $this->{thing};
    my $target = vim_escape($this->_make_target($key));
    return !!vim_eval_raw("exists('$target')");
}

sub DELETE {
    my ($this, $key) = @_;
    my $dict = $this->{thing};
    my $value = $this->FETCH($key);
    my $target = $this->_make_target($key);
    vim_do("unlet! $target");
    return $value;
}

!!42;

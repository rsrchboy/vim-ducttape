package VIMx::Tie::List;

use v5.10;
use warnings;
use strict;

use Role::Tiny::With;
use JSON::Tiny qw{ encode_json decode_json };
use VIMx::Util;

use base 'Tie::Array';

with 'VIMx::Role::Tie';

sub TIEARRAY {
    my ($class, $list) = @_;
    # ensure we exist
    vim_do(q{if !exists('} . vim_escape($list) . "') | let $list = [] | endif");
    return bless { thing => $list }, $class;
}

sub SHIFT   { shift->_poppy( 0) }
sub POP     { shift->_poppy(-1) }
sub PUSH    { shift->_pushie('add',            @_) }
sub UNSHIFT { shift->_pushie('insert', reverse @_) }

sub CLEAR { vim_do("unlet $_[0]->{thing}".'[:]'); return }

sub FETCHSIZE {
    ### in FETCHSIZE()...
    my ($this) = @_;
    return vim_eval_raw("len($this->{thing})");
}


sub STORESIZE {
    my ($this, $new_size) = @_;
    my $list = $this->{thing};
    ### in STORESIZE(): $new_size
    ### @_

    my $size = $this->FETCHSIZE;

    if ($new_size < $size) {
        vim_do("let $list = $list".'[:'.($new_size-1).']');
    }
    elsif ($new_size > $size) {
        my $xtn = ',v:null' x ($new_size - $size - 1);
        vim_do("let $list += [v:null$xtn]");
    }

    return;
}

sub _make_target {
    my ($this, $key) = @_;
    my $list = $this->{thing};

    return "$list"."[$key]";
}
sub _pushie {
    my ($this, $func, @values) = @_;
    my $list = $this->{thing};

    ### @values
    my @viml_values;
    for my $value (@values) {
        if (ref $value eq 'SCALAR') {
            push @viml_values, $value;
        }
        else {
            push @viml_values,
                q{json_decode('}
                . vim_escape(encode_json($value))
                . q{')}
                ;
        }
    }

    my $cmd = join ' | ',
        # map { "let $list = $func($list, $_)" }
        map { "call $func($list, $_)" }
        @viml_values
        ;

    ### $cmd
    vim_do($cmd);
    return $this->FETCHSIZE;
}

sub _poppy {
    my ($this, $index) = @_;

    return undef
        unless $this->FETCHSIZE;

    my $doomed = $this->FETCH($index);

    ### popped: $doomed
    vim_do("unlet $this->{thing}"."[$index]");

    return $doomed;
}

!!42;

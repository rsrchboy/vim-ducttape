package VIMx::Role::Eval;

# ABSTRACT: helpers when evaling VimL bits

use v5.10;
use strict;
use warnings;

use Carp 'confess';
use Role::Tiny;
use JSON::Tiny qw{ encode_json decode_json };

sub _or_throw {
    my ($this, $viml) = @_;

    $viml = $this->_escape($viml);
    # VIM::DoCommand("call ducttape#wrapper($viml)");
    # my $error = VIM::Eval("call ducttape#wrapper('$viml')");
    my $error = VIM::Eval("ducttape#util#wrapper('$viml')");
    confess "Gaack: $error"
        if !!$error;
    return;
}

sub _escape { (my $viml = $_[1]) =~ s/'/''/g; return $viml }

sub _eval_or_confess {
    my ($this, $viml) = @_;
    my ($success, $v) = VIM::Eval($viml);
    confess "something bad happened in the eval"
        unless $success;
    return $v;
}

!!42;

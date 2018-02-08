package VIMx::Util;

# ABSTRACT: helpers when evaling viml

use v5.10;
use strict;
use warnings;

use Carp 'confess';
use Exporter 'import';
use JSON::Tiny qw{ encode_json decode_json };

our @EXPORT = qw{
    vim_eval
    vim_eval_raw
    vim_escape
    vim_do
};

sub vim_do { VIM::DoCommand($_[0]) }

sub _or_throw {
    my ($viml) = @_;

    $viml = vim_escape($viml);
    # VIM::DoCommand("call ducttape#wrapper($viml)");
    # my $error = VIM::Eval("call ducttape#wrapper('$viml')");
    my $error = VIM::Eval("ducttape#util#wrapper('$viml')");
    confess "Gaack: $error"
        if !!$error;
    return;
}

sub vim_escape { (my $viml = $_[0]) =~ s/'/''/g; return $viml }

sub _eval_or_confess {
    my ($viml) = @_;
    my ($success, $v) = VIM::Eval($viml);
    confess "something bad happened in the eval"
        unless $success;
    return $v;
}

sub vim_eval {
    my ($viml) = @_;

    return decode_json(_eval_or_confess("json_encode($viml)"));
}

sub vim_eval_raw { _eval_or_confess(@_) }

!!42;

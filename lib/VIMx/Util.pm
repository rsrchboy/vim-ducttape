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
    vim_typeof
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

sub vim_typeof {
    my ($viml) = @_;

    # we can't -- shouldn't -- depend on %VIMx::x being available
    state $types = {
        map { vim_eval_raw("v:t_$_") => $_ }
        qw{ number string func list dict float bool none job channel }
    };

    ### $types
    ### typeof(): $viml
    my $type = vim_eval_raw("type($viml)");

    ### $type
    return $types->{$type};
}

!!42;

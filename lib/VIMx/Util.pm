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
    vim_has
    vim_has_feature
    vim_has_patch
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

    ### _eval_or_confess(): $viml
    my ($success, $v) = VIM::Eval($viml);

    confess "something bad happened in the eval"
        unless $success;

    ### $v
    return $v;
}

sub vim_eval {
    my ($viml) = @_;

    ### vim_eval(): $viml
    return decode_json(_eval_or_confess("json_encode($viml)"));
}

sub vim_eval_raw { _eval_or_confess(@_) }

sub vim_typeof {
    my ($viml) = @_;

    # we can't -- shouldn't -- depend on %VIMx::v being available
    my $i = 0;
    state $types = {
        # v:t_* aren't available until v7.4.2071, _le sigh_
        map { $i++ => $_ }
        qw{ number string func list dict float bool none job channel }
    };

    #### typeof(): $viml
    my $type = vim_eval_raw("type($viml)");

    #### $type
    return $types->{$type};
}

sub vim_has { 0 + vim_eval_raw("has('$_[0]')") }

sub vim_has_patch { vim_has_feature("patch-$_[0]") }

sub vim_has_feature {
    my $feature = shift;

    state $checked = {};
    return $checked->{$feature} //= 0+vim_eval_raw("has('$feature')");
}

!!42;
__END__

=head1 DESCRIPTION

=head1 FUNCTIONS

=cut

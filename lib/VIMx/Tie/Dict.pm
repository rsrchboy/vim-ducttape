package VIMx::Tie::Dict;

use strict;
use warnings;

use Carp 'croak';
use JSON::Tiny qw{ encode_json decode_json };
use Role::Tiny::With;

use base 'Tie::Hash';
with 'VIMx::Role::Tie';

# # debugging...
# use Smart::Comments '###';

# NOTE right now we only handle simple cases, where the value of the slot to
# be set/read is a plain scalar, a string or number.  We should probably
# refactor this to do the whole json {en,de}coding bit we're doing to handle
# @_ and a:000.

sub TIEHASH {
    my ($class, $dict) = @_;
    # ensure we exist
    VIM::DoCommand("if !exists('$dict') | let $dict = {} | endif");
    return bless { thing => $dict }, $class;
}

sub _make_target {
    my ($this, $key) = @_;
    my $dict = $this->{thing};

    # croak "VimL dicts cannot have numeric keys: $dict, $key"
    #     if "$key" =~ /^\d+$/;

    return "$dict"."['$key']";
}

sub _keys_hash {
    my ($this) = @_;
    my $dict = $this->{thing};

    my ($success, $v) = VIM::Eval("json_encode(keys($dict))");
    my @keys          = sort @{ decode_json($v) };

    ### @keys
    my $first = shift @keys;
    my $last  = pop @keys;

    my %keys = (
        $first,
        ( map { $_ => $_ } @keys ),
        ( defined $last ? ( $last, $last ) : () ),
        undef,
    );

    ### %keys
    return \%keys;
}

sub FIRSTKEY {
    my ($this) = @_;
    my $dict = $this->{thing};

    my ($success, $v) = VIM::Eval("len(keys($dict))");
    return unless $v;

    ($success, $v) = VIM::Eval("keys($dict)[0]");
    return $v;
}

sub NEXTKEY {
    my ($this, $prevkey) = @_;

    return _keys_hash($this)->{$prevkey};
}

!!42;
__END__

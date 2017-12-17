package VIMx::Tie::Dict;

use strict;
use warnings;

use base 'Tie::Hash';

# debugging...
# use Smart::Comments '###';

# NOTE right now we only handle simple cases, where the value of the slot to
# be set/read is a plain scalar, a string or number.  We should probably
# refactor this to do the whole json {en,de}coding bit we're doing to handle
# @_ and a:000.

sub TIEHASH {
    my ($class, $dict) = @_;
    return bless { dict => $dict }, $class;
}

sub STORE {
    my ($this, $key, $value) = @_;
    my $dict = $this->{dict};
    my ($success, $v) = VIM::Eval("let $dict"."['$key'] = '$value'");
    return;
}

sub FETCH {
    my ($this, $key) = @_;
    ### @_
    my $dict = $this->{dict};
    my ($success, $v) = VIM::Eval("get($dict, '$key')");
    return $v;
}

sub EXISTS {
    my ($this, $key) = @_;
    my $dict = $this->{dict};
    my ($success, $v) = VIM::Eval("has_key($dict, '$key')");
    return !!$v;
}

sub DELETE {
    my ($this, $key) = @_;
    my $dict = $this->{dict};
    my ($success, $v) = VIM::Eval("unlet! ${dict}"."['$key'])");
    return;
}

!!42;
__END__

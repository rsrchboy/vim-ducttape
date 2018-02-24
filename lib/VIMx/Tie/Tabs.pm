package VIMx::Tie::Tabs;

use v5.10;
use warnings;
use strict;

# use overload
#     '""' => sub { shift->buffer->Name },
#     '0+' => sub { shift->buffer->Number },
#     fallback => 1,
#     ;

use Role::Tiny::With;
use JSON::Tiny qw{ encode_json decode_json };
use VIMx::Tie::BufferVars;
use VIMx::Tab;
use VIMx::Util;

use base 'Tie::Array';

# buffer could be, e.g., '%' to always be the current buffer
sub TIEARRAY {
    my ($class, @opts) = @_;
    # ensure we exist
    return bless { @opts }, $class;
}

sub FETCHSIZE {
    my ($this) = @_;
    return vim_eval_raw(q{tabpagenr('$')});
}

sub FETCH {
    my ($this, $index) = @_;
    return VIMx::Tab->new($index);
}

sub STORE { ... }

sub EXISTS {
    my ($this, $index) = @_;

    return $index < $this->FETCHSIZE;
    # my $highest_tabnr = q{tabpagenr('$')};
    # return vim_eval_raw(qq{exe "if $index < $highest_tabnr | 1 | else | 0 | endif"})
}

sub DELETE {
    my ($this, $index) = @_;

    ...
}

sub PUSH {
    my ($this, @values) = @_;

    ...
}

sub SPLICE {
    my ($this, $offset, $len, @replacements) = @_;

    ...
}

sub CLEAR {
    my ($this) = @_;

    ...
}

sub POP {
    my ($this) = @_;

    ...
}

sub SHIFT { ... }

sub UNSHIFT { ... }

!!42;
__END__

sub STORESIZE {
    ...
}

# optional methods - for efficiency
sub SHIFT { ... }
sub UNSHIFT { ... }
sub SPLICE { ... }

# probably not needed
sub EXTEND { }
sub DESTROY { ... }


!!42;

package VIMx::Tie::Buffer;

use v5.10;
use warnings;
use strict;

use overload
    '""' => sub { shift->buffer->Name },
    ;

use Role::Tiny::With;
use JSON::Tiny qw{ encode_json decode_json };

use base 'Tie::Array';

# buffer could be, e.g., '%' to always be the current buffer
sub TIEARRAY {
    my ($class, $buffer) = @_;
    # ensure we exist
    return bless { buffer => $buffer }, $class;
}

sub FETCHSIZE {
    my ($this) = @_;
    return $this->buffer->Count;
}

sub STORE {
    my ($this, $index, $value) = @_;
    $this->buffer->Set($index+1 => $value);
    return $value;
}

sub FETCH {
    my ($this, $index) = @_;
    return $this->buffer->Get($index+1);
}

sub EXISTS {
    my ($this, $line) = @_;
    my $buffer = $this->{buffer};

    return $line >= $this->FETCHSIZE;
}

sub DELETE {
    my ($this, $index) = @_;

    my $deleted = $this->FETCH($index);
    $this->buffer->Delete($index+1);
    return $deleted;
}

sub PUSH {
    my ($this, @values) = @_;

    $this->buffer->Append($this->FETCHSIZE, @values);
}

sub SPLICE {
    my ($this, $offset, $len, @replacements) = @_;
    my $buf = $this->buffer;

    $len //= $this->FETCHSIZE - $offset;

    my @doomed = ( $buf->Get($offset+1, $len) );

    $buf->Delete($offset+1, $len);
    $buf->Append($offset, @replacements)
        if !!@replacements;

    return @doomed;
}

sub CLEAR {
    my ($this) = @_;

    my $buf = $this->buffer;
    $buf->Delete(1, $buf->Count);
    return;
}

sub POP {
    my ($this) = @_;

    my $last = $this->FETCHSIZE;
    my $doomed = $this->FETCH($last-1);
    $this->buffer->Delete($last);
    return $doomed;
}

sub SHIFT { shift->DELETE(0) }

sub UNSHIFT { shift->buffer->Append(0, @_); return }

# for current buffer, just swap this out
sub buffer { VIM::Buffers(shift->{buffer}) }

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

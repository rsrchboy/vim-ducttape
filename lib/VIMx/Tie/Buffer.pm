package VIMx::Tie::Buffer;

use v5.10;
use warnings;
use strict;

use overload
    '""' => sub { shift->buffer->Name },
    '0+' => sub { shift->buffer->Number },
    fallback => 1,
    ;

use Role::Tiny::With;
use JSON::Tiny qw{ encode_json decode_json };
use VIMx::Tie::BufferVars;
use VIMx::Util;

use base 'Tie::Array';

# # debugging...
# use Smart::Comments '###';

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

sub STORESIZE {
    my ($this, $count) = @_;

    ### STORESIZE(): $count
    my $buf = $this->buffer;

    return
        if $buf->Count == $count;

    if ($count == 0) {
        $this->{cleared} = 1;
        $buf->Delete(1, $buf->Count);
    }
    elsif ($count < $buf->Count) {
        $buf->Delete($count+1, $buf->Count);
    }
    else {
        $buf->Append($buf->Count, [ (q{}) x ($count - $buf->Count) ]);
    }

    return;
}

sub STORE {
    my ($this, $index, $value) = @_;

    my $buf = $this->buffer;

    # FIXME need to handle Count < $index
    $buf->Append($buf->Count, [ (q{}) x ($index - $buf->Count) ])
        if ($buf->Count - 1) < $index;

    ### STORE(): "$index => $value"
    $this->buffer->Set($index+1 => $value);
    $this->{cleared} = 0;
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

    # TODO FIXME set cleared when deleting and Count is 1

    ### DELETE(): $index
    my $deleted = $this->FETCH($index);
    $this->buffer->Delete($index+1);
    return $deleted;
}

sub PUSH {
    my ($this, @values) = @_;

    ### PUSH(): scalar @values
    $this->buffer->Append($this->FETCHSIZE, @values);

    do { $this->buffer->Delete(1); $this->{cleared} = 0 }
        if $this->{cleared};

    return scalar @values;
}

sub SPLICE {
    ### SPLICE(): @_
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

    ### CLEAR()...
    my $buf = $this->buffer;
    $buf->Delete(1, $buf->Count);
    $this->{cleared} = 1;
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

sub info { vim_eval("getbufinfo('$_[0]->{buffer}')") }

sub vars    { shift->_reader('vars',    { prefix => q{} }, @_) }
sub options { shift->_reader('options', { prefix => '&' }, @_) }

sub Save {
    my ($this) = @_;

    my $bufnr = $this->buffer->Number;
    vim_do(":${bufnr}bufdo write");

    return;
}

sub _reader {
    my ($this, $key, $tie_opts) = @_;

    return $this->{$key}
        if exists $this->{$key};

    tie my %thing, 'VIMx::Tie::BufferVars', $this->buffer->Number, %$tie_opts;
    return $this->{$key} = \%thing;
}

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

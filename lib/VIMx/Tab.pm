package VIMx::Tab;

use v5.10;
use warnings;
use strict;

# use overload
#     '""' => sub { shift->buffer->Name },
#     '0+' => sub { shift->buffer->Number },
#     fallback => 1,
#     ;

# use VIMx::Tie::BufferVars;
use VIMx::Util;

# use 'tabpagenr()' as tabnr for an object that tracks the current tab
sub new {
    my ($class, $tabnr, @opts) = @_;

    return bless { tabnr => $tabnr, @opts }, $class;
}

sub info { vim_eval("gettabinfo($_[0]->{tabnr})") }

sub vars    { shift->_reader('vars',    { prefix => q{}, set => 'settabvar', get => 'gettabvar' }, @_) }
# sub options { shift->_reader('options', { prefix => '&' }, @_) }

sub number {
    my ($this) = @_;

    return $this->{tabnr}
        if $this->{tabnr} =~ /^\d+$/;

    return 0 + vim_eval_raw($this->{tabnr});
}

# be consistent... kinda
sub Number { goto \&number }

sub _reader {
    my ($this, $key, $tie_opts) = @_;

    return $this->{$key}
        if exists $this->{$key};

    tie my %thing, 'VIMx::Tie::BufferVars', $this->{tabnr}, %$tie_opts;
    return $this->{$key} = \%thing;
}

!!42;

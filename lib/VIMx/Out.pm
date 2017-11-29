package VIMx::Out;

# Adopted, with love and a somewhat decent level of irk that I didn't think of
# this on my own, from: https://github.com/vim-scripts/perl_io.vim

use strict;
use warnings;

use base 'Tie::Handle';

sub TIEHANDLE {
    my ($class, $group) = @_;
    return bless(\$group, $class);
}

sub PRINT {
    my ($group, @args) = @_;
    VIM::Msg(join((defined $, ? $, : q{}), @args), $$group || q{});
    return;
}

sub PRINTF {
    my ($group, $format, @args) = @_;
    VIM::Msg(sprintf ($format, @args), $$group);
    return;
}

!!42;

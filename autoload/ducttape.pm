package VIMx::autoload::ducttape;

use v5.10;
use strict;
use warnings;

use VIMx::Symbiont;
use Module::Info;
use Module::Runtime qw{ use_module require_module };
use Try::Tiny;

# debugging...
# use Smart::Comments '###';

# the VIMx::Symbiont-generated sub functions handles turning the parameters
# JSON into Perl values -- and the other way around on return.

function has => sub {
    my ($module) = @_;
    return !!Module::Info->new_from_module($module) ? 1 : 0;
};

function use => sub {
    my @modules = @_;
    return try {
        use_module($_)
            for @modules;
        return 1;
    }
    catch {
        return 0;
    };
};

function require => sub {
    my @modules = @_;
    return try {
        require_module($_)
            for @modules;
        return 1;
    }
    catch {
        return 0;
    };
};

function inc => sub { @INC };

!!42;
__END__

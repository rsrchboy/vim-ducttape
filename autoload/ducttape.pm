package ducttape;

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
    my ($module) = @_;
    return try {
        use_module($module);
    }
    catch {
        return 0;
    };
};

function require => sub {
    my ($module) = @_;
    return try {
        return require_module($module);
    }
    catch {
        return 0;
    };
};

function version => sub { "$^V" };

function version_gt => sub { $^V gt shift ? 1 : 0 };
function version_ge => sub { $^V ge shift ? 1 : 0 };
function version_lt => sub { $^V lt shift ? 1 : 0 };
function version_le => sub { $^V le shift ? 1 : 0 };



!!42;
__END__

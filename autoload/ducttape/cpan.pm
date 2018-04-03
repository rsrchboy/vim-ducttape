package VIMx::autoload::ducttape::cpan;

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

function info => sub {
    my ($module) = @_;
    return Module::Info->new_from_module($module);
};

# function info => sub {
#     my ($module) = @_;
#     return !!Module::Info->new_from_module($module) ? 1 : 0;
# };

!!42;
__END__

package ducttape::perl;

# ABSTRACT: Perly things one might need

use v5.10;
use strict;
use warnings;

use Config;

use VIMx::Symbiont;

# the VIMx::Symbiont-generated sub functions handles turning the parameters
# JSON into Perl values -- and the other way around on return.

function args => q{}, version         => sub { "$^V" };
function args => q{}, decimal_version => sub {   $]  };

function args => 'ver', version_gt => sub { $^V gt $a{ver} ? 1 : 0 };
function args => 'ver', version_ge => sub { $^V ge $a{ver} ? 1 : 0 };
function args => 'ver', version_lt => sub { $^V lt $a{ver} ? 1 : 0 };
function args => 'ver', version_le => sub { $^V le $a{ver} ? 1 : 0 };

function args => 'key', config => sub { $Config{$a{key}} };

!!42;
__END__

=head1 FUNCTIONS

=head2 version()

Returns the version of the linked Perl (C<$^V>), e.g. C<v5.26.1>.

=head2 decimal_version()

As with L</version()>, but in decimal form (C<$]>), e.g. c<5.026001>.

=head2 config($key)

Access to the L<Config> hash of Perl configuration values.

=cut

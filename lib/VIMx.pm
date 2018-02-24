package VIMx;

# ABSTRACT: Basic vim-perl combobulators

use v5.10;
use strict;
use warnings;

use VIMx::AutoLoadFor::Tie;
use VIMx::Tab;
use VIMx::Tie::Buffer;
use VIMx::Tie::Buffers;
use VIMx::Tie::Dict;
use VIMx::Tie::Options;
use VIMx::Tie::Tabs;

use Exporter 'import';

our @EXPORT = qw/
    %a %b %g %l %s %t %v %w
    %self
    $BUFFER
    %BUFFERS
    $TAB
    @TABS
    %OPTIONS
/;

our @EXPORT_OK = qw/
    %global_options %local_options
    buffer          buffers
/;

our %EXPORT_TAGS = (
    variables => [ qw{ %a %b %g %l %s %t %v %w } ],
    buffers   => [ qw{ $BUFFER %BUFFERS } ],
    options   => [ qw{ %GOPTIONS %LOPTIONS %OPTIONS } ],
);

# see help for internal-variables for more information
tie our %a, 'VIMx::Tie::Dict', 'a:', turtles => 1;
tie our %b, 'VIMx::Tie::Dict', 'b:', turtles => 1;
tie our %g, 'VIMx::Tie::Dict', 'g:', turtles => 1;
tie our %l, 'VIMx::Tie::Dict', 'l:', turtles => 1;
tie our %s, 'VIMx::Tie::Dict', 's:', turtles => 1;
tie our %t, 'VIMx::Tie::Dict', 't:', turtles => 1;
tie our %v, 'VIMx::Tie::Dict', 'v:', turtles => 1;
tie our %w, 'VIMx::Tie::Dict', 'w:', turtles => 1;

tie our %self, 'VIMx::Tie::Dict', 'l:self', turtles => 1;

tie our %GOPTIONS, 'VIMx::Tie::Options', '&g:';
tie our %LOPTIONS, 'VIMx::Tie::Options', '&l:';
tie our %OPTIONS,  'VIMx::Tie::Options', '&';

tie our %BUFFERS, 'VIMx::Tie::Buffers';

tie our @curbuf, 'VIMx::Tie::Buffer', '%';
tied(@curbuf)->{vars} = \%b;
tied(@curbuf)->{options} = \%OPTIONS;
our $BUFFER = bless \@curbuf, 'VIMx::AutoLoadFor::Tie';

tie our @TABS, 'VIMx::Tie::Tabs';
our $TAB = VIMx::Tab->new('tabpagenr()', vars => \%t);

# TODO register access?

sub buffer {
    my ($bufid) = @_;

    tie our @buf, 'VIMx::Tie::Buffer', $bufid;
    our $buf = bless \@buf, 'VIMx::AutoLoadFor::Tie';

    return $buf;
}

sub buffers { +{ map { $_ => buffer($_) } map { $_->Name } VIM::Buffers() } }

!!42;
__END__

=head1 SYNOPSIS

    use VIMx; # exports everything by default

    # ...

    # aka: let b:eep = 'bzzzt'
    $b{eep} = 'bzzzt';

=head1 DESCRIPTION

This small utility package exports a number of tied variables designed to make
writing code running in vim via it's embedded interpreter a touch easier.  The
variables C<%b>, C<%g>, C<%a>, etc, all correspond to C<b:>, C<g:>, C<a:>,
etc.  Assigning and reading structures is supported.  For more information,
see L<VIMx::Tie::Dict>.

For buffers...

Note this package has nothing to do with using vim to write Perl, and rather everything
to do with writing Perl to run on vim.  (Don't think about that one too much.)

=cut

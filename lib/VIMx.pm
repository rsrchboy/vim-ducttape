package VIMx;

# ABSTRACT: Basic vim-perl combobulators

use v5.10;
use strict;
use warnings;

use VIMx::Tie::Dict;
use VIMx::Tie::Buffer;
use Exporter 'import';

our @EXPORT = qw/
    %a %b %g %l %s %t %v %w
    %self
    @curbuf
/;

# see help for internal-variables for more information
tie our %a, 'VIMx::Tie::Dict', 'a:';
tie our %b, 'VIMx::Tie::Dict', 'b:';
tie our %g, 'VIMx::Tie::Dict', 'g:';
tie our %l, 'VIMx::Tie::Dict', 'l:';
tie our %s, 'VIMx::Tie::Dict', 's:';
tie our %t, 'VIMx::Tie::Dict', 't:';
tie our %v, 'VIMx::Tie::Dict', 'v:';
tie our %w, 'VIMx::Tie::Dict', 'w:';

tie our %self, 'VIMx::Tie::Dict', 'l:self';

tie our @curbuf, 'VIMx::Tie::Buffer', '%';

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

All variables are exported by default.

=cut

package VIMx;

# ABSTRACT: Basic vim-perl combobulators

use v5.10;
use strict;
use warnings;

use VIMx::Tie::Dict;
use Exporter 'import';

our @EXPORT = qw/
    %a %b %g %l %s %t %v %w
    %self
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

!!42;
__END__

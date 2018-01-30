package VIMx::Symbiont;

# ABSTRACT: Co-dependent Perl

# Some notes, before we get started:
#
# For portability's sake, use as few external packages as possible: the whole
# idea is to be able to just drop this in and use it, after all. The ::Tiny
# ones are generally fine, as they can be included as submodules, but XS is
# "right out".

use v5.10;
use strict;
use warnings;

use Path::Tiny;
use JSON::Tiny qw{ encode_json decode_json };
use Try::Tiny;
use VIMx;
use VIMx::Tie::Dict;

use Exporter 'import';

# use Smart::Comments;

# also JSON::Tiny and VIMx, for convenience
our @EXPORT = qw/
    decode_json
    encode_json

    function
    fun

    method
    make_new

    %a %b %g %l %s %t %v %w
    %self
    $cbuf
/;

tie our %vimx_return, 'VIMx::Tie::Dict', 'g:vimx_symbiont_return';
tie our %vimx_viml,   'VIMx::Tie::Dict', 'g:vimx_symbiont_viml';

sub _class_to_vim_ns { (my $ns = shift) =~ s/::/#/g; $ns }

# NOTE: when using the args option, the named parameters must be accessed
# through the %a tie.

sub method {
    my ($coderef, $name) = (pop, pop);
    my %opts = (
        fn_ns       => 's:method_',
        perl_prefix => 'method_',
        opts        => 'abort dict',
        pkg         => (caller)[0],
        @_,
    );

    my $prelude = <<"VIML";
if !has_key(s:, 'prototype') | let s:prototype = {} | endif
VIML
    my $postlude = <<"VIML";
let s:prototype['$name'] = function('$opts{fn_ns}$name')
VIML

    # _ensure_prototype;
    return fun(
        viml_prelude  => $prelude,
        viml_postlude => $postlude,
        %opts,
        $name         => $coderef,
    );
}

sub make_new {
    my ($pkg) = caller;
    my $vim_ns    = _class_to_vim_ns($pkg);

    my $viml = <<"VIML";
if !has_key(s:, 'prototype') | let s:prototype = {} | endif
let s:prototype.isa = '$vim_ns'
fun! $vim_ns#New(...) abort
    let l:obj = a:0 ? a:1 : {}
    return extend(l:obj, s:prototype, 'keep')
endfun
VIML
    $vimx_viml{$pkg} .= $viml;
    return;
}

sub function {
    my ($coderef, $name) = (pop, pop);
    # my $vim_ns    = _class_to_vim_ns($pkg);
    my %opts = (
        pkg           => (caller)[0], # our implementing package
        args          => '...',       # arguments for the generated viml function
        opts          => 'abort',     # viml function opts
        perl_prefix   => 'func_',     # prefix to the perl sub name
        viml_prelude  => q{},         # viml to insert before the func...
        viml_postlude => q{},         # ...and after
        @_,
    );
    my $pkg         = $opts{pkg}; # FIXME hack
    $opts{fn_ns}  //= _class_to_vim_ns($opts{pkg}) . '#';
    $opts{vim_ns} //= _class_to_vim_ns($opts{pkg});

    # TODO just return if we're not inside vim

    my $perl_name  = "${pkg}::$opts{perl_prefix}${name}";
    my $return_var = "g:vimx_symbiont_return['$perl_name']";

    my $viml = <<"END";
$opts{viml_prelude}
function! $opts{fn_ns}$name($opts{args}) $opts{opts}
    perl ${perl_name}()
    return $return_var
endfunction
$opts{viml_postlude}
END

    my $wrapped = sub {

        try {
            # make any unnamed params available in @_
            my @ret = $coderef->(@{$a{'000'}});
            $vimx_return{$perl_name} = ( @ret == 1 ? $ret[0] : \@ret );
        }
        catch {
            # translate our Perl exception into a VimL one
            $_ =~ s/'/''/g;
            VIM::DoCommand("throw '$opts{vim_ns}: $_'");
        };

        return;
    };

# if !has_key(s:, 'prototype') | let s:prototype = {} | endif
    $vimx_viml{$pkg} //= <<"END";
let g:$opts{vim_ns}#loaded = 1
let s:prototype = {}
fun! $opts{vim_ns}#load() abort
endfun
END

    # say 'function: ' . $vimx_viml{$pkg};
    # optimize later -- some cruft built up here
    $vimx_viml{$pkg} .= $viml;

    {
        no strict 'refs';
        *{$perl_name} = $wrapped;
    }

    return;
}

sub throw {
    (my $msg = shift) =~ s/'/''/g;
    VIM::DoCommand("throw 'symbiont: $msg'");
    return;
}

# shorthand
sub fun { goto \&function }

!!42;
__END__

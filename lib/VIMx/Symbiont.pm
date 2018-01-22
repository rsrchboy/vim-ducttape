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
use VIMx::Tie::Dict;

use parent 'Exporter';

use Smart::Comments;

# also JSON::Tiny, for convenience
our @EXPORT = qw/
    decode_json
    encode_json

    function
    fun

    method
    make_new

    %a %b %g %l %s %t %v %w
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

# may as well make life a little easier at the command prompt
$main::a = \%a;
$main::b = \%b;
$main::g = \%g;
$main::l = \%l;
$main::s = \%s;
$main::t = \%t;
$main::v = \%v;
$main::w = \%w;

sub _class_to_vim_ns { (my $ns = shift) =~ s/::/#/g; $ns }


tie our %vimx_return, 'VIMx::Tie::Dict', 'g:vimx_symbiont_return';
tie our %vimx_viml,   'VIMx::Tie::Dict', 'g:vimx_symbiont_viml';

# NOTE: when using the args option, the named parameters must be accessed
# through the %a tie.

# sub _ensure_prototype {
#     $s{prototype} //= {
#         isa => _class_to_vim_ns((caller)[0]),
#     };
#     return;
# }

sub method {
    my ($coderef, $name) = (pop, pop);
    my %opts = (
        fn_ns       => 's:method_',
        perl_prefix => 'method_',
        pkg         => (caller)[0],
        @_,
    );

    my $prelude = <<"END";
if !has_key(s:, 'prototype') | let s:prototype = {} | endif
END
    my $postlude = <<"END";
let s:prototype['$name'] = function('$opts{fn_ns}$name', [])
END

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

    my $viml = <<"END";
if !has_key(s:, 'prototype') | let s:prototype = {} | endif
let s:prototype.isa = '$vim_ns'
fun! $vim_ns#New(...) abort
    let l:obj = a:0 ? a:1 : {}
    return extend(l:obj, s:prototype, 'keep')
endfun
END
    # $vimx_viml{$pkg} = $VIML{$pkg} .= $viml;
    # $vimx_viml{$pkg} //= q{};
    ### $pkg
    ### viml before concat: $vimx_viml{$pkg}
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
    # my $perl_name = "${pkg}::func_${name}";
    my $perl_name = "${pkg}::$opts{perl_prefix}${name}";
    # $name = _class_to_vim_ns($pkg) . "#$name";

    my $return_var = "g:vimx_symbiont_return['$perl_name']";

    my $viml = <<"END";
$opts{viml_prelude}
function! $opts{fn_ns}$name($opts{args}) $opts{opts}
    perl ${perl_name}(scalar VIM::Eval('json_encode(a:000)'))
    return json_decode($return_var)
endfunction
$opts{viml_postlude}
END

    # $viml =

    my $wrapped = sub {
        # vivify our args, execute the coderef, etc
        my @a000 = @{ decode_json(scalar VIM::Eval('json_encode(a:000)')) };
        try {
            ( $vimx_return{$perl_name} = encode_json($coderef->(@a000)) ) =~ s/'/''/g;

            # handle getting the return value(s) back into vim-land
            VIM::DoCommand("let $return_var = '$vimx_return{$perl_name}'");
            # $vimx_return{$name} = $coderef->(@a000);
        }
        catch {
            $_ =~ s/'/''/g;
            VIM::DoCommand("throw 'symbiont: $_'");
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

# shorthand
sub fun { goto \&function }

!!42;
__END__

sub method { function opts => 'abort dict', perl_prefix => ..., ... }

!!42;
__END__

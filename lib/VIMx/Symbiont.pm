package VIMx::Symbiont;

# ABSTRACT: Co-dependent Perl

use strict;
use warnings;

use Path::Tiny;
use JSON::Tiny qw{ encode_json decode_json };

use parent 'Exporter';

# also JSON::Tiny, for convenience
our @EXPORT = qw/
    decode_json
    encode_json

    function
/;

our %VIML;
VIM::DoCommand('let g:vimx_symbiont_viml = {}');

our %RETURN;
VIM::DoCommand('let g:vimx_symbiont_return = {}');

sub _class_to_vim_ns { (my $ns = shift) =~ s/::/#/g; $ns }


sub function {
    my ($name, $coderef) = @_;

    # TODO just return if we're not inside vim

    my ($pkg) = caller;
    my $perl_name = "${pkg}::${name}";
    my $vim_ns    = _class_to_vim_ns($pkg);
    $name = _class_to_vim_ns($pkg) . "#$name";

    my $return_var = "g:vimx_symbiont_return['$name']";

    my $viml = <<"END";
function! $name(...) abort
    perl ${perl_name}(scalar VIM::Eval('json_encode(a:000)'))
    return json_decode($return_var)
endfunction
END

    my $wrapped = sub {
        # vivify our args, execute the coderef, etc
        my @a000 = @{ decode_json(scalar VIM::Eval('json_encode(a:000)')) };
        ( $RETURN{$name} = encode_json($coderef->(@a000)) ) =~ s/'/''/g;

        # handle getting the return value(s) back into vim-land
        VIM::DoCommand("let $return_var = '$RETURN{$name}'");
    };

    warn $viml;
    $VIML{$pkg} //= q{};
    $VIML{$pkg}  .= $viml;

    # get everything
    ($viml = $VIML{$pkg}) =~ s/'/''/g;
    # optimize later -- easier to pass it in from this side
    VIM::DoCommand(qq{let g:vimx_symbiont_viml['$pkg'] = json_decode('} . encode_json($viml) . q{')});

    {
        no strict 'refs';
        *{$perl_name} = $wrapped;
    }

    return;
}

!!42;
__END__

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

    my ($pkg) = caller;

    # TODO just return if we're not inside vim

    my $perl_name = "${pkg}::${name}";
    my $vim_ns    = _class_to_vim_ns($pkg);
    $name = _class_to_vim_ns($pkg) . "#$name";

    my $return_var = "g:vimx_symbiont_return['$name']";

    # crutch
    my $json = 1;

    my $return_viml = $json
        ? "let $return_var = json_decode('\$VIMx::Symbiont::RETURN{q{$name}}')"
        : "let $return_var = '\$VIMx::Symbiont::RETURN{q{$name}}'"
        ;

    my $viml = <<"END";
function! $name(...) abort
    perl ( \$VIMx::Symbiont::RETURN{q{$name}} = JSON::Tiny::encode_json( ${perl_name}(\@{ JSON::Tiny::decode_json(scalar VIM::Eval('json_encode(a:000)')) }) )) =~ s/'/''/g; VIM::DoCommand("$return_viml")
    return $return_var
endfunction
END

    warn $viml;
    $VIML{$pkg} //= q{};
    $VIML{$pkg}  .= $viml;

    # get everything
    ($viml = $VIML{$pkg}) =~ s/'/''/g;
    # optimize later -- easier to pass it in from this side
    VIM::DoCommand(qq{let g:vimx_symbiont_viml['$pkg'] = json_decode('} . encode_json($viml) . q{')});

    {
        no strict 'refs';
        *{$perl_name} = $coderef;
    }

    return;
}

!!42;
__END__

" For those following along at home:  the reason we can get away with
" autoloaded functions is that we execute the VimL that creates them from
" inside this script/file.  That's enough to convince vim that these functions
" belong in that namespace -- or perhaps just that we're determined so it may
" as well get out of the way.

for s:eval in ducttape#symbiont#autoload(expand('<sfile>'))
    execute s:eval
endfor

fun! ducttape#AddLocalToInc(dir) abort " {{{1

    " let s:our_dir = simplify(expand('<sfile>:p:h') . '/..')

    let l:perl_init = ':perl push @INC'

    " local modules not in autoload/
    if isdirectory(a:dir. '/lib')
        let l:perl_init .= ', q{' . a:dir . '/lib}'
    endif

    " embedded modules (typically submodule clones of CPAN dists)
    for l:subdir in glob(a:dir . '/p5/*/lib',1,1)
        let l:perl_init .= ', q{' . l:subdir . '}'
    endfor

    let l:perl_init .= ';'

    execute l:perl_init

    return
endfun


fun! ducttape#AddLocalLib(dir) abort " {{{1
    exe 'perl use local::lib q{' . a:dir . '}'
    return
endfun

" __END__

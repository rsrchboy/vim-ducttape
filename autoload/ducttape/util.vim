
fun! ducttape#util#wrapper(viml) abort
    let l:error = ''
    try
        " echom a:viml
        " call eval(a:viml)
        exe a:viml
    catch
        let l:error = v:exception
    endtry
    return l:error
endfun

fun! ducttape#util#AddLocalToInc(dir) abort

    " let s:our_dir = simplify(expand('<sfile>:p:h') . '/..')

    let l:perl_init = ':perl push @INC'

    " local modules not in autoload/
    if isdirectory(a:dir. '/lib')
        let l:perl_init .= ', q{' . a:dir . '/lib}'
    endif

    " embedded modules (typically submodule clones of CPAN dists)
    for l:subdir in glob(a:dir . '/p5/*/lib',1,1)
        let l:perl_init .= ', q{' . s:subdir . '}'
    endfor

    let l:perl_init .= ';'

    execute l:perl_init

    return
endfun

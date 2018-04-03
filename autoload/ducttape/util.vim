
fun! ducttape#util#wrapper(viml) abort " {{{1
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


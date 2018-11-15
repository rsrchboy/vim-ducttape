" Functions related to filesystem paths

for s:eval in ducttape#symbiont#autoload(expand('<sfile>'))
    execute s:eval
endfor
unlet s:eval

" __END__

fun! ducttape#path#simpletempdir() abort " {{{1
    return perleval('Path::Tiny->tempdir(CLEANUP => 0) . q{}')
endfun

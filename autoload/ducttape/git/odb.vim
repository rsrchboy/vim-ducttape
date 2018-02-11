" For those following along at home:  the reason we can get away with
" autoloaded functions is that we execute the VimL that creates them from
" inside this script/file.  That's enough to convince vim that these functions
" belong in that namespace -- or perhaps just that we're determined so it may
" as well get out of the way.

if !ducttape#require('Git::Raw')
    " TODO FIXME create a FuncUndefined au here to warn?
    let g:ducttape#git#odb#loaded = 0
    finish
endif

for s:eval in ducttape#symbiont#autoload(expand('<sfile>'))
    execute s:eval
endfor

" __END__

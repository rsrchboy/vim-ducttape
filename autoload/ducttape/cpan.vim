" For those following along at home:  the reason we can get away with
" autoloaded functions is that we execute the VimL that creates them from
" inside this script/file.  That's enough to convince vim that these functions
" belong in that namespace -- or perhaps just that we're determined so it may
" as well get out of the way.

for s:eval in ducttape#symbiont#autoload(expand('<sfile>'))
    execute s:eval
endfor

fun! s:SetMaybe(key, val) abort
    if !has_key(g:, a:key)
        let g:[a:key] = a:val
    endif
    return
endfun

call s:SetMaybe('ducttape#cpan#cpanm', 'cpanm')

fun! ducttape#cpan#install(module) abort

    if !executable('cpanm')
        throw 'ducttape#cpan: cpanm not available'
    endif

    echom 'Installing ' . a:module . ' from the CPAN'
    return system('cpanm ' . a:module)
endfun

" __END__

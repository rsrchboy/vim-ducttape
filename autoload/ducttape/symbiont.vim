if !has_key(g:, 'ducttape#symbiont#loaded')
    let g:ducttape#symbiont#loaded = {}
endif

if !has_key(g:, 'ducttape_loaded')
    runtime 'plugin/ducttape.vim'
endif

" These functions all deal with symbiote perl -- that is, for a foo/bar.vim, a
" foo/bar.pm package.
"
" Most viml looking to load their symbiont should just need to do this:
"
"   for s:eval in ducttape#symbiont#autoload(expand('<sfile>'))
"       execute s:eval
"   endfor
"
" Because we provide the viml functions to load our symbiont, we should take
" care to avoid needing a symbiont ourselves -- or be careful how we load it!

function! ducttape#symbiont#autoload(sfile) abort
    if !has('perl')
        let l:vim_ns = fnamemodify(a:sfile, ':p:r:s?^.*/autoload/??:gs?/?#?')
        let g:[l:vim_ns . '#loaded'] = 0

        " FIXME throw something here?
        return 'fun! ' . l:vim_ns . "#load() abort\nendfun"
    endif
    let l:pmfile = simplify(fnamemodify(a:sfile,':r') . '.pm')
    let l:perl_pkg = 'VIMx::autoload::' . fnamemodify(l:pmfile, ':p:r:s?^.*/autoload/??:gs?/?::?')
    " echom 'Loading ' . pmfile . ' for ' . a:sfile
    execute 'perl require "'.pmfile.'" unless $INC{"'.pmfile.'"}'
    let g:ducttape#symbiont#loaded[l:pmfile] = 1
    return g:vimx_symbiont_viml[l:perl_pkg]
endfunction

" !!42

if !has('perl')
    finish
endif

if !has_key(g:, 'ducttape#symbiont#loaded')
    let g:ducttape#symbiont#loaded = {}
endif

" These functions all deal with symbiote perl -- that is, for a foo/bar.vim, a
" foo/bar.pm package.
"
" Most viml looking to load their symbiont should just need to do this:
"
"   call ducttape#symbiont#load(expand('<sfile>'))
"
" Because we provide the viml functions to load our symbiont, we should take
" care to avoid needing a symbiont ourselves -- or be careful how we load it!

function! ducttape#symbiont#autoload(sfile) abort
    let l:pmfile = simplify(fnamemodify(a:sfile,':r') . '.pm')
    let l:perl_pkg = fnamemodify(l:pmfile, ':p:r:s?^.*/autoload/??:gs?/?::?')
    " echom 'Loading ' . pmfile . ' for ' . a:sfile
    execute 'perl require "'.pmfile.'" unless $INC{"'.pmfile.'"}'
    let g:ducttape#symbiont#loaded[l:pmfile] = 1
    return g:vimx_symbiont_viml[l:perl_pkg]
endfunction

" !!42

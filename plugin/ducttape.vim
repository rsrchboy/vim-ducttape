if has('g:ducttape_loaded')
    finish
endif
let g:ducttape_loaded = 1

let g:ducttape_topdir = simplify(expand('<sfile>:p:h') . '/..')

let g:ducttape_locallib = get(g:, 'ducttape_locallib', g:ducttape_topdir.'/perl5')
let g:ducttape_cpanm    = get(g:, 'ducttape_cpanm',    g:ducttape_topdir.'/cpanm')

let s:our_dir = g:ducttape_topdir

let s:perl_init = ':perl BEGIN { push @INC, q{' . s:our_dir . '/lib}'
for s:subdir in glob(s:our_dir . '/p5/*/lib',1,1)
    let s:perl_init .= ', q{' . s:subdir . '}'
endfor

let s:perl_init .= '}; '
    \   . 'use local::lib; '
    \   . 'BEGIN { local::lib->new(quiet => 1)->activate(q{'.g:ducttape_topdir.'/perl5})->setup_local_lib } '
    \   . 'use VIMx;'

execute s:perl_init

" in some versions, s:subdir seems to stick around
unlet! s:subdir s:perl_init s:our_dir

" for reference:
" perleval() became available with 2016-01-17 e9b892ebc (tag: v7.4.1125) patch 7.4.1125

" the rest became unnecessary after 6244a0fc2 (tag: v7.4.1729) patch 7.4.1729
if v:version > 704 || v:version == 704 && has('patch1729')
    finish
endif

perl <<EOP
# line 27 "plugin/ducttape.vim"
use VIMx::Out;

# again, somethings we only ever need to do once...
unless (tied *VIMOUT) {
    tie (*VIMOUT, 'VIMx::Out');
    tie (*VIMERR, 'VIMx::Out', 'ErrorMsg');
    select VIMOUT;
}

EOP

" __END__

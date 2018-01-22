if has('g:ducttape_loaded')
    finish
endif
let g:ducttape_loaded = 1

" perleval() became available with 2016-01-17 e9b892ebc (tag: v7.4.1125) patch 7.4.1125
execute ':perl push @INC, q{' . expand('<sfile>:h') . '/../lib}'

" the rest became unnecessary after 6244a0fc2 (tag: v7.4.1729) patch 7.4.1729
if v:version < 704 || v:version == 704 && !has('patch1729')
    finish
endif

perl <<EOP
# line 16 "plugin/ducttape.vim"
use VIMx::Out;

# again, somethings we only ever need to do once...
unless (tied *VIMOUT) {
    tie (*VIMOUT, 'VIMx::Out');
    tie (*VIMERR, 'VIMx::Out', 'ErrorMsg');
    select VIMOUT;
}

EOP

" __END__

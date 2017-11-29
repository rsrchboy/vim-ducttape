if has('g:ducttape_loaded')
    finish
endif
let g:ducttape_loaded = 1

execute ':perl push @INC, q{' . expand('<sfile>:h') . '/../lib}'

finish

perl <<EOP
# line 12 "~/work/vim/vim-ducttape/plugin/ducttape.vim"

use strict;
use warnings;

# push onto @INC, but only once
BEGIN {
    my $base = VIM::Eval('expand("<sfile>:h")') . '/..';

    push @INC,
        # note the $_'s are *different* in the following line
        grep { ! { map { $_ => 1 } @INC }->{$_} }
        "$base/module-info/lib", "$base/lib", scalar VIM::Eval('g:perl#bootstrap')
        ;
}

use VIMx::Out;

# again, somethings we only ever need to do once...
unless (tied *VIMOUT) {
    tie (*VIMOUT, 'VIMx::Out');
    tie (*VIMERR, 'VIMx::Out', 'ErrorMsg');
    select VIMOUT;
}

EOP

" __END__

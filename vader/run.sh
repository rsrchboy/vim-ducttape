#!/bin/sh

[ -d vader.vim ] || git clone --depth=1 --branch=spew-messages https://github.com/rsrchboy/vader.vim.git

# sanity run of HTTP::Tiny w/included demo script
# perl p5/http-tiny/eg/get.pl https://api.github.com/rate_limit

_LIB=$(find p5/ -maxdepth 2 -name lib -type d -printf ':%p')
find autoload -name '*.pm' | PERL5LIB=$PERL5LIB:$_LIB xargs -L1 perl -I autoload -I lib -I t/lib -MVIM -wc 2>&1

# vim *MUST* also load a file here for all tests to pass
vim -Nu vader/vimrc -c 'Vader! vader/*' README.md 2>&1

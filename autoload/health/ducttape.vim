"     ____ _               _    _   _            _ _   _
"  _ / ___| |__   ___  ___| | _| | | | ___  __ _| | |_| |__
" (_) |   | '_ \ / _ \/ __| |/ / |_| |/ _ \/ _` | | __| '_ \
"  _| |___| | | |  __/ (__|   <|  _  |  __/ (_| | | |_| | | |
" (_)\____|_| |_|\___|\___|_|\_\_| |_|\___|\__,_|_|\__|_| |_|
"
" see https://github.com/rhysd/vim-healthcheck
"
" This file enables ":CheckHealth ducttape"

function s:hasError(feature, text) abort
    if has(a:feature)
        call health#report_ok(a:text . ' found (' . a:feature . ')')
    else
        call health#report_error(a:text . ' NOT found (' . a:feature . ')')
    endif
endfunction

function s:has(feature, text) abort
    if has(a:feature)
        call health#report_ok(a:text . ' found (' . a:feature . ')')
    else
        call health#report_warn(a:text . ' NOT found (' . a:feature . ')')
    endif
endfunction

function! s:vimSection() abort " {{{1
    call health#report_start('vim')

    if has('nvim')
        call health#report_error("You're using nvim.  All bets are off!")
        return
    endif

    call s:hasError('perl', 'Vim compiled with +perl')
    call s:hasError('patch-7.4.1304', 'Minimum viable version')
    call s:has('patch-7.4.2204', 'for get{buf,tab,win}info()')
    call s:has('patch-7.4.2273', 'buffer-local option reading/setting')

endfunction

function! s:checkGlobal(name) abort
    if has_key(g:, a:name)
        call health#report_ok('g:' . a:name . ' is: ' . get(g:, a:name))
    else
        call health#report_error('g:' . a:name . ' NOT set!')
    endif
endfunction

function! s:settingsSection() abort " {{{1
    call health#report_start('settings')

    " if has_key(g:, 'ducttape_loaded')
    " endif
    call s:checkGlobal('ducttape_loaded')
    call s:checkGlobal('ducttape_loaded_ok')
    call s:checkGlobal('ducttape_locallib')
    call s:checkGlobal('ducttape_real_locallib')

endfunction

function! health#ducttape#check() abort " {{{1

    if !exists('g:ducttape_loaded')
        call health#report_error('vim-ducttape is not loaded')
    endif
    if !get(g:, 'ducttape_loaded_ok', 1)
        call health#report_error('vim-ducttape was not loaded OK')
    endif

    call s:vimSection()
    call s:settingsSection()
    return
endfunction

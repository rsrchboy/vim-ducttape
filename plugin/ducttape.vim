" also: /opt/perl5.26.1/lib/site_perl/5.26.1/x86_64-linux/.meta


let s:metacpan_api_base    = 'https://fastapi.metacpan.org/v1/'
let s:metacpan_api_release = s:metacpan_api_base . 'release/'
let s:metacpan_api_module  = s:metacpan_api_base . 'module/'

let s:metacpan_release = 'https://metacpan.org/release/'

function! s:GetUrl(module) abort
    let l:module = json_decode(webapi#http#get(s:metacpan_api_module . a:module).content)
    return s:metacpan_release . l:module.distribution
endfunction

function! DucttapeGetUrl(module) abort
    return s:GetUrl(a:module)
endfunction

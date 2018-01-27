This is a VimL library to assist one in using Perl in vim; that is, not to
help you with *writing* Perl in vim, using Perl in vim (VimL).

# Oh, the things you can do!

There are two main efforts here; the first to make loading Perl functions and
generating "glue" viml functions trivial, the second to make interacting with
vim-bits from Perl easier.


# "vim-bits from Perl"

## Variables

`%b`, `%g`, `%a`, etc, are provided to access `b:`, `g:`, `a:`, etc.  Complex
data structures are supported on both sides; e.g.:

```perl
$b{eep} = [ 1, 2, { three => 3 } ];
```

...equates to:

```vim
let b:eep = [ 1, 2, { 'three': 3 } ]
```

...and the other way around.

Additionally, `%self` is provided for use in dict functions.  See [VIMx] for
more information.

## Functions

Perl functions can easily be bound to generated viml functions by exploiting
`ducttape::symbiont` and vim's autoload functionality.

```vim
" autoload/heya/there.vim
execute ducttape#symbiont#autoload(expand('<sfile>'))
```
```perl
# autoload/heya/there.pm
package heya::there;
use VIMx::Symbiont;

function hello => sub { print 'hello, ' . ($_[0] // 'world') };
```

Given the above files:

```vim
:call heya#there#hello()
" prints 'hello, world'
:call heya#there#hello('chris')
" prints 'hello, chris'
```

# Components

## VIMx::Out

If you're using a version of vim older than 7.4.1729, writing to `STDOUT` or
`STDERR` will fail silently.  We work around that by playing with the
file-handles until they use `VIM::Msg()` and company.  (Yes, this is probably
not the best way to do it, but as people upgrade it'll be moot anyways.)

## VIMx::Tie::Dict

This package allows one to create tied hashes that access vim Dictionaries
transparently.  e.g., you could access global variables by:

```perl
tie our %g, 'VIMx::Tie::Dict', 'g:';
print "$g{some_string_variable}"; # g:some_string_variable

# or even something like
tie my %self, 'VIMx::Tie::Dict', 'l:self';
```

Dicts and Lists are mapped to hashrefs and arrayrefs automatically, so the
following would work:

```perl
$g{a_dict} = { 'rainbow dash' => '120%' };
my $coolness = $g{a_dict}; # hashref
```

## VIMx::Symbiont

This package starts tying things together.  When used, it exports a number of
things, e.g. `%g`, `%b`, `%s`, etc, tied to `g:`, `b:`, `s:`, etc.  It also
exports a `%self` tied to `l:self` for use in `dict` functions.

`function()` is also exported: this takes a coderef, wraps it appropriately,
installs it, then generates a glue viml function.

...

## Essential CPAN packages

We include a minimal subset of CPAN packages to assist us in our efforts
while keeping things as simple as possible, mainly `*::Tiny` packages I'd
really rather not reimplement here.  They're pulled in as submodules, and
their source repositories should be viewed to learn more about those packages,
including their authors, maintainers, and licenses.

* HTTP::Tiny
* JSON::Tiny
* Path::Tiny
* Role::Tiny
* Try::Tiny

`JSON::Tiny` in particular is key, as we lean heavily on vim's `json_encode()`
and `json_decode()` to make bits like `VIMx::Tie::Dict` and
`VIMx::Symbiont::function()` work.

# Mechanism

...

# Requirements

## Vim Requirements

Your vim must be compiled with Perl support.  (Just in case that wasn't 120%
clear.)  Past that, it needs to be compiled against at least Perl v5.10.

If the vim you're using lacks `json_encode()` and `json_decode()` this isn't
going to work -- we make extensive use of those functions when passing data
back and forth from Perl-space to VIM-space.

Here's a list of the newer VimL bits we're using. ...that I'm aware of, at any
rate.

* vim/vim@7823a3bd2eed6ff9e544d201de96710bd5344aaf (tag: v7.4.1304) The
    `json_encode()` and decode functions
  * (introduced as `jsonencode()` / `jsondecode()` in
        vim/vim@520e1e41f35b063ede63b41738c82d6636e78c34 (tag: v7.4.1154))

Honorable mentions go to:

* vim/vim@6244a0fc29163ba1c734f92b55a89e01e6cf2a67 (tag: v7.4.1729) allows a
    `print()`/etc from Perl to actually work.  We work around this for older
    vim.
* vim/vim@e9b892ebcd8596bf813793a1eed5a460a9495a28 (tag: v7.4.1125) gives us
    `perleval()`, which we do not currently use.

## Perl Requirements

Perl v5.10+.

We do not depend on anything past core modules and those included here as
submodules.

# Why "ducttape"?

![Honestly, we just hacked it all together](https://imgs.xkcd.com/comics/lisp.jpg)


# COPYRIGHT AND LICENSE

This software is Copyright (c) 2017 by Chris Weyl <cweyl@alumni.drew.edu>.

This is free software, licensed under:

    The GNU Lesser General Public License, Version 2.1, February 1999

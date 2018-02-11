# Vim and Perl: Perfect together

[![Build Status](https://travis-ci.org/rsrchboy/vim-ducttape.svg?branch=master)](https://travis-ci.org/rsrchboy/vim-ducttape)

This is a VimL library to assist one in using Perl in vim; that is, not to
help you with *writing* Perl in vim, but rather *using* vim's embedded Perl
(`+perl` via VimL).

There are two main efforts here; the first to make loading Perl functions and
generating "glue" viml functions trivial, the second to make interacting with
vim-bits from Perl easier.

You may find the test suite (available under `vader/`) helpful, for examples
and demonstrations of expected behaviour.

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

## Buffers

Buffers can be accessed in a number of ways.

### Current Buffer

The current buffer can be accessed via `$VIMx::BUFFER`, a blessed reference to a
tied variable.  The contents of the buffer can be read or modified by
accessing the underlying array:

```perl
my $len = @$VIMx::BUFFER;
my $first_line = $VIMx::BUFFER->[0];
my $line5 = delete $VIMx::BUFFER->[4];
push @$VIMx::BUFFER, 'remember gems for spike';
```

Note that Vim's functions (e.g. `VIM::Buffer(...)->Get(10)`) are 1-based,
while our array is the expected 0-based.

You can also call any method you can call on a `VIBUF`:

```perl
my $name = $VIMx::BUFFER->Name;
# ...etc.  see `:h perl` for more
```

You can delete lines by using the Perl built-in `delete`, a la:

```perl
my $line5 = delete $VIMx::BUFFER->[4];
```

`$VIMx::BUFFER` stringifies to its name.

### All Buffers (`%VIMx::BUFFERS`)

Similarly, all buffers can be accessed via the `%VIMx::BUFFERS` hash.  The
keys are the names of the buffers, while the values are a reference tied and
blessed in the same way as the current buffer variable (`$VIMx::BUFFER`).

This hash behaves in the expected fashion, e.g.

```perl
say 'it exists!'
    if exists $VIMx::BUFFERS{'hippograph-relations.txt'};
say "buf: $_"
    for keys %VIMx::BUFFERS;
```

## Perl Functions from Vim

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

## VIMx::Tie::Buffer

Ties an array to a `VIBUF`, allowing the buffer contents to be accessed
through the tied array.  It also contains additional "methods" that the
blessed references in `$VIMx::BUFFER` and `%VIMx::BUFFERS` will look for if
invoked on those references; e.g.

```perl
say $BUFFER->Name; # AKA $curbuf->Name
```

The references also support overloading, e.g.
```perl
say "$BUFFER"; # AKA $curbuf->Name
say 0+$BUFFER; # AKA $curbuf->Number
```

## VIMx::Tie::Buffers

The magic behind `%VIMx::BUFFERS`.

...

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

## VIMx::Tie::List

As with `VIMx::Tie::Dict`, but for Lists.

## VIMx::Symbiont

This package starts tying things together.  When used, it exports a number of
things, e.g. `%g`, `%b`, `%s`, etc, tied to `g:`, `b:`, `s:`, etc.  It also
exports a `%self` tied to `l:self` for use in `dict` functions.

`function()` is also exported: this takes a coderef, wraps it appropriately,
installs it, then generates a glue viml function.

...

## VIMx::Out

If you're using a version of vim older than 7.4.1729, writing to `STDOUT` or
`STDERR` will fail silently.  We work around that by playing with the
file-handles until they use `VIM::Msg()` and company.  (Yes, this is probably
not the best way to do it, but as people upgrade it'll be moot anyways.)

## Essential CPAN packages

We include a minimal subset of CPAN packages to assist us in our efforts
while keeping things as simple as possible, mainly `*::Tiny` packages I'd
really rather not reimplement here.  They're pulled in as submodules, and
their source repositories should be viewed to learn more about those packages,
including their authors, maintainers, and licenses.

* Data::Section::Simple
* HTTP::Tiny
* JSON::Tiny
* Module::Runtime
* Path::Tiny
* Role::Tiny
* Template::Tiny (*in `lib/`)
* Try::Tiny

`JSON::Tiny` in particular is key, as we lean heavily on vim's `json_encode()`
and `json_decode()` to make bits like `VIMx::Tie::Dict` and
`VIMx::Symbiont::function()` work.

# Mechanism

...

# Requirements

In short, [vim v7.4.1304](https://github.com/vim/vim/tree/v7.4.1304) compiled with (`+perl`) Perl v5.10+ support.

## Vim Requirements

Your vim must be compiled with Perl support.  (Just in case that wasn't 120%
clear.)  Past that, it needs to be compiled against at least Perl v5.10.

If the vim you're using lacks `json_encode()` and `json_decode()` this isn't
going to work -- we make extensive use of those functions when passing data
back and forth from Perl-space to VIM-space.

Here's a list of the newer VimL bits we're using. ...that I'm aware of, at any
rate.

* [v7.4.1304](https://github.com/vim/vim/tree/v7.4.1304) The
    `json_encode()` and decode functions (introduced as `jsonencode()` / `jsondecode()` in
    [v7.4.1154](https://github.com/vim/vim/tree/v7.4.1154))

Honorable mentions go to:

* [v8.0.0654](https://github.com/vim/vim/tree/v8.0.0654), changes to how
    `:endfunction` is handled.  This would allow us to consolidate certain
    `:execute` calls, but is too new for most vim installations.
* [v7.4.1729](https://github.com/vim/vim/tree/v7.4.1729) allows a
    `print()`/etc from Perl to actually work.  We work around this for older
    vim.
* [v7.4.1125](https://github.com/vim/vim/tree/v7.4.1125) gives us `perleval()`, which we do not currently use.

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

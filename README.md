[![pipeline status](https://gitlab.com/rsrchboy/vim-ducttape/badges/master/pipeline.svg)](https://gitlab.com/rsrchboy/vim-ducttape/commits/master)

# Vim and Perl: Perfect together

<!-- vim-markdown-toc GFM -->

* [Configuration](#configuration)
    * [`g:ducttape_loaded`](#gducttape_loaded)
    * [`g:ducttape_locallib`](#gducttape_locallib)
    * [`g:ducttape_real_locallib`](#gducttape_real_locallib)
    * [`g:ducttape_cpanm`](#gducttape_cpanm)
* [Vim Functions](#vim-functions)
    * [`ducttape#symbiont#autoload()`](#ducttapesymbiontautoload)
    * [`ducttape#has(module)`](#ducttapehasmodule)
    * [`ducttape#require(module)`](#ducttaperequiremodule)
    * [`ducttape#use(module)`](#ducttapeusemodule)
* ["vim-bits from Perl"](#vim-bits-from-perl)
    * [`VIMx`](#vimx)
        * [Export Groups](#export-groups)
        * [`%b`, `%g`, `%a`, etc](#b-g-a-etc)
        * [`%self`](#self)
        * [`$BUFFER`](#buffer)
        * [`%BUFFERS`](#buffers)
        * [`$TAB`](#tab)
        * [`@TABS`](#tabs)
    * [`VIMx::Tie::Buffer`](#vimxtiebuffer)
    * [`VIMx::Tie::Buffers`](#vimxtiebuffers)
        * [FETCH](#fetch)
        * [KEYS](#keys)
        * [VALUES](#values)
    * [`VIMx::Tie::Dict`](#vimxtiedict)
    * [`VIMx::Tie::List`](#vimxtielist)
    * [`VIMx::Symbiont`](#vimxsymbiont)
    * [`VIMx::Out`](#vimxout)
* [Essential CPAN packages](#essential-cpan-packages)
* [Requirements](#requirements)
    * [Vim Requirements](#vim-requirements)
    * [Perl Requirements](#perl-requirements)
* [Why "ducttape"?](#why-ducttape)
* [COPYRIGHT AND LICENSE](#copyright-and-license)

<!-- vim-markdown-toc -->

`ducttape` is a VimL library to assist one in using Perl in vim; that is, not
to help you with *writing* Perl in vim, but rather *using* vim's embedded Perl
(`+perl`).

There are two main efforts here; the first to make loading Perl functions and
generating "glue" viml functions trivial, the second to make interacting with
vim-bits from Perl easier.

You may find the test suite (available under `vader/`) helpful, for examples
and demonstrations of expected behaviour.

# Codebase Notes

This project currently lives on GitHub, but CI is done via GitLab.

https://gitlab.com/rsrchboy/vim-ducttape/pipelines?scope=branches

# Configuration

Generally speaking, most of these take effect only when set prior to plugin
initialization.

## `g:ducttape_loaded`

If this variable exists, the plugin will not be initialized.

You probably don't want to mess with this.

## `g:ducttape_locallib`

_Default_: `<plugin directory>/perl5`

`ducttape` maintains a [local::lib](https://metacpan.org/pod/local::lib) for
anything we install locally.  Usually this is in the `perl5` directory at the
top level of the plugin.

You probably don't want to mess with this.

## `g:ducttape_real_locallib`

_Default:_ 0

Did I say we maintain a `local::lib`?  What I really meant was we fake it by
manipulating `@INC` in the same manner.  This allows `cpanm` to install (and
us to use) the modules we need, without forcing everything we spawn to use our
`local::lib` settings.

If you want a real `local::lib`, with all that implies, set this to 1.

You probably don't want to mess with this.

## `g:ducttape_cpanm`

_Default_: `<plugin directory>/cpanm`

We include copy of the `cpanm` executable to enable the installation of
additional CPAN packages to our local lib.  It's fatpacked, so won't require
any additional dependencies on your system.

# Vim Functions

## `ducttape#symbiont#autoload()`

This is relatively straight-forward.  `VIMx::Symbiont` takes a package and
functions, and generates viml that can be sourced to create glue functions.

First, decide what you want the vim namespace of the glue functions to be and
create a minimal autoload file; e.g. if you want your functions to live under
`foo#bar`, create `autoload/foo/bar.vim` as:

```vim
" For those following along at home:  the reason we can get away with
" autoloaded functions is that we execute the VimL that creates them from
" inside this script/file.  That's enough to convince vim that these functions
" belong in that namespace -- or perhaps just that we're determined so it may
" as well get out of the way.

for s:eval in ducttape#symbiont#autoload(expand('<sfile>'))
    execute s:eval
endfor
```

Then, write your Perl as `autoload/foo/bar.pm`:

```perl
package VIMx::autoload::foo::bar;
use strict;
use warnings;
use VIMx::Symbiont;

# glue: foo#bar#thing(...) abort
function thing => sub { ... };

# glue: foo#bar#hello(name) abort
function args => 'name', hello => sub {
  return "Hello, $a{name}!";
};

# glue: foo#bar#coolness(factor, ...) abort
function args => 'factor, ...', coolness => sub {
  my $pony = shift // 'Rainbow_Dash';

  $g{$pony} *= $a{factor};
  return;
};

# glue: foo#bar#line5() abort
function args => q{}, line5 => sub { print $BUFFER->[4]; return };
```

When calling the glue functions, any non-named parameters end up in `@_`, as
one might expect, while named parameters end up in the tied hash `%a`.
Anything `return` works as you'd expect, including complex returns (e.g. a
list, hashref, etc, will be translated.)

The current buffer can be accessed via `$BUFFER`; all buffers can be accessed
via `%BUFFERS`.  Similarly, `%g` will get you `g:`, `%t` gets you `t:`, etc.

## `ducttape#has(module)`

Given a module, returns true if the module is available; false otherwise.

## `ducttape#require(module)`

Given a module, `require`'s the module.  Essentially equivalent to:

  require Some::Module;

## `ducttape#use(module)`

Given a module, `use`'s the module.  Essentially equivalent to:

  use Some::Module;

Note: any exports the module's `inport()` function performs will end up in the
`main` namespace.

# "vim-bits from Perl"

## `VIMx`

The `VIMx` package exports a number of useful routines and variables designed
to make interfacing with Vim easier.  You can choose to not export any (or
all) of them and access them via their fully-qualified names (e.g.
`%VIMx::b`).

Where exported by default, we'll refer to variables by their unqualified name.

### Export Groups

`VIMx` recognizes the following export groups:

* `:variables`
  * `%a %b %g %l %s %t %v %w %self`
* `:buffers`
  * `$BUFFER %BUFFERS`
* `:options`
  * `%GOPTIONS %LOPTIONS %OPTIONS`
* `:tabs`
  * `$TAB @TABS`

### `%b`, `%g`, `%a`, etc

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

### `%self`

Additionally, `%self` is provided for use in dict functions; this corresponds
to `l:self`. See `VIMx` for more information.

### `$BUFFER`

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
## ...etc.  see `:h perl` for more
```

You can delete lines by using the Perl built-in `delete`, a la:

```perl
my $line5 = delete $VIMx::BUFFER->[4];
```

`$VIMx::BUFFER` stringifies to its name in string context, and to its number
in numeric context.

[`VIMx::Tie::Buffer`](#vimxtiebuffer)

### `%BUFFERS`

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

### `$TAB`

### `@TABS`

## `VIMx::Tie::Buffer`

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

## `VIMx::Tie::Buffers`

The magic behind `%VIMx::BUFFERS`, this is a `Tie::Hash`.

This tie allows one to access all buffers known to vim: listed, unlisted, etc,
etc.  Use a map if you need to narrow something down:

```perl
my @listed = grep { $_->options->{buflisted} } values %BUFFERS;
```

It's unlikely you'll ever need to tinker with this directly, as
`%VIMx::BUFFERS` is already tied to it.

Here's how the different hash operations are implemented; not all of them are,
e.g. trying to clear the hash (e.g. `%BUFFERS = ()`) is unimplemented, as is
creating a buffer (currently).

### FETCH

Returns a reference to a blessed/tied `VIMx::Tie::Buffer`; `undef` if a
buffer with a matching name/number is not found.

```perl
# fetches buffer number 42
my $bufA = $BUFFERS{42};
# fetches buffer named meaning.txt
my $also_bufA = $buffers{'meaning.txt'};
# fetches buffer _named_ 42
my $bufB = $buffers{'42'};
```

### KEYS

While all buffer names are returned, we don't also return the buffer number.
(If you're looking for a specific number, just fetch it directly.)

```perl
# I know, terribly, shockingly surprising
my @names = keys %BUFFERS;
```

### VALUES

Just as expected, all the buffers.

```perl
# again, shocking
my @bufs = values %BUFFERS;
```

## `VIMx::Tie::Dict`

This package allows one to create tied hashes that access vim Dictionaries
transparently.  e.g., you could access global variables by:

```perl
tie our %g, 'VIMx::Tie::Dict', 'g:';
print "$g{some_string_variable}"; # g:some_string_variable

# or even something like
tie my %self, 'VIMx::Tie::Dict', 'l:self';
```

Dicts and Lists are mapped to hashrefs and arrayrefs automatically, so the
following will work:

```perl
$g{a_dict} = { 'rainbow dash' => '120%' };
my $coolness = $g{a_dict}; # hashref
```

## `VIMx::Tie::List`

As with `VIMx::Tie::Dict`, but for Lists.

## `VIMx::Symbiont`

This package starts tying things together.  When used, it exports a number of
things, e.g. `%g`, `%b`, `%s`, etc, tied to `g:`, `b:`, `s:`, etc.  It also
exports a `%self` tied to `l:self` for use in `dict` functions.

`function()` is also exported: this takes a coderef, wraps it appropriately,
installs it, then generates a glue viml function.

...

## `VIMx::Out`

If you're using a version of vim older than 7.4.1729, writing to `STDOUT` or
`STDERR` will fail silently.  We work around that by playing with the
file-handles until they use `VIM::Msg()` and company.  (Yes, this is probably
not the best way to do it, but as people upgrade it'll be moot anyways.)

# Essential CPAN packages

We include a minimal subset of CPAN packages to assist us in our efforts
while keeping things as simple as possible, mainly `*::Tiny` packages I'd
really rather not reimplement here.  They're pulled in as submodules, and
their source repositories should be viewed to learn more about those packages,
including their authors, maintainers, and licenses.

* [Data::Section::Simple](https://metacpan.org/pod/Data::Section::Simple)
* [HTTP::Tiny](https://metacpan.org/pod/HTTP::Tiny)
* [JSON::Tiny](https://metacpan.org/pod/JSON::Tiny)
* [Module::Runtime](https://metacpan.org/pod/Module::Runtime)
* [Path::Tiny](https://metacpan.org/pod/Path::Tiny)
* [Role::Tiny](https://metacpan.org/pod/Role::Tiny)
* [Template::Tiny](https://metacpan.org/pod/Template::Tiny) (*in `lib/`)
* [Try::Tiny](https://metacpan.org/pod/Try::Tiny)

`JSON::Tiny` in particular is key, as we lean heavily on vim's `json_encode()`
and `json_decode()` to make bits like `VIMx::Tie::Dict` and
`VIMx::Symbiont::function()` work.

# Requirements

`vim` compiled with (`+perl`) Perl (v5.10+) support.

[vim v7.4.2273](https://github.com/vim/vim/tree/v7.4.2273) for full
functionality, v7.4.2204 for everything except the ability to get and
set buffer-local options of non-current buffers, v7.4.1304 for the above
except the buffer/win/tab `info()` methods.


## Vim Requirements

Your vim must be compiled with Perl support.  (Just in case that wasn't 120%
clear.)  Past that, it needs to be compiled against at least Perl v5.10.

If the vim you're using lacks `json_encode()` and `json_decode()` this isn't
going to work -- we make extensive use of those functions when passing data
back and forth from Perl-space to VIM-space.

Here's a list of the newer VimL bits we're using. ...that I'm aware of, at any
rate.

* [v7.4.1304](https://github.com/vim/vim/tree/v7.4.1304) The
    `json_encode()` and decode functions (introduced as `jsonencode()` /
    `jsondecode()` in [v7.4.1154](https://github.com/vim/vim/tree/v7.4.1154))
* [v7.4.2204](https://github.com/vim/vim/tree/v7.4.2204) introduces
    `get{buf,tab,win}info()`.
* [v7.4.2273](https://github.com/vim/vim/tree/v7.4.2273) provides for
    buffer-local option reading/setting.

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

This software is Copyright (c) 2017, 2018 by Chris Weyl
<cweyl@alumni.drew.edu>.

This is free software, licensed under:

    The GNU Lesser General Public License, Version 2.1, February 1999

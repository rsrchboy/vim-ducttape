This is a VimL library to assist one in using Perl in vim; that is, not to
help you with *writing* Perl in vim, using Perl in vim (VimL).

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

# Vim Requirements

If the vim you're using lacks `json_encode()` and `json_decode()` this isn't
going to work -- we make extensive use of those functions when passing data
back and forth from Perl-space to VIM-space.

Here's a list of the newer VimL bits we're using. ...that I'm aware of, at any
rate.

* vim/vim@7823a3bd2eed6ff9e544d201de96710bd5344aaf (tag: v7.4.1304) The `json_encode()` and decode functions
  * (introduced as `jsonencode()` / `jsondecode` in vim/vim@520e1e41f35b063ede63b41738c82d6636e78c34 (tag: v7.4.1154))

Honorable mentions go to:

* vim/vim@6244a0fc29163ba1c734f92b55a89e01e6cf2a67 (tag: v7.4.1729) allows a
    `print()`/etc from Perl to actually work.  We work around this for older
    vim.
* vim/vim@e9b892ebcd8596bf813793a1eed5a460a9495a28 (tag: v7.4.1125) gives us
    `perleval()`, which we do not currently use.

# Why "ducttape"?

![Honestly, we just hacked it all together](https://imgs.xkcd.com/comics/lisp.jpg)

## Essential CPAN packages

We include a minimal subset of CPAN packages to assist us in our efforts
while keeping things as simple as possible, mainly `*::Tiny` packages I'd
really rather not reimplement here.  They're pulled in as submodules, and
their source repositories should be viewed to learn more about those packages,
including their authors, maintainers, and licenses.

* HTTP::Tiny
* JSON::Tiny
* Path::Tiny
* Try::Tiny

# COPYRIGHT AND LICENSE

This software is Copyright (c) 2017 by Chris Weyl <cweyl@alumni.drew.edu>.

This is free software, licensed under:

    The GNU Lesser General Public License, Version 2.1, February 1999

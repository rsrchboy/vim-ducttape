This is a VimL library to assist one in using Perl in vim; that is, not to
help you with *writing* Perl in vim, using Perl in vim (VimL).

## Notes

If the vim you're using lacks `json_encode()` and `json_decode()` this isn't
going to work -- we make extensive use of those functions when passing data
back and forth from Perl-space to VIM-space.

## Why "ducttape"?

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

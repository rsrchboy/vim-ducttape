package VIMx::autoload::ducttape::path;

use v5.10;
use strict;
use warnings;

use VIMx::Symbiont;

sub fpath    { function args => q{path},      @_ }
sub fpathand { function args => q{path, ...}, @_ }

# Create a tempdir, with all the bells and whistles.

function tempdir => sub {
    return Path::Tiny
        ->tempdir(CLEANUP => 0, %{$a{000} ? $a{1} : {}})
        ->stringify;
};

function args => q{dir}, rmtree => sub {
    path($a{dir})->remove_tree({ safe => 0 });
    return;
};

function args => q{path}, mkpath => sub {
    path($a{path})->mkpath;
    return $a{path};
};

function path => sub { my $p = path(@_); "$p" };

fpath exists      => sub { path($a{path})->exists      ? 1 : 0 };
fpath is_relative => sub { path($a{path})->is_relative ? 1 : 0 };
fpath is_absolute => sub { path($a{path})->is_absolute ? 1 : 0 };
fpath is_rootdir  => sub { path($a{path})->is_rootdir  ? 1 : 0 };
fpath is_dir      => sub { path($a{path})->is_dir      ? 1 : 0 };
fpath is_file     => sub { path($a{path})->is_file     ? 1 : 0 };
fpath touch       => sub { my $p = path($a{path})->touch;     "$p" };
fpath touchpath   => sub { my $p = path($a{path})->touchpath; "$p" };

fpath    relative  => sub { my $p = path($a{path})->relative;     "$p" };
fpath    remove    => sub { path($a{path})->remove ? 1 : 0             };
fpathand absolute  => sub { my $p = path($a{path})->absolute(@_); "$p" };
fpathand basename  => sub { my $p = path($a{path})->basename(@_); "$p" };
fpathand digest    => sub { my $p = path($a{path})->digest(@_);   "$p" };
fpathand parent    => sub { my $p = path($a{path})->parent(@_);   "$p" };
fpathand realpath  => sub { my $p = path($a{path})->realpath(@_); "$p" };
function canonpath => sub { my $p = path(@_)->canonpath;          "$p" };
function cwd       => sub { my $p = path(@_)->cwd;                "$p" };

fpathand append      => sub { path($a{path})->append(@_)      };
fpathand append_raw  => sub { path($a{path})->append_raw(@_)  };
fpathand append_utf8 => sub { path($a{path})->append_utf8(@_) };
fpathand lines       => sub { path($a{path})->lines(@_)       };
fpathand lines_raw   => sub { path($a{path})->lines_raw(@_)   };
fpathand lines_utf8  => sub { path($a{path})->lines_utf8(@_)  };
fpathand slurp       => sub { path($a{path})->slurp(@_)       };
fpathand slurp_raw   => sub { path($a{path})->slurp_raw(@_)   };
fpathand slurp_utf8  => sub { path($a{path})->slurp_utf8(@_)  };
fpathand spew        => sub { path($a{path})->spew(@_)        };
fpathand spew_raw    => sub { path($a{path})->spew_raw(@_)    };
fpathand spew_utf8   => sub { path($a{path})->spew_utf8(@_)   };

function args => q{path, subsumes},
    subsumes => sub { path($a{path})->subsumes($a{subsumes}) ? 1 : 0 };
function args => q{path, mode},
    chmod => sub { path($a{path})->chmod($a{mode}) ? 1 : 0 };
function args => q{path, target},
    copy => sub { path($a{path})->copy($a{target}) ? 1 : 0 };
function args => q{path, target},
    move => sub { path($a{path})->move($a{target}) ? 1 : 0 };

!!42;

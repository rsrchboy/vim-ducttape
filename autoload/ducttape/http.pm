package VIMx::autoload::ducttape::http;

use v5.10;
use strict;
use warnings;

use VIMx::Symbiont;
use HTTP::Tiny;

# the VIMx::Symbiont-generated sub functions handles turning the parameters
# JSON into Perl values -- and the other way around on return.

function get    => sub { request(GET    => @_) };
function head   => sub { request(HEAD   => @_) };
function put    => sub { request(PUT    => @_) };
function post   => sub { request(POST   => @_) };
function delete => sub { request(DELETE => @_) };

sub request {
    ### @_
    my ($method, $url, $args) = @_;

    my $ua = HTTP::Tiny->new(
        agent      => 'VimFetch ',
        verify_SSL => 1,
        %{ $args->{ua_opts} // {} },
    );

    my $ret = $ua->request($method => $url, $args->{req_opts} // {});

    # convenience: if we've been sent JSON, decode it
    do { $ret->{content} = decode_json($ret->{content}) }
        if $ret->{headers}->{'content-type'} =~ m!application/json!;

    return $ret;
}

!!42;
__END__


package Elasticsearch::Dancer::App::Search;

use strict;
use warnings;

use AnyEvent;
use AnyEvent::HTTP;
use URI;
use URI::Escape;
use JSON::XS;

use Dancer::Logger::Console;
my $logger = Dancer::Logger::Console->new;

sub new { my $self = bless { }; return $self; }

sub _pickrandom {
    my ($self, $config) = @_;
    # pick random URI (load balancing)
    my $uricount = scalar @{$config->{uri}};
    my $random = int(rand($uricount));
    my $uri = $config->{uri}[$random];
    return $uri;
}

sub search {
    my ($self, $config, $query, $request) = @_;
    my $url = $self->_pickrandom($config) . '/_search';
    # with AnyEvent, we can search over many URLs (metasearch), but we have just one URL
    my $urls = [ $url ];
    my $request_body = encode_json($request);
    $logger->info('Elasticsearch query = ' . $request_body);
    my $result;
    my $done = 0;
    while (not $done) {
      my $cv = AnyEvent->condvar();
      $cv->begin(sub { shift->send($result) });
      foreach my $url (@$urls) {
        $cv->begin;
        my $request;
        $request = http_request(POST => $url, 
            headers => { 'Content-Type' => 'application/json; charset=UTF-8' },
            body => $request_body,
            persistent => 1,
            keepalive => 1,
            timeout => 0,
            sub {
                my ($data, $hdr) = @_;
                my $u = URI->new($url);
                $done = 1;
                if ($hdr->{'Status'} =~ /^2/) {
                    if ($hdr->{'content-type'} eq 'application/json; charset=UTF-8') {
                        my $r = { ok => 1, url => $url, header => $hdr, body => $data, json => decode_json($data) };
                        push @$result, $r;
                        $logger->info('Elasticsearch ' . $u->host . ':' . $u->port 
                              . ' successful query ' . $query . ', '
                              . $r->{json}{hits}{total}. ' hits, took '. $r->{json}{took}. ' ms'
                        );
                    }
                } elsif ($hdr->{'Status'} =~ /^596/) { 
                    # 596 = Connection timed out
                   $done = 0;
                   $logger->error('Elasticsearch '  . $u->host . ':' . $u->port
                           . ' failed query ' . $query 
                           . ', status '. $hdr->{'Status'} 
                           . ', reason ' . $hdr->{'Reason'} );                
                } else {
                   push @$result, { ok => 0, url => $url, header => $hdr };
                   $logger->error('Elasticsearch '  . $u->host . ':' . $u->port
                           . ' failed query ' . $query 
                           . ', status '. $hdr->{'Status'} 
                           . ', reason ' . $hdr->{'Reason'} );
                }
                undef $request;
                $cv->end;
            }
        );
      }
      $cv->end();
      my $response = $cv->recv();
      return $response if $done;
    }
}

sub status {
    my ($self, $config) = @_;
    my $cv = AnyEvent->condvar;
    my $url = $self->_pickrandom($config);
    my $uri = URI->new($url);# get base URI only
    $url = $uri->scheme . '://' . $uri->host . ':' . $uri->port . '/_cluster/health/';
    http_get($url, sub {
        my ($msg) = @_;
        $cv->send( { response => $msg ? decode_json($msg) : undef } );
    }); 
    my $response = $cv->recv();
    return $response;
} 

1;

__END__

=pod

=head1 NAME

Elasticsearch::Dancer::App::Search - Elasticsearch client based on AnyEvent::HTTP

=head1 SYNOPSIS

    elasticsearch:
        uri: 
            - http://localhost:9200/test/
        facets:
            Language:
                terms:
                    field: mylanguage
            Date:
                terms:
                    field: myyear
        filter:
            Language: mylanguage
            Date: myyear
        fields:
            title: mytitle       
            description: mydescription
            url: myurl
            date: mydate


    use Elasticsearch::Dancer::App::Search;

    my $searcher = Elasticsearch::Dancer::App::Search->new();

    my $results = $searcher->search(config->{elasticsearch}, $q, $request);  
 
    my $status = $searcher->status(config->{elasticsearch});
 
=head1 DESCRIPTION

Elasticsearch::Dancer::App::Search implements simple HTTP GET/POST commands
to search in Elasticsearch or send control statements to Elasticsearch.

=head1 METHODS

=head2 search

Search in Elasticsearch.

=head2 status

Request cluster health from Elasticsearch.

=head1 SEE ALSO
 
L<Dancer>, L<Elasticsearch>
 
=head1 AUTHOR
 
Jörg Prante <joergprante@gmail.com>  
 
=head1 LICENSE
 
Copyright (C) 2013 Jörg Prante <joergprante@gmail.com>
 
This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
 
See http://www.perl.com/perl/misc/Artistic.html
 
=cut

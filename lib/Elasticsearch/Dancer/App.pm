
package Elasticsearch::Dancer::App;

use strict;
use warnings;

use Elasticsearch::Dancer::App::Search;
use Dancer qw(:syntax);
use URI::Escape;
use JSON::XS qw(decode_json);
use Clone qw(clone);

our $VERSION = '0.1';

my $searcher = Elasticsearch::Dancer::App::Search->new();

get '/' => sub {
    my $q = param('q');
    my $p = param('p') || (session('user') ? session('user')->{'p'} : 1);
    my $f = param('f');
    my $len = param('len') || (session('user') ? session('user')->{'len'} : config->{pagination}->{entries_per_page});
    my $sort = param('sort') || (session('user') ? session('user')->{'sort'} : config->{sort}->{field}) || '_score';
    my $order = param('order') || (session('user') ? session('user')->{'order'} : config->{sort}->{order}) || 'desc';
    my $facets = (session('user') ? session('user')->{'facets'} : clone(config->{elasticsearch}->{facets}) );
    my $fname = param('fname');

    my $html;    
    unless ($q) {
        $html = template 'splash', { page => { logo => config->{logo}, search_action => '/', query => '' } };
    } else {
        my $request = {
             query => { query_string => { query => $q } },
             from => ($p - 1) * $len,
             size => $len,
             sort => [ { $sort => $order } ]
        };
        if ($f) {            
            my $filter = decode_json(uri_unescape($f));
            $request->{filter} = $filter;
            if ($facets) {
                $facets->{$fname}->{facet_filter} = $filter if $fname;
                $request->{facets} = $facets;
            }            
        } elsif ($facets and $fname) {
            delete $facets->{$fname}->{facet_filter};
            $request->{facets} = $facets;
        } elsif ($facets) {
            $request->{facets} = $facets;
        }
        my $results = $searcher->search(config->{elasticsearch}, $q, $request);
        $html = template 'results', {
            page => {
              search_action => '/', 
              query => $q, 
              logo => config->{logo},
              result => $results,
              paginate => { 
                  current_page => $p, 
                  total_entries => $results->[0]->{json}{hits}{total},
                  entries_per_page => $len
              },
              sort => $sort, 
              order => $order,
              facet_result => $results->[0]->{json}{facets}
            }
        };
    }    

    session user => {
       'p' => $p,
       'f' => $f,
       'len' => $len,
       'sort' => $sort,
       'order' => $order,
       'facets' => $facets
    };
    
    return $html;
};

get '/status' => sub {
    template 'status', {
        page => { logo => config->{logo}, search_action => '/', query => '' },
        status => $searcher->status(config->{elasticsearch})
    };
};

get '/logout' => sub {
    session->destroy;
    redirect '/';
};

true;

__END__

=pod

=head1 NAME

Elasticsearch::Dancer::App - a simple Elasticsearch Dancer/Bootstrap application

=head1 SYNOPSIS

    use Dancer;
    ...

    our $searcher = Elasticsearch::Dancer::App::Search->new();

    get '/' => sub { 
         ...
         my $request = {
             query => { query_string => { query => $q } }
         };
         ...
         my $results = $searcher->search(config->{elasticsearch}, $q, $request);
         template 'results', { 
             ... 
             result => $results
          }
    }

=head1 DESCRIPTION

This simple Elasticsearch Dancer application can be used as a starting point
for your own search applications with Dancer/Bootstrap.

The application makes use of AnyEvent::HTTP for parallel HTTP requests,
XSlate templates for fast templates, and Bootstrap for front-end framework.

=head1 SEE ALSO

L<Dancer>, L<Dancer::Template::XSlate>, L<AnyEvent::HTTP>,  L<Elasticsearch>

=head1 AUTHOR
 
Jörg Prante <joergprante@gmail.com>  
 
=head1 LICENSE
 
Copyright (C) 2013 Jörg Prante <joergprante@gmail.com>
 
This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
 
See http://www.perl.com/perl/misc/Artistic.html

=cut

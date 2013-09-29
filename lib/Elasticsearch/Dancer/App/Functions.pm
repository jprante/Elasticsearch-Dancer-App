
package Elasticsearch::Dancer::App::Functions;

use strict;
use warnings;

use Dancer ':script';
use Dancer::Logger::Console;
use Elasticsearch::Dancer::App::Paginate;
use URI::Escape;
use JSON::XS qw(encode_json);
use Exporter ();

our @ISA = qw(Exporter);
our @EXPORT_OK = qw(will_paginate sort_link facet_reset facet_link field json);

my $logger = Dancer::Logger::Console->new;

sub will_paginate {
    my ($p, $q) = @_;
    return '' unless $p->{total_entries};
    my $paginator = Elasticsearch::Dancer::App::Paginate->new($p);
    my $s = $paginator->html('<a href="/?q='.uri_escape_utf8($q).'&amp;p=%p">%a</a>');
    return $s;
}

sub sort_link {
    my ($query, $sort, $order) = @_;
    my $field = config->{elasticsearch}->{sort} ? config->{elasticsearch}->{sort}->{$sort} : $sort;
    my $s = '/?q=' . uri_escape_utf8($query) . '&amp;sort=' . $field . '&amp;order='. $order;
    return $s;
}

sub facet_reset {
    my ($query, $name) = @_;
    my $s = '/?q=' . uri_escape_utf8($query) . '&amp;fname='.$name;
    return $s;    
}

sub facet_link {
    my ($query, $name, $term) = @_;
    my $field = config->{elasticsearch}->{filter} ? config->{elasticsearch}->{filter}->{$name} : $name;
    my $s = '/?q=' . uri_escape_utf8($query) . '&amp;fname='.$name.'&amp;f=' . uri_escape_utf8('{"term":{"' . $field . '":"' . $term . '"}}');
    return $s;
}

sub field {
    my ($field, $source) = @_;
    return '' unless $field and $source;
    my $s = config->{elasticsearch}->{fields} ? config->{elasticsearch}->{fields}->{$field} : $field;
    if (ref $s eq 'ARRAY') {
        # concatenate values over more than one field
        return join ' &mdash; ', map { _get_val($source, split('\.',$_)) } @$s;
    } else {
        return _get_val($source, split('\.',$s));
    }
}

sub _get_val {
    my ($obj, @keys) = @_;
    return '' unless $obj;
    my ($head,$index) = (shift @keys,0);
    ($head,$index) = ($1,$2) if $head =~ /^(.*)\[(\d+)\]$/;
    $index = 0 unless $index;
    $obj = $obj->[$index] if ref $obj eq 'ARRAY';
    return (defined $obj ? $obj : '')  unless ref $obj eq 'HASH';
    if (scalar @keys == 0) {
         $obj = $obj->{$head};
         my $res = ref $obj eq 'ARRAY' ? $obj->[$index] : $obj;
         return defined $res ? $res : '';
    }
    return _get_val($obj->{$head}, @keys);
}

sub json {
    my ($obj) = @_;
    return '' unless $obj;
    my $s = encode_json($obj);
    return $s;
}

1;

__END__

=pod

=head1 NAME

Elasticsearch::Dancer::App::Functions - some Xslate functions

=head1 SYNOPSIS

     html_builder_module:
        - "Elasticsearch::Dancer::App::Functions"
        - ["will_paginate", "sort_link", "facet_reset", "facet_link", "field", "json"]
 
=head1 DESCRIPTION

Elasticsearch::Dancer::App::Functions provides some HTML builder functions for Dancer Xslate teamplates.

=head1 METHODS

=head2 will_paginate

=head2 sort_link

=head2 facet_reset

=head2 facet_link

=head2 field

=head2 json

=head1 SEE ALSO
 
L<Dancer::Template::Xslate>

=head1 AUTHOR
 
Jörg Prante <joergprante@gmail.com>  
 
=head1 LICENSE
 
Copyright (C) 2013 Jörg Prante <joergprante@gmail.com>
 
This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
 
See http://www.perl.com/perl/misc/Artistic.html
 
=cut

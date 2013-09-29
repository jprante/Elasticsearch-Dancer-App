
package Elasticsearch::Dancer::App::Paginate;

use strict;
use warnings;

use base 'Data::Pageset';

sub new {
    my ($class, $conf) = @_;
    my $self = $class->SUPER::new({ %$conf });
    $self->{link_format} = $conf->{link_format};
    return $self;
}

sub html {
    my $self = shift;
    my $frmt = shift || $self->{link_format};
    my $frmt_for_current = _strip_href_from_format($frmt);

    my $txt;

    $txt .= '<div class="pagination"><ul>';

    my $disabled = $self->current_page == 1 ? 'disabled' : '';
    $txt .=  _sprintf( '<li class="prev previous_page '.$disabled.'">'
             . ($disabled ? $frmt_for_current : $frmt) 
             . '</li>', $self->current_page - 1, '&#8592; Previous' );
    if ($self->previous_set) {
        if ($self->previous_set < _min( @{ $self->pages_in_set })) {
            my $chunk = $frmt;
            $txt .= _sprintf( '<li>'. $frmt . '</li>', 1 );
            $txt .= _sprintf( '<span class="gap">&hellip;</span>' );
        }
    }
    for my $num ( @{ $self->pages_in_set } ) {
        if ( $num == $self->current_page ) {
            $txt .= _sprintf( '<li class="active">'.$frmt.'</li>', $num );
        } else {
            $txt .= _sprintf( '<li>'.$frmt.'</li>', $num );
        }
    }
    if ( $self->next_set ) {
        if ( $self->next_set > _max( @{ $self->pages_in_set } ) ) {
            $txt .= _sprintf( '<span class="gap">&hellip;</span>' );
            $txt .= _sprintf( '<li>'.$frmt.'</li>', $self->last_page );
        }
    }
    $disabled = $self->current_page < $self->last_page ? '' : 'disabled';
    $txt .= _sprintf( '<li class="next next_page '.$disabled.'">'
            . ($disabled ? $frmt_for_current : $frmt) 
            .'</li>', $self->current_page + 1, 'Next &#8594;' );

    $txt .= '</ul></div>';

    return $txt;
}

sub link_format {
    my ( $self, $frmt ) = @_;
    $self->{link_format} = $frmt if defined $frmt;
    return $self->{link_format};
}

sub _strip_href_from_format {
    my $frmt = shift;
    return unless defined $frmt;
    $frmt =~ s/href="(.*?)"/href="#"/;
    return $frmt;
}

sub _sprintf {
    my $frmt = shift;
    my $p = shift;
    my $l = shift || $p;
    $frmt =~ s{ \%p }{$p}gx;
    $frmt =~ s{ \%a }{$l}gx;
    return $frmt;
}

sub _min {
    my ( $min, @list ) = @_;
    for (@list) {
        $min = $_ if $_ < $min;
    }
    return $min;
}

sub _max {
    my ( $max, @list ) = @_;
    for (@list) {
        $max = $_ if $_ > $max;
    }
    return $max;
}

1;

__END__

=head1 NAME

Elasticsearch::Dancer::App::Paginate - search result pagination for Dancer

=head1 SYNOPSIS

    template 'results', {
        page => {
            query => $q,
            paginate => {
                current_page => $p,
                total_entries => $results->[0]->{json}{hits}{total},
                entries_per_page => $len
            },   
    }  
    ...

   <div class='item-paging bottom'>
        : will_paginate( $page.paginate, $page.query )
   </div>    
  
 
=head1 DESCRIPTION

Pagination is a requirement of each web application that presents large document sets.
Elasticsearch::Dancer::App::Paginate uses Data::Pageset and implements Bootstrap HTML
output.

=head1 METHODS

=head2 html

Returns HTML code for pagination

=head1 SEE ALSO
 
L<Data::Pageset>, https://github.com/nickpad/will_paginate-bootstrap

=head1 AUTHOR

Based on Mark Grimes module L<Data::Pageset::Render>
 
Jörg Prante <joergprante@gmail.com>  
 
=head1 LICENSE
 
Copyright (C) 2013 Jörg Prante <joergprante@gmail.com>
 
This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
 
See http://www.perl.com/perl/misc/Artistic.html
 
=cut


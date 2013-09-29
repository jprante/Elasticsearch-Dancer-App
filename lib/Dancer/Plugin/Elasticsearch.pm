
package Dancer::Plugin::Elasticsearch;

use Dancer qw(:syntax);
use Dancer::Plugin;
use Elasticsearch;

my $connection;

register elasticsearch => sub {
    return $connection or _create_connection();
};
    
sub _create_connection {
    my $settings = plugin_setting;
    my $es = Elasticsearch->new(%$settings) or die 'error connecting to Elasticsearch';
    return $connection = $es;
}
                        
register_plugin;
                       
true;

__END__

=pod

=head1 NAME

Dancer::Plugin::Elasticsearch - Elasticsearch connection for Dancer

=head1 SYNOPSIS

    use Dancer::Plugin::Elasticsearch;

    $data = elasticsearch->get(
            index => 'twitter',
            type  => 'tweet',
            id    => 1
    );

=head1 DESCRIPTION

Dancer::Plugin::Elasticsearch allows easy Elasticsearch use.

=head1 METHODS

=head2 elasticsearch

Returns an Elasticsearch connection object.

=head1 CONFIG

Make sure to appropriately configure the plugin in your config.yml
    
    plugins:
        Elasticsearch:
            servers: 127.0.0.1:9200
            transport: http

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
                        
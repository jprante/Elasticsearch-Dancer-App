use strict;
use warnings;
use ExtUtils::MakeMaker;

# Normalize version strings like 6.30_02 to 6.3002,
# so that we can do numerical comparisons on it.
my $eumm_version = $ExtUtils::MakeMaker::VERSION;
$eumm_version =~ s/_//;

WriteMakefile(
    NAME                => 'Elasticsearch::Dancer::App',
    AUTHOR              => q{Jörg Prante <joergprante@gmail.com>},
    VERSION_FROM        => 'lib/Elasticsearch/Dancer/App.pm',
    ABSTRACT            => 'a demonstration of a Dancer/Bootstrap app for searching with Elasticsearch',
    ($eumm_version >= 6.3001
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
        'YAML' => 0,
        'Dancer' => 1.3112,
        'Dancer::Plugin::FlashMessage' => 0.314,
        'Elasticsearch' => 0.71,
        'Dancer::Template::Xslate' => 0.003,
        'AnyEvent::HTTP' => 2.15,
        'JSON::XS' => 2.32,
        'Clone' => 0.31,
        'URI' => 1.60,
        'Data::Pageset' => 1.06,
        'File::Touch' => 0.08
    },
    dist => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean  => { FILES => 'Elasticsearch-Dancer-App-*' },
);

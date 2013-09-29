.. image:: ../../../Elasticsearch-Dancer-App/raw/master/assets/dance.png

Elasticsearch Dancer App
========================

This simple Elasticsearch Dancer application can be used as a starting point
for your own search applications with Dancer/Bootstrap.

The application makes use of AnyEvent::HTTP for parallel HTTP requests,
XSlate templates for fast templates, and Bootstrap for front-end framework.

For convenience, the official Elasticsearch client is also added as a dependency.
By using a Dancer plugin, you can have access to the  Elasticsearch client object.


Quickstart
---------

Download Elasticsearch and unzip the zip distribution.

Start Elasticsearch::

    ./bin/elasticsearch

Change into the current directory of the Elasticsearch Dancer App.

First, load some demo documents into Elasticsearch for Elasticsearch Dancer app::

    ./bin/load-example-docs.sh 127.0.0.1 9200

Check if you have all the dependent perl modules installed and install them if necessary::

    perl Makefile.PL
    make

Note: before each start, the Xslate templates (suffix .xt) must be touched so they get recompiled.
Otherwise the Dancer app might hang at template invocation. Example: touch views/*.xt

Start the app like a Dancer app::

    ./bin/app.pl

Fire up your browser to view the Dancer app. The default port is 3000::

    http://localhost:3000

Now you can start to use your own documents, add features ... happy hacking!

Screenshots
-----------

Here are some screenshots with the example documents.

.. image:: ../../../Elasticsearch-Dancer-App/raw/master/assets/screenshot1.png

.. image:: ../../../Elasticsearch-Dancer-App/raw/master/assets/screenshot2.png


Credits
-------

Thanks to Karl Jonathan Ward for the open source CrossRef search https://github.com/CrossRef/cr-search
from which a stripped down bootstrap layout was taken for this project.

Copyright
--------

Copyright (C) 2013 Jörg Prante <joergprante@gmail.com>
 
This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
 
See http://www.perl.com/perl/misc/Artistic.html

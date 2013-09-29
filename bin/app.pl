#!/usr/bin/env perl
BEGIN {
   use File::Touch;
   @t = <views/*.tx>;
   touch(@t);
}
use Dancer;
use Elasticsearch::Dancer::App;
dance;

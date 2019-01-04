#!/usr/bin/env perl

use strict;
use warnings;

use WWW::Mechanize;
use Test::HTML::Content (tests => 1);

# Create a new mechanize object
my $mech = WWW::Mechanize->new();
my $url = 'http://localhost:42080/cgi-bin/conferences.cgi';
# Associate the mechanize object with a URL
$mech->get($url);
# Test for some content
xpath_ok($mech->content, '/', 'Conference Archive works');
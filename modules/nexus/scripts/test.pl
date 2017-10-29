#!/usr/bin/env perl

use strict;
use warnings;

use WWW::Mechanize;
use Test::HTML::Content (tests => 1);

# Create a new mechanize object
my $mech = WWW::Mechanize->new();
my $url = 'http://localhost:8081/nexus/';
# Associate the mechanize object with a URL
$mech->get($url);
# Test for the logo in the content of the URL
xpath_ok($mech->content, '/html/body/div[@id="header"]/div[@id="branding"]', 'Nexus HTML contains branding');
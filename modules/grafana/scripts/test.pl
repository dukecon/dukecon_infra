#!/usr/bin/env perl

use strict;
use warnings;

use WWW::Mechanize;
use Test::Simple tests => 1;

# Create a new mechanize object
my $mech = WWW::Mechanize->new();
my $url = 'http://localhost:3000/login';
# Associate the mechanize object with a URL
$mech->get($url);
# Test for the logo in the content of the URL
ok ("200" eq $mech->status(), "grafana is running");

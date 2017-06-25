#!/usr/bin/env perl

use strict;
use warnings;

use WWW::Mechanize;
use Test::Simple tests => 1;

# Create a new mechanize object
my $mech = WWW::Mechanize->new();
my $url = 'http://localhost:8086/ping';
# Associate the mechanize object with a URL
$mech->get($url);
# Test for the logo in the content of the URL
ok ("204" eq $mech->status(), "influxdb is running");
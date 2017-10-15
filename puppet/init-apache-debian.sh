#!/bin/bash

set -e

dir=`dirname $0`

if test -d /vagrant
   then dir=/vagrant
fi

sudo=/usr/bin/sudo
test -x $sudo || sudo=

test -d /etc/puppet/modules/apache || $sudo puppet module install --version 1.11.0 puppetlabs-apache

$sudo puppet apply $dir/puppet/manifests/apache.pp


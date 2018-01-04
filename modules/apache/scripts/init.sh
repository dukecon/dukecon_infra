#!/bin/bash

set -eu

dir=`dirname $0`

basedir="${dir}/.."

modulename=`dirname $basedir`
modulename=`dirname $modulename`
modulename=`basename $modulename`
cat<<EOM
======================================================================
Installing "${modulename}"
======================================================================
EOM

sudo=/usr/bin/sudo
test -x $sudo || sudo=

test -d /etc/puppetlabs/code/environments/production/modules/apache || $sudo /opt/puppetlabs/bin/puppet module install puppetlabs-apache

$sudo /opt/puppetlabs/bin/puppet apply ${basedir}/puppet/init.pp


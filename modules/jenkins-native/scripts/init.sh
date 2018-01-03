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

test -d /etc/puppetlabs/code/environments/production/modules/jenkins || $sudo /opt/puppetlabs/bin/puppet module install rtyler-jenkins --version '>=1.7.0'

# Set up Jenkins
$sudo /opt/puppetlabs/bin/puppet apply ${basedir}/puppet/init.pp

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

$sudo apt-get update
$sudo apt-get install -qq puppet

test -r /etc/puppet/modules/etckeeper || $sudo puppet module install thomasvandoren-etckeeper
test -r /etc/puppet/modules/stdlib || $sudo puppet module install puppetlabs-stdlib --version 4.12.0
test -r /etc/puppet/modules/apt || $sudo puppet module install --force puppetlabs-apt --version 2.3.0
test -r /etc/puppet/modules/inifile || $sudo puppet module install puppetlabs-inifile

$sudo puppet apply ${basedir}/puppet/init.pp

$sudo apt-get autoremove -y
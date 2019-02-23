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

#test -x /usr/local/bin/docker-compose || \
#  $sudo curl -L https://github.com/docker/compose/releases/download/1.18.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose

#export

$sudo FACTER_module_basedir=`realpath "${basedir}"` /opt/puppetlabs/bin/puppet apply ${PUPPET_DEBUG:-} ${basedir}/puppet/init.pp

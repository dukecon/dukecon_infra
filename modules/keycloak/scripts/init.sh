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

$sudo FACTER_module_basedir=`realpath "${basedir}"` /opt/puppetlabs/bin/puppet apply ${basedir}/puppet/init.pp

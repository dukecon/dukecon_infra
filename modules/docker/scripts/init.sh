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

# Avoid the following error 'Error: Error while evaluating a Function Call, Must pass update_defaults to Class[Apt]' - which seem to occur with apt module >= 3.0.0
test -r /etc/puppetlabs/code/environments/production/modules/apt || $sudo puppet module install puppetlabs-apt --version 2.4.0
test -r /etc/puppetlabs/code/environments/production/modules/docker || $sudo puppet module install garethr-docker

$sudo puppet apply ${basedir}/puppet/init.pp

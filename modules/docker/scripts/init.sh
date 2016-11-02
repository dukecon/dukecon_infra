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

<<<<<<< 6e7071f393d7b0dbc6dd2c7fa87d1cc992c79f0a
# Avoid the following error 'Error: Error while evaluating a Function Call, Must pass update_defaults to Class[Apt]' - which seem to occur with apt module >= 3.0.0
test -r /etc/puppet/modules/apt || $sudo puppet module install puppetlabs-apt --version 2.4.0
=======
>>>>>>> Starting to align with "devopssquare"
test -r /etc/puppet/modules/docker || $sudo puppet module install garethr-docker

$sudo puppet apply ${basedir}/puppet/init.pp

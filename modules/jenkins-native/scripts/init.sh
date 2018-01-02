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

test -d /etc/puppetlabs/code/environments/production/modules/maven || $sudo puppet module install maestrodev-maven
test -d /etc/puppetlabs/code/environments/production/modules/jenkins || $sudo puppet module install rtyler-jenkins

# This is the minimum DukeCon Docker application which is needed for Jenkins
$sudo puppet apply ${dir}/../../../puppet/manifests/docker-dukecon-latest.pp
# Set up Jenkins
$sudo puppet apply ${basedir}/puppet/init.pp

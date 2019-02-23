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

puppet_module() {
    dir=$1
    module=$2
    version=$3

    if test -r /etc/puppetlabs/code/environments/production/modules/${dir}; then
        $sudo /opt/puppetlabs/bin/puppet module upgrade --ignore-changes ${module} ${version}
    else
        $sudo /opt/puppetlabs/bin/puppet module install ${module} ${version}
    fi
}

puppet_module docker puppetlabs-docker "--version 3.1.0"

$sudo /opt/puppetlabs/bin/puppet apply ${basedir}/puppet/init.pp

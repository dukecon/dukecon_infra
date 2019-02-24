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
    options=$3

    if test -r /etc/puppetlabs/code/environments/production/modules/${dir}; then
        $sudo /opt/puppetlabs/bin/puppet module upgrade ${options} --ignore-changes ${module}
    else
        $sudo /opt/puppetlabs/bin/puppet module install ${options} ${module}
    fi
}

puppet_module jenkins rtyler-jenkins "--version >=1.7.0 --ignore-dependencies"

# Set up Jenkins
$sudo /opt/puppetlabs/bin/puppet apply ${basedir}/puppet/init.pp

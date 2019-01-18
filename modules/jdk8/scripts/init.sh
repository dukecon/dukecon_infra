#!/bin/bash

# Hotfix/TODO
unset LC_CTYPE

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
    
    if test -r /etc/puppetlabs/code/environments/production/modules/${dir}; then
        /opt/puppetlabs/bin/puppet module upgrade --ignore-changes ${module}
    else
        /opt/puppetlabs/bin/puppet module install ${module}
    fi
} 

puppet_module oraclejdk8 zuinnote-oraclejdk8

$sudo /opt/puppetlabs/bin/puppet apply ${basedir}/puppet/init.pp
# For some reason the first attempt fails very often if not always - so give it a second try
test -d /usr/lib/jvm/java-8-oracle || $sudo /opt/puppetlabs/bin/puppet apply ${basedir}/puppet/init.pp

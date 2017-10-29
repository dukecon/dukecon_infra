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

if test -r /vagrant/.vagrantenv
   then echo "Loading Vagrant environment"
        source /vagrant/.vagrantenv
fi

sudo=/usr/bin/sudo
if test -x $sudo
   then sudo="$sudo -E"
   else sudo=
fi

$sudo puppet apply "$basedir/puppet/init.pp"

set +u # Avoid hassles if $TEST_SKIP is not set!
if test -z "${TEST_SKIP}" -o "${TEST_SKIP}" != "false"
   then sleeptime=60
        echo "Sleeping ${sleeptime}s until Docker/Nexus is up and running"
        sleep $sleeptime
        $dir/test.pl
fi
set -u

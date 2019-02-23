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

if test -d /opt/puppetlabs; then
    $sudo apt-get update
else
    $sudo /bin/sh -c '
      cd /tmp \
      && wget https://apt.puppetlabs.com/puppet5-release-bionic.deb \
      && dpkg -i puppet5-release-bionic.deb \
      && apt-get update \
      && apt-get install -qq puppetserver \
      && /bin/rm -f puppet5-release-bionic.deb \
      '
fi

export PATH=$PATH:/opt/puppetlabs/bin

$sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade

puppet_module() {
    dir=$1
    module=$2
    options=${3:-}

    if test -r /etc/puppetlabs/code/environments/production/modules/${dir}; then
        $sudo /opt/puppetlabs/bin/puppet module upgrade ${options} --ignore-changes ${module}
    else
        $sudo /opt/puppetlabs/bin/puppet module install ${options} ${module}
    fi
}

puppet_module etckeeper thomasvandoren-etckeeper
puppet_module stdlib    puppetlabs-stdlib
puppet_module translate puppetlabs-translate "--version 1.1.0" # Needed for puppetlabs-docker
puppet_module apt       puppetlabs-apt # --version 2.4.0 # Needed for rtyler-jenkins in an optional subsequent step
puppet_module inifile   puppetlabs-inifile

$sudo /opt/puppetlabs/bin/puppet apply ${basedir}/puppet/init.pp

$sudo apt-get autoremove -y

$sudo sudo update-locale LANG=C LANGUAGE=C

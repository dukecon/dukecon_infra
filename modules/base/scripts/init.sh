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
      && wget https://apt.puppetlabs.com/puppet5-release-xenial.deb \
      && dpkg -i puppet5-release-xenial.deb \
      && apt-get update \
      && apt-get install -qq puppetserver \
      && /bin/rm -f puppet5-release-xenial.deb \
      '
fi

export PATH=$PATH:/opt/puppetlabs/bin

$sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade

test -r /etc/puppetlabs/code/environments/production/modules/etckeeper || $sudo /opt/puppetlabs/bin/puppet module install thomasvandoren-etckeeper
test -r /etc/puppetlabs/code/environments/production/modules/stdlib || $sudo /opt/puppetlabs/bin/puppet module install puppetlabs-stdlib
test -r /etc/puppetlabs/code/environments/production/modules/apt || $sudo /opt/puppetlabs/bin/puppet module install puppetlabs-apt --version 2.4.0 # Needed for rtyler-jenkins in an optional subsequent step
test -r /etc/puppetlabs/code/environments/production/modules/inifile || $sudo /opt/puppetlabs/bin/puppet module install puppetlabs-inifile

$sudo /opt/puppetlabs/bin/puppet apply ${basedir}/puppet/init.pp

$sudo apt-get autoremove -y

$sudo sudo update-locale LANG=C LANGUAGE=C
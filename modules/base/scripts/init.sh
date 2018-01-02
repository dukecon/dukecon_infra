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

$sudo /bin/sh -c '
  cd /tmp \
  && wget https://apt.puppetlabs.com/puppet5-release-xenial.deb \
  && dpkg -i puppet5-release-xenial.deb \
  && apt update \
  && apt-get install -qq puppetserver \
  && /bin/rm -f puppet5-release-xenial.deb \
  '

export PATH=$PATH:/opt/puppetlabs/bin

$sudo apt-get upgrade

test -r /etc/puppetlabs/code/environments/production/modules/etckeeper || $sudo /opt/puppetlabs/bin/puppet module install thomasvandoren-etckeeper
test -r /etc/puppetlabs/code/environments/production/modules/stdlib || $sudo /opt/puppetlabs/bin/puppet module install puppetlabs-stdlib
test -r /etc/puppetlabs/code/environments/production/modules/apt || $sudo /opt/puppetlabs/bin/puppet module install --force puppetlabs-apt
test -r /etc/puppetlabs/code/environments/production/modules/inifile || $sudo /opt/puppetlabs/bin/puppet module install puppetlabs-inifile

$sudo /opt/puppetlabs/bin/puppet apply ${basedir}/puppet/init.pp

$sudo apt-get autoremove -y
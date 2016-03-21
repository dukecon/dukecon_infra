#!/bin/bash

set -e

dir=`dirname $0`
if test -d /vagrant
   then dir=/vagrant
fi

sudo=/usr/bin/sudo
test -x $sudo || sudo=

test -d /etc/puppet/modules/maven || $sudo puppet module install maestrodev-maven
test -d /etc/puppet/modules/jenkins || $sudo puppet module install rtyler-jenkins
test -d /etc/puppet/modules/stdlib || $sudo puppet module install puppetlabs-stdlib

# This is the minimum DukeCon Docker application which is needed for Jenkins
$sudo puppet apply $dir/puppet/manifests/docker-dukecon-latest.pp
# Set up Jenkins
$sudo puppet apply $dir/puppet/manifests/jenkins.pp

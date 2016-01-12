#!/bin/bash

set -e

sudo=/usr/bin/sudo
test -x $sudo || sudo=

test -d /etc/puppet/modules/jenkins || $sudo puppet module install rtyler-jenkins
test -d /etc/puppet/modules/maven || $sudo puppet module install maestrodev-maven

$sudo puppet apply /vagrant/puppet/manifests/jenkins.pp

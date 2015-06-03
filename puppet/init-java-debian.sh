#!/bin/bash

set -e

sudo=/usr/bin/sudo
test -x $sudo || sudo=

test -d /etc/puppet/modules/java || $sudo puppet module install puppetlabs-java
$sudo puppet apply manifests/jdk.pp

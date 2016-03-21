#!/bin/bash

set -e

dir=`dirname $0`

sudo=/usr/bin/sudo
test -x $sudo || sudo=

test -r /etc/puppet/modules/docker || $sudo puppet module install garethr-docker
$sudo puppet apply $dir/puppet/manifests/docker-base.pp

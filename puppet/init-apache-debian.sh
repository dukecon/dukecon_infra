#!/bin/bash

set -e

sudo=/usr/bin/sudo
test -x $sudo || sudo=

test -d /etc/puppet/modules/apache || $sudo puppet module install puppetlabs-apache

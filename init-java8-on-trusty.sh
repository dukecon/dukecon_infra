#!/bin/bash

set -e

sudo=/usr/bin/sudo
test -x $sudo || sudo=

if ! test -d /usr/lib/jvm/java-8-oracle; then
    $sudo apt-get -y -q install software-properties-common htop
    if ! test -r /etc/apt/sources.list.d/webupd8team-java-trusty.list; then
        $sudo add-apt-repository ppa:webupd8team/java
        $sudo apt-get -y -q update
        $sudo etckeeper commit 'Added Oracle Java 8 repository'
    fi
    $sudo apt-get update
    $sudo apt-key update

    echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | $sudo /usr/bin/debconf-set-selections
    $sudo apt-get --force-yes -y -q install oracle-java8-installer
fi
$sudo update-java-alternatives -s java-8-oracle

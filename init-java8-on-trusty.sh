#!/bin/bash

set -e

sudo=/usr/bin/sudo
test -x $sudo || sudo=

$sudo apt-get -y -q update
$sudo apt-get -y -q upgrade
$sudo apt-get -y -q install software-properties-common htop
if ! test -r /etc/apt/sources.list.d/webupd8team-java-trusty.list; then
	$sudo add-apt-repository ppa:webupd8team/java
	$sudo apt-get -y -q update
	$sudo etckeeper commit 'Added Oracle Java 8 repository'
fi
echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | $sudo /usr/bin/debconf-set-selections
$sudo apt-get -y -q install oracle-java8-installer
$sudo update-java-alternatives -s java-8-oracle

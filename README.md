# Setup DukeCon Infrastructure

* Install vanilla Ubuntu 14.04 (LTS, "trusty", optionally run this in a Vagrant
box, see below)
* Perform the following actions as root in a locally checked out dukecon_infra repository

## Preparations

Check out the whole project into a suitable place on your system and change
your working directory to this place, e.g.,

    mkdir -p ~/wrk
    cd ~/wrk
    git clone https://github.com/dukecon/dukecon_infra.git
    cd dukecon_infra

The remaining steps are performed from this directory (unless mentioned otherwise).

## Vagrant box (optional)

For development and testing (or virtualization) purposes of the infrastructure we
provide a [Vagrant](http://vagrantup.com) box setup. This is optional, skip this
step if you want to install the overall infrastructure on a native Linux box.

Just run the following command to get the virtual box up and running

    vagrant up

This will print a lot of information to keep you informed about the progress.
You may even run into some problems (usually with etckeeper). In this case just
run the vagrant provisioning process again:

    vagrant provision

If everything is fine you can login to the new box:

    vagrant ssh

You will find all files in /vagrant directory of the box (your working directory
is mounted there).

    cd /vagrant

Proceed with the remaining steps from here.

TODO: Split up for development and production system

## Setup Puppet modules for EtcKeeper, Jenkins, Docker, Maven, ...

TODO: Split this up into separate scripts

    ./puppet/init-puppet-debian.sh
    ./puppet/init-puppet-docker-base.sh
    
Both implicitely call

    puppet apply puppet/manifests/debian.pp
    puppet apply puppet/manifests/docker-base.pp

## Setup Apache

    ./puppet/init-apache-debian.sh

Implicitely calls

    puppet apply puppet/manifests/apache.pp

## Setup Jenkins

    ./puppet/init-puppet-jenkins.sh

## Setup Java 8

    ./init-java8-on-trusty.sh

## Setup Docker based Nexus

TODO: Add these to scripts/puppet

    mkdir -p /data/sonatype
    chown 200:200 /data/sonatype
    cp -p scripts/nexus-security.sh ~/bin
    # Set new passwords for Nexus
    vi ~/bin/nexus-security.sh

    puppet apply puppet/manifests/docker-nexus.pp
    ~/bin/nexus-security.sh

## Setup Maven

You may run this as different user (not root, e.g. "jenkins")

    mkdir ~/.m2
    cp maven/settings-localhost.xml ~/.m2/settings.xml
    # Set deployment password from ~root/bin/nexus-security.sh
    vi ~/.m2/settings.xml

Run Maven to test it:

    mkdir ~/wrk
    cd ~/wrk
    git clone https://github.com/dukecon/dukecon_html5.git
    cd dukecon_html5
    mvn clean deploy

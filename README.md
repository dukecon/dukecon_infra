# Setup DukeCon Infrastructure

* Install vanilla Ubuntu 14.04 (LTS, "trusty")
* Perform the following actions as root in a locally checked out dukecon_infra repository

## Setup Puppet modules for EtcKeeper, Jenkins, Docker, Maven, ...

TODO: Split this up into separate scripts

    ./puppet/init-puppet-debian.sh
    puppet apply puppet/manifests/docker-base.pp

## Setup Apache

    ./puppet/init-apache-debian.sh
    puppet apply puppet/manifests/apache.pp

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
    cp maven/settings-local.xml ~/.m2/settings.xml
    # Set deployment password from ~root/bin/nexus-security.sh
    vi ~/.m2/settings.xml
    
Run Maven to test it:

    mkdir ~/wrk
    cd ~/wrk
    git clone https://github.com/jugda/dukecon_html5.git
    cd dukecon_html5
    mvn clean deploy

# -*- mode: ruby -*-
# vi: set ft=ruby :

name = "dukecon"
memory = 3072

Vagrant.configure(2) do |config|
  # Generic/Defaults
  config.vm.box = "ubuntu/trusty64"
  config.vm.hostname = name
  config.vm.synced_folder "cache/apt-archives", "/var/cache/apt/archives"

  config.vm.provider "virtualbox" do |vbox|
    vbox.name = name
    vbox.memory = memory
    # Docker
    # vbox.vm.network "forwarded_port", guest: 2375, host: 32375
    # Docker Registry
    # vbox.vm.network "forwarded_port", guest: 5000, host: 35000
    # Docker Registry UI
    # vbox.vm.network "forwarded_port", guest: 8080, host: 38080
  end

  config.vm.provider "parallels" do |parallels, override|
    override.vm.box = "parallels/ubuntu-14.04"
    parallels.name = name
    parallels.memory = memory
    override.vm.network "private_network", ip: "10.211.55.8"
  end

  config.vm.provision "shell", path: "puppet/init-puppet-debian.sh"

end

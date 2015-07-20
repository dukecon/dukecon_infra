# -*- mode: ruby -*-
# vi: set ft=ruby :

name = "dukecon"
memory = 2048
Vagrant.configure(2) do |dukecon|
  # Generic/Defaults
  dukecon.vm.box = "ubuntu/trusty64"

  dukecon.vm.provider "virtualbox" do |vbox|
    vbox.name = name
    vbox.memory = memory
    # Docker
    # vbox.vm.network "forwarded_port", guest: 2375, host: 32375
    # Docker Registry
    # vbox.vm.network "forwarded_port", guest: 5000, host: 35000
    # Docker Registry UI
    # vbox.vm.network "forwarded_port", guest: 8080, host: 38080
  end

  dukecon.vm.provider "parallels" do |parallels, override|
    override.vm.box = "parallels/ubuntu-14.04"
    parallels.name = name
    parallels.memory = memory
    parallels.vm.network "private_network", ip: "10.211.55.8"
  end

  dukecon.vm.provision "shell", path: "puppet/init-puppet-debian.sh"

end

# -*- mode: ruby -*-
# vi: set ft=ruby :

# Make sure to have the latest Vagrant installed (>=1.8), e.g., https://releases.hashicorp.com/vagrant/1.8.5/vagrant_1.8.5_x86_64.deb

composite = ENV['VAGRANT_COMPOSITE'] || "production"

name = ENV['VAGRANT_NAME'] || "dukecon-vagrant"
memory = ENV['VAGRANT_MEMORY'] || 3072

ip_unique = ENV['VAGRANT_IP_UNIQUE'] || "55"
port_unique = ENV['VAGRANT_PORT_UNIQUE'] || "55"

Vagrant.configure(2) do |config|
  # Generic/Defaults
  config.vm.hostname = name
  config.vm.synced_folder "cache/apt-archives", "/var/cache/apt/archives"
  config.vm.synced_folder ".", "/vagrant"

  config.vm.provider "docker" do |d|
    d.image = "ubuntu:18.04"
  end

  config.vm.provider "virtualbox" do |vbox, override|
    config.vm.box = "bento/ubuntu-18.04"
    vbox.name = name
    vbox.memory = memory
    # workaround for "NAT interface disconnected at startup"
    # https://github.com/hashicorp/vagrant/issues/7648
    vbox.customize ['modifyvm', :id, '--cableconnected1', 'on']
    override.vm.network "private_network", ip: "192.168.50.#{ip_unique}", virtualbox__intnet: true
    # Grafana (inspectIT)
    override.vm.network "forwarded_port", guest: 3000, host: "#{port_unique}030"
    # Docker Registry
    override.vm.network "forwarded_port", guest: 5000, host: "#{port_unique}050"
    # CMR Agent (inspectIT)
    override.vm.network "forwarded_port", guest: 9070, host: "#{port_unique}070"
    # Apache
    override.vm.network "forwarded_port", guest: 80, host: "#{port_unique}080"
    # Nexus
    override.vm.network "forwarded_port", guest: 8081, host: "#{port_unique}081"
    # InfluxDB (inspectIT)
    override.vm.network "forwarded_port", guest: 8086, host: "#{port_unique}086"
    # CMR Agent (inspectIT)
    override.vm.network "forwarded_port", guest: 8182, host: "#{port_unique}182"
    # Docker
    override.vm.network "forwarded_port", guest: 2375, host: "#{port_unique}375"
  end

  # Install libvirt provider: vagrant plugin install vagrant-libvirt
  config.vm.provider "libvirt" do |domain, override|
    override.vm.box = "baremettle/ubuntu-14.04"
    override.vm.hostname = name
    override.vm.network "private_network", ip: "10.211.42.#{ip_unique}", virtualbox__intnet: true
    prefix = name[name.index('-')+1..-1]
    domain.default_prefix = prefix
    # override.name = name
    domain.memory = memory
    domain.graphics_autoport = "no"
    domain.graphics_port = "59#{port_unique}"
  end

  config.vm.provision "shell", path: "composites/scripts/run.sh", args: composite
end

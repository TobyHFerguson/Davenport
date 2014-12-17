# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.hostmanager.enabled = true
  config.hostmanager.include_offline = true # Add up boxes or boxes with private network to 

  config.vm.define "dhcp" do |d|
    d.vm.box = "ol6minimal"
    d.vm.network "private_network", ip: "192.168.50.3"
  end

  config.vm.define "oemrepo" do |db|
    db.vm.box = "ol6minimal"
    db.vm.hostname = "oemrepo.lab.net"
    db.vm.network "private_network", ip: "192.168.50.4"
    db.vm.provision "shell", path: ".oemrepo/oemrepo_setup.sh", privileged: false
  end

  config.vm.define "stage" do |s|
    s.vm.box = "ol6minimal"
    s.vm.network "private_network", ip: "192.168.50.6"
  end

  config.vm.define "tftp" do |t|
    t.vm.box = "ol6minimal"
    t.vm.network "private_network", ip: "192.168.50.7"
  end
  # config.vm.define "yum" do |y|
  #   y.vm.box = "ol6minimal"
  #   y.vm.network "private_network", ip: "192.168.50.8"
  # end
  end

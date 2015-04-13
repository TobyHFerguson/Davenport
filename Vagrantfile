# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # ##########
  # Configuration shared by all vms
  # All vms use the same underlying box image
  config.vm.box = "ol6u5-minimal-btrfs-uek"
  config.vm.box_url = "http://tobyhferguson.org/boxes/ol6u5-minimal-btrfs-uek.box"

  # Manage hostnaming on all vms
   config.hostmanager.enabled = true
   config.hostmanager.include_offline = true # Add up boxes or boxes with private network to /etc/hosts on active hosts
   # Update the public-yum-ol6.repo file to the latest one
   config.vm.provision "update_repo_file", type: "shell", inline: "curl --silent http://public-yum.oracle.com/public-yum-ol6.repo >/etc/yum.repos.d/public-yum-ol6.repo"
   # Update the OS
   config.vm.provision "yum_update", type: "shell", inline: "yum -q -y update"
   # ##########
   
  # OEMREPO
  config.vm.define "oemrepo" do |db|
    db.vm.hostname = "oemrepo.lab.net"
    db.vm.network "private_network", ip: "192.168.50.4"
    db.vm.provision "oemrepo_setup", type: "shell", path: ".oemrepo/oemrepo_setup.sh", privileged: false
    # OMS requires that the DB have plenty of RAM for performance reasons. I'll give it 2G and see how we do!
    db.vm.provider "virtualbox" do |v|
      v.memory = 2048
    end  
  end

  # OMS
  config.vm.define "oms" do |oms|
    oms.vm.hostname = "oms.lab.net"
    oms.vm.network "private_network", ip: "192.168.50.5"

    # oms runs a webserver on 7802 - forward it out for external access:
    oms.vm.network "forwarded_port", guest: 7802, host: 17802

    # Enterprise Manager requires at least 3G of RAM (3072M). Need to allocate more because VirtualBox eats 40M (I think). Therefore need to allocate 4102M - make it 3G5 (3584M)
    oms.vm.provider "virtualbox" do |v|
      v.memory = 3584
    end

    oms.vm.provision "setup", type: "shell", path: ".oms/setup.sh", privileged: false
    oms.vm.provision "make_agent_pull", type: "shell", path: ".oms/make_agent_pull.sh"
    oms.vm.provision "generate_agent", type: "shell", path: ".oms/generate_agent.sh"
    oms.vm.provision "start_oms", type: "shell", inline: "service gcstartup start", run: "always"
  end

   # DHCP
  config.vm.define "dhcp" do |x|
    x.vm.hostname="dhcp.lab.net"
    x.vm.network "private_network", ip: "192.168.50.3"
    x.vm.provision "provision_as_managed_server", type: "shell", path: ".common/provision_as_managed_server.sh"
    x.vm.provision "setup", type: "shell", path: ".dhcp/setup.sh", privileged: false
  end

  # STAGE
  config.vm.define "stage" do |x|
    x.vm.hostname = "stage.lab.net"
    x.vm.network "private_network", ip: "192.168.50.6"
    x.vm.provision "provision_as_managed_server", type: "shell", path: ".common/provision_as_managed_server.sh"
    x.vm.provision "setup", type: "shell", path: ".stage/setup.sh"
  end

  # TFTP
  config.vm.define "tftp" do |x|
    x.vm.hostname = "tftp.lab.net"
    x.vm.network "private_network", ip: "192.168.50.7"
    x.vm.provision "provision_as_managed_server", type: "shell", path: ".common/provision_as_managed_server.sh"
    x.vm.provision "setup", type: "shell", path: ".tftp/setup.sh"    
  end

  # YUM
  config.vm.define "yum" do |x|
    x.vm.hostname = "yum.lab.net"
    x.vm.network "private_network", ip: "192.168.50.8"
    x.vm.provision "provision_as_managed_server", type: "shell", path: ".common/provision_as_managed_server.sh"
    x.vm.provision "setup", type: "shell", path: ".yum/setup.sh" 
  end

end

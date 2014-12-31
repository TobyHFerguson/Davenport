# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # Manage hostnaming on all vms
   config.hostmanager.enabled = true
   config.hostmanager.include_offline = true # Add up boxes or boxes with private network to /etc/hosts on active hosts
   # Update the public-yum-ol6.repo file to the latest one
   config.vm.provision "update_repo_file", type: "shell", inline: "curl --silent http://public-yum.oracle.com/public-yum-ol6.repo >/etc/yum.repos.d/public-yum-ol6.repo"
   # Update the OS
   config.vm.provision "yum_update", type: "shell", inline: "yum -q -y update"
  
  # OEMREPO
  config.vm.define "oemrepo" do |db|
    db.vm.box = "ol6minimal"
    db.vm.hostname = "oemrepo.lab.net"
    db.vm.network "private_network", ip: "192.168.50.4"
    db.vm.provision "db_service", type: "shell", path: ".oemrepo/oemrepo_setup.sh", privileged: false
    # OMS requires that the DB have plenty of RAM for performance reasons. I'll give it 2G and see how we do!
    db.vm.provider "virtualbox" do |v|
      v.memory = 2048
    end  
  end

  # OMS
  config.vm.define "oms" do |oms|
    oms.vm.box = "ol6minimal"
    oms.vm.hostname = "oms.lab.net"
    oms.vm.network "private_network", ip: "192.168.50.5"

    # oms runs a webserver on 7802 - forward it out for external access:
    oms.vm.network "forwarded_port", guest: 7802, host: 17802

    # Enterprise Manager requires at least 3G of RAM (3072M). Need to allocate more because VirtualBox eats 40M (I think). Therefore need to allocate 4102M - make it 3G5 (3584M)
    oms.vm.provider "virtualbox" do |v|
      v.memory = 3584
    end

    oms.vm.provision "oms_service", type: "shell", path: ".oms/setup.sh", privileged: false
    oms.vm.provision "make_agent_pull", type: "shell", path: ".oms/make_agent_pull.sh"
    oms.vm.provision "make_agent_rpm", type: "shell", path: ".oms/generate_agent.sh"
    oms.vm.provision "start_oms", type: "shell", inline: "service gcstartup start", run: "always"
  end

   # DHCP
  config.vm.define "dhcp" do |d|
    d.vm.box = "ol6minimal"
    d.vm.hostname="dhcp.lab.net"
    d.vm.network "private_network", ip: "192.168.50.3"
    d.vm.provision "managed_server", type: "shell", path: ".common/provision_as_managed_server.sh"
    d.vm.provision "dhcp_service", type: "shell", path: ".dhcp/setup.sh", privileged: false
  end

  # STAGE
  config.vm.define "stage" do |s|
    s.vm.box = "ol6minimal"
    s.vm.hostname = "stage.lab.net"
    s.vm.network "private_network", ip: "192.168.50.6"
    s.vm.provision "managed_server", type: "shell", path: ".common/provision_as_managed_server.sh"
    s.vm.provision "stage_service", type: "shell", path: ".stage/setup.sh"
  end

  # TFTP
  config.vm.define "tftp" do |t|
    t.vm.box = "ol6minimal"
    t.vm.hostname = "tftp.lab.net"
    t.vm.network "private_network", ip: "192.168.50.7"
    t.vm.provision "managed_server", type: "shell", path: ".common/provision_as_managed_server.sh"
    t.vm.provision "tftp_service", type: "shell", path: ".tftp/setup.sh"    
  end

  # YUM
  config.vm.define "yum" do |y|
    y.vm.box = "ol6minimal"
    y.vm.hostname = "yum.lab.net"
    y.vm.network "private_network", ip: "192.168.50.8"
    y.vm.provider "virtualbox" do |v|
      v.customize [ "modifyvm", :id, "--boot1", "disk"]
      v.customize [ "storageattach", :id, "--storagectl", "SATA", "--port", "1", "--device", "0", "--type", "dvddrive", "--medium", "ol6.iso" ]
    end
    y.vm.provision "managed_server", type: "shell", path: ".common/provision_as_managed_server.sh"
    y.vm.provision "yum_service", type: "shell", path: ".yum/setup.sh" 
  end

end

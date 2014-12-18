#!/bin/bash
# update the image
sudo yum -q -y upgrade

. /vagrant/.common/oem_agent_packages

# We need the oem_agent_packages so that we can be managed
# and the dnsmasq package to provide dhcp service

sudo yum -q -y install ${oem_agent_packages[*]} dnsmasq

# use the configuration file and then restart dnsmasq
sudo cp -f /vagrant/.dhcp/dnsmasq.conf /etc/dnsmasq.conf
sudo chkconfig --add dnsmasq
sudo service dnsmasq start

# Update iptables so that the service can be accessed
sudo iptables -I INPUT -i eth1 -p udp --dport 67 -j ACCEPT
sudo iptables save

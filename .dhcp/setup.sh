#!/bin/bash
# Install dhcp service specific packages
sudo yum -q -y install dnsmasq

# use the configuration file and then restart dnsmasq
sudo cp -f /vagrant/.dhcp/dnsmasq.conf /etc/dnsmasq.conf
sudo chkconfig --add dnsmasq
sudo service dnsmasq start

# Update iptables so that the service can be accessed
sudo iptables -I INPUT -i eth1 -p udp --dport 67 -j ACCEPT
sudo service iptables save

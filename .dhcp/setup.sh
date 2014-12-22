#!/bin/bash
# Install dhcp service specific packages
rpm --quiet -q dnsmasq || sudo yum -q -y install dnsmasq

# Copy in the configuration file
sudo cp -f /vagrant/.dhcp/dnsmasq.conf /etc/dnsmasq.conf
# Take care of dnsmasq as a service
sudo chkconfig dnsmasq on
sudo service dnsmasq start

# Update iptables so that the service can be accessed on port 67
# Update iptables iff they need to be updated
sudo iptables -L INPUT | grep 'dpt:67' || {
    sudo iptables -I INPUT -i eth1 -p udp --dport 67 -j ACCEPT
    sudo service iptables save
    }

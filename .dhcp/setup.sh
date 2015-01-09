#!/bin/bash
# Install dhcp service specific packages
rpm --quiet -q dnsmasq || sudo yum -q -y --disablerepo='*' --enablerepo='*ol6_latest' install dnsmasq

# Copy in the configuration file
sudo cp -f /vagrant/.dhcp/dnsmasq.conf /etc/dnsmasq.conf

# Ensure /etc/hosts has the correct SELINUX context
#restorecon /etc/hosts
# It looks like hostmanager will keep breaking the SELINUX context of /etc/hosts
# so, for now, simply turn off SELINUX
sudo setenforce 0

# Take care of dnsmasq as a service
sudo chkconfig dnsmasq on
sudo service dnsmasq start

# Update iptables so that the bootps service can be accessed on port 67
# and the DNS service on port 53 (default ports for each)

# Update iptables iff they need to be updated
sudo iptables -L INPUT | grep 'dpt:bootps' || {
    sudo iptables -I INPUT -i eth1 -p udp --dport bootps -j ACCEPT
    sudo iptables -I INPUT -i eth1 -p udp --dport domain -j ACCEPT
    sudo service iptables save
    }

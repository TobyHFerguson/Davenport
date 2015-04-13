#!/bin/bash
# Install dhcp service specific packages
rpm --quiet -q dnsmasq || sudo yum -q -y --disablerepo='*' --enablerepo='*ol6_latest' install dnsmasq

# Copy in the configuration file
sudo cp -f /vagrant/.dhcp/dnsmasq.conf /etc/dnsmasq.conf

# Ensure /etc/hosts has the correct SELINUX context
#restorecon /etc/hosts
# It looks like hostmanager will keep breaking the SELINUX context of /etc/hosts
# so, for now, simply turn off SELINUX
sudo sed -i 's/SELINUX=enforcing/SELINUX=permissive/' /etc/sysconfig/selinux
sudo setenforce 0

# Take care of dnsmasq as a service
sudo chkconfig dnsmasq on
sudo service dnsmasq start

# Update iptables so that the bootps service and domain services can be accessed iff necessary
sudo iptables -L INPUT | grep 'dpt:bootps' || {
    sudo iptables -I INPUT -i eth1 -p udp --dport bootps -j ACCEPT
    sudo iptables -I INPUT -i eth1 -p udp --dport domain -j ACCEPT
    sudo service iptables save
    }

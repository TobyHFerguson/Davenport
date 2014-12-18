#!/bin/bash
# Yum requires httpd

yum -y install httpd

service httpd start
chkconfig httpd on
mkdir /var/www/html/ol6
mount -o loop /vagrant/ol6.iso /var/www/html/ol6

iptables -I INPUT -p tcp --dport 80 -m state --state NEW -j ACCEPT
service iptables save

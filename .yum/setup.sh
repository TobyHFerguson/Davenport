#!/bin/bash
# Yum requires httpd
yum -q -y --disablerepo='*' --enablerepo='*ol6_latest' install httpd

# Setup the httpd conf file properly
sed -i 's/^#ServerName.*80/ServerName yum.lab.net:80/' /etc/httpd/conf/httpd.conf

service httpd start
chkconfig httpd on


readonly CONTEXT_DIR=/var/www/html/ol6

# Update the /etc/fstab if necessary and mount the iso image
mkdir -p ${CONTEXT_DIR:?}
grep -q ${CONTEXT_DIR:?} /etc/fstab || {
     echo -e "/vagrant/ol6.iso\t${CONTEXT_DIR:?}\tiso9660\tloop,ro\t0 0\n" >>/etc/fstab
     mount -a
     }

# Update the iptables iff necessary
iptables -L INPUT -n | grep -q dpt:80 || {
    iptables -I INPUT -p tcp --dport 80 -m state --state NEW -j ACCEPT
    service iptables save
    }

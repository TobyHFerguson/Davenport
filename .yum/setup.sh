#!/bin/bash
# Yum requires httpd
yum -q -y --disablerepo='*' --enablerepo='*ol6_latest' install httpd

# Setup the httpd conf file properly
sed -i 's/^#ServerName.*80/ServerName yum.lab.net:80/' /etc/httpd/conf/httpd.conf

service httpd start
chkconfig httpd on


readonly CONTEXT_DIR=ol6
readonly ISO=/dev/sr0
readonly ISO_IMAGE_DIR=/media/ol6

# Update the /etc/fstab if necessary and mount the iso image
mkdir -p ${ISO_IMAGE_DIR:?}
 grep -q ${ISO:?} /etc/fstab || {
     echo -e "${ISO:?}\t${ISO_IMAGE_DIR:?}\tauto\tro\t0 0\n" >>/etc/fstab
     mount -a
     }
# Expose the iso image directory via the web
ln -fs ${ISO_IMAGE_DIR:?} /var/www/html/${CONTEXT_DIR:?}

# Update the iptables iff necessary
iptables -L INPUT -n | grep -q dpt:80 || {
    iptables -I INPUT -p tcp --dport 80 -m state --state NEW -j ACCEPT
    service iptables save
    }

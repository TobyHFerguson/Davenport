#!/bin/bash

# Install tftp service specific packages

yum -q -y --disablerepo='*' --enablerepo=ol6_latest install tftp-server syslinux-tftpboot

# Unfortunately the above two packages don't agree on where the tftpdir should live
# Bind mount them to one location!
# Ensure /tfptboot is owned by oracle, thus allowing a less privileged user to perform BMP
install --owner oracle --group oinstall -d /tftpboot
# ensure that the selinux context is set correctly
restorecon -R /tftpboot/

grep -q tftpboot /etc/fstab || {
    echo "/var/lib/tftpboot /tftpboot none bind" >>/etc/fstab
    mount -a
    }

# enable tftp launch from xinetd
sed -i '/disable/s/yes/no/' /etc/xinetd.d/tftp

# configure iptables
# First, add connection tracking (for explanation, see here: http://packetzone.wordpress.com/2013/10/31/how-to-setup-a-tftp-server-under-centosrhel-6/)

sed -i 's/IPTABLES_MODULES=""/IPTABLES_MODULES="ip_conntrack_tftp"/' /etc/sysconfig/iptables-config

# Secondly, add rules to iptables and restart
iptables -I INPUT -p udp --dport 69 -s 192.168.50.0/24 -j ACCEPT
service iptables save
service iptables restart


# Ensure xinetd is running, and after reboot
service xinetd start
chkconfig xinetd on

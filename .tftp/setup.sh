#!/bin/bash

# Install tftp service specific packages
# tftp-server installs a tftp server attached to xinetd, serving files out of /var/lib/tftpboot
# syslinux-tftpboot provides all the syslinux files (such as pxelinux.0) that implement PXE

rpm --quiet -q tftp-server syslinux-tftpboot || yum -q -y --disablerepo='*' --enablerepo=ol6_latest install tftp-server syslinux-tftpboot

# We want to enable the 'oracle' user to be able to provision to the boot server
# Thus we change the ownership of the /var/lib/tftpboot dir and its contents

chown --recursive oracle:oinstall /var/lib/tftpboot

# We want to be able to use /tftpboot as the location of the directory
# so we create that directory, update /etc/fstab to bind mount it as necessary
mkdir -p /tftpboot

grep -q tftpboot /etc/fstab || {
    echo "/var/lib/tftpboot /tftpboot none bind" >>/etc/fstab
}

# Ensure that the bind mount is performed
mount -a

# enable tftp launch from xinetd
sed -i '/disable/s/yes/no/' /etc/xinetd.d/tftp

# configure iptables
# First, add connection tracking (for explanation, see here: http://packetzone.wordpress.com/2013/10/31/how-to-setup-a-tftp-server-under-centosrhel-6/)

sed -i 's/IPTABLES_MODULES=""/IPTABLES_MODULES="ip_conntrack_tftp"/' /etc/sysconfig/iptables-config

# Secondly, add rules to iptables and restart
iptables -L INPUT -n | grep --quiet dpt:69 || {
    iptables -I INPUT -p udp --dport 69 -s 192.168.50.0/24 -j ACCEPT
    service iptables save
    service iptables restart
    }


# Ensure xinetd is running, and after reboot
service xinetd start
chkconfig xinetd on

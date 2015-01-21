packages=(wget rpcbind nfs-utils)
# Stage service specific operations
rpm --quiet -q ${packages[*]} || yum -q -y install ${packages[*]}

# Update iptables (according to http://mcdee.com.au/tutorial-configure-iptables-for-nfs-server-on-centos-6/)

# Firstly, edit the NFS port definitions file:
sed -i -e 's/#\(LOCKD_.*\)/\1/' -e 's/#\(MOUNTD_PORT.*\)/\1/' /etc/sysconfig/nfs

# Secondly, update the iptables (only iff necessary)
iptables -L INPUT -n | grep --quiet 111 || {
    iptables -I INPUT -m state --state NEW -p tcp -m multiport --dport 111,892,2049,32803 -j ACCEPT
    iptables -I INPUT -m state --state NEW -p udp -m multiport --dport 111,892,2049,32803 -j ACCEPT
    service iptables save
    service iptables restart
    }


# Expose stage directory via nfs
export STAGE_DIR=/stage
install --owner oracle --group oinstall -d ${STAGE_DIR:?}
grep --silent "${STAGE_DIR:?}" /etc/exports || echo "${STAGE_DIR:?} *(ro,sync)" >>/etc/exports


# Ensure services are running and will run after a reboot
service rpcbind start
chkconfig rpcbind on
service nfs start
chkconfig nfs on

# iff the shared agent rpm is newer than the one in the /stage directory, or there isn't an agent rpm in that directory, copy it in
RPM=oracle-agt-12.1.0.4.0-1.0.x86_64.rpm
SRC=/vagrant/${RPM:?}
DEST=/stage/${RPM:?}
# Copy in the agent rpm if the source is newer
if [[ ${SRC:?} -nt ${DEST:?} ]] 
then 
    install --mode 444 ${SRC:?} /stage
fi


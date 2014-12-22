# Stage service specific operations
yum -q -y install wget rpcbind nfs-utils

# Expose stage directory via nfs
export STAGE_DIR=/stage
install --owner oracle --group oinstall -d ${STAGE_DIR:?}
echo "${STAGE_DIR:?} *(ro,sync)" >>/etc/exports

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
[[ ${SRC:?} -nt ${DEST:?} ]] &&  install --mode 444 ${SRC:?} /stage


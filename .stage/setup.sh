# Stage service specific operations
yum -y install wget rpcbind nfs-utils

# Expose stage directory via nfs
export STAGE_DIR=/stage
install --owner oracle --group oracle -d ${STAGE_DIR:?}
echo "${STAGE_DIR:?} *(ro,sync)" >>/etc/exports

# Ensure needed services start at boot time
chkconfig rpcbind on
chkconfig nfs on

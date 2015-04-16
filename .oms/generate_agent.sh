#!/bin/bash
# copy or generate the agent RPM as necessary, and then copy it to the shared directory
AGENT_RPM=oracle-agt-12.1.0.4.0-1.0.x86_64.rpm
BASE_DIR=/usr/lib/oracle
SRC_DIR=${BASE_DIR:?}/RPMS/x86_64
TMP_DIR=/tmp/agentimage
DEST_DIR=/vagrant
# ensure directories are available, with correct permissions (this corrects a bug in the OEM installation)
install --owner oracle -d ${BASE_DIR:?}



usermod -a -G vagrant oracle

if [ -f ${DEST_DIR:?}/${AGENT_RPM:?} ] # does final RPM exist?
then
    :				       # yes - do nothing
else
    if [ -f ${TMP_DIR:?}/${AGENT_RPM:?} ] # no final RPM, is there one in TMP_DIR?
    then				  # yes - copy it to the dest dir
	cp ${TMP_DIR:?}/${AGENT_RPM:?} ${DEST_DIR:?}/${AGENT_RPM:?}
    else
	if [ -f ${SRC_DIR:?}/${AGENT_RPM:?} ] # not one in TMP_DIR - is there an internal copy?
	then				# yes - then copy it to the destination directory
	    cp ${SRC_DIR:?}/${AGENT_RPM:?} ${DEST_DIR:?}/${AGENT_RPM:?}
	else			# no - generate the rpm into the TMP_DIR and copy to the destination directory
	    echo 'Generating agent RPM. This takes around 10 minutes'
	    # Ensure TMP_DIR is empty, and writable by oracle user
	    rm -rf ${TMP_DIR:?}
	    install --owner oracle -d ${TMP_DIR:?}
	    su -c "emcli get_agentimage_rpm -destination=${TMP_DIR:?} -platform='Linux x86-64'" - oracle
	    cp ${TMP_DIR:?}/${AGENT_RPM:?} ${DEST_DIR:?}
	fi
	chown vagrant:vagrant ${DEST_DIR:?}/${AGENT_RPM:?}
    fi
fi


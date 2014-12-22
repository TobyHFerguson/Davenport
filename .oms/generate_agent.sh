#!/bin/bash
# copy or generate the agent RPM as necessary, and then copy it to the shared directory
AGENT_RPM=oracle-agt-12.1.0.4.0-1.0.x86_64.rpm
BASE_DIR=/usr/lib/oracle
SRC_DIR=${BASE_DIR:?}/RPMS/x86_64
DEST_DIR=/vagrant
# ensure directories are available, with correct permissions (this corrects a bug in the OEM installation)
install --owner oracle -d ${BASE_DIR:?}

install --owner oracle -d ${DEST_DIR:?}
usermod -a -G vagrant oracle

if [ -f ${DEST_DIR:?}/${AGENT_RPM:?} ] # does final RPM exist?
then				       # yes - do nothing
elif [ -f ${SRC_DIR:?}/${AGENT_RPM:?} ] # no - is there an internal copy?
    then				# yes - then copy it to the destination directory
	cp ${SRC_DIR:?}/${AGENT_RPM:?} ${DEST_DIR:?}/${AGENT_RPM:?}
    else			# no - generate the rpm into the destination directory
	echo 'Generating agent RPM. This takes around 10 minutes'
	su -c "emcli get_agentimage_rpm -destination=${DEST_DIR:?} -platform='Linux x86-64'" - oracle
    fi
    chown vagrant:vagrant ${DEST_DIR:?}/${AGENT_RPM:?}
fi


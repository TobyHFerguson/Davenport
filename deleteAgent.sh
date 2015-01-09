#!/bin/bash -x
# Script for deleting a host agent and all its managed targets
# $1 must be the Fully Qualified Domain Name of the host to be deleted.

usage() {
    echo "useage: deleteAgent.sh hostname" 1>&2
}
[ $# -ne 1 ] && { usage; exit 1; }

readonly HOST_NAME=$1



STATUS=$(emcli get_targets -target=oracle_emd | grep ${HOST_NAME:?}) || { 
    # No agent found - do nothing
    exit; }
AGENT=$(echo $STATUS | sed -n "/${HOST_NAME:?}/s/.*\(${HOST_NAME:?}.*\)/\1/p")
[ "$(echo $STATUS | awk '{ print $2 }')" = "Up" ] && {
    emcli stop_agent -agent_name=$AGENT -credential_setname=HostCreds
    }

emcli delete_target -name=$AGENT  -type=oracle_emd -delete_monitored_targets

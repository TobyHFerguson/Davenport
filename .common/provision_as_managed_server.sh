#!/bin/bash
# Provision agent to server
[ -f /u01/agent12cR4/core/12.1.0.4.0/root.sh ] || {
    echo 'Installing Agent - this will take about 5 minutes'
    install --owner oracle --group oinstall -d /u01
    su -c '/vagrant/agentpull.sh RSPFILE_LOC=/vagrant/.common/agent.rsp' - oracle && {
	/u01/agent12cR4/core/12.1.0.4.0/root.sh
	/u01/app/oraInventory/orainstRoot.sh
    }
}

# Port 3872 is how the OMS contacts the agent
iptables -L INPUT -n | grep --silent 3872 || {
    iptables -I INPUT -p tcp -m state --state NEW -m multiport --dports 3872,1830:1849 -j ACCEPT
    service iptables save
}



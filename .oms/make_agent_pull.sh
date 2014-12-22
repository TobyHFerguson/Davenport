#!/bin/bash
# generate the agentpull.sh file if it hasn't already been made
[ ! -f /vagrant/agentpull.sh ] && {
    curl --silent https://localhost:7802/em/install/getAgentImage --insecure |
	sed 's/-S/-S -s/' >/vagrant/agentpull.sh
    chmod +x /vagrant/agentpull.sh
}

# Agents 'phone home' on 1159, or 4899-4908 - so those ports need opening up
# Open up these ports if they're not already open
iptables -L INPUT -n | grep 4899:4908 || {
    iptables -I INPUT -m state --state NEW -m multiport -p tcp --dports 1159,4899:4908
    service iptables save
}

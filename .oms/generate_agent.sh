# Generate the agent RPM if necessary, and then copy it to stage

#
# Correct permissions issues
sudo install --owner oracle -d /usr/lib/oracle
sudo install --owner oracle -d /tmp/OMSAgentRPM
sudo su -c '[ ! -f /tmp/OMSAgentRPM/oracle-agt-12.1.0.4.0-1.0.x86_64.rpm ] && {
echo "generating agent RPM - this takes around 10 minutes"; emcli get_agentimage_rpm -destination=/tmp/OMSAgentRPM -platform="Linux x86-64"; }' - oracle
sudo chmod --recursive a+r /tmp/OMSAgentRPM
scp /tmp/OMSAgentRPM/oracle-agt-12.1.0.4.0-1.0.x86_64.rpm oracle@stage.lab.net:/stage

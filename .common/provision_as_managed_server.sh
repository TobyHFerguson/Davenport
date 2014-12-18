# A managed server has a specific set of packages and an oracle user
. /vagrant/.common/oem_agent_packages
sudo yum -y install ${oem_agent_packages[*]}
# configure oracle user for agent access
sudo useradd -U -m oracle
echo oracle | sudo passwd --stdin oracle
# configure oracle user's sudo access
sudo install --mode 440 --owner root --group root /vagrant/.oms/sudo_oracle /etc/sudoers.d
# configure sudo so that it can be used by Enterprise Manager
sudo sed -i -e '/requiretty$/s/^/#/' -e'/visiblepw$/s/!//'  /etc/sudoers
# Create the oracle software directory
sudo install -o oracle -g oracle -d /u01



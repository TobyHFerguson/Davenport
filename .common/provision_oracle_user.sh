# configure oracle user for agent access
echo oracle | sudo passwd --stdin oracle
# configure oracle user's sudo access
sudo install --mode 440 --owner root --group root /vagrant/.oms/sudo_oracle /etc/sudoers.d
# configure sudo so that it can be used by Enterprise Manager
sudo sed -i -e '/requiretty$/s/^/#/' -e'/visiblepw$/s/!//'  /etc/sudoers
# Create the oracle software directory
sudo install -o oracle -g oinstall -d /u01

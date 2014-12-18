#!/bin/bash

# update the image
sudo yum -q -y update

# Install needed packages
declare -a packages

# glibc for OMS
packages=(glibc-devel.x86_64 glibc-devel.i686)
# Packages needed by OMS Agent
packages+=(bc)
packages+=(make)
packages+=(zip)
packages+=(unzip)
# packages needed for ssh -X access
packages+=(xorg-x11-xauth)		# for authorisation
packages+=(xorg-x11-utils)		# for /usr/bin/xdpyinfo - to figure out the colors
# packages needed for OEM Management Agent
packages+=(openssh-clients)
packages+=(binutils)
packages+=(gcc)
packages+=(libaio)
packages+=(glibc-common)
packages+=(libstdc++)
packages+=(sysstat)
# rpm-build needed to construct the agent rpm
packages+=(rpm-build)

sudo yum -q -y install ${packages[*]}

# configure oracle user
sudo useradd -U -m oracle
echo oracle | sudo passwd --stdin oracle
# configure oracle user's sudo access
sudo install --mode 440 --owner root --group root /vagrant/.oms/sudo_oracle /etc/sudoers.d
# configure sudo so that it can be used by Enterprise Manager
sudo sed -i -e '/requiretty$/s/^/#/' -e'/visiblepw$/s/!//'  /etc/sudoers
# Create the oracle software directory
sudo install -o oracle -g oracle -d /u01
# Configure oracle user for ssh access
sudo cp --recursive ~vagrant/.ssh ~oracle
sudo chown --recursive oracle:oracle ~oracle
# Configure oracle's environment
sudo su -c 'cat /vagrant/.oms/oracle_profile  >>/home/oracle/.bash_profile' - oracle

# Create the directories in which the oms and the agent are to be installed.
sudo su -c "mkdir -p /u01/app/oracle/product/12cr4/Middleware" - oracle
sudo su -c "mkdir -p /u01/app/oracle/agent12cr4" - oracle
sudo install -o oracle -g oracle -d /u01/app/oracle/swlib
sudo chown --recursive oracle:oracle /u01

# Change File Descriptor limits (both hard and soft) to 16384 for oracle user. Needed by WebLogic
sudo su -c 'echo -e "oracle\t-\tnofile\t16384" >>/etc/security/limits.conf' - root

# setup firewall so we can access the OMS remotely
sudo iptables -I  INPUT -m state --state NEW -p tcp --dport 7802 -j ACCEPT
sudo service iptables save

# Check that the oem_install directory exists. Exit if it doesn't
[ -d /vagrant/oem_install ] || {
    cat - 1>&2 <<EOF
Can't find the directory "oem_install" in the current directory. 
Please unzip the OEM Installation Zip files into "oem_install", like this:
unzip -u -d oem_install /path/to/V45344-01.zip
unzip -u -d oem_install /path/to/V45345-01.zip
unzip -u -d oem_install /path/to/V45346-01.zip
EOF
}

# Install the OEM software
sudo su -c '/vagrant/oem_install/runInstaller -silent -waitforcompletion -responsefile /vagrant/.oms/oem.rsp' - oracle

#Execute the root scripts
sudo /u01/app/oraInventory/orainstRoot.sh
sudo /u01/app/oracle/product/12cr4/Middleware/oms/allroot.sh

# After the installation copy the setup file:
sudo cp /u01/app/oracle/product/12cr4/Middleware/oms/install/setupinfo.txt /vagrant/oem_setupinfo.txt

echo "Read oem_setupinfo.txt to find out how to connect to oem"

# Install emcli locally
sudo su -c 'mkdir ~/emcli_home' - oracle
curl --insecure https://localhost:7802/em/public_lib_download/emcli/kit/emclikit.jar >/tmp/emclikit.jar
sudo su -c 'java -jar -jar /tmp/emclikit.jar -install_dir=/home/oracle/emcli_home' - oracle
sudo su -c 'emcli setup -url=https://localhost:7802/em -username=sysman -password=Welcome1 -trustall -autologin' - oracle

# Create the named credentials ORACLE_NC and ROOT_NC
sudo su -c 'emcli create_named_credential -cred_name=ROOT_NC -auth_target_type=host -cred_type=HostCreds -attributes="HostUserName:root;HostPassword:oracle"' - oracle 
sudo su -c 'emcli create_named_credential -cred_name=ORACLE_NC -auth_target_type=host -cred_type=HostCreds -attributes="HostUserName:oracle;HostPassword:oracle"' - oracle 

# Assign the named credentials to the appropriate default credential sets
sudo su -c 'emcli set_default_pref_cred -set_name="HostCredsNormal" -target_type=host -credential_name=ORACLE_NC'  - oracle
sudo su -c 'emcli set_default_pref_cred -set_name="HostCredsPriv" -target_type=host -credential_name=ROOT_NC'  - oracle
sudo su -c 'emcli set_default_pref_cred -set_name="HostCreds" -target_type=oracle_emd -credential_name=ORACLE_NC'  - oracle 

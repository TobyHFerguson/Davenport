#!/bin/bash

# Install needed packages
declare -a packages

# Packages required for Oracle Linux 6, as per http://docs.oracle.com/cd/E24628_01/install.121/e22624/preinstall_req_packages.htm#EMBSC131
packages=(make binutils gcc libaio glibc-common libstdc++ libXtst sysstat glibc-devel glibc-devel.i686)
# Packages needed by OMS Agent construction process (figured out by trial and error)
packages+=(bc)
packages+=(zip)
packages+=(unzip)
packages+=(rpm-build)
# packages needed for ssh -X access
# for authorisation
packages+=(xorg-x11-xauth)
# for /usr/bin/xdpyinfo - to figure out the colors
packages+=(xorg-x11-utils)		
# packages needed for OEM Management Agent
packages+=(openssh-clients)

rpm --quiet -q ${packages[*]} || sudo yum -q -y install ${packages[*]}


# configure oracle user as per http://docs.oracle.com/cd/E24628_01/install.121/e22624/preinstall_req_os_grps_usrs.htm#EMBSC142
groupadd oinstall
useradd -g oinstall oracle
echo oracle | passwd --stdin oracle
echo oracle | sudo passwd --stdin oracle
# configure oracle user's sudo access
sudo install --mode 440 --owner root --group root /vagrant/.oms/sudo_oracle /etc/sudoers.d
# configure sudo so that it can be used by Enterprise Manager
sudo sed -i -e '/requiretty$/s/^/#/' -e'/visiblepw$/s/!//'  /etc/sudoers
# Create the oracle software directory
sudo install -o oracle -g oinstall -d /u01
# Configure oracle user for ssh access
sudo cp --recursive ~vagrant/.ssh ~oracle
sudo chown --recursive oracle:oinstall ~oracle
# Configure oracle's environment
sudo su -c 'cat /vagrant/.oms/oracle_profile  >>/home/oracle/.bash_profile' - oracle

# Create the directories in which the oms and the agent are to be installed.
sudo su -c "mkdir -p /u01/app/oracle/product/12cr4/Middleware" - oracle
sudo su -c "mkdir -p /u01/app/oracle/agent12cr4" - oracle
sudo install -o oracle -g oinstall -d /u01/app/oracle/swlib
sudo chown --recursive oracle:oinstall /u01

# Change File Descriptor limits (both hard and soft) to 16384 for oracle user. Needed by WebLogic
# as per http://docs.oracle.com/cd/E24628_01/install.121/e22624/install_em_exist_db.htm#EMBSC162
sudo su -c 'cat >> /etc/security/limits.conf <<EOF
oracle  soft    nofile  16384
oracle  hard    nofile  16384
oracle  soft    nproc   13312
oracle  hard    nproc   13312
EOF' - root

# Ensure that neither oms.lab.net nor oms are resolved in /etc/hosts to 127.0.0.1
sudo sed -i '/127.0.0.1/s/oms.lab.net oms //' /etc/hosts

# setup firewall so we can access the OMS remotely
# sudo iptables -L INPUT -n | grep -q 7802  || {
#     sudo iptables -I  INPUT -m state --state NEW -p tcp --dport 7802 -j ACCEPT
#     sudo service iptables save
#     }

# Turn off security until I can figure out which ports are required
sudo service iptables stop
sudo chkconfig iptables off
sudo sed -i 's/SELINUX=enforcing/SELINUX=permissive/' /etc/sysconfig/selinux
sudo setenforce 0

# Check that the oms_install directory exists. Exit if it doesn't
[ -d /vagrant/oms_install ] || {
    cat - 1>&2 <<EOF
Can't find the directory "oms_install" in the current directory. 
Please unzip the OEM Installation Zip files into "oms_install", like this:
unzip -u -d oms_install /path/to/V45344-01.zip
unzip -u -d oms_install /path/to/V45345-01.zip
unzip -u -d oms_install /path/to/V45346-01.zip
EOF
}

# Install the OEM software
sudo su -c '/vagrant/oms_install/runInstaller -silent -waitforcompletion -responsefile /vagrant/.oms/oem.rsp' - oracle

#Execute the root scripts
sudo /u01/app/oraInventory/orainstRoot.sh
sudo /u01/app/oracle/product/12cr4/Middleware/oms/allroot.sh

# After the installation copy the setup file:
sudo cp /u01/app/oracle/product/12cr4/Middleware/oms/install/setupinfo.txt /vagrant/oem_setupinfo.txt

echo "Read oem_setupinfo.txt to find out how to connect to oem"

# Install emcli locally
sudo su -c 'mkdir ~/emcli_home' - oracle
curl --silent --insecure https://localhost:7802/em/public_lib_download/emcli/kit/emclikit.jar >/tmp/emclikit.jar
sudo su -c 'java -jar -jar /tmp/emclikit.jar -install_dir=/home/oracle/emcli_home' - oracle
sudo su -c 'emcli setup -url=https://localhost:7802/em -username=sysman -password=Welcome1 -trustall -autologin' - oracle

# Create the named credentials ORACLE_NC and ROOT_NC
sudo su -c 'emcli create_named_credential -cred_name=ROOT_NC -auth_target_type=host -cred_type=HostCreds -attributes="HostUserName:root;HostPassword:vagrant"' - oracle 
sudo su -c 'emcli create_named_credential -cred_name=ORACLE_NC -auth_target_type=host -cred_type=HostCreds -attributes="HostUserName:oracle;HostPassword:oracle"' - oracle 

# Assign the named credentials to the appropriate default credential sets
sudo su -c 'emcli set_default_pref_cred -set_name="HostCredsNormal" -target_type=host -credential_name=ORACLE_NC'  - oracle
sudo su -c 'emcli set_default_pref_cred -set_name="HostCredsPriv" -target_type=host -credential_name=ROOT_NC'  - oracle
sudo su -c 'emcli set_default_pref_cred -set_name="HostCreds" -target_type=oracle_emd -credential_name=ORACLE_NC'  - oracle 


# Ensure that the dhcp server is used for dns
sudo su -c 'echo "prepend domain-name-servers 192.168.50.3;" >/etc/dhcp/dhcpclient.conf'

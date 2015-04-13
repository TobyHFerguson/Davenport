#!/bin/bash
# Add the prereqs
packages=(unzip oracle-rdbms-server-11gR2-preinstall)
rpm --quiet -q ${packages[*]} || sudo yum -y -q --disablerepo='*' --enablerepo='*ol6_latest' install ${packages[*]}
# Construct the needed oracle environment
sudo grep --silent /vagrant/.oemrepo/oracle_profile /home/oracle/.bash_profile || { 
    sudo su -c 'echo ". /vagrant/.oemrepo/oracle_profile"  >>/home/oracle/.bash_profile' - oracle
    }
# Ensure that user oracle can be used by the OEM Manager
sudo sed -i -e '/requiretty$/s/^/#/' -e'/visiblepw$/s/!//'  /etc/sudoers
# Construct the ORACLE_BASE
sudo mkdir -p /u01/app/oracle
sudo chown -R oracle:oinstall /u01

# Ensure that port 1521 is open to allow db clients access
sudo iptables -L INPUT -n | grep --silent 1521 || {
    sudo iptables -I INPUT -p tcp --dport 1521 -m state --state NEW,ESTABLISHED -j ACCEPT
    sudo service iptables save
    }

# Check that the db_install directory has been constructed
[ -d /vagrant/db_install ] || {
        cat - 1>&2 <<EOF
Can't find the directory "db_install" in the current directory. 
Please unzip the OEM Installation Zip files into "db_install", like this:
unzip -u -d db_install /path/to/p10404530_112030_Linux-x86-64_1of7.zip
unzip -u -d db_install /path/to/p10404530_112030_Linux-x86-64_2of7.zip
EOF
}

# Install the db
sudo su -c "/vagrant/db_install/runInstaller -silent -ignorePrereq -responseFile /vagrant/.oemrepo/db.rsp -waitforcompletion" - oracle

# Execute the root scripts
sudo /u01/app/oraInventory/orainstRoot.sh
sudo /u01/app/oracle/product/11.2.0/db_1/root.sh

# Configure the listener
sudo su -c 'netca -silent -responseFile $ORACLE_HOME/assistants/netca/netca.rsp' - oracle

# Unzip the templates into the VM
sudo su -c 'unzip -u -d ${ORACLE_HOME:?}/assistants/dbca/templates /vagrant/11.2.0.3_Database_Template_for_EM12_1_0_4_Linux_x64.zip' - oracle

# Clone a DB for OEM from the templates
sudo su -c 'dbca -silent -createDatabase -responseFile /vagrant/.oemrepo/dbca.rsp' - oracle

# Create a DB service
sudo cp /vagrant/.oemrepo/dbora /etc/init.d
sudo chmod 755 /etc/init.d/dbora
sudo chkconfig --add dbora

sudo sed -i 's/N$/Y/' /etc/oratab
sudo service dbora start

# Patch the db for OEM
sudo su -c 'sqlplus / as sysdba @/vagrant/.oemrepo/patch.sql' - oracle


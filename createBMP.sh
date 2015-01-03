#!/bin/bash

#. ./profile
function get_private_network_name() {
    vboxmanage showvminfo $(cat .vagrant/machines/oms/virtualbox/id) | awk '/NIC 2/ { print $8 }' | tr -d "',"
}
# Create a VM for testing purposes

readonly VM=BMP
readonly os=Oracle_64
readonly storage="SATA"
readonly vboxdir=$(vboxmanage list systemproperties | awk '/^Default.machine.folder/ { print $4 }')
readonly diskfile="${vboxdir:?}/${VM:?}/${VM:?}.vdi"
readonly memsize=512
readonly vramsize=10
readonly diskSizeInGiB=15

# Delete it if its already there
vboxmanage list runningvms | grep -q "\"${VM:?}\"" && {
    vboxmanage controlvm ${VM:?} poweroff
}
vboxmanage list vms | grep -q "\"${VM:?}\"" && {
    vboxmanage unregistervm ${VM:?} --delete
}

# Create the VM
vboxmanage createvm --name "${VM:?}" -ostype "${os:?}"  --register
# Attach a sata storage controller
vboxmanage storagectl "${VM:?}"  --name "${storage:?}" --add sata

# Create a hard drive and attach it to the vm
vboxmanage createhd --filename "${diskfile:?}" --size $((diskSizeInGiB * 1024))
vboxmanage storageattach "${VM}" --storagectl "${storage:?}" --port 0 --device 0 --type hdd --medium "${diskfile:?}"

# Modify the vm to boot from disk, and then from the network
vboxmanage modifyvm "${VM:?}" --boot1 disk --boot2 net --boot3 none --boot4 none
# Modify the vm to use an adapter that supports PXE booting
VBoxManage modifyvm "${VM:?}" --nictype1 Am79C973
# Connect the VM to the hostonly network that we're using
vboxmanage modifyvm "${VM:?}" --nic1 hostonly --hostonlyadapter1 $(get_private_network_name)
# Connect the VM's eth1 (nic2) to the NAT network
vboxmanage modifyvm "${VM:?}" --nic2 NAT
# Forward host port 6622 to vm port 22
vboxmanage modifyvm "${VM:?}" --natpf2 "guestssh,tcp,,6622,,22"
# Modify the vms' memory and vram sizes
vboxmanage modifyvm "${VM:?}" --memory "${memsize:?}" --vram "${vramsize:?}"
# Report the vm's MAC address
MAC=$(vboxmanage showvminfo "${VM:?}" | grep 'NIC 1' |
sed -n "/MAC/s/.*MAC: \([^,][^,]*\),.*/\1/p" |
sed "s/\(..\)\(..\)\(..\)\(..\)\(..\)\(..\)/\1:\2:\3:\4:\5:\6/")
echo $MAC,192.168.50.196,bmp.lab.net >.dhcp/dhcp-hostsfile_tmp
vagrant ssh dhcp -c 'sudo service dnsmasq restart'
echo "${VM:?}'s MAC address is: ${MAC:?}"

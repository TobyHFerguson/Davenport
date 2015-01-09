readonly VM=BMP
readonly HOSTNAME=bmp.lab.net
readonly os=Oracle_64
readonly storage="SATA"
readonly vboxdir=$(vboxmanage list systemproperties | awk '/^Default.machine.folder/ { print $4 }')
readonly diskfile="${vboxdir:?}/${VM:?}/${VM:?}.vdi"
readonly memsize=512
readonly vramsize=10
readonly diskSizeInGiB=15

# Poweroff the VM
vboxmanage list runningvms | grep -q "\"${VM:?}\"" && {
    vboxmanage controlvm ${VM:?} poweroff
}

# Detach and delete the disk
vboxmanage storageattach "${VM}" --storagectl "${storage:?}" --port 0 --device 0 --type hdd --medium none
vboxmanage closemedium disk ${diskfile:?} --delete

# Create a new blank disk and attach it
vboxmanage createhd --filename "${diskfile:?}" --size $((diskSizeInGiB * 1024))
vboxmanage storageattach "${VM}" --storagectl "${storage:?}" --port 0 --device 0 --type hdd --medium "${diskfile:?}"

# Delete the agent from the OMS
vagrant ssh oms -c "sudo su -c \"/vagrant/deleteAgent.sh ${HOSTNAME:?}\" - oracle"

# start the vm
vboxmanage startvm ${VM}


readonly VM=BMP
readonly os=Oracle_64
readonly storage="SATA"
readonly vboxdir=$(vboxmanage list systemproperties | awk '/^Default.machine.folder/ { print $4 }')
readonly diskfile="${vboxdir:?}/${VM:?}/${VM:?}.vdi"
readonly memsize=512
readonly vramsize=10
readonly diskSizeInGiB=15

vboxmanage list runningvms | grep -q "\"${VM:?}\"" && {
    vboxmanage controlvm ${VM:?} poweroff
}
vboxmanage storageattach "${VM}" --storagectl "${storage:?}" --port 0 --device 0 --type hdd --medium none
vboxmanage closemedium disk ${diskfile:?} --delete
vboxmanage createhd --filename "${diskfile:?}" --size $((diskSizeInGiB * 1024))
vboxmanage storageattach "${VM}" --storagectl "${storage:?}" --port 0 --device 0 --type hdd --medium "${diskfile:?}"
vboxmanage startvm ${VM}




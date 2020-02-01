fstype="$(getarg rootfstype=)"
if [ -z "$fstype" ]; then
    fstype="auto"
fi

mountflag="$(getarg rootflags=)"
if [[ ! -z "$mountflag" ]]; then
    mountflag="-o $mountflag"
mount $mountflag -t $fstype /dev/rootfsloop /sysroot

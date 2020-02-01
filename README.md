dracut-vdfuseloop: Boot Virtual Disk Images on NTFS partitions
==============================================

This work is inspired by [rgcjonas/dracut-ntfsloop](https://github.com/rgcjonas/dracut-ntfsloop).

This dracut module allows you to use a root system located inside
a virtual disk image including VHD, VMDK and VDI on a NTFS partition, 
similar to how vloop/vboot worked.


## Requirements

* dracut (tested with Ubuntu 18.04)
* fuse, ntfs-3g, vdfuse, losetup
* fuse and loop kernel modules available

The disk image should contain a full partition table. If the first partition in the image is not
your active partition, you'll need to change your kernel parameter.

## Installation

* copy the `90vdfuseloop` directory to `/usr/lib/dracut/modules.d`
* regenerate your initrd using `dracut --force`
* add to your kernel command line: `rd.hostdev=/PATH/TO/DEVICE rd.vdisk=/PATH/OF/VHD/IN_hostdev rd.vdloop=/PATH/OF/VDLOOP`
  where `/PATH/TO/DEVICE` can be like `/dev/sda1` but also `UUID=...`, rd.vdloop is 
  the path we get after mounting rd.vdisk, which would usually be /dev/vdhost/Partition1

You'll want to do this while your system is still running inside virtual environments.

## Booting

To boot the final system, your `/boot` partition will need to be accessible
by your boot loader of choice. You can copy out the vmlinuz and initramfs file to other
places for example you harddisk or flash drive and then boot it.
The example grub4dos config is:
```
iftitle [ find --set-root --ignore-floppies --ignore-cd  /VMs/LinuxWorkspace/LinuxWorkspace.vmdk ] Start Ubuntu
find --set-root --ignore-floppies --ignore-cd  /VMs/LinuxWorkspace/LinuxWorkspace.vmdk
uuid ()
kernel /ubuntuvm-vhd-helper/vmlinuz  rw rd.hostdev=UUID=%?x% rd.vdisk=/VMs/LinuxWorkspace/LinuxWorkspace.vmdk rd.vdloop=/dev/vdhost/Partition1 verbose nomodeset
initrd /ubuntuvm-vhd-helper/initrd.img
```


## Warning

Never take a snapshot for the vdisk file, using it to boot the phys device, 
and then restore the snapshot. Doing so will destroy your filesystem, for example the 
refcount system of ext4 will fail, leaving to a unusable image.
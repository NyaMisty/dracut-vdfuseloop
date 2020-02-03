#!/bin/bash

# Copyright © 2016-2019 Jonas Kümmerlin <jonas@kuemmerlin.eu>
# Copyright © 2019-2020 NyaMisty
#
# Permission to use, copy, modify, and distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

. /lib/dracut-lib.sh

mount_vdfuseloop() {
    local dev
    local vdisk
    local vdloop

    dev=$1
    vdisk=$2
    vdloop=$3
    snapshot=$4

    mkdir -p "/dev/host"
    mkdir -p "/dev/vdhost"
    mkdir -p "/run/initramfs/vdfuse"

    if ! ismounted "$dev"; then
        info "vdfuseloop: Mounting $dev onto /dev/host"

        # mount using ntfs-3g
        # the @ sign is so that systemd doesn't attempt to kill the ntfs-3g process
        ( exec -a @ntfs-3g ntfs-3g "$dev" "/dev/host" ) | (while read l; do warn $l; done)

        # create a symlink for the device path - this symlink will survive and
        # be there for the shutdown hook, the mount point won't
        ln -s "$dev" "/run/initramfs/vdfuse/host_device"
    fi

    # get the loop device up
    info "vdfuseloop: mounting vmdk /dev/host/$vdisk"
    if [ -z $snapshot ]; then
        ( exec -a @vdfuse vdfuse -f "/dev/host/$vdisk" "/dev/vdhost") | (while read l; do warn $l; done)
    else
        snapshot_vdisk=${vdisk%/?}/$snapshot
        ( exec -a @vdfuse vdfuse -f "/dev/host/$vdisk" -s "/dev/host/$snapshot_vdisk" "/dev/vdhost") | (while read l; do warn $l; done)
    
    # mount the loop
    info "vdfuseloop: Creating loop device for $vdloop"
    ( loopdev=`losetup -f`; losetup ${loopdev} "${vdloop#/}"; ln -s $loopdev /dev/rootfsloop ) | (while read l; do warn $l; done)
    
    # make sure our shutdown script runs
    need_shutdown
}

mount_vdfuseloop "$@"

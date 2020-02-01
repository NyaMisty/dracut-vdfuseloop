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

umount_vdfuseloop() {
    warn "Umounting oldroot"
    umount -f /oldroot | (while read l; do warn "$l"; done)
    warn "Umounting vdfuse's loop device"
    losetup -D | (while read l; do warn "$l"; done)
    warn "Umounting vdfuse mount point"
    umount /oldsys/dev/vdhost | (while read l; do warn "$l"; done)
    warn "Umounting host mount point"
    umount /oldsys/dev/host | (while read l; do warn "$l"; done)
}

umount_vdfuseloop

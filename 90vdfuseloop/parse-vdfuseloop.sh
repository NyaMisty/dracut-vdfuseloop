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

parse_vdfuseloop() {
    local n
    local dev
    local path

    # truncate rule file
    : > /etc/udev/rules.d/90-vdfuseloop.rules
    dev=$(getargs rd.hostdev=)
    vdisk=$(getargs rd.vdisk=)
    vdloop=$(getargs rd.vdloop=)
    snapshot=$(getargs rd.snapshot=)
    
    if [ -z "$dev" ] || [ -z "$vdisk" ] || [ -z "$vdloop" ]
    then
        warn "Wrong format: missing rd.hostdev or rd.vdisk or rd.vdloop"
        return 1
    fi

    # create udev rule for this device
    {
        printf '# rd.vdfuseloop=%s\n' "$n"
        udevmatch "$dev" || {
            warn "Illegal device specification: $dev"
            continue
        }
        printf ', '

        printf 'RUN+="%s --settled --onetime ' $(command -v initqueue)
        printf '%s ' $(command -v vdfuseloop)
        printf '$env{DEVNAME} '\''%s'\'' '\''%s'\'' '\''%s'\''"\n\n' $vdisk $vdloop $snapshot
    } >> /etc/udev/rules.d/90-vdfuseloop.rules
    
    wait_for_dev /dev/rootfsloop
}

parse_vdfuseloop

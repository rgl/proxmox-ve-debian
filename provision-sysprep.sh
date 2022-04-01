#!/bin/bash
set -euxo pipefail

# remove the debian kernel.
# NB this does not remove the pve kernel.
apt-get remove -y --purge $(dpkg-query --showformat '${Package}\n' --show | grep -E '^linux-image-')

# reset the machine-id.
# NB systemd will re-generate it on the next boot.
# NB machine-id is indirectly used in DHCP as Option 61 (Client Identifier), which
#    the DHCP server uses to (re-)assign the same or new client IP address.
# see https://www.freedesktop.org/software/systemd/man/machine-id.html
# see https://www.freedesktop.org/software/systemd/man/systemd-machine-id-setup.html
echo '' >/etc/machine-id
rm -f /var/lib/dbus/machine-id

# reset the random-seed.
# NB systemd-random-seed re-generates it on every boot and shutdown.
# NB you can prove that random-seed file does not exist on the image with:
#       sudo virt-filesystems -a ~/.vagrant.d/boxes/proxmox-ve-amd64/0/libvirt/box.img
#       sudo guestmount -a ~/.vagrant.d/boxes/proxmox-ve-amd64/0/libvirt/box.img -m /dev/pve/root --pid-file guestmount.pid --ro /mnt
#       sudo ls -laF /mnt/var/lib/systemd
#       sudo guestunmount /mnt
#       sudo bash -c 'while kill -0 $(cat guestmount.pid) 2>/dev/null; do sleep .1; done; rm guestmount.pid' # wait for guestmount to finish.
# see https://www.freedesktop.org/software/systemd/man/systemd-random-seed.service.html
# see https://manpages.debian.org/stretch/manpages/random.4.en.html
# see https://manpages.debian.org/stretch/manpages/random.7.en.html
# see https://github.com/systemd/systemd/blob/master/src/random-seed/random-seed.c
# see https://github.com/torvalds/linux/blob/master/drivers/char/random.c
systemctl stop systemd-random-seed
rm -f /var/lib/systemd/random-seed

# clean packages.
apt-get -y autoremove
apt-get -y clean

# clean cloud-init.
cloud-init clean

# show the free space.
df -h /

# zero the free disk space -- for better compression of the box file.
# NB prefer discard/trim (safer; faster) over creating a big zero filled file
#    (somewhat unsafe as it has to fill the entire disk, which might trigger
#    a disk (near) full alarm; slower; slightly better compression).
if [ "$(lsblk -no DISC-GRAN $(findmnt -no SOURCE /) | awk '{print $1}')" != '0B' ]; then
    while true; do
        output="$(fstrim -v /)"
        cat <<<"$output"
        sync && sync && sleep 15
        bytes_trimmed="$(echo "$output" | perl -n -e '/\((\d+) bytes\)/ && print $1')"
        # NB if this never reaches zero, it might be because there is not
        #    enough free space for completing the trim.
        if (( bytes_trimmed < $((4*1024*1024)) )); then # < 4 MiB is good enough.
            break
        fi
    done
else
    dd if=/dev/zero of=/EMPTY bs=1M || true && sync && rm -f /EMPTY
fi

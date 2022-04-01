#!/bin/bash
set -euxo pipefail

# see https://pve.proxmox.com/wiki/Install_Proxmox_VE_on_Debian_11_Bullseye

# configure apt for non-interactive mode.
export DEBIAN_FRONTEND=noninteractive

# add the proxmox apt package repository.
# see https://pve.proxmox.com/wiki/Package_Repositories
dpkg-divert --divert /etc/apt/sources.list.d.pve-enterprise.list.distrib --rename /etc/apt/sources.list.d/pve-enterprise.list
echo "deb http://download.proxmox.com/debian/pve $(lsb_release -c -s) pve-no-subscription" >/etc/apt/sources.list.d/pve.list
wget -q "https://enterprise.proxmox.com/debian/proxmox-release-$(lsb_release -c -s).gpg" -O /etc/apt/trusted.gpg.d/pve.gpg
expected_hash='7fb03ec8a1675723d2853b84aa4fdb49a46a3bb72b9951361488bfd19b29aab0a789a4f8c7406e71a69aabbc727c936d3549731c4659ffa1a08f44db8fdcebfa'
actual_hash="$(sha512sum /etc/apt/trusted.gpg.d/pve.gpg | awk '{print $1}')"
if [ "$expected_hash" != "$actual_hash" ]; then
    echo "ERROR: failed to verify the pxe gpg key"
    exit 1
fi

# set the machine hostname, FQDN, and address.
cat >/etc/hosts <<EOF
127.0.0.1 localhost
$(hostname --all-ip-address | awk '{print $1}') pve.test pve

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
EOF
hostnamectl set-hostname --static pve

# install pve.
apt-get remove -y --purge os-prober
apt-get update
apt-get dist-upgrade -y
apt-get install -y proxmox-ve postfix open-iscsi

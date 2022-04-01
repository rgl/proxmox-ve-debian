SHELL=bash
.SHELLFLAGS=-euo pipefail -c

help:
	@echo type make build-libvirt

build-libvirt: proxmox-ve-debian-amd64-libvirt.box

proxmox-ve-debian-amd64-libvirt.box: provision-*.sh proxmox-ve-debian.pkr.hcl Vagrantfile.template
	rm -f $@
	PACKER_KEY_INTERVAL=10ms CHECKPOINT_DISABLE=1 PACKER_LOG=1 PACKER_LOG_PATH=$@.log PKR_VAR_vagrant_box=$@ \
		packer build -only=qemu.proxmox-ve-debian-amd64 -on-error=abort -timestamp-ui proxmox-ve-debian.pkr.hcl
	@echo BOX successfully built!
	@echo to add to local vagrant install do:
	@echo vagrant box add -f proxmox-ve-debian-amd64 proxmox-ve-debian-amd64-libvirt.box

.PHONY: help buid-libvirt

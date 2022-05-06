variable "disk_image_path" {
  type = string
  default = "${env("HOME")}/.vagrant.d/boxes/debian-11-amd64/0/libvirt/box.img"
}

variable "vagrant_box" {
  type = string
}

source "qemu" "proxmox-ve-debian-amd64" {
  accelerator = "kvm"
  qemuargs = [
    ["-m", "2048"],
    ["-smp", "2"],
  ]
  headless = true
  format = "qcow2"
  disk_interface = "virtio-scsi"
  disk_discard = "unmap"
  disk_image = true
  use_backing_file = false
  iso_url = var.disk_image_path
  iso_checksum = "none"
  ssh_username = "vagrant"
  ssh_password = "vagrant"
  ssh_timeout = "15m"
  shutdown_command = "sudo poweroff"
}

build {
  sources = [
    "source.qemu.proxmox-ve-debian-amd64"
  ]

  provisioner "shell" {
    expect_disconnect = true
    execute_command = "sudo {{ .Vars }} bash {{.Path}}"
    scripts = [
      "provision-pve.sh",
      "provision-reboot.sh",
      "provision-sysprep.sh",
    ]
  }

  post-processor "vagrant" {
    output = var.vagrant_box
    vagrantfile_template = "Vagrantfile.template"
  }
}

This builds an up-to-date [Proxmox VE](https://www.proxmox.com/en/proxmox-ve) in a Debian 11 Vagrant Base Box.

Currently this targets Proxmox VE 7.1.

# Usage

Build and install the [debian-11 base vagrant box](https://github.com/rgl/debian-vagrant).

Create the base box as described in the section corresponding to your provider.

If you want to troubleshoot the packer execution see the `.log` file that is created in the current directory.

After the example vagrant enviroment is started, you can access the [Proxmox Web Interface](https://10.10.10.2:8006/) with the default `root` user and `vagrant` password.

For a cluster example see [rgl/proxmox-ve-cluster-vagrant](https://github.com/rgl/proxmox-ve-cluster-vagrant).

For an alternate way to install Proxmox VE from the ISO file see [rgl/proxmox-ve](https://github.com/rgl/proxmox-ve).

## libvirt

Create the base box:

```bash
make build-libvirt
```

Add the base box as suggested in make output:

```bash
vagrant box add -f proxmox-ve-amd64 proxmox-ve-amd64-libvirt.box
```

Start the example vagrant environment with:

```bash
cd example
vagrant up --no-destroy-on-error --provider=libvirt
```

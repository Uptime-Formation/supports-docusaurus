# TP Nested Virtualization

Dans une machine virtuelle Proxmox ou autre, on va lancer une autre machine virtuelle.

Changer le type de CPU.

On va utiliser un CPU "physique" pour lancer un KVM dans notre machine virtuelle.

```shell

$ cat /etc/modprobe.d/kvm_amd.conf
options kvm-intel nested=1
options kvm-intel enable_shadow_vmcs=1
options kvm-intel enable_apicv=1
options kvm-intel ept=1

```
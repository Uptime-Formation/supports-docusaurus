# TP: KVM Images 

## Objectifs pédagogiques 

## Utiliser virt-builder


```shell
$ apt install guestfs-tools
$ man virt-builder
$ mkdir -p /var/lib/libvirt/images
$ virt-builder centos-6 --format qcow2  -o /var/lib/libvirt/images/centos6.qcow2
$ screen 
$ virt-install --name centos6  --os-variant centos6.0 --memory 2048 --vcpus 2 --disk /var/lib/libvirt/images/centos6.qcow2 --import --graphics none 
$ virsh console centos6
```


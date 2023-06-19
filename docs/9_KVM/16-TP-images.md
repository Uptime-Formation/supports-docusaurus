# TP: KVM Images 


## Objectifs pédagogiques

**Théoriques**

- Connaître les spécificités de la virtualisation KVM

**Pratiques**

- Installer KVM et ses IHM
- Créer des images système pour KVM
- Opérer des instances KVM via ses IHM
  - Démarrer un nouvel OS invité (VM)

---

## virt-builder

**Virt-builder  est un outil qui permet de créer rapidement de nouvelles machines.**

Vous accédez à une variété de distributions pour un usage local ou pour du cloud.

Et la construction des images prend quelques minutes.

---

**Virt-builder offre également la possibilité de personnaliser les VMs construites.**

Ces opérations sont faites en ligne de commande et ne nécessitent pas les privilèges root de manière générale.

---
**virt-builder installe les VM depuis un `template` signé mis à disposition sur Internet.**

> https://builder.libguestfs.org/

Les opérations de customisation sont faites sur la base de ce template.

Cette approche est plus rapide, mais avec `virt-install` on peut lancer des installations complètes.  

---

## Installation

**Sur le host Debian / Ubuntu mis à votre disposition, installer le package `guestfs-tools`.** 

```shell
$ apt install -y libguestfs-tools virtinst libvirt-daemon-system
$ dpkg -L libguestfs-tools | grep /usr/bin/
$ man virt-builder
````
---

## Obtenir la liste des distributions 

```shell
$ virt-builder --list
```

---

## Premières images 

```shell
$ virt-builder --notes fedora-27
$ virt-builder fedora-27
[   2.0] Downloading: http://archive.libguestfs.org/builder/fedora-27.xz
################                                                                                                                                                                                                                         7,3%###################################################################################################################################################################################################################################### 120,0%
[  97.5] Planning how to build this image
[  97.5] Uncompressing
[ 123.5] Opening the new disk
[ 114.1] Setting a random seed
[ 114.2] Setting passwords
virt-builder: Setting random password of root to cmYq1829WYVIsMWY
[ 115.0] Finishing off
                   Output file: fedora-27.img
                   Output size: 6.0G
                 Output format: raw
            Total usable space: 5.3G
                    Free space: 4.4G (81%)

$ qemu-img info fedora-27.img  
$ virt-rescue -a fedora-27.img
...
The virt-rescue escape key is ‘^]’.  Type ‘^] h’ for help.

------------------------------------------------------------

Welcome to virt-rescue, the libguestfs rescue shell.

Note: The contents of / (root) are the rescue appliance.
You have to mount the guest’s partitions under /sysroot
before you can examine them.
><rescue> mount /dev/sda4 /sysroot
><rescue> cd /sysroot
><rescue> ls 
bin   dev  home  lib64	mnt  proc  run	 srv  tmp  var
boot  etc  lib	 media	opt  root  sbin  sys  usr


```

---

## Cas d'usage réaliste 
```shell

$ mkdir -p /var/lib/libvirt/images
$ cat <<EOF > install.sh 
apt update 
apt install -y nginx php-fpm
EOF 
$ virt-builder debian-12 \
    --size 15G\
    --hostname app.dev.example.com\
    --format qcow2 \
    --run install.sh \
    --root-password password:mySecurePassword\
    -o /var/lib/libvirt/images/debian12.qcow2
```    

---

## Démarrage de l'image 

```shell
# On utilise screen en cas de souci de console 
$ screen 
$ virt-install \
    --name debian12  \
    --os-variant debian12 \
    --memory 2048 \
    --vcpus 2 \
    --disk /var/lib/libvirt/images/debian12.qcow2 \
    --import \
    --graphics none 
    
# Pour quitter, utiliser la combinaison de touches CTRL + ALT + )
# Ou kill le PID ex: killall -9 virsh
$ virsh console debian12


```

## Modification a posteriori de l'image 

**On peut faire d'autres modifications dans l'image a posteriori**

```shell

$ virt-customize -a /var/lib/libvirt/images/centosstream-8.qcow2 --root-password password:foobar

```


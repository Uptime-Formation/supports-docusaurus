# TP: Migration Offline 

## Objectifs pédagogiques

**Pratiques**

- Opérer des instances KVM via ses IHM
  - Démarrer un nouvel OS invité (VM)

**Stratégiques**

- Savoir choisir KVM comme outil d'architecture en fonction de critères rationnels.

## Prérequis 

* Deux serveurs qui hébergeront le système de fichiers partagé GlusterFS.
* Deux hôtes exécutant libvirt et qemu qui seront utilisés pour migrer l'invité KVM.
* Tous les serveurs doivent pouvoir communiquer entre eux à l'aide de noms d'hôte.
* Les deux serveurs hébergeant les volumes partagés doivent disposer d'un périphérique de bloc disponible pour être utilisé comme briques GlusterFS. Si un périphérique de bloc n'est pas disponible, veuillez vous reporter à la section Il y a plus... de la recette Migration hors ligne manuelle à l'aide d'un pool de stockage iSCSI dans ce chapitre pour savoir comment en créer un à l'aide d'un fichier standard.
* Connectivité à un référentiel Linux pour installer l'OS invité.

---


Sur les deux serveurs qui hébergeront les volumes partagés, installez GlusterFS

```shell

glusterfs1/2:~# apt-get update && apt-get install glusterfs-server

```
---


Depuis l'un des nœuds GlusterFS, testez l'autre afin de former un cluster

```shell

glusterfs1:~# gluster peer probe glusterfs2

```
---

## Vérifiez que les nœuds GlusterFS se connaissent


```shell

glusterfs1::~# gluster peer status

```
---


## Création du block device local

**Sur les deux hôtes GlusterFS, créez un système de fichiers sur les périphériques de bloc qui seront utilisés comme briques GlusterFS.**

```shell

glusterfs1/2:~# truncate --size 20G /root/xvdb.img
glusterfs1/2:~# losetup /dev/loop0 /root/xvdb.img

```
---

## Création du FS

**Montez les devices** 
```shell


glusterfs1/2:~# mkfs.ext4 /dev/loop0
glusterfs1/2:~# mount /dev/loop0 /mnt/
glusterfs1/2:~# mkdir /mnt/bricks

```
**Assurez-vous de remplacer le nom du périphérique de bloc par ce qui est approprié sur votre système.**

---

## Cluster GlusterFS

**Depuis l'un des nœuds GlusterFS, créez le volume de stockage répliqué, en utilisant les briques des deux serveurs, puis listez-le**

```shell

glusterfs1:~# gluster volume create kvm_gfs replica 2 transport tcp

```
---



---

## Démarrage du volume partagé

Depuis l'un des hôtes GlusterFS, démarrez le nouveau volume et obtenez plus d'informations à son sujet

```shell

glusterfs1:~# gluster volume start kvm_gfs

```
---

## Installation du client glusterfs 

Sur les deux nœuds libvirt, installez le client GlusterFS et montez le volume GlusterFS qui sera utilisé pour héberger l'image KVM

```shell

kvm1/2:~# apt-get update && apt-get install glusterfs-client
kvm1/2:~# mkdir /tmp/kvm_gfs
kvm1/2::~# mount -t glusterfs glusterfs1:/kvm_gfs /tmp/kvm_gfs

```
---

## Démarrage d'une VM sur le volume 

**Lors du montage du volume GlusterFS, vous pouvez spécifier l'un des nœuds du cluster. Dans l'exemple précédent, nous montons à partir du nœud glusterfs1.**

Sur l'un des nœuds libvirt, créez une nouvelle instance KVM, en utilisant le volume GlusterFS monté

```shell

kvm1::~# virt-install --name kvm_gfs --ram 1024 --extra-args="text console=tty0 utf8 console=ttyS0,115200" --graphics vnc,listen=0.0.0.0 --hvm -- location=http://ftp.us.debian.org/debian/dists/stable/main/installer-amd64/ --disk /tmp/kvm_gfs/gluster_kvm.img,size=5

```
---

## Affichage du disque 

**Assurez-vous que les deux nœuds libvirt peuvent voir l'image de l'invité**

```shell

kvm1/2:~# ls -al /tmp/kvm_gfs/
total 1820300
drwxr-xr-x 3 racine racine 4096 13 avril 14:48 .
drwxrwxrwt 6 racine racine 4096 13 avril 15:00 ..
-rwxr-xr-x 1 racine racine 5368709120 13 avril 14:59 gluster_kvm.img

```
---

## Préparation de la migration

**Pour migrer manuellement l'instance KVM d'un nœud libvirt à l'autre, arrêtez d'abord l'instance et videz sa définition XML**

```shell

kvm1:~# virsh destroy kvm_gfs
kvm1::~# virsh dumpxml kvm_gfs > kvm_gfs.xml

```
---

## Migration

**À partir du nœud libvirt source, définissez l'instance sur l'hôte cible**

```shell

kvm1::~# virsh --connect qemu+ssh://kvm2/system define kvm_gfs.xml
kvm1::~# virsh --connect qemu+ssh://kvm2/system list --all
```

---


## Démarrage

```shell

kvm2:~# virsh démarrer kvm_gfs

```
---

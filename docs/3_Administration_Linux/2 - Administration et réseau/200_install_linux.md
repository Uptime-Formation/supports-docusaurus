---
title: Cours - Installer Linux et gérer les partitions
---

## Administration Linux


![](/img/linux/admin/previously.jpg)


## Previously on Games of Codes

- Découverte de Linux
- La ligne de commande
- Des fichiers
- Des utilisateurs et des permissions
- Des processus
- Assembler des commandes
- Écriture de script

## Rappels

#### Utilisez [Tab], ↑ ↓, et Ctrl+A/E !

#### Soyez attentif à ce que vous tapez et à ce que la machine vous renvoie


## Cette semaine

- installer et gérer une distribution
- acquérir des bases de réseau et de sécurité
- administrer un serveur à distance
- configurer et gérer des services
- déployer un serveur web / des apps web


## Plan

1. Installer une distribution, gérer les partitions
2. Le gestionnaire de paquet (et les archives)
3. Notions de réseau
4. Notions de cryptographie
5. Se connecter et gérer un serveur avec SSH
6. Services et sécurité basique d'un serveur
7. Déployer un site "basique" avec nginx
8. Déployer une "vrai" app : Nextcloud ?

#### et gérer les partitions


## 1. Installer une distribution

Installons un système Linux nous-même ... et au passage, choisissons un environnement graphique (ou bien si vous ne voulez pas choisir : gardez Cinnamon)

### Fonctionnement de l'environnement graphique : Xorg

C'est le serveur graphique (qui commence a être remplacée par Wayland ?)

Il fonctionne en client/serveur

### Et un autre morceau : le window manager

Qui s'occupe de toute la gestion des fenêtres (bordures, décoration, redimensionnement, minimisation, vignette, ...)


![](/img/linux/admin/x-org.png)

### Procédure d'installation générale

(Prerequis : avoir accès au BIOS du système (et avoir de la place))

- Télécharger et flasher une "Live CD/USB"
- Dire au BIOS de booter sur la "Live CD/USB"
- Lancer l'installation
    - (définir un plan de partitionnement)
- Prendre un café
- Rebooter et vérifier que ça a fonctionné


### Telecharger l'ISO

![](/img/linux/admin/download.png)

### Vérifier l'intégrité / authenticité

![](/img/linux/admin/checksum.png)

##### Sous Linux: `sha256sum <fichier>` directement disponible

##### Sous Windows: ... il faut trouver un `sha256sum.exe`

### Le BIOS

- Programme lancé par la machine à son démarrage
- Change entre les modèles de PC ...
- Gère différent aspects "bas-niveau" (e.g. horloge intégrée)
- Gère le lancement du "vrai" système d'exploitation
    - analyse typiquement le lecteur CD
    - ... puis le HDD
    - ... puis le network (PXE)
    - ...
- De nos jours, l'UEFI et Secure boot complique beaucoup les choses ...

![](/img/linux/admin/bios.jpg)

### Live CD/USB

- Un système généralement "éphémère" (données perdues)
- Typiquement sur un CD rom ou une clef USB
- Système entièrement chargé dans la RAM (performances moindres)
- Destiné à tester / faire une démo du système et à l'installer
- Permet aussi d'avoir accès à certains outils
- Généralement sous forme d'un fichier `.iso`


![](/img/linux/admin/livedesktop.png)

### Lancer l'installation

![](/img/linux/admin/install.png)


![](/img/linux/admin/install2.png)


### Plan de partitionnement (exemple!)

- 300 Mo pour `/boot/` en ext4
- 12 Go pour `/` en ext4
- 3 Go pour `/home/` en ext4
- Le reste en swap (une extension "lente" de la RAM)

![](/img/linux/admin/install3.png)


### Lancer l'installation "pour de vrai"

- Répondre aux questions pour créer l'utilisateur, etc...
- ... le système s'installe ...

### Finir l'installation

- Redémarrer
- (Enlever le média d'installation)
- (Dire au BIOS de booter de nouveau sur le HDD)

### GRUB

<!-- ![](/img/linux/admin/grub1.png) -->

![](/img/linux/admin/grub2.png)

Le chargeur d'amorçage est le logiciel qui charge le système d'exploitation.

Il affiche une liste des OS et façons de démarrer disponible sur la machine, generalement autodetectée à l'installation.

https://doc.ubuntu-fr.org/grub-pc

https://doc.ubuntu-fr.org/tutoriel/grub2_parametrage_manuel


### Résumé du boot complet (du Bios à l'interface de login)

Historiquement:
![](/img/linux/admin/boot.png)

Plus actuel avec Systemd:
![](/img/linux/admin/Linux-boot-process.png)

Plus sur le démarrage SystemD avec les targets : https://opensource.com/article/20/5/systemd-startup

### Log du boot

- Les logs du boot du kernel (contient aussi par ex. le log de la détection de dispositif USB branchés après le boot, etc...)
peuvent être trouvés dans `/var/log/dmesg` ou `journalctl -b`

<!-- ### Init levels / Run levels

- 0 = Shutdown
- 1 = Single-user mode : Mode for administrative tasks
- 2 = Multi-user mode, without network interfaces
- 3 = Multi-user mode with networking
- 4 = ... not used ...
- 5 = Multi-user with networking and graphical environment
- 6 = Reboot

#### Sous SysVinit, choses à lancées décrites dans /etc/rc.d/rcX.d/... mais aujourd'hui : c'est différent avec systemd... -->


### Login

![](/img/linux/admin/login.png)


### Le bureau

![](/img/linux/admin/desktop.png)


### Notation des partitions

![](/img/linux/admin/parts.png)


Les disques partitions sous Linux sont généralement dénommées :

- `/dev/sda` (premier disque)
   - `/dev/sda1` (première partition de /dev/sda)
   - `/dev/sda2` (deuxieme partition de /dev/sda)
- `/dev/sdb` (deuxieme disque)
   - `/dev/sdb1` (première partition de /dev/sdb)
   - `/dev/sdb2` (deuxieme partition de /dev/sdb)
   - `/dev/sdb3` (troisieme partition de /dev/sdb)


### Outil pour lister les disques, gérer les partions

```bash
$ fdisk -l
Disk /dev/sda: 29.8 GiB, 32017047552 bytes, 62533296 sectors
[...]
Device       Start      End  Sectors  Size Type
/dev/sda1     2048  2099199  2097152    1G Linux filesystem
/dev/sda2  2099200 62524946 60425747 28.8G Linux filesystem
```

Plus sur `fdisk`: https://www.malekal.com/fdisk-gfdisk-creer-supprimer-redimensionner-des-partitions-de-disque-en-ligne-de-commandes-linux/

### Les points de montage

Une partition ou n'importe quel "bidule de stockage" peut être "monté" dans le système de fichier
- partition
- clef usb
- image iso
- stockage distant
- ...

### Les points de montage

![](/img/linux/admin/mounpoints.png)


Les points de montages sont gérés avec `mount`

```bash
$ mkdir /media/usbkey
$ mount /dev/sdb1 /media/usbkey
$ ls /media/usbkey
## [le contenu de la clef usb s'affiche]
```

On peut "démonter" un element monté avec `umount`

```bash
$ umount /media/usbkey
```

### Configurer les points de montage : `/etc/fstab`

`/etc/fstab` décrit les systèmes de fichier montés automatiquement au boot

```text
## <file system>     <mountpoint> <type>  <options>       <dump>  <pass>
UUID=[id tres long] /            ext4    default         0       1
UUID=[id tres long] /home/       ext4    defaults        0       2
```
Les points de mon
(historiquement, la premiere colomne contenait `/dev/sdxY`, mais les UUID sont plus robustes)


### Les points de montage : outils

Juste `mount` permet aussi de lister les différents points de montage

```bash
$ mount
[...]
/dev/sda1 on /boot type ext4 (rw,noatime,discard,data=ordered)
/dev/sda2 on / type ext4 (rw,noatime,discard,data=ordered)
```


Il existe aussi `df` :

```bash
$ df -h
Filesystem      Size  Used Avail Use% Mounted on
dev             2.8G     0  2.8G   0% /dev
run             2.8G  1.1M  2.8G   1% /run
/dev/dm-0        29G   22G  5.0G  82% /
tmpfs           2.8G   22M  2.8G   1% /dev/shm
tmpfs           2.8G     0  2.8G   0% /sys/fs/cgroup
tmpfs           2.8G  1.9M  2.8G   1% /tmp
/dev/sda1       976M  105M  804M  12% /boot
tmpfs           567M   16K  567M   1% /run/user/1000
```

Et aussi `lsblk` :

```bash
$ lsblk
NAME          MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
sda             8:0    0 29.8G  0 disk
├─sda1          8:1    0    1G  0 part  /boot
└─sda2          8:2    0 28.8G  0 part  /
```


### Autres configurations du système (avec systemd)

- `hostnamectl` : 
- `timedatectl` : https://wiki.archlinux.org/title/System_time_(Fran%C3%A7ais)#Fuseau_horaire*
- `localectl` : 

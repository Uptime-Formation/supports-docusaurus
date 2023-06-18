# TP: QEMU Single user 



## Objectifs pédagogiques

**Théoriques**

- Connaître les spécificités de la virtualisation KVM
- Connaître les IHM permettant de piloter KVM


**Apprendre à utiliser QEMU pour lancer un processus basé sur une autre architecture.**



binfmt_misc est une fonctionnalité du noyau qui permet d'invoquer presque tous les programmes en tapant simplement son nom dans le shell. 

Il reconnaît le type binaire en faisant correspondre certains octets au début du fichier avec une séquence d'octets magiques (masquant les bits spécifiés) que vous avez fournie.

binfmt_misc peut également reconnaître une extension de nom de fichier aka '.com' ou '.exe'.


---

## Installer les packages QEMU

```shell

$ apt install binfmt-support qemu-user-static

$ grep binfmt /proc/mounts
binfmt_misc on /proc/sys/fs/binfmt_misc type binfmt_misc (rw,nosuid,nodev,noexec,relatime)

$ dpkg -L qemu-user-static

```
**On voit toute la liste des processeurs que QEMU pourra émuler.**

---

**Vérifiez si les entrées binfmt ont été enregistrées avec succès.**


```shell

$ update-binfmts --display

```

Cette commande doit imprimer des entrées pour chaque émulateur d'utilisateur cible pris en charge, à l'exception du système hôte.

--- 

## Réglage du système

**Selon les paramètres de votre noyau, vous devrez peut-être définir l'option** 

``` 

$ sysctl 'vm.mmap_min_addr=0' 

```
pour autoriser l'exécution d'un programme sous un utilisateur normal, et non root.

---

## Exécution d'exécutables liés dynamiquement

Avec les instructions ci-dessus, vous devriez pouvoir exécuter des exécutables cibles liés statiquement. Pour pouvoir exécuter des binaires liés dynamiquement, QEMU doit avoir accès à l'interpréteur ELF cible. Le package libc6 pour l'architecture cible contient l'interpréteur ELF de la cible utilisé par QEMU.


```

$ sudo dpkg --add-architecture armhf
$ sudo apt update 
$ sudo apt install libc6:armhf

``` 

--- 

## Test de l'environnement d'émulation

**Nous utiliserons le paquet "hello" ARM Debian pour tester le nouvel environnement.**

Installez le paquet hello et lancez-le.

``` 

$ sudo apt install hello:armhf
$ sudo apt install file
$ file /usr/bin/hello 
$ hello
# Il devrait afficher "Bonjour, le monde !".

``` 

--- 

## Confirmer l'utilisation de QEMU

**Nous allons utiliser l'utilitaire strace pour afficher les appels systèmes effectués par la commande.**

Identifier quels appels systèmes et quelles données affichées indiquent l'usage de `binfmt`.

``` 

$ sudo apt install strace
$ strace hello

``` 


--- 

## Avancé 

**Peut-on faire la même chose dans un chroot ?**

Indice : 

```shell

$ sudo mkdir /tmp/chroot 
$ cd /tmp/chroot
$ sudo debootstrap stable .
$ sudo chroot .
# Suivre les opérations

```
---

**Peut-on lancer un chroot avec une autre architecture ? Un chroot dans un chroot ?**

Indices 

```shell

$ debootstrap --arch=armhf stable  .
...
$ file /bin/bash 


```
---

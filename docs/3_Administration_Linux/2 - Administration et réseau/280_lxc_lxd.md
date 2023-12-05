---
title: Cours - Les conteneurs Linux (LXD/LXC)
---

## Jusqu'ici : machines virtuelle

- Une machine entière simulée dans une autre machine
- Bonne isolation
- Ressources "garanties", allouées explicitement à la VM
- "Lourd" en terme de taille (plusieurs Go) et performances


![](/img/linux/admin/toodamnhigh.png)


## Généralités sur la conteneurisation

La conteneurisation permet :
- de créer des systèmes isolés, similaire à des VM
- mais qui partagent un kernel commun ... !
- (et potentiellement des fichiers commun)
- ⇒ système léger (taille et perf), déployable rapidement, "jetable"
- (mais : ressources partagées, non garanties)


![](/img/linux/admin/vm_vs_containers.png)


## Généralités sur les LXC

- Technologie de conteneurisation de Linux
    - (c.f. fonctionnalité du kernel, les cgroups)
- Relativement récent !
    - V1.0 date de début 2014 ! 
    - V3.0 cette année
- À l'intérieur : un mini-système complet


![](/img/linux/admin/lxc.png)


## "Vanilla" LXC

`apt install lxc` puis utilisation des commandes `lxc-<stuff>`

## LXD !

- "Hyperviseur" pour gérer des LXC
- UX bien meilleure (commande `lxc <stuff>` (et non `lxd` !))
- Développé par Canonical (c.f. Ubuntu)


```
Usage:
  lxc [command
Available Commands:
  config      Manage container and server configuration options
  delete      Delete containers and snapshots
  exec        Execute commands in containers
  file        Manage files in containers
  image       Manage images
  info        Show container or server information
  launch      Create and start containers from images
  list        List containers
  snapshot    Create container snapshots
  start       Start containers
  stop        Stop containers
```


## Creer un LXC (1/2)

- De nombreuse images de systeme disponible

```bash
$ lxc image list images:
+--------------+----------+
|       ALIAS  |   SIZE   |
+--------------+----------+
| alpine/3.8   | 2.34MB   |
| archlinux    | 137.20MB |
| centos/7     | 83.47MB  |
| debian/10    | 122.36MB |
| fedora/28    | 60.40MB  |
| gentoo       | 242.96MB |
| ubuntu/18.10 | 124.88MB |
+--------------+----------+
```


## Creer un LXC (2/2)

```bash
$ lxc launch images:debian/stretch test1
Creating test1
Starting test1
```


## Interagir avec un LXC (1/2)

```bash
$ lxc exec test1 -- ps -ef --forest
UID      PID  CMD
root     103  ps -ef --forest
root       1  /sbin/init
root      32  /lib/systemd/systemd-journald
systemd+  39  /lib/systemd/systemd-networkd
root      53  /lib/systemd/systemd-logind
message+  55  /usr/bin/dbus-daemon --system
root      80  /sbin/dhclient -4 -v -pf /run/
systemd+  94  /lib/systemd/systemd-resolved
root      95  /sbin/agetty --noclear --keep-
```


## Interagir avec un LXC (2/2)

```bash
root@scw-32c380:~$ lxc exec stretch1 -- /bin/bash
root@stretch1:~$       # <<< Dans le LXC !
```

```bash
root@scw-32c380:~$ lxc console stretch1
To detach from the console, press: <ctrl>+a q
                                             
Debian GNU/Linux 9 stretch1 console

stretch1 login:
```


## I can haz internetz ?

- Les LXC sont sur un réseau local, via `lxcbr0`

```
$ lxc list
+----------------+---------+------------------+
|      NAME      |  STATE  |     IPV4         |
+----------------+---------+------------------+
| saperlipopette | RUNNING | 10.0.0.51 (eth0) |
| veganaise      | RUNNING | 10.0.0.32 (eth0) |
| vinaigrette    | STOPPED |                  |
+----------------+---------+------------------+
```


## Push / pull files

```bash
# Envoyer un fichier sur un LXC
$ lxc file push -- <fichier> <machine>/<destination>
# Recuperer un fichier dans un LXC
$ lxc file pull -- <machine>/<fichier> <destination>
```

Exemples :
```bash
$ lxc file push -- template.html test1/var/www
$ lxc file pull -- test1/var/log/auth.log test1.auth.log
```


## Snapshots

- Il est possible de sauvegarder l'état d'un LXC pour le restaurer plus tard
- (ACHTUNG : Le LXC doit être *à l'arrêt !*)

```bash
$ lxc snapshot <container> <nom_du_snapshot>
```


![](/img/linux/admin/lxc.png)

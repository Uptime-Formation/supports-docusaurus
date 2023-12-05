---
title: Cours - Le gestionnaire de paquet et les archives
---

### Motivation du gestionnaire de paquet

Historiquement, c'est très compliqué d'installer un programme :
- le télécharger et le compiler
- la compilation (ou le programme lui-même) requiert des dependances
- il faut télécharger et compiler les dépendances
- qui requiert elles-mêmes des dépendances ...

#### Paquet =~ programmes ou librairies

### Le travail d'une distribution (entre autre)

- créer et maintenir un ensemble de paquet cohérents
- ... et le gestionnaire de paquet qui va avec
- les (pre)compiler pour fournir des binaires

### Le gestionnaire de paquet c'est :

- La "clef de voute" d'une distribution ?
- un **système unifié pour installer** des paquets ...
- ... **et les mettre à jour !**
- le tout en gérant les dépendances et les conflits
- et via une commaunauté qui s'assure que les logiciels ne font pas n'importe quoi.

### Comparaison avec Windows

Sous Windows historiquement
- téléchargement d'un .exe par l'utilisateur ...
- ... depuis une source obscure ! (**critical security risk !**)
- procédure d'installation spécifique
- ... qui tente de vous refiler des toolbar bloated, et/ou des CGU obscures
- système de mise à jour spécifique
- nécessité d'installer manuellement des dépendances

Maintenant:
- le Microsoft store (hum supermarché désagréable selon moi)
- Toujours la méthode manuelle si on aime pas le store officiel
- ou Chocolatey (gestionnaire de paquet inspiré de linux sur Windows)

<!-- ## 2. Le gestionnaire de paquet

*One package to rule them all*

*One package to find them*

*One package to download them all*

*and on the system bind them* -->


### Sous Debian / Ubuntu et le reste de la famille

`apt` : couche "haut niveau"
- dépot,
- authentification,
- ...

`dpkg` : couche "bas niveau"
- gestion des dépendances,
- installation du paquet (`.deb`),
- ...


### Parenthèse sur `apt-get`

- Historiquement, `apt-get` (et `apt-cache`, `apt-mark`, ..) étaient utilisés
- Syntaxe inutilement complexe ?
- `apt` fourni une meilleur interface (UI et UX)


### Utilisation de `apt`

- `apt install <package>`
    - télécharge et installe le paquet et tout son arbre de dépendances
- `apt remove <package>`
    - désinstaller le paquet (et les paquet dont il dépends !)
- `apt autoremove`
    - supprime les paquets qui ne sont plus nécessaires


![](/img/linux/admin/aptinstallooffice.png)


### Mais qu'est-ce que c'est, un paquet ?

Un programme, et des fichiers (dossier `debian/`) qui décrivent le paquet :
- `control` : décrit le paquet et ses dépendances
- `install` : liste des fichiers et leur destination
- `changelog` : un historique de l'evolution du paquet
- `rules` : des trucs techniques pour compiler le paquet
- `postinst`, `prerm`, ... : des scripts lancés quand le paquet est installé, désinstallé, ...

- https://www.baeldung.com/linux/package-deb-change-repack

### Mettre à jour les paquets

- `apt update`
   - récupère la liste des paquets depuis les dépots
- `apt full-upgrade`
   - calcule et lance la mise à jour de tous les paquets
   - (anciennement appelé : `apt dist-upgrade`)
- Moins utilisé : `apt upgrade`
   - mise à jour "safe", sans installer/supprimer de nouveaux paquets
   - en général, `full-upgrade` est okay

N.B. : pour les moldus dans la vraie vie, il y a des interfaces graphiques pour gérer tout ça sans ligne de commande, mais ici on présente les détails techniques

### Les dépots

Les dépots de paquets sont configurés via `/etc/apt/sources.list` et les fichiers du dossier `/etc/apt/sources.list.d/`.

Exemple :

```
deb http://ftp.debian.fr/debian/ stretch main contrib
```

- `stretch` est le nom actuel de la distribution
- `main` et `contrib` sont des composantes à utiliser
- le protocole est `http` ... l'authenticité des paquets est géré par un autre mécanisme (GPG)

### Les versions de Debian

Debian vise un système libre et très stable

- `stable` : paquets éprouvés et très stable (bien que souvent un peu vieux)
- `testing` : paquets en cours de test, comportant encore quelques bugs
- `unstable` (sid) : pour les gens qui aiment vivre dangereusement

Les versions tournent tous les ~2 ans environ
- l'ancienne `testing` devient la nouvelle `stable`
- le passage de version peut être un peu douloureux ... (quoiqu'en vrai c'est de + en + smooth)

### Les versions de Debian

Basé sur les personnages de Toy Story

- 9, `stretch` (oldoldoldstable)
- 10, `buster` (oldoldstable)
- 11, `bullseye` (oldstable)
- 12, `bookworm` **(stable depuis juin 2023)**
- 13, `trixie` (testing, "nextstable")

![](/img/linux/admin/debiantimeline.png)


### Naviguez dans les paquets debian en ligne

`https://packages.debian.org/search`

![](/img/linux/admin/debianpackagesite.png)

### Les backports

- Un intermédiaire entre stabilité et nouveauté
- Fournissent des paquets venant de `testing` en `stable` (sous debian) de `latest` vers `LTS` (sous ubuntu)
- À utiliser avec prudence (plus de risque de bug du a des incompatibilité de librairies ou autre)

### Comparaison avec Ubuntu server

https://phoenixnap.com/blog/debian-vs-ubuntu-server


### Comparaison APT avec le nouveau système de fichier SNAP de Canonical (Ubuntu)

https://www.baeldung.com/linux/snap-vs-apt-package-management-system

### Comparaison avec RedHat (RHEL) / AlmaLinux

AlmaLinux (ou Rocky) remplace CentOS depuis que RedHat l'a torpillé : il s'agit d'une copie plus libre de RHEL globalement identique (les même paquets et configuration sont utilisés)

https://www.tecmint.com/redhat-vs-debian/

### En pratique ...

- Si on a besoin de dépendances récentes, on les installe généralement avec le gestionnaire de paquet correspondant au language de notre app : `pip`, `npm`, `composer`, `carton`, `gem`, ... 

### Et les autres distributions ?

- Redhat/Centos/AlmaLinux : `yum install <pkg>`, `yum search <keyword>`, `yum makecache`, `yum update`, ... et maintenant `dnf install` nouvelle version de YUM

=> Très testé aussi (comme Debian)

- Archlinux : `pacman -S <pkg>`, `-Ss <keyword>`, `-Syu`, ...

=> Très récent = moins testé et aussi plus vanilla (moins customizé)

## Gérer des archives

`tar` (tape archive) permet de créer des archives (non compressées) qui rassemblent des fichiers.

```bash
## Créer une archive monarchive.tar
tar -cvf monarchive.tar file1 file2 folder2/ folder2/

## Désassembler une archive
tar -xvf monarchive.tar
```

`gzip` (gunzip) permet de compresser des fichiers (similaire aux .zip, .rar, ...)

```bash
## Compresser zblorf.scd
gzip zblorf.scd

## [...] le fichier a été compressé et renommé zblorf.scd.gz

## Decompresser le fichier :
gzip -d zblorf.scd.gz
```

`tar` peut en fait être invoqué avec `-z` pour générer une archive compressée

```bash
## Créer une archive compressée
tar -cvzf monarchive.tar.gz file1 file2 folder2/ folder2/

## Désassembler une archive
tar -xvzf monarchive.tar.gz
```

![](/img/linux/admin/xkcd_tar.png)
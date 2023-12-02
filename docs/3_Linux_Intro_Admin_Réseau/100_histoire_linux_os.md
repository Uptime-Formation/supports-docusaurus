---
title: Cours - Histoire de Linux et des systèmes d'exploitation
---

<!-- *Become a Command Line Padawan in three days!* -->
![](/img/linux/gnulinux.png)

## Hello, world!

## À propos de moi

## À propos de vous ?

## Signatures de présence

## Évaluations (?)

<!-- # Plan du cursus -->

<!-- # Autres formateurs / référents -->
<!-- 
## Plan de la formation

**Jour 1 ?** / Bases de Linux

- 1 - Historique, introduction, rappels, setup initial
- 2, 3 - Prise en main du terminal et de la ligne de commande
- 4 - Manipulation des fichiers

**Jour 2 ?** / Bases de Linux

- 5, 6 - Utilisateurs, groupes et permissions
- 7 -  Les processus

**Jour 3 ?** / Bases de Linux

- 8 - Personnaliser son environnement
- 9 - Commandes avancées (redirections, enchainements, pipes, ..)

**Jour 4 ?** / Administrer Linux

- 11 - Installer Linux
   - (choisir une distro, boot sequence, live CD, partitionnement)
- 12 - Le gestionnaire de paquet, les outils d'archivage

**Jour 5 ?** / Reseau

- 13 - Notions de réseaux
- 14 - Notions de cryptographie et sécurité

**Jour 6 ?** / Administrer Linux + réseau

- 15 - Mettre en place un serveur, utiliser SSH
- 16 - Services, systemd, sécurité basique d'un serveur (firewall, fail2ban)

**Jour 7 ?** / Administrer Linux + réseau

- 17 - Configurer un serveur web : nginx
- 18 - Déployer une "vraie" application PHP/Mysql : Nextcloud
- Créer un service systemd ?

**Jour 8 ?** / Administrer Linux + réseau

- Savoir débugger un système cassé ?
- LXC ?
- HTTPS ?
- Etude d'un serveur "complet" ?

**Jour 9 ?** / Scripting bash, automatisation

- Scripting bash
   - variables
   - interactivité
   - conditions

**Jour 10 ?** / Scripting bash, automatisation

- Scripting bash
   - fonctions
   - boucles

**Jour 11 ?** / Scripting bash, automatisation

- Cron jobs
- Regex ?
- TP d'application -->

## Méthode de travail

- Alternance théorie / pratique
- Contenu sur ce ce site
- Travail dans une machine virtuelle
- Setup avec Guacamole pour les stagiaires à distance

## Objectifs

- Vous fournir des bases solides via la pratique
- Vous transmettre une forme d'enthousiasme !

## Disclaimers

- C'est une formation d'informatique technique
- L'informatique technique, c'est compliqué
- Le brute force ne marche pas, il faut être précis / rigoureux...
- Soyez **patient, méthodique, attentifs** !
- **Ne laissez pas l'écran vous aspirer** !

### On est là pour apprendre

- Réussir les exo importe peu, il faut **comprendre ce que vous faites** !
- Apprendre plus que de la théorie (posture, savoir se dépatouiller...)
- Prenez le temps de vous tromper (et de comprendre pourquoi)

### **N'hésitez pas à poser vos questions !**

## 1. Les origines de (GNU/)Linux

### (ou plus largement de l'informatique contemporaine)

### La préhistoire de l'informatique

- ~1940 : Ordinateurs electromecaniques, premiers ordinateurs programmables
- ~1950 : Transistors
- ~1960 : Circuits intégrés

...Expansion de l'informatique...

### 1970 : PDP-7

![](/img/linux/pdp7.jpg)


### 1970 : (old computer?)

![](/img/linux/old_computer.jpg)

### 1970 : UNIX

- Définition d'un 'standard' pour les OS
- Un multi-utilisateur, multi-tâche
- Design modulaire, simple, élégant, efficace
- Adopté par les universités américaines
- Ouvert (évidemment)
- (Écrit en assembleur)

![](/img/linux/ritchie_thompson_kernighan.png)


### 1970 : UNIX

![](/img/linux/unixtree.png)


### 1975 : Le langage C

- D. Ritchie et K. Thompson définissent un nouveau langage : le C ;
- Le C rends portable les programmes ;
- Ils réécrivent une version d'UNIX en C, ce qui rends UNIX portable ;

![](/img/linux/ritchie_thompson.jpg)


### 1970~1985 : Les débuts d'Internet

- Définition des protocoles IP et TCP
    - Faire communiquer les machines entre elles
    - Distribué / décentralisé : peut survivre à des attaques nucléaires
- ARPANET ...


### 1970~1985 : Les débuts d'Internet

![](/img/linux/arpanet.png)

### 1970~1985 : Les débuts d'Internet

- Définition des protocoles IP et TCP
    - Faire communiquer les machines entre elles
    - Distribué / décentralisé : peut survivre à des attaques nucléaires
- ARPANET ...
- ... puis le "vrai" Internet
- Terminaux dans les grandes universités
- Appartition des newsgroup, ...


### 1980 : Culture hacker, logiciel libre

- Le logiciel devient un enjeu commercial avec des licences propriétaires
- L'informatique devient un enjeu politique
- La culture hacker se développe dans les universités
    - Partage des connaisances
    - Transparence, détournement techniques
    - Contre les autorités centrales et la bureaucratie
    - Un mouvement technique, artistique et politique


### 1980 : Culture hacker, logiciel libre

- R. Stallman fonde le mouvement du logiciel libre et la FSF <small>(Free Software Foundation)</small>
    0. Liberté d'utiliser du programme
    1. Liberté d'étudier le fonctionnement du programme
    2. Liberté de modifier le programme
    3. Liberte de redistribuer les modificiations
- ... et le projet GNU : un ensemble de programmes libres

![](/img/linux/stallman.jpg)
![](/img/linux/gnu.png)


### 1990 : Création de Linux

- Linus Torvalds écrit Linux dans son garage

![](/img/linux/torvalds.jpg)
![](/img/linux/tux.png)

### 1990 : Création de Linux

*I'm doing a (free) operating system (**just a hobby, won't be big and professional like gnu**) for 386(486) AT clones. This has been brewing since april, and is starting to get ready. I'd like any feedback on things people like/dislike in minix, as my OS resembles it somewhat (same physical layout of the file-system (due to practical reasons) among other things).*

*I've currently ported bash(1.08) and gcc(1.40), and things seem to work. This implies that I'll get something practical within a few months, and I'd like to know what features most people would want. Any suggestions are welcome, but I won't promise I'll implement them :-)*

*Linus (torvalds@kruuna.helsinki.fi)*

*PS. [...] It is NOT portable [...] and it probably never will support anything other than AT-harddisks, as that's all I have :-(.
— Linus Torvalds*


### 1990 : Et en fait, Linux se développe...

- Linus Torvalds met Linux sous licence GPL
- Support des processeurs Intel
- Système (kernel + programmes) libre et ouvert
- Compatibles avec de nombreux standard (POSIX, SystemV, BSD)
- Intègre des outils de développement (e.g. compilateurs C)
- Excellent support de TCP/IP
- Création de Debian en 1993


... L'informatique et Internet se démocratisent ...

En très résumé :
- Linux remporte le marché de l'infrastructure (routeur, serveurs, ..)
- Windows remporte le marché des machines de bureau / gaming
- Google remporte le marché des smartphones


### L'informatique contemporaine

![](/img/linux/datacenter.jpg)

![](/img/linux/laptop.jpg)
![](/img/linux/smartphone.jpg)


### Architecture d'un ordinateur

![](/img/linux/computer.png)


<!-- ### Le rôle d'un système d'exploitation -->

<!-- ![](/img/linux/systemedexploitation.jpg) -->

### Le rôle d'un système d'exploitation

- permet aux users d'exploiter les ressources
- sais communiquer avec le hardware
- créer des abstractions pour les programmes (e.g. fichiers)
- partage le temps de calcul entre les programmes
- s'assure que les opérations demandées sont légales


### Linux aujourd'hui

- Très présent dans les routeurs, les serveurs et les smartphones
- Indépendant de tout constructeur
- Evolutif mais très stable
- Le système est fait pour être versatile et personnalisable selon son besoin
- Pratiques de sécurités beaucoup plus saines et claires que Microsoft


### Les distributions

Un ensemble de programmes "packagés", préconfigurés, intégré pour un usage ~précis ou suivant une philosophie particulière

- Un noyau (Linux)
- Des programmes (GNU, ...)
- Des pré-configurations
- Un gestionnaire de paquet
- Un (ou des) environnements graphiques (Gnome, KDE, Cinnamon, Mate, ...)
- Une suite de logiciel intégrée avec l'environnement graphique
- Des objectifs / une philosophie

### Les distributions

![](/img/linux/debian.png)
![](/img/linux/ubuntu.png)
![](/img/linux/mint.png)
![](/img/linux/centos.png)
![](/img/linux/arch.png)
![](/img/linux/kali.png)
![](/img/linux/android.png)
![](/img/linux/yunohost.png)
![](/img/linux/kubernetes.png)

- **Debian** : réputé très stable, typiquement utilisé pour les serveurs
- **Ubuntu, Mint** : grand public
- **CentOS**, RedHat : pour les besoins des entreprises
- **Archlinux** : un peu plus technicienne, très à jour avec les dernières version des logiciels
- **Kali Linux** : orientée sécurité et pentesting
- **Android** : pour l'embarqué (téléphone, tablette)
- **YunoHost** : auto-hébergement grand-public
- **Kubernetes** / k8s : devops, déploiement et orchestration de flotte de conteneur


### Les distributions

Et bien d'autres : Gentoo, LinuxFromScratch, Fedora, OpenSuse, Slackware, Alpine, Devuan, elementaryOS, ...

### Linux, les environnement

- Gnome
- Cinnamon, Mate
- KDE
- XFCE, LXDE
- Tiling managers (awesome, i3w, ...)

![](/img/linux/gnome.jpg)

![](/img/linux/kde.jpg)

![](/img/linux/cinnamon.jpg)

![](/img/linux/xfce.jpg)

![](/img/linux/awesome.jpg)


### Environnement de travail : Linux Mint

- (Choix arbitraire du formateur)
- Distribution simple, sobre, pas spécialement controversée (?)
- Profite de la stabilité de Debian et de l'accessibilité d'Ubuntu

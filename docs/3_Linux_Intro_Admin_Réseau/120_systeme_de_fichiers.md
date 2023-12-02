---
title: Cours - Le système de fichier Linux
---

## 4. Le système de fichier

## 4. Le système de fichier

### Généralités

- (En anglais : *filesystem*, abrégé *fs*)
- La façon dont sont organisés et référencé les fichiers
- Une abstraction de la mémoire
- Analogie : une bibliothèque avec seulement les pages des livres dans les étagères
- Le *fs* connait le nom, la taille, l'emplacemenent des différents morceaux, la date de création, ...

## 4. Le système de fichier

###  Partitionnement d'un disque

- Un disque peut être segmenté en "partitions"
- Chaque partition héberge des données indépendantes des autres et sous un format / filesystem différent

![](/img/linux/parts.png)


## 4. Le système de fichier

### Quelques systèmes de fichier classiques

- *FAT16*, *FAT32* : disquettes, Windows 9x (~obsolète)
- *NTFS* : système actuellement utilisé par Windows
- **EXT3**, **EXT4** : système typiquement utilisé par Linux (Ubuntu, Mint, ...)
- *HFS+* : système utilisé par MacOS
- *TMPFS* : système de fichier pour gérer des fichiers temporaires (`/tmp/`)


## 4. Le système de fichier

### Quelques systèmes de fichier "avancés"

- **ZFS**
    - snapshots
    - haute dispo
    - gestion RAID, auto-réparation, diverses optimisations
- **BTRFS** / "better FS"
    - similaire à zfs, mais la peinture est encore fraiche
- **LVM** (gestionnaire de volumes logiques)
    - snapshots
    - gestion flexible des partitions "à chaud"
    - fusion de plusieurs disques
- **RAID *n* **
    - un ensemble de schema d'architecture de disque pour créer de la redondance en cas de perte de disque
    - données copiées sur plusieurs disques (grappe)


## 4. Le système de fichier

### Quelques systèmes de fichier exotiques(?) / autre

- *Tahoe-LAFS*
- *FUSE*
- *IPFS*


## 4. Le système de fichier

### Sous UNIX / Linux : "Tout est fichier"


- **fichiers ordinaires** (`-`) : données, configuration, ... texte ou binaire
- **répertoires** (directory, `d`) : gérer l'aborescence, ...
- **spéciaux** :
    - `block` et `char` (`b`, `c`) (clavier, souris, disque, ...)
    - sockets (`s`), named pipe (`p`) (communication entre programmes)
    - links (`l`) ('alias' de fichiers, ~comme les raccourcis sous Windows)



## 4. Le système de fichier

### Un fichier

- Un inode (numéro unique représentant le fichier)
- *Des* noms (chemins d'accès)
    - Un même fichier peut être à plusieurs endroits en meme temps (hard link)
- Des propriétés
    - Taille
    - Permissions
    - Date de création, modification


## 4. Le système de fichier

### Nommage des fichiers

- Noms sensibles à la casse
- (Eviter d'utiliser des espaces)
- Un fichier commençant par `.` est "caché"
- Les extensions de fichier sont purement indicatives : un vrai mp3 peut s'apeller musique.jpg et vice-versa
- Lorsqu'on parle d'un dossier, on l'ecrit plutôt avec un `/` à la fin pour expliciter sa nature


## 4. Le système de fichier

### Arborescence de fichier

```
coursLinux/
├── dist/
│   ├── exo.html
│   └── presentation.html
├── exo.md
├── img/
│   ├── whatisthissorcery.jpg
│   └── bottomlesspit.png
├── presentation.md
└── template/
    ├── index.html
    ├── remark.min.js
    └── style.scss
```


## 4. Le système de fichier

### Filesystem Hierarchy Standard

![](/img/linux/filetree.png)


## 4. Le système de fichier

### Filesystem Hierarchy Standard

- `/` : racine de toute la hierarchie
- `/bin/`, `/sbin/` : programmes essentiels (e.g. `ls`)
- `/boot/` : noyau et fichiers pour amorcer le système
- `/dev/`, `/sys` : périphériques, drivers
- `/etc/` : **fichiers de configuration**
- `/home/` : **répertoires personnels des utilisateurs**
- `/lib/` : librairies essentielles
- `/proc/`, `/run` : fichiers du kernel et processus en cours
- `/root/` : répertoire personnel de `root`
- `/tmp/` : fichiers temporaires
- `/usr/` : progr. et librairies "non-essentielles", doc, données partagées
- `/var/` : **fichiers / données variables** (e.g. cache, logs, boîtes mails)


## 4. Le système de fichier

### Répertoires personnels

- Tous les utilisateurs ont un répertoire personnel
- Classiquement `/home/<user>/` pour les utilisateurs "normaux"
- Le home de root est `/root/`
- D'autres utilisateurs ont des home particulier (`/var/mail/`, ...)


## 4. Le système de fichier

### Designation des fichiers

"Rappel" :
- `.` : désigne le dossier actuel
- `..` : désigne le dossier parent
- `~` : désigne votre home

Un chemin peut être :
- Absolu : `/home/alex/dev/yunohost/script.sh`
- Relatif : `../yunohost/script.sh` (depuis `/home/alex/dev/apps/`)

Un chemin relatif n'a de sens que par rapport à un dossier donné... mais est souvent moins long à écrire


## 4. Le système de fichier

### Designation des fichiers

- Pour parler d'un dossier ou fichier `toto` **dans le répertoire courant**

```bash
ls toto
## ou bien
ls ./toto
```

- Pour parler d'un dossier ou fichier `toto` **à la racine**

```bash
ls /toto
```



![](/img/linux/relativepath_1_1.png)


![](/img/linux/relativepath_1_2.png)


![](/img/linux/relativepath_1_3.png)


![](/img/linux/relativepath_1_4.png)


![](/img/linux/relativepath_1_5.png)


![](/img/linux/relativepath_2_1.png)


![](/img/linux/relativepath_2_2.png)


![](/img/linux/relativepath_2_3.png)



![](/img/linux/relativepath_2_4.png)



![](/img/linux/relativepath_2_5.png)


![](/img/linux/relativepath_2_6.png)


![](/img/linux/relativepath_2_7.png)


## 4. Le système de fichier

### Chemins relatifs

+ d'exemples, tous équivalents (depuis `/home/alex/dev/apps/`)

- `/home/alex/dev/yunohost/script.sh`
- `~/dev/yunohost/script.sh`
- `../yunohost/script.sh`
- `./../yunohost/script.sh`
- `./wordpress/../../yunohost/script.sh`
- `../.././music/.././../camille/.././alex/dev/ynh-dev/yunohost/script.sh`


## 4. Le système de fichier

### Manipuler des fichiers (1/5)

- `ls` : lister les fichiers
- `cat <fichier>` : affiche le contenu d'un fichier dans la console
- `wc -l <fichier>` : compte le nombre de lignes dans un fichier

Exemples :

```bash
ls /usr/share/doc/                       # Liste les fichiers de /usr/share/doc
wc -l /usr/share/doc/nano/nano.html      # 2005 lignes !
```


## 4. Le système de fichier

### Manipuler des fichiers (2/5)

- `head <fichier>`, `tail <fichier>` : affiche les quelques premières ou dernières ligne du fichier
- `less <fichier>` : regarder le contenu d'un fichier de manière "interactive" (paginateur)
   - ↑, ↓, ⇑, ⇓ pour se déplacer
   - `/mot` pour chercher un mot
   - `q` pour quitter

```bash
tail -n 30 /usr/share/doc/nano/nano.html # Affiche les 30 dernieres lignes du fichier
less /usr/share/doc/nano/nano.html       # Regarder interactivement le fichier
```


## 4. Le système de fichier

### Manipuler des fichiers (2/5)

![](/img/linux/cat.jpeg)


## 4. Le système de fichier

### Manipuler des fichiers (3/5)

- `touch <fichier>` : créer un nouveau fichier, et/ou modifie sa date de modification
- `nano <fichier>` : éditer un fichier dans la console
    - (`nano` créera le fichier si besoin)
    - [Ctrl]+X pour enregistrer+quitter
    - [Ctrl]+W pour chercher
    - [Alt]+Y pour activer la coloration syntaxique
- `vi` ou `vim <fichier>` : alternative à nano
    - plus puissant (mais plus complexe)


## 4. Le système de fichier

### Manipuler des fichiers (4/5)

- `cp <source> <destination>` : copier un fichier
- `rm <fichier>` : supprimer un fichier
- `mv <fichier> <destination>` : déplace (ou renomme) un fichier

Exemple

```bash
cp cours.html coursLinux.html  # Créée une copie avec un nom différent
cp cours.html ~/bkp/linux.bkp  # Créée une copie de cours.html dans /home/alex/bkp/
rm cours.html                  # Supprime cours.html
mv coursLinux.html linux.html  # Renomme coursLinux.html en linux.html
mv linux.html ~/archives/      # Déplace linux.html dans ~/archives/
```


## 4. Le système de fichier

### Manipuler des fichiers (5/5)

- `wget` : télécharger un fichier depuis les Internets

Exemple

```text
$ wget https://dismorphia.info/documents/formationLinux/toto

--2021-12-05 17:12:45--  https://dismorphia.info/documents/formationLinux/toto
Resolving dismorphia.info (dismorphia.info)... 92.92.115.142
Connecting to dismorphia.info (dismorphia.info)|92.92.115.142|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 6 [application/octet-stream]
Saving to: ‘toto’

toto               100%[=============>]       6  --.-KB/s    in 0s 

2021-12-05 17:12:46 (3.20 MB/s) - ‘toto’ saved [6/6]
```

```shell
$ cat toto
pouet
```


## 4. Le système de fichier

### Manipuler des dossiers (1/3)

- `pwd` : connaître le dossier de travail actuel
- `cd <dossier>` : se déplacer vers un autre dossier


## 4. Le système de fichier

### Manipuler des dossiers (2/3)

- `mkdir <dossier>` : créer un nouveau dossier
- `cp -r <source> <destination>` : copier un dossier et l'intégralité de son contenu

Exemples :

```bash
mkdir ~/dev           # Créé un dossier dev dans /home/alex
cp -r ~/dev ~/dev.bkp # Créé une copie du dossier dev/ qui s'apelle dev.bkp/
cp -r ~/dev /tmp/     # Créé une copie de dev/ et son contenu dans /tmp/
```


## 4. Le système de fichier

### Manipuler des dossiers (3/3)

- `mv <dossier> <destination>` : déplace (ou renomme) un dossier
- `rmdir <dossier>` : supprimer un dossier vide
- `rm -r <dossier>` : supprimer un dossier et tout son contenu récursivement

Exemples :

```bash
mv dev.bkp  dev.bkp2   # Renomme le dossier dev.bkp en dev.bkp2
mv dev.bkp2 ~/trash/   # Déplace dev.bkp2 dans le dossier ~/trash/
rm -r ~/trash          # Supprime tout le dossier ~/trash et son contenu
```


## 4. Le système de fichier

### Les liens durs (hard link)

![](/img/linux/hardlink.png)

- `ln <source> <destination>`
- Le même fichier ... à plusieurs endroits !
- Supprimer une instance de ce fichier ne supprime pas les autres


## 4. Le système de fichier

### Les liens symbolic (symlink)

![](/img/linux/symlink.png)

- `ln -s <cible> <nom_du_lien>`
- Similaire à un "raccourci", le fichier n'est pas vraiment là .. mais comme si
- Supprimer le fichier pointé par le symlink "casse" le lien


## 4. Le système de fichier

### Les liens symbolic (symlink)

![](/img/linux/symlink.png)

- Dans ce exemple, le lien a été créé avec
    - `ln -s ../../../conf/ynh.txt conf.json`
- `conf.json` est "le raccourci" : on peut le supprimer sans problème
- `ynh.txt` est la cible : le supprimer rendra inopérationnel le raccourci



## 4. Le système de fichier

### symlink vs. hardlink

- On croise plus souvent des symlinks que des hardlinks (les symlinks sont + intuitifs)
- On peut avoir des symlinks de répertoires (à la différence des hardlinks)
    - Attention tout de même à certains comportements étrange (`..` en étant à l'intérieur d'un symlink)
- On peut avoir des symlinks entre des filesystem différents ! (à la différence des hardlinks)


## 4. Le système de fichier

### Recap dossiers importants (l'essentiel)

- `/home/<user>/` : le répertoire personnel de `<user>`
- `/etc/` : là où habitent les fichiers de configuration
- `/var/log/` : là ou habitent les fichiers de logs
- `/root/` : le répertoire personnel de `root`


## 4. Le système de fichier

### Recap des commandes

- `ls` : lister les fichiers d'un dossier
- `cat` : afficher le contenu d'un fichier
- `head`, `tail` : afficher les N premières / dernière ligne d'un fichier
- `less` : afficher le contenu d'un fichier avec un mode interactif
- `touch` : créer un fichier vide (ou changer sa date de modif sans rien faire)
- `nano`, `vim` : éditer un fichier (et le créer si besoin)
- `cp` : copier un fichier (ou dossier avec `-r`)
- `mv` : déplacer ou renommer un fichier ou un dossier
- `rm` : supprimer un fichier (ou un dossier avec `-r`)
- `wc -l` : compter les lignes d'un fichier
- `ln -s` : créer un lien symbolique
- `wget` : télécharger un fichier sur les Internets

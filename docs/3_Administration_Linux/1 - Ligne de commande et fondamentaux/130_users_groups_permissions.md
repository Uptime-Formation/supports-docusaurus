---
title: Cours - Utilisateurs, groupes et permissions
---

### Généralités

- une entité / identité (!= être humain) qui demande des choses au système
- possède des fichiers, peut en créer, modifier, naviguer, ...
- peut lancer des commandes / des processus

### Répertoire des utilisateurs

Classiquement, les utilisateurs sont répertoriés dans `/etc/passwd`

```
alex:x:1000:1000:Super Formateur Linux:/home/alex:/bin/bash
```

- identifiant / login
- `x` (historique)
- uid (id utilisateur)
- gid (id de groupe)
- commentaire
- répertoire home
- shell de démarrage

### root

- Dieu sur la machine, `uid=0`, `gid=0`
- **With great power comes great responsabilities**
    - Si un attaquant devient root, l'OS est entièrement compromis (à jamais)

![](/img/linux/iamroot.jpg)
![](/img/linux/heistheone.png)


### Parenthèse sur la terminologie

##### Le terminal / la console

Dans le temps, il s'agissait d'une machine sans interface graphique, similaire à un minitel qui permettait d'interagir avec le "vrai" ordinateur (mainframe) à distance.

De nos jours, par abus de language un terminal est en fait un **émulateur** de terminal, c'est-à-dire un programme qui émule la même fonctionnalité. (La distinction terminal/mainframe a disparu)

##### Le shell

Il s'agit du programme qui gère l'invite de commande et l'execution des commandes tapées.

Classiquement, il s'agit de `bash`. Il existe d'autres shell comme `sh`, `zsh`, `fish`, ...

Lorsque l'on programme dans certains languages de scripting, on parle aussi de shell `python`, `perl`, `ruby`, `javascript`, ...

Un shell que vous utilisez peut potentiellement être situé sur une autre machine que celle devant laquelle vous êtes !

### Passer root (ou changer d'utilisateur)

```bash
su                  # Demande à ouvrir un shell en tant que root
su camille          # Demande à ouvrir un shell en tant que camille
su -c "ls /root/"   # Executer 'ls /root/' en tant que root (de manière ephemere)
exit                # Quitter un shell
```

### Sudo

- On peut autoriser les utilisateurs à faire des choses en root en leur donnant les droits 'sudo'

```bash
su -c "ls /root/"   # Executer 'ls /root/' en tant que root (de manière ephemere)
sudo ls /root/      # Meme chose mais avec sudo
sudo whoami         # Renvoie "root"
sudo su             # Ouvrir un shell root via sudo...
```

- Suivant la commande demandée, le mot de passe n'est pas le même...
   - `su` : mot de passe root
   - `sudo` : mot de passe utilisateur


### `su` vs `sudo`

- Generalement, on essaye de ne pas rester en root constamment.
   - `sudo` permet de faire juste une commande en root, ponctuellement
- On peut avoir plusieurs personnes partageant des droits d'administrateur
   - avec `sudo`, pas besoin de se mettre d'accord sur un mot de passe commun
- `sudo` permet aussi de garder une historique "par utilisateur / être humain" de qui à fait quoi sur la machine
   - chaque commande effectuée avec `sudo` est logguée dans `/var/log/auth.log`
   - utile pour les audits de sécurité

### Les groupes

- Chaque user à un groupe associé qui possède le même nom
- Des groupes supplémentaires peuvent être créés
- Ils permettent ensuite de gérer d'accorder des permissions spécifiques
- Ils sont indexés dans le fichier `/etc/group` (similaire à `/etc/passwd`)

Exemples de groupes qui pourraient exister:
- `students`
- `usb`
- `power`

N.B : lorsqu'on ajoute un utilisateur à un groupe, il doit se reloguer pour que le changement soit propagé...

### Mot de passe

- Autrefois dans `/etc/passwd` (accessibles à tous mais hashés)
- Maintenant dans `/etc/shadow` (accessibles uniquement via root)

```
alex:$6$kncRwIMqSb/2PLv3$x10HgX4iP7ZImBtWRChTyufsG9XSKExHyg7V26sFiPx7htq0VC0VLdUOdGQJBJmN1Rn34LRVAWBdSzvEXdkHY.:0:0:99999:7:::
```

## (Parenthèse sur le hashing)

```
$ md5sum coursLinux.html
458aca9098c96dc753c41ab1f145845a
```

...Je change un caractère...

```
$ md5sum coursLinux.html
d1bb5db7736dac454c878976994d6480
```

Hasher un fichier (ou une donnée) c'est la transformer en une chaîne :
- de taille fixe
- qui semble "aléatoire" et chaotique (mais déterministe !)
- qui ne contient plus l'information initiale

Bref : une empreinte caractérisant une information de manière très précise


### Commandes utiles

```bash
whoami                  # Demander qui on est...!
groups                  # Demander dans quel groupe on est
id                      # Lister des infos sur qui on est (uid, gid, ..)
passwd <user>           # Changer son password (ou celui de quelqu'un si on est root)
who                     # Lister les utilisateurs connectés
useradd <user>          # Créé un utilisateur
userdel <user>          # Supprimer un utilisateur
groupadd <group>        # Ajouter un groupe
usermod -a -G <group> <user>  # Ajouter un utilisateur à un groupe
```


## Les permissions


- Chaque fichier a :
    - un utilisateur proprietaire
    - un groupe proprietaire
    - des permissions associés
- (`root` peut tout faire quoi qu'il arrive)
- Système relativement minimaliste mais suffisant pour pas mal de chose
    - (voir SELinux pour des mécanismes avancés)

```
$ ls -l coursLinux.html
-rw-r--r-- 1 alex alex 21460 Sep 28 01:15 coursLinux.html

    ^         ^     ^
    |         |     '- groupe proprio
    |          '- user proprio
    les permissions !
```


![](/img/linux/permissions.jpg)


![](/img/linux/permissions2.png)


### Permissions des **fichiers**

- `r` : lire le fichier
- `w` : écrire dans le fichier
- `x` : executer le fichier

### Permissions des **dossiers**

- `r` : lire le contenu du dossier
- `w` : créer / supprimer des fichiers
- `x` : traverser le répertoire

(On peut imager que les permissions d'un dossier soient `r--` ou `--x`)

### Gérer les propriétaires

**(Seul root peut faire ces opérations !!)**

```bash
chown <user> <cible>          # Change l'user proprio d'un fichier
chown <user>:<group> <cible>  # Change l'user et groupe proprio d'un fichier
chgrp <group> <cible>         # Change juste le groupe d'un fichier
```

Exemples :

```bash
chown camille:students coursLinux.md  # "Donne" coursLinux.md à camille et au groupe students
chown -R camille /home/alex/dev/      # Change le proprio récursivement !
```

(ACHTUNG: si l'on fait un malencontreux `chown -R`, il peut être difficile de revenir en arrière)

### Gérer les permissions

```bash
chmod <changement> <cible>   # Change les permissions d'un fichier
```

Exemples
```bash
chmod u+w   coursLinux.html  # Donne le droit d'ecriture au proprio
chmod g=r   coursLinux.html  # Remplace les permissions du groupe par "juste lecture"
chmod o-rwx coursLinux.html  # Enlève toutes les permissions aux "others"
chmod -R +x ./bin/           # Active le droit d'execution pour tout le monde et pour tous les fichiers dans ./bin/
```

(ACHTUNG: si l'on fait un malencontreux `chmod -R`, il peut être difficile de revenir en arrière)

### Représentation octale

![](/img/linux/chmod_octal.png)

![](/img/linux/chmod_octal2.png)

### Gérer les permissions .. en octal !

```bash
chmod <permissions> <cible>
```

Exemples
```bash
chmod 700 coursLinux.html  # Fixe les permissions à rwx------
chmod 644 coursLinux.html  # Fixe les permissions à rw-r--r--
chmod 444 coursLinux.html  # Fixe les permissions à r--r--r--
```

### Chown vs. chmod

![](/img/linux/chown_chmod.png)


Lorsque l'on fait :
```bash
$ /etc/passwd
```

Obtenir comme réponse

```bash
-bash: /etc/passwd: Permission denied
```

ne signifie pas qu'on a pas les droits de lecture sur le fichier, mais bien que l'on a "juste" pas le droit de l'executer <small>(car ça n'a en fait pas de sens de chercher à l'executer)</small>


### Permissions "théoriques" vs permissions réelles

Pour pouvoir accéder à `/home/alex/img/pikachu.jpg` j'ai besoin de :

- Pouvoir entrer (`x`) dans le dossier `/`
- Pouvoir entrer (`x`) dans le dossier `/home/`
- Pouvoir entrer (`x`) dans le dossier `/home/alex/`
- Pouvoir entrer (`x`) dans le dossier `/home/alex/img/`
- Pouvoir lire (`r`) le fichier `/home/alex/img/pikachu`


Une commande pour lister toutes les permissions sur un chemin: `namei -l`

```shell
$ namei -l ~/img/pikachu.jpg
f: /home/alex/img/pikachu.jpg
drwxr-xr-x root root /
drwxr-xr-x root root home
drwxr-x--- alex alex alex
drwxr-xr-x alex alex img
-rw-r--r-- alex alex pikachu.jpg
```


On peut un peu casser son système si on fait `chmod -x /`

(plus personne n'a le droit de rentrer dans la racine !)


### Permissions avancées : les ACL (Access Control Lists)


Par défaut, la gestion des droits sous Linux est relativement basique (bien que souvent suffisante). En effet, il n'est possible de permettre ou d'interdire la lecture, l'écriture et l'exécution de fichiers **que pour trois catégories d'utilisateurs** : le propriétaire du fichier, l'ensemble des utilisateurs inscrits dans le groupe éponyme relatif à l'utilisateur et le reste du monde.

Cette gestion des droits permet de configurer les accès aux fichiers dans la plupart des situations simples **mais peut s'avérer limitée**.

Par exemple: plusieurs utilisateurs doivent accéder à une ressource partagée alors que ni l'un ni l'autre ne sont réciproquement inscrits dans le groupe de l'autre utilisateur.

Les ACL permettent de pallier cette déficience de sorte qu'**il devient possible d'autoriser un utilisateur tiers à effectuer des opérations sur un fichier (dossier) sans autoriser tout un groupe** ou tout le reste du monde.


### Exemples

autoriser à "utilisateur" la lecture et l'écriture sur "fichier"

- `setfacl -m user:utilisateur:rw fichier`

- `setfacl -m u:utilisateur:rw fichier` (en abrégé)

La même commande est disponible pour les groupes. Il suffit de remplacer u/user par g/group
modifier les permissions de plusieurs utilisateurs/groupes sur "fichier" en même temps

- `setfacl -m user:utilisateur:rwx,user:utilisateur2:r,group:groupe:rw fichier`

définir l'accès en lecture par défaut pour "utilisateur" pour les nouveaux fichiers créés dans "dossier"

- `setfacl -m d:u:utilisateur:r dossier`

supprimer les ACL pour un utilisateur sur une arborescence

- `setfacl -R -x user::nom_user repertoire_base_arborescence`

supprimer les ACL sur un fichier/dossier

- `setfacl -b fichier`




source: https://doc.ubuntu-fr.org/acl
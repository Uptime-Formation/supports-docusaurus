---
title: Cours - Les processus
---

- Un processus est *une instance* d'un programme en cours d'éxécution
- (Un même programme peut tourner plusieurs fois sous la forme de plusieurs processus)

- Un processus utilise des ressources :
    - code qui s'execute dans le CPU, ou en attente en cache/RAM
    - données du processus en cache/RAM
    - autres ressources (port, fichiers ouverts, ...)

- Un processus a des attributs (iidentifiant, proprio, priorité, ...)

### Execution

La machine comprends seulement du code machine ("binaire").

Un programme est donc soit :
- compilé (par ex. un programme en C)
- interprété par un autre programme, qui lui est compilé (par ex. un programme en python, interprété par l'interpreteur python)

Rappel : UNIX est multi-tâche, multi-utilisateur
- partage de temps, execution parallèle
- coordonnées par le kernel


Un processus est lancé soit :

- en interactif (depuis un shell / la ligne de commande)
- de manière automatique (tâche programmées, c.f. `at` et jobs cron)
- en tant que daemon/service

En mode interactif, on peut interragir directement avec le processus pendant qu'il s'execute

### Attributs d'un processus

- Propriétaire
- PID (processus ID)
- PPID (processus ID du parent !)
- Priorité d'execution
- Commande / programme lancé
- Entrée, sortie

### Lister les processus et leurs attributs

```bash
ps aux            # Liste tous les processus
ps ux -U alex     # Liste tous les processus de l'utilisateur alex
ps -ef --forest   # Liste tous les processus, avec des "arbres de parenté"
ps fauxw          # Liste tous les processus, avec des "arbres de parenté"
pstree            # Affiche un arbre de parenté entre les processus
```

Exemple de `ps fauxw`

```
  935   927  0 Sep25 ?      00:00:52  \_ urxvtd
 3839   935  0 Sep26 pts/1  00:00:00      \_ -bash
16076  3839  0 00:49 pts/1  00:00:49      |   \_ vim coursLinux.html
20796   935  0 Sep27 pts/2  00:00:00      \_ -bash
 2203 20796  0 03:10 pts/2  00:00:00      |   \_ ps -ef --forest
13070   935  0 00:27 pts/0  00:00:00      \_ -bash
13081 13070  0 00:27 pts/0  00:00:00          \_ ssh dismorphia -t source getIrc.sh
```


#### `top` et `htop`

Et aussi :
```bash
top               # Liste les processus actif interactivement
  -> [shift]+M    #    trie en fonction de l'utilisation RAM
  -> [shift]+P    #    trie en fonction de l'utilisation CPU
  -> q            # Quitte
```



### Gérer les processus interactif

```bash
<commande>            # Lancer une commande de façon classique
<commande> &          # Lancer une commande en arrière plan
[Ctrl]+Z  puis 'bg'   # Passer la commande en cours en arrière-plan
fg                    # Repasser une commande en arrière-plan en avant-plan
jobs                  # Lister les commandes en cours d'execution
```

### Tuer des processus

```bash
kill <PID>     # Demande gentillement à un processus de finir ce qu'il est en train de faire
kill -9 <PID>  # Tue un processus avec un fusil à pompe
pkill <nom>    # (pareil mais via un nom de programme)
pkill -9 <nom> # (pareil mais via un nom de programme)
```

Exemples

```bash
kill 2831
kill -9 2831
pkill java
pkill -9 java
```

![](/img/linux/dont-sigkill.jpeg)
![](/img/linux/dontsigkill.png)


#### Un petit outil en passant

`watch` permet d'afficher le résultat d'une commande et de relancer cette commandes toutes les 2 secondes

Par exemple : 

```bash
watch 'ps -ux -U alex --forest' # Surveiller les process lancé par l'utilisateur alex
watch ls -l ~/Documents         # Surveiller le contenu de ~/Documents
watch free -h                   # Surveiller l'utilisation de la RAM
```

### `screen`

`screen` permet de lancer une commande dans un terminal que l'on peut récupérer plus tard

1. On ouvre une session avec `screen`
2. On lance ce que l'on veut dedans
3. On peut sortir de la session avec `<Ctrl>+A` puis `D`.
4. La commande lancée continue à s'executer
5. On peut revenir dans la session plus tard avec `screen -r`

### `byobu` 

`screen` en mieux => tmux préconfiguré

- https://www.byobu.org/

### Processus et permissions

- Un processus est rattaché à l'identité de l'utilisateur qui l'a lancé
- Il est donc soumis aux permissions que cet utilisateur possède, par exemple pour lire ou écrire un fichier..

#### Problème

- Lorsqu'un user veut changer son mot de passe, il faut modifier `/etc/shadow` ... que seul `root` peut lire et écrire !
- Pourtant ... le programme `/usr/bin/passwd` permet effectivement de changer son mot de passe !

```
 > ls -l /usr/bin/passwd
-rwsr-xr-x 1 root root 63960 Feb  7  2020 /usr/bin/passwd
```

Le `s` correspond à [une permission spéciale : le SUID bit](https://fr.wikipedia.org/wiki/Permissions_UNIX#Droits_%C3%A9tendus), qui fait en sorte que lorsque le programme est lancé par n'importe quel user, il s'éxécute quand même en tant que `root` !

- https://linuxhandbook.com/suid-sgid-sticky-bit/

### Priorité des processus

- Il est possible de régler la priorité d'execution d'un processus
- "Gentillesse" (*niceness*) entre -20 et 19
    - -20 : priorité la plus élevée
    - 19 : priorité la plus basse
- Seul les process du kernel peuvent être "méchant"
    - niceness négative, et donc les + prioritaires


```bash
nice -n <niceness> <commande> # Lancer une commande avec une certaine priorité
renice <modif> <PID>       # Modifier la priorité d'un process
```

Exemples :
```bash
## Lancer une création d'archive avec une priorité faible
nice -n 5 tar -cvzf archive.tar.gz /home/
## Redéfinir la priorité du processus 9182
renice +10 9182
```

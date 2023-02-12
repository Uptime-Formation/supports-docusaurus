---
title: "Pourquoi Docker : Qu'est ce qu'un process ?"
pre: "<b>1.03 </b>"
weight: 4
---

## Objectifs Pédagogiques
  - Connaître le rôle et les attributs d'un process Linux
  - Identifier les process docker dans la liste des process du système

## Docker est un "gestionnaire de process"

Vous allez voir que le(s) conteneur(s) Docker que vous avez lancé avec Portainer sont des processus visibles dans votre système.

Pour le moment, on ne vas pas expliquer pourquoi on appelle ça un conteneur, ça viendra plus tard, ce n'est pas essentiel dans un premier temps.

On verra plus tard comment Docker peut être défini par opposition aux machines virtuelles.

Pour le moment cette approche par les process est suffisante.

## Lancer une commande listant les process dans un terminal

* Appeler un terminal et entrer la commande `ps` suivante.
```bash
sudo ps fauxw
```
* `ps` est un outil qui permet d'obtenir des listes de process.
* Ce qui apparaît à l'écran est une liste de processus du système. 

**Avancé** `man ps`, `ps -u`, `ps -p 1 -o stat,euid,ruid,tty,tpgid,sess,pgrp,ppid,pid,pcpu,comm` 

## Qu'est-ce qu'un process ?

**Analogie** 

Imaginez un restaurant. Le responsable de salle doit en permanence 
* savoir combien de personnes sont dans la salle (disponibilité)
* dans quel état est leur commande (statut)
* ce qu'ils ont commandé (consommation)

Un système d'opération et des process, c'est pareil. 
* Le système est le chef de salle
* Chaque table est un process
* Le chef de table est chargé de surveiller que tout le monde soit servi et paie à la sortie

**Définition**

Un `process` est un programme en cours d'exécution, autrement dit c'est une instance active d'un programme.

Toute commande que vous exécutez lance un process, voire plusieurs ("processus enfants").

**Une base de donnés, un serveur web, un éditeur de texte, c'est toujours un process.**

Un process c'est l'entité qui permet au système de gérer un programme en cours d'exécution.

Pour CHAQUE process individuellement, le système :
* lui attribue un numéro unique
* lui associe un utilisateur 
* lui alloue de la mémoire à la demande  
* lui alloue du temps de calcul 
* garde la liste des fichiers qu'il a ouvert 
* maintient des statistiques le concernant
* permet de communiquer avec lui 

**En somme, le process est l'unité de base pour exécuter du code dans un système avec**
- des accès aux ressources systèmes
- des autorisations
- des échanges
- des mesures d'usage des ressources

## Revenons à notre liste de process

On peut retrouver pour chaque ligne les informations attribuées par le système à ses process.

```bash
-----     ------ ---- ---- ------  ---- -------  ---  --------  ----  ---------------
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START     TIME  COMMAND
alban     209950  0.0  0.0   6820  2340 ?        S    févr.02   0:00 /bin/bash
alban     209962  2.7  4.8 4052524 783580 ?      Sl   févr.02  49:15  \_ /usr/lib/thunderbird/thunderbird
-----     ------ ---- ---- ------  ---- -------  ---  --------  ----  ---------------
USER : Utilisateur
PID: Numéro du process
%CPU, %MEM : statistiques CPU / RAM
VSZ, RSS : Usage mémoire 
TTY : Terminal attaché au process
STAT : état du process 
START : Temps de départ 
TIME : Temps de calcul écoulé 
COMMAND : Programme exécuté
```

Le signe `\_` dans la commande indique un process enfant.

## Docker est un "gestionnaire de process"

On a vu qu'un conteneur Docker, c'est l'activation d'une image Docker. 

Cette activation c'est un process, avec ou sans process enfants.

**Chaque image Docker est spécialisée pour lancer un seul process (sauf exception).**

Dans la liste des process, saurez vous identifier les conteneurs Docker ?

```bash
root      293758  0.0  0.0 1525548 5728 ?        Sl   10:27   0:00 /usr/bin/containerd-shim-runc-v2 -namespace moby -id c905f6e1b44cd2b77bd26f0415a451e8d039b7fc3f6b27d1b9831ba5b9e93e0b -address /run/containerd/containerd.sock
root      293777  0.0  0.1 754284 21988 ?        Ssl  10:27   0:03  \_ /portainer
root      301521  0.0  0.0 1526700 5468 ?        Sl   10:06   0:00 /usr/bin/containerd-shim-runc-v2 -namespace moby -id 37df9e23b649ff41ac8c80d32ebcacd4d36fef37b19bc6271894e1af1cc23af1 -address /run/containerd/containerd.sock
root      301541  0.0  0.0 111380  2664 ?        Ssl  10:06   0:00  \_ /go/bin/web-password-generator
```

**Avancé** `ps fauxw | grep containe[r] -C 1 `

On voit que portainer est lancé via Docker, tout comme notre générateur de mots de passe. 

Le process "important", celui qui est spécifique à l'image, est un enfant du process `containerd-shim-runc-v2`.

**Quand on parle de Docker, c'est une simplification, car en fait un système de ce type dépend toujours de plusieurs composants.**

Analogie : on dit qu'on conduit une voiture, mais une voiture est nécessairement composée d'un moteur, de roues, d'une boîte de vitesse, etc.

`containerd-shim-runc-v2` est un composant chargé de démarrer les process dans les images docker pour l'utilisateur.

Ce sont ces process que l'on appelle les "conteneurs".

Docker surveille l'état des conteneurs, les relancer en cas de problème, les arrêter, etc.
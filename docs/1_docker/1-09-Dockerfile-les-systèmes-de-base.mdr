---
title: "Dockerfile : les systèmes de base"
pre: "<b>1.09 </b>"
weight: 10
---
## Objectifs pédagogiques

  - Savoir trouver et choisir les systèmes de base
  - Savoir utiliser les commandes FROM ... AS ...

---

## Instruction `FROM`

C'est l'instruction fondamentale des Dockerfiles. 

Elle fournit l'image de base à partir de laquelle est construite l'image qu'on va construire.

**On peut utiliser toute image Docker comme base.**

Le Dockerhub fournit une liste des images de base "officielles" :

> https://hub.docker.com/search?q=&type=image&image_filter=official

---

Il y a généralement 2 chemins que l'on peut suivre : 

1. Soit on veut déployer une application maison, et dans ce cas on peut utiliser une image de base généraliste qu'on va customiser.
  * Debian-based (Debian, Ubuntu, ...)
  * RHEL-based (CentOs, Rocky, ...)
  * Alpine
2. Soit on veut déployer une solution standard, et dans ce cas on utilise une image dédiés:
  * langage (python, nodejs, ...)
  * serveur web (Nginx, Traefik, ...)
  * DBMS (Postgres, MySQL, ...)
  * NoSQL (redis, mongoDB, ...) 
  * services (prometheus, registry, ...)
  * autres (busybox, hello-world, ...)


## Optimiser la création d'images

Les images Docker ont souvent une taille de plusieurs centaines de **mégaoctets** voire parfois **gigaoctets**. `docker image ls` permet de voir la taille des images.

Or, on construit souvent plusieurs dizaines de versions d'une application par jour (souvent automatiquement sur les serveurs d'intégration continue).

**L'espace disque devient alors un sérieux problème.**

Le principe de Docker est justement d'avoir des images légères car on va créer beaucoup de conteneurs (un par instance d'application/service).

De plus on télécharge souvent les images depuis un registry, ce qui consomme de la bande passante.

> La principale **bonne pratique** dans la construction d'images est de **limiter leur taille au maximum**.

---

## Limiter la taille d'une image

Choisir une image Linux de base **minimale**:

Une image `ubuntu` complète pèse déjà presque une soixantaine de mégaoctets.

mais une image trop rudimentaire (`busybox`) est difficile à débugger et peu bloquer pour certaines tâches à cause de binaires ou de bibliothèques logicielles qui manquent (compilation par exemple).

Souvent on utilise des images de base construites à partir de `alpine` qui est un bon compromis (6 mégaoctets seulement et un gestionnaire de paquets `apk`).

Par exemple `python3` est fourni en version `python:alpine` (99 Mo), `python:3-slim` (179 Mo) et `python:latest` (918 Mo).

---

# Créer des conteneurs personnalisés

Il n'est pas nécessaire de partir d'une image Linux vierge pour construire un conteneur.

On peut utiliser la directive `FROM` avec n'importe quelle image.

De nombreuses applications peuvent être configurées en étendant une image officielle
_Exemple : une image Wordpress déjà adaptée à des besoins spécifiques._

L'intérêt ensuite est que l'image est disponible préconfigurée pour construire ou mettre à jour une infrastructure, ou lancer plusieurs instances (plusieurs containers) à partir de cette image.

C'est grâce à cette fonctionnalité que Docker peut être considéré comme un outil d'_infrastructure as code_.

On peut également prendre une sorte de "capture" du conteneur (de son système de fichiers, pas des processus en train de tourner) sous forme d'image avec `docker commit <image>` et `docker push`.

---

### Une image plus simple

A l'aide de l'image `python:3.9-alpine` et en remplaçant les instructions nécessaires (pas besoin d'installer `python3-pip` car ce programme est désormais inclus dans l'image de base), repackagez l'app microblog en une image taggée `microblog:slim` ou `microblog:light`. Comparez la taille entre les deux images ainsi construites.

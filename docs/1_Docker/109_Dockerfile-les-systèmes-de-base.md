---
title: "Cours Dockerfile : les systèmes de base"
---

<!-- ## Objectifs pédagogiques

  - Savoir trouver et choisir les systèmes de base
  - Savoir utiliser les commandes FROM ... AS ... -->

## Instruction `FROM`

C'est l'instruction fondamentale des Dockerfiles. 

Elle fournit l'image de base à partir de laquelle est construite l'image qu'on va construire.

**On peut utiliser toute image Docker comme base.**

Le Dockerhub fournit une liste des images de base "officielles" :

> https://hub.docker.com/search?q=&type=image&image_filter=official


**Il y a généralement 2 chemins que l'on peut suivre.**

1. Soit on veut déployer une application maison, et dans ce cas on peut utiliser une image de base généraliste qu'on va customiser.
  * Debian-based (debian, ubuntu, ...)
  * RedHat-based (ubi, etc, ...)
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

> La principale **bonne pratique** dans la construction d'images est de **limiter leur taille (mais pas forcément au détriment de tout)**.

Alors qu'une image Docker de 1 Go en développement local est insignifiante en termes de consommation d'espace, les inconvénients deviennent apparents dans les pipelines CI/CD, où vous pourriez avoir besoin de récupérer une image spécifique plusieurs fois pour exécuter des tâches. Alors que la bande passante et l'espace disque sont bon marché, le temps ne l'est pas. Chaque minute supplémentaire ajoutée au temps de CI s'accumule pour devenir conséquente.

Par exemple, chaque minute ou deux de temps de construction supplémentaire qui peut être optimisée pourrait s'ajouter au fil du temps pour représenter des heures de temps perdues chaque année

## Comment limiter la taille d'une image

Choisir une image Linux de base **minimale**:

Une image `ubuntu` complète pèse déjà presque une soixantaine de mégaoctets.

mais une image trop rudimentaire (`busybox`) est difficile à débugger et peu bloquer pour certaines tâches à cause de binaires ou de bibliothèques logicielles qui manquent (compilation par exemple).

Par exemple `python3` est fourni en version `python:alpine` (99 Mo), `python:3-slim` (179 Mo) et `python:latest` (918 Mo).

## Créer des conteneurs personnalisés

Il n'est pas nécessaire de partir d'une image Linux vierge pour construire un conteneur. On peut utiliser la directive `FROM` avec n'importe quelle image.

De nombreuses applications peuvent être configurées en étendant une image officielle
_Exemple : une image Wordpress déjà adaptée à des besoins spécifiques._

L'intérêt ensuite est que l'image est disponible préconfigurée pour construire ou mettre à jour une infrastructure, ou lancer plusieurs instances (plusieurs containers) à partir de cette image.

C'est aussi grâce à cette fonctionnalité que Docker peut être considéré comme un outil d'_infrastructure as code_.

On peut également prendre une sorte de "capture" du conteneur (de son système de fichiers, pas des processus en train de tourner) sous forme d'image avec `docker commit <conteneur> <repo/image_name>:<tag/version>` et `docker push`.

## Avancé : bien choisir son image de base un choix complexe (et partiellement subjectif ?)

Beaucoup de personnes utilisent des images de base construites à partir de `alpine` qui est un bon compromis (6 mégaoctets seulement et un gestionnaire de paquets `apk`). Mais ce choix a aussi ses inconvénients:

- https://pythonspeed.com/articles/alpine-docker-python/

Les images basées sur `debian-slim` et redhat `ubi-micro` sont a peine plus lourde et probablement plus solide/sécurisées et polyvalentes.

A mentionner: les images de base distroless : un projet de Google des images linux Debian de base mais sans tout ce qui fait la distribution (notamment apt) => a utiliser pour injecter les elements prébuildé dans un build multistage.

- avantage encore plus léger et moins de surface d'attaque
- images plus difficiles à patcher pour des failles car on ne peut pas utiliser le travail de la distribution

Pour s'y retrouver on peut se référer à ce comparatif assez complet (bien que pro-redhat) : https://crunchtools.com/comparison-linux-container-images/

Pour entrer dans les détails d'une image on peut installer et utiliser https://github.com/wagoodman/dive. C'est souvent nécessaire quand on optimiser au maximum son image d'avoir conscience de tous les fichiers
---
title: Les images Docker Analyse d'une récupération
pre: "<b>2.02 </b>"
weight: 15
---
## Objectifs pédagogiques
  - Identifier les strates qui composent une image docker
  - Comprendre comment les étapes du Dockerfile commandent les couches

![](../assets/images/docker-cycle.jpg)
**Docker** possède à la fois un module pour lancer les applications (runtime) et un **outil de build** d'application.

- Une image est le **résultat** d'un build :
  - on peut la voir un peu comme une boîte "modèle" : on peut l'utiliser plusieurs fois comme base de création de containers identiques, similaires ou différents.

Pour lister les images on utilise :

```bash
docker images
docker image ls
```

---

## Les conteneurs

- Un conteneur est une instance en cours de fonctionnement ("vivante") d'une image.
  - un conteneur en cours de fonctionnement est un processus (et ses processus enfants) qui tourne dans le Linux hôte (mais qui est isolé de celui-ci)

## Commandes Docker

Docker fonctionne avec des sous-commandes et propose de grandes quantités d'options pour chaque commande.

Utilisez `--help` au maximum après chaque commande, sous-commande ou sous-sous-commandes

```bash
docker image --help
```

---
title: 2.02 Les images Docker Analyse d'une récupération
pre: "<b>2.02 </b>"
weight: 15
---
## Objectifs pédagogiques
  - Identifier les strates qui composent une image docker
  - Comprendre comment les étapes du Dockerfile commandent les couches

![](../assets/images/docker-cycle.jpg)

---

# Que se passe-t-il quand on pull une image ?

```shell
$ docker pull python:3.9
```
On voit que différentes couches sont récupérées individuellement.

Ces couches ont des identifiants, des hashs, et des poids, donc des contenus, différents

Observez l'historique de construction de l'image avec 

```shell
$ docker image history python:3.9
```

On peut également avoir des informations avancées avec 

```shell
$ docker image inspect python:3.9
```

---

# Décortiquer une image

Une image est composée de plusieurs layers empilés entre eux par le Docker Engine et de métadonnées.

- Affichez la liste des images présentes dans votre Docker Engine.

- Inspectez la dernière image que vous venez de créez (`docker image --help` pour trouver la commande)

- Observez l'historique de construction de l'image avec `docker image history <image>`

- Visitons **en root** (`sudo su`) le dossier `/var/lib/docker/` sur l'hôte. En particulier, `image/overlay2/layerdb/sha256/` :

  - On y trouve une sorte de base de données de tous les layers d'images avec leurs ancêtres.
  - Il s'agit d'une arborescence.

- Vous pouvez aussi utiliser la commande `docker save votre_image -o image.tar`, et utiliser `tar -C image_decompressee/ -xvf image.tar` pour décompresser une image Docker puis explorer les différents layers de l'image.

- Pour explorer la hiérarchie des images vous pouvez installer `https://github.com/wagoodman/dive`

---
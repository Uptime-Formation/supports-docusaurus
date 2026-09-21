---
title:  Les images Docker Analyse d'une récupération
weight: 15
---

## Les images Docker Analyse d'une récupération

## Objectifs pédagogiques
  - Identifier les strates qui composent une image docker
  - Comprendre comment les étapes du Dockerfile commandent les couches

![](../assets/images/docker-cycle.jpg)

---

# Que se passe-t-il quand on pull une image ?

```shell
$ docker pull python:3.9
3.9: Pulling from library/python
1e4aec178e08: Downloading [=========================================>         ]  45.75MB/55.05MB
6c1024729fee: Download complete 
c3aa11fbc85a: Download complete 
aa54add66b3a: Downloading [================================================>  ]  53.31MB/54.59MB
9e3a60c2bce7: Downloading [==========>                                        ]  40.86MB/196.9MB
3b2123ce9d0d: Waiting 
079055eff04f: Pulling fs layer 
efbdad4af3b4: Waiting 
6052bc42f4a6: Waiting 

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
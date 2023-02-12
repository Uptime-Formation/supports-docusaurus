---
title: Volumes Docker Monter des fichiers en ligne de commande
pre: "<b>2.07 </b>"
weight: 20
---
## Objectifs pédagogiques
  - Comprendre le montage dans les systèmes de fichier Linux
  - Savoir monter un volume dans un conteneur Docker


## Volumes

<-- Ajout schéma -->
<-- Ajout raisonnement tout ce qui est stateful sur un volume : fichiers de config, certifs, fichiers de base de données -->

## Les volumes Docker via la sous-commande `volume`

- `docker volume ls`
- `docker volume inspect`
- `docker volume prune`
- `docker volume create`
- `docker volume rm`

<-- ## Volumes nommés -->
<-- Où sont ils stockés -->


## Bind mounting

Lorsqu'un répertoire hôte spécifique est utilisé dans un volume (la syntaxe `-v HOST_DIR:CONTAINER_DIR`), elle est souvent appelée **bind mounting** ("montage lié").
C'est quelque peu trompeur, car tous les volumes sont techniquement "bind mounted". La particularité, c'est que le point de montage sur l'hôte est explicite plutôt que caché dans un répertoire appartenant à Docker.

Exemple :

```bash
# Sur l'hôte
docker run -it -v /home/user/app/config.conf:/config/main.conf:ro -v /home/user/app/data:/data ubuntu /bin/bash

# Dans le conteneur
cd /data/
touch testfile
exit

# Sur l'hôte
ls /home/user/app/data:
```

## Volumes nommés

- L'autre technique est de créer d'abord un volume nommé avec :
  `docker volume create mon_volume`
  `docker run -d -v mon_volume:/data redis`

---
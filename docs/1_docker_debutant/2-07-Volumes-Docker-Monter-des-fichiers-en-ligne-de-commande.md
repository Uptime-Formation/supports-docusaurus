---
title: 2.07 Volumes Docker Monter des fichiers en ligne de commande
pre: "<b>2.07 </b>"
weight: 20
---
## Objectifs pédagogiques
  - Comprendre le montage dans les systèmes de fichier Linux
  - Savoir monter un volume dans un conteneur Docker


## Volumes

Un volume est utile pour tout ce qui est "stateful" dans un conteneur :

* fichiers de config
* stockages de base de données
* certificats SSL
* etc.



# Bind mounting

Lorsqu'un répertoire hôte spécifique est utilisé dans un volume (la syntaxe `-v HOST_DIR:CONTAINER_DIR`), elle est souvent appelée **bind mounting** ("montage lié").

La particularité, c'est que le point de montage sur l'hôte est explicite plutôt que caché dans un répertoire appartenant à Docker.

Exemple :

```shell
# Sur l'hôte
docker run -it -v /home/user/app/config.conf:/config/main.conf:ro -v /home/user/app/data:/data ubuntu /bin/bash

# Dans le conteneur
cd /data/
touch testfile
exit

# Sur l'hôte
ls /home/user/app/data:
```

---

## L'argument docker run --mount

Cette option plus verbeuse que "-v" est préconisée car elle permet de bien spécifier les types de points de montage.

```shell
--mount type=TYPE, TYPE-SPECIFIC-OPTION[,...]
           Attacher un montage de système de fichiers au conteneur
           
       type=bind,source=/path/on/host,destination=/path/in/container
       type=volume,source=myvolume,destination=/path/in/container,volume-label="color=red",volume-label="shape=round"
       type=tmpfs,tmpfs-size=512M,destination=/path/in/container

```
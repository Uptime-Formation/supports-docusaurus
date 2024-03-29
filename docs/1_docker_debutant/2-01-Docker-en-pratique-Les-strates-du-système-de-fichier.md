---
title: Docker en pratique Les strates du système de fichier
pre: "<b>2.01 </b>"
weight: 14
---
## Objectifs pédagogiques
  - Connaître l'histoire qui mène à ce système de couche
  - Comprendre les avantages et inconvénients de ce système



## Les layers et la mise en cache

- **Docker construit les images comme une série de "couches" de fichiers successives.**

- On parle d'**Union Filesystem** car chaque couche (de fichiers) écrase la précédente.

![](../assets/images/overlay_constructs.jpg)
<-- ![](../assets/images/OverlayFS_Image.png) -->

<-- In order to understand the relationship between images and containers, we need to explain a key piece of technology that enables Docker—the UFS (sometimes simply called a union mount). Union file systems allow multiple file systems to be overlaid, appearing to the user as a single filesytem. Folders may contain files from multiple filesystems, but if two files have the exact same path, the last mounted file will hide any previous files. Docker supports several different UFS implentations, including AUFS, Overlay, devicemapper, BTRFS, and ZFS. Which implementation is used is system dependent and can be checked by running docker info where it is listed under “Storage Driver.” It is possible to change the filesystem, but this is only recom‐ mended if you know what you are doing and are aware of the advantages and disad‐ vantages.
Docker images are made up of multiple layers. Each of these layers is a read-only fil‐ eystem. A layer is created for each instruction in a Dockerfile and sits on top of the previous layers. When an image is turned into a container (from a docker run or docker create command), the Docker engine takes the image and adds a read-write filesystem on top (as well as initializing various settings such as the IP address, name, ID, and resource limits). -->

- Chaque couche correspond à une instruction du Dockerfile.

- `docker image history <conteneur>` permet d'afficher les layers, leur date de construction et taille respectives.

- Ce principe est au coeur de l'**immutabilité** des images Docker.

- Au lancement d'un container, le Docker Engine rajoute une nouvelle couche de filesystem "normal" read/write par dessus la pile des couches de l'image.

- `docker diff <container>` permet d'observer les changements apportés au conteneur depuis le lancement.

<-- ![](../assets/images/overlay.jpeg) -->

---


- Observez l'historique de construction de l'image avec `docker image history <image>`

- Il lance ensuite la série d'instructions du Dockerfile et indique un *hash* pour chaque étape.
  - C'est le *hash* correspondant à un *layer* de l'image

---



## _Facultatif_ : Décortiquer une image

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

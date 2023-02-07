---
title: "Dockerfile : build multistage"
pre: "<b>1.12 </b>"
weight: 13
---
## Objectifs pédagogiques
  - Savoir compiler un binaire dans un builder
  - Savoir utiliser les commandes COPY ... FROM ...

# Les layers et la mise en cache

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

# Optimiser la création d'images

- Les images Docker ont souvent une taille de plusieurs centaines de **mégaoctets** voire parfois **gigaoctets**. `docker image ls` permet de voir la taille des images.
- Or, on construit souvent plusieurs dizaines de versions d'une application par jour (souvent automatiquement sur les serveurs d'intégration continue).

  - L'espace disque devient alors un sérieux problème.

- Le principe de Docker est justement d'avoir des images légères car on va créer beaucoup de conteneurs (un par instance d'application/service).

- De plus on télécharge souvent les images depuis un registry, ce qui consomme de la bande passante.

> La principale **bonne pratique** dans la construction d'images est de **limiter leur taille au maximum**.

---

# Limiter la taille d'une image

- Choisir une image Linux de base **minimale**:

  - Une image `ubuntu` complète pèse déjà presque une soixantaine de mégaoctets.
  - mais une image trop rudimentaire (`busybox`) est difficile à débugger et peu bloquer pour certaines tâches à cause de binaires ou de bibliothèques logicielles qui manquent (compilation par exemple).
  - Souvent on utilise des images de base construites à partir de `alpine` qui est un bon compromis (6 mégaoctets seulement et un gestionnaire de paquets `apk`).
  - Par exemple `python3` est fourni en version `python:alpine` (99 Mo), `python:3-slim` (179 Mo) et `python:latest` (918 Mo).

<-- - Limiter le nombre de commandes de modification du conteneur :
  -  -->

---

## Les multi-stage builds

Quand on tente de réduire la taille d'une image, on a recours à un tas de techniques. Avant, on utilisait deux `Dockerfile` différents : un pour la version prod, léger, et un pour la version dev, avec des outils en plus. Ce n'était pas idéal.
Par ailleurs, il existe une limite du nombre de couches maximum par image (42 layers). Souvent on enchaînait les commandes en une seule pour économiser des couches (souvent, les commandes `RUN` et `ADD`), en y perdant en lisibilité.

Maintenant on peut utiliser les multistage builds.

Avec les multi-stage builds, on peut utiliser plusieurs instructions `FROM` dans un Dockerfile. Chaque instruction `FROM` utilise une base différente.
On sélectionne ensuite les fichiers intéressants (des fichiers compilés par exemple) en les copiant d'un stage à un autre.

Exemple de `Dockerfile` utilisant un multi-stage build :

```Dockerfile
FROM golang:1.7.3 AS builder
WORKDIR /go/src/github.com/alexellis/href-counter/
RUN go get -d -v golang.org/x/net/html
COPY app.go .
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o app .

FROM alpine:latest
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=builder /go/src/github.com/alexellis/href-counter/app .
CMD ["./app"]
```

---


## _Facultatif :_ Un multi-stage build

Transformez le `Dockerfile` de l'app `dnmonster` située à l'adresse suivante pour réaliser un multi-stage build afin d'obtenir l'image finale la plus légère possible :
<https://github.com/amouat/dnmonster/>

La documentation pour les multi-stage builds est à cette adresse : <https://docs.docker.com/develop/develop-images/multistage-build/>


##  _Facultatif_ : construire une image "à la main"

Avec `docker commit`, trouvons comment ajouter une couche à une image existante.
La commande `docker diff` peut aussi être utile.

{{% expand "Solution :" %}}

```bash
docker run --name debian-updated -d debian apt-get update
docker diff debian-updated 
docker commit debian-updated debian:updated
docker image history debian:updated 
```

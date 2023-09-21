---
title: "1.12 Dockerfile : build multistage"
pre: "<b>1.12 </b>"
weight: 13
---
## Objectifs pédagogiques
  - Savoir compiler un binaire dans un builder
  - Savoir utiliser les commandes COPY ... FROM ...


---

# Optimiser la création d'images : la suite 

> Rappel :La principale **bonne pratique** dans la construction d'images est de **limiter leur taille au maximum**.

Un des problèmes courants est de conserver dans l'image dont on n'aura pas besoin à l'exécution.

**Le cache des packages est un exemple.** 

On installera plus de packages à l'exécution.

C'est pouquoi dans le build on commence par lancer une mise à jour (ex: apt update) avant d'installer des packages : il n'y a pas de cache package dans l'image de base.   

**Les artefacts de build en sont un autre.**

À l'exécution, on aura pas besoin de tous les fichiers intermédiaires utilisés lors du build. 

On aura généralement besoin de l'exécutable produit.

---

## Les multi-stage builds

**Quand on tente de réduire la taille d'une image, on a recours à un tas de techniques. Avant, on utilisait deux `Dockerfile` différents : un pour la version prod, léger, et un pour la version dev, avec des outils en plus. Ce n'était pas idéal.**

Par ailleurs, il existe une limite du nombre de couches maximum par image (42 layers). Souvent on enchaînait les commandes en une seule pour économiser des couches (souvent, les commandes `RUN` et `ADD`), en y perdant en lisibilité.
  
---

**Maintenant on peut utiliser les multistage builds.**

Avec les multi-stage builds, on peut utiliser plusieurs instructions `FROM` dans un Dockerfile. Chaque instruction `FROM` utilise une base différente.
On sélectionne ensuite les fichiers intéressants (des fichiers compilés par exemple) en les copiant d'un stage à un autre.
  
---

**Exemple de `Dockerfile` utilisant un multi-stage build**  

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

La documentation pour les multi-stage builds est à cette adresse : 
> https://docs.docker.com/develop/develop-images/multistage-build/

  
---

##  _Facultatif_ : construire une image "à la main"

Avec `docker commit`, trouvons comment ajouter une couche à une image existante.
La commande `docker diff` peut aussi être utile.


```shell
docker run --name debian-updated -d debian apt-get update
docker diff debian-updated 
docker commit debian-updated debian:updated
docker image history debian:updated 
```
  
---

##  _Facultatif_ : construire une image avec une base "distroless"

Chercher la documentation sur les distroless. 

Quel est l'intérêt ? Quels sont les cas d'usage ? 
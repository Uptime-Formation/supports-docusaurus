---
title: "1.12 Dockerfile : build multistage"
pre: "<b>1.12 </b>"
weight: 13
---

## Objectifs pédagogiques
  - Savoir compiler un binaire dans un builder
  - Savoir utiliser les commandes COPY ... FROM ...


# Optimiser la création d'images : la suite 

> Rappel :La principale **bonne pratique** dans la construction d'images est de **limiter leur taille au maximum**.

Un des problèmes courants est de conserver dans l'image dont on n'aura pas besoin à l'exécution.

**Le cache des packages est un exemple.** 

On installera plus de packages à l'exécution.

C'est pouquoi dans le build on commence par lancer une mise à jour (ex: apt update) avant d'installer des packages : il n'y a pas de cache package dans l'image de base.   

**Les artefacts de build en sont un autre.**

À l'exécution, on aura pas besoin de tous les fichiers intermédiaires utilisés lors du build. 

On aura généralement besoin de l'exécutable produit.


## Les multi-stage builds

**Quand on tente de réduire la taille d'une image, on a recours à un tas de techniques. Avant, on utilisait deux `Dockerfile` différents : un pour la version prod, léger, et un pour la version dev, avec des outils en plus. Ce n'était pas idéal.**

Par ailleurs, il existe une limite du nombre de couches maximum par image (42 layers). Souvent on enchaînait les commandes en une seule pour économiser des couches (souvent, les commandes `RUN` et `ADD`), en y perdant en lisibilité.
  

**Maintenant on peut utiliser les multistage builds.**

Avec les multi-stage builds, on peut utiliser plusieurs instructions `FROM` dans un Dockerfile. Chaque instruction `FROM` utilise une base différente.
On sélectionne ensuite les fichiers intéressants (des fichiers compilés par exemple) en les copiant d'un stage à un autre.
  

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

## TP avancé : Un multi-stage build avec distroless comme image de base de prod

Chercher la documentation sur les images distroless. 
Quel est l'intérêt ? Quels sont les cas d'usage ? 

Objectif : transformer le `Dockerfile` de l'app nodejs (express) suivante en build multistage : https://github.com/Uptime-Formation/docker-example-nodejs-multistage-distroless.git
 Le builder sera par exemple basé sur l'image `node:20` et le résultat sur `gcr.io/distroless/nodejs20-debian11`.

La doc:
- https://docs.docker.com/build/building/multi-stage/

 Deux exemples simple pour vous aider:
 - https://alphasec.io/dockerize-a-node-js-app-using-a-distroless-image/
 - https://medium.com/@luke_perry_dev/dockerizing-with-distroless-f3b84ae10f3a

 Une correction possible dans la branche correction : `git clone https://github.com/Uptime-Formation/docker-example-nodejs-multistage-distroless/-b correction`

 L'image résultante fait tout de même environ 170Mo.

 Pour entrer dans les détails de l'image on peut installer et utiliser https://github.com/wagoodman/dive

 On peut alors constater que pour une application nodejs, même le minimum du minimum dans une image c'est déjà un joyeux bordel difficile à auditer: (confs linux + locales + ssl + autre + votre node_modules avec plein de lib + votre app)

## TP avancé: Essayer les builds multistage parallélisés

- Tutoriel : https://www.gasparevitta.com/posts/advanced-docker-multistage-parallel-build-buildkit/
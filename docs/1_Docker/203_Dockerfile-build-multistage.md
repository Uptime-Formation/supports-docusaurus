---
title: "Cours+TP : les builds multistage"
---

<!-- ## Objectifs pédagogiques
  - Savoir compiler un binaire dans un builder
  - Savoir utiliser les commandes COPY ... FROM ... -->

> Rappel :La principale **bonne pratique** dans la construction d'images est de **limiter leur taille au maximum**.

Un des problèmes courants est d'être obliger de conserver dans l'image des fichiers dont on n'aura pas besoin à l'exécution.

- Parce qu'on a pas besoin de tous les fichiers intermédiaires utilisés lors du build.
- Parce qu'on a besoin d'une image lourde par exemple avec tout gcc pour builder certaines librairies (pip et npm par exemple)

On se retrouve avec des images de 1GB basé par exemple sur `python` "full" pour pas grand chose.

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

### Exemple : notre application microblog en multistage avec python slim

```Dockerfile
# Stage 1
FROM python:3.9 AS builder

WORKDIR /microblog

COPY ./requirements.txt /requirements.txt
RUN pip3 install -r /requirements.txt

# Stage 2
FROM python:3.9-slim

COPY --from=builder /usr/local/ /usr/local/

# Ajoute un user et groupe appelés microblog
RUN  useradd -ms /bin/bash -d /microblog microblog

USER microblog
WORKDIR /microblog

COPY --chown=microblog:microblog . /microblog

ENV CONTEXT=PROD
EXPOSE 5000

CMD ["./boot.sh"]
```

## TP : Un multi-stage build avec distroless comme image de base de prod

Chercher la documentation sur les images distroless. 
Quel est l'intérêt ? Quels sont les cas d'usage ? 

Objectif : transformer le `Dockerfile` de l'app nodejs (express) suivante en build multistage : https://github.com/Uptime-Formation/docker-example-nodejs-multistage-distroless.git

Le builder sera par exemple basé sur l'image `node:20` et le résultat sur `gcr.io/distroless/nodejs20-debian11`.

La doc:
- https://docs.docker.com/build/building/multi-stage/

Reade de distroless:
- https://github.com/GoogleContainerTools/distroless

A noter que l'utilisateur par défaut de distroless est `nonroot` qui a l'UID 65535

Deux exemples pour vous aider:
- https://alphasec.io/dockerize-a-node-js-app-using-a-distroless-image/
- https://medium.com/@luke_perry_dev/dockerizing-with-distroless-f3b84ae10f3a

 Une correction possible dans la branche correction : `git clone https://github.com/Uptime-Formation/docker-example-nodejs-multistage-distroless/-b correction`

L'image résultante fait tout de même un peu plus de 170Mo, mais elle ne contient ni shell ni utilitaires unix ce qui réduit notamment la surface d'attaque et les signalements aux scans de sécurité.

Pour entrer dans les détails de l'image on peut installer et utiliser https://github.com/wagoodman/dive

On peut alors constater que pour une application nodejs, même le minimum du minimum dans une image c'est déjà un joyeux bordel difficile à auditer: (confs linux + locales + ssl + autre + votre node_modules avec plein de lib + votre app)


<details><summary>correction:</summary>
<p>

```dockerfile
# Stage 1
FROM node:20 AS base

WORKDIR /app
COPY package*.json /app/

# prod deps install
RUN npm install --omit=dev

# Stage 2
# Even simpler and more secure than node-alpine but not lighter because based on debian
FROM gcr.io/distroless/nodejs20-debian12

# use the unpriviledge user from distroless images

WORKDIR /app
COPY --chown=nonroot:nonroot index.js /app
COPY --chown=nonroot:nonroot --from=base /app/node_modules /app/node_modules

ENV NODE_ENV="production"
EXPOSE 3000

USER nonroot
CMD ["index.js"]
```

</p>
</details>



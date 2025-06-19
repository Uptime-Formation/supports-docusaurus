---
title: Docker - Les images 
weight: 0
---

## Les images Docker

![](../../static/img/docker/docker-image-layers.png)

---  

**Chaque layer correspond à une information qui peut être mise en cache**

Quel est l'intérêt ? 

Quelles sont les impacts en terme de construction de Dockerfiles ?

Savez-vous ce que fait la commande `docker commit` ? En quoi est-elle utile ? 

---

## Dockerfile 

Voici un Dockerfile. Qu'en pensez-vous ? 

```Dockerfile
ARG FROM=alpine:3.21
FROM ${FROM} 

ENV APP="/app"
ENV USER="nonroot"
ENV AWS_KEY="fd60687f-40d0-1b5be705b21e-4ba1-9fee"

LABEL org.opencontainers.image.authors='author@company.org' \
      org.opencontainers.image.url='https://tool.company.org' \
      org.opencontainers.image.documentation='https://app.readthedocs.org' \
      org.opencontainers.image.source='https://github.com/compagny/tool' \
      org.opencontainers.image.vendor='The Company' \
      org.opencontainers.image.licenses='Apache-2.0'
      
RUN apk --update --no-cache add nginx=1.22.1-r1
RUN adduser -h ${APP} -D ${USER}
WORKDIR ${APP}
COPY . .

EXPOSE 80
VOLUME /data

HEALTHCHECK --interval=5m --timeout=3s \
  CMD curl -f http://localhost/ || exit 1

ENTRYPOINT ["./entrypoint.sh"]
CMD ["nginx"]

```

---

## Build = Dockerfile -> Image

La commande pour construire une image est :

```shell
docker build [-t <tag:version>] [-f <chemin_du_dockerfile>] <contexte_de_construction>
```

Observez l'historique de construction de l'image avec `docker image history <image>`

---

**Installer l'outil Dive pour analyser en détail la construction d'une image**

cf. [https://github.com/wagoodman/dive](https://github.com/wagoodman/dive)

---

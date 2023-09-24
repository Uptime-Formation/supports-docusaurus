---
title: 3.08 Déployer avec docker Utiliser un reverse proxy
weight: 35
---

## Objectifs pédagogiques
  - Connaître le fonctionnement d'un reverse proxy
  - Savoir utiliser Traefik pour docker

## Gérer le reverse proxy

Avec Traefik, aussi grâce aux labels sur les conteneurs Docker

![](../assets/images/traefik-architecture.png)

Ou avec Nginx, avec deux projets :

- https://github.com/nginx-proxy/nginx-proxy
- https://github.com/nginx-proxy/acme-companion

## Exercice 1 - Utiliser Traefik pour le routage

Traefik est un reverse proxy très bien intégré à Docker. Il permet de configurer un routage entre un point d'entrée (ports `80` et `443` de l'hôte) et des containers Docker, grâce aux informations du daemon Docker et aux `labels` sur chaque containers.
Nous allons nous baser sur le guide d'introduction [Traefik - Getting started](https://doc.traefik.io/traefik/getting-started/quick-start/).

Avec l'aide de la documentation Traefik, ajoutez une section pour le reverse proxy Traefik pour dans un fichier Docker Compose de votre choix.


---

```yaml
services:
  reverse-proxy:
    # The official v2 Traefik docker image
    image: traefik:v2.3
    # Enables the web UI and tells Traefik to listen to docker
    command: --api.insecure=true --providers.docker
    ports:
      # The HTTP port
      - "80:80"
      # The Web UI (enabled by --api.insecure=true)
      - "8080:8080"
    volumes:
      # So that Traefik can listen to the Docker events
      - /var/run/docker.sock:/var/run/docker.sock
```


**Explorez le dashboard Traefik accessible sur le port indiqué dans le fichier Docker Compose.**

Pour que Traefik fonctionne, 2 étapes :
- faire en sorte que Traefik reçoive la requête quand on s'adresse à l'URL voulue (DNS + routage)
- faire en sorte que Traefik sache vers quel conteneur rediriger le trafic reçu (et qu'il puisse le faire) 

Ajouter des labels à l'app web que vous souhaitez desservir grâce à Traefik à partir de l'exemple de la doc Traefik, grâce aux labels ajoutés dans le `docker-compose.yml` (attention à l'indentation).

---

```yaml
# ...
whoami:
  # A container that exposes an API to show its IP address
  image: traefik/whoami
  labels:
    - "traefik.http.routers.whoami.rule=Host(`whoami.docker.localhost`)"
```

---

Avec l'aide de la [documentation Traefik sur Let's Encrypt et Docker Compose](https://doc.traefik.io/traefik/user-guides/docker-compose/acme-http/), configurez Traefik pour qu'il crée un certificat Let's Encrypt pour votre container.

---

Remplacer le service `reverse-proxy` précédent par :

```yaml
reverse-proxy:
    image: "traefik:v2.3"
    container_name: "traefik"
    command:
      #- "--log.level=DEBUG"
      - "--api.insecure=true"
      - "--providers.docker=true"
      - "--providers.docker.exposedbydefault=false"
      - "--entrypoints.websecure.address=:443"
      - "--certificatesresolvers.myresolver.acme.tlschallenge=true"
      #- "--certificatesresolvers.myresolver.acme.caserver=https://acme-staging-v02.api.letsencrypt.org/directory"
      - "--certificatesresolvers.myresolver.acme.email=postmaster@domain.com"
      - "--certificatesresolvers.myresolver.acme.storage=/letsencrypt/acme.json"
    ports:
      - "443:443"
      - "8080:8080"
    volumes:
      - "./letsencrypt:/letsencrypt"
      - "/var/run/docker.sock:/var/run/docker.sock:ro"

whoami:
    image: "traefik/whoami"
    container_name: "simple-service"
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.whoami.rule=Host(`user.place.domain.tld`)"
      - "traefik.http.routers.whoami.entrypoints=websecure"
      - "traefik.http.routers.whoami.tls.certresolver=myresolver"


```

Il faut remplacer l'e-mail `postmaster@mydomain.com` par un autre ne terminant pas par `mydomain.com`).

Et remplacer `user.place.domain.tld`


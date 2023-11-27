---
title: Passer des informations Les secrets Docker
sidebar_class_name: hidden
---

<!-- ## Objectifs pédagogiques
  - Comprendre les dangers d'exposer les secrets
  - Savoir utiliser les secrets avec Docker

---  -->

# Mauvaise pratique : exposer les secrets  

Le nombre de piratage dus aux secrets intégrés dans le code ou dans les Dockerfile d'applications est élevé. 

De telle sorte qu'il est désormais courant que des détections automatiques soient effectuées dans les environnements de CI/CD pour détecter et bloquer le passage d'informations critiques "en dur".

Ces informations sont typiquement 

* Des clefs d'accès à des API (cloud, services externes, ...)
* Des mots de passe (de base de données, de stockage)
* Des identifiants sensibles 
* Des URLs privées
* ...

# Les secrets Docker : disponibles dans Swarm

Il existe bien une page sur les secrets dans Docker mais ils sont réservés à Swarm.

> https://docs.docker.com/engine/swarm/secrets/

Le principe est pourtant simple : on fournit à Docker un contenu, que le dockerengine stocke de manière chiffrée.

```shell
 echo "f94togJrq9BEqRfxgrtrlU48DlryHMPha" | docker secret create pg_db_password -
```

Ensuite on peut monter ce secret comme un volume accessible au process lancé.

```shell
docker service  create --name redis --secret my_secret_data redis:alpine
```
Èvidemment, `docker service` est dépendant de Swarm et ça ne marche pas avec `docker run`.

## Comment faire ? 

Il existe de nombreux moyens de régler ce problème de première importance.

Ces différents moyens impliquent d'injecter les secrets au moment de lancer Docker.

Et comme on l'a vu, désormais il n'est pas rare qu'on utilise d'autres plateformes pour lancer du Docker.

## En local avec des variables d'environnement 

C'est la solution simple : on lance l'image avec le paramètre --env 

```shell
docker run --name some-postgres -e POSTGRES_PASSWORD=mysecretpassword -d postgres
```

`-e` est la version courte de `--env` 

## Avec docker-compose 

On va voir cette solution juste après.

Parmi ses nombreux avantages elle supporte le fait d'accepter 

- de créer dynamiquement des secrets depuis un fichier
```yaml
version: "3"
secrets:
    db_password:
      file: ./db_password.txt
services:
  app:
    image: example-app:latest
    secrets:
      - db_password
```
- de consommer les secrets docker Swarm
```shell
echo P@55w0rd | docker secret create db_password -
# or
docker secret create db_password ./db_password.txt

```
```yaml
version: "3"
secrets:
    db_password:
      external: true
services:
  app:
    image: example-app:latest
    secrets:
      - db_password
```

## Depuis son orchestrateur 

Par exemple Kubernetes gère des objets secrets, qu'on peut injecter dans ses conteneurs.

On peut aussi par exemple faire appel à Hashicorp Vault, qui fournit une interface centrale pour les secrets.

---
title: Réseaux Docker Créer Lister Détruire
weight: 24
---

## Objectifs pédagogiques
  - Savoir utiliser les commandes volume (create, ls, rm, connect, prune)
  - Savoir lancer un conteneur Docker en le connectant à un réseau
  - Savoir faire communiquer deux conteneurs Docker

--- 


# Pourquoi du réseau ? Pour relier des conteneurs

Le cas classique est l'application web connectée à une base de donnée.

**Une fonctionnalité obsolète et déconseillée permettait de créer un lien entre des conteneurs sans sous-réseau manifeste**
  - avec l'option `--link` de `docker run`
  - avec l'instruction `link:` dans un docker composer

**Aujourd'hui il faut utiliser un réseau dédié créé par l'utilisateur ("user-defined bridge network")**
  - avec l'option `--network` de `docker run`
  - avec l'instruction `networks:` dans un docker composer

--- 

# Les commandes network 

$ docker create
$ docker ls
$ docker rm
$ docker connect
$ docker prune

**Documentation** :
$ man docker-network-create
- [https://docs.docker.com/network/](https://docs.docker.com/network/)

--- 

# Docker networking en action

**Pour expérimenter avec le réseau nous allons lancer une petite application nodejs d'exemple (moby-counter) qui fonctionne avec une file (_queue_) redis (comme une base de données mais pour stocker des paires clé/valeur simples).**

Récupérons les images depuis Docker Hub:
```shell
$ docker image pull redis:alpine
$ docker image pull russmckendrick/moby-counter
```
---

**Lancez la commande `ip -br a` pour lister vos interfaces réseau**

Pour connecter les deux applications créons un réseau manuellement:

```shell
$ docker network create moby-network
```
---

Docker implémente ces réseaux virtuels en créant des interfaces. Lancez la commande `ip -br a` de nouveau et comparez. Qu'est-ce qui a changé ?

---

**Maintenant lançons les deux applications en utilisant notre réseau**

```shell
$ docker run -d --name redis --network <réseau> redis:alpine
$ docker run -d --name moby-counter --network <réseau> -p 80:80 russmckendrick/moby-counter
```

Visitez la page de notre application. Qu'en pensez vous ? Moby est le nom de la mascotte Docker 🐳 😊. Faites un motif en cliquant.

Comment notre application se connecte-t-elle au conteneur redis ? Elle utilise ces instructions JS dans son fichier `server.js`:

```javascript
var port = opts.redis_port || process.env.USE_REDIS_PORT || 6379;
var host = opts.redis_host || process.env.USE_REDIS_HOST || "redis";
```
**En résumé par défaut notre application se connecte sur l'hôte `redis` avec le port `6379`**

---


**Explorons un peu notre réseau Docker.**

Exécutez (`docker exec`) la commande `ping -c 3 redis` à l'intérieur de notre conteneur applicatif (`moby-counter` donc). 

Quelle est l'adresse IP affichée ?

```shell
$ docker exec moby-counter ping -c3 redis
```

--- 

Affichez le contenu des fichiers `/etc/hosts` du conteneur (c'est la commande `cat` couplée avec `docker exec`). 

Nous constatons que Docker a automatiquement configuré l'IP externe **du conteneur dans lequel on est** avec l'identifiant du conteneur. 

De même affichez `/etc/resolv.conf` : le résolveur DNS a été configuré par Docker. 

C'est comme ça que le conteneur connaît l'adresse IP de `redis`. 

**Qu'est-ce que Docker fournit qui permet que ce ping fonctionne ?**

---

Pour s'en assurer interrogeons le serveur DNS de notre réseau `moby-network` en lançant la commande `nslookup redis` grâce à `docker exec` :
```shell
$ docker exec moby-counter nslookup redis
```
---

**Créez un deuxième réseau `moby-network2`**

Créez une deuxième instance de l'application dans ce réseau.
```shell
$ docker run -d --name moby-counter2 --network moby-network2 \
  -p 9090:80 russmckendrick/moby-counter`
```

Lorsque vous pingez `redis` depuis cette nouvelle instance `moby-counter2`

Qu'obtenez-vous ? Pourquoi ?

---

**Vous ne pouvez pas avoir deux conteneurs avec les mêmes noms comme nous l'avons déjà découvert.**

Par contre notre deuxième réseau fonctionne complètement isolé de notre premier réseau.

Ce qui signifie que nous pouvons toujours utiliser le nom de domaine `redis`. 

Pour ce faire nous devons spécifier l'option `--network-alias` :

Créons un deuxième redis avec le même domaine: 
```shell
$ docker run -d --name redis2 --network moby-network2 --network-alias redis redis:alpine`
```

Lorsque vous pingez `redis` depuis cette nouvelle instance de l'application, quelle IP obtenez-vous ?

---

Récupérez comme auparavant l'adresse IP du nameserver local pour `moby-counter2`.


Lancez `nslookup redis` dans le conteneur `moby-counter2` pour tester la résolution de DNS. 

Vous pouvez retrouver la configuration du réseau et les conteneurs qui lui sont reliés avec 

```shell
$ docker network inspect moby-network2
```
  Notez la section IPAM (IP Address Management).

---

Arrêtons nos conteneurs et faisons le ménage 

```shell
$ docker stop moby-counter2 redis2
$ docker container prune
```

 **De même `docker network prune` permet de faire le ménage des réseaux qui ne sont plus utilisés par aucun conteneur.**

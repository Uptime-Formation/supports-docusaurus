---
title: TP - Réseaux Docker - compter les baleines (😢)
---

Pour expérimenter avec le réseau nous allons **lancer une petite application nodejs d'exemple (moby-counter)** qui fonctionne avec un datastore **redis** (comme une base de données mais pour stocker des paires clé/valeur simples).**

![](/img/docker/schemas-perso/docker-auto-dns-tp-reseau.png)


**Lancez la commande `ip -br a` pour lister vos interfaces réseau**

Pour connecter les deux applications créons un réseau manuellement:

```shell
docker network create moby-network
```

Docker implémente ces réseaux virtuels en créant des interfaces. Lancez la commande `ip -br a` de nouveau et comparez. Qu'est-ce qui a changé ?

**Maintenant lançons les deux conteneurs en utilisant notre réseau**

```shell
docker run -d --name redis --network <réseau> redis:alpine
docker run -d --name moby-counter --network <réseau> -p 8080:80 russmckendrick/moby-counter
```

Visitez la page de notre application. Qu'en pensez vous ? Moby est le nom de la mascotte Docker 🐳 😊. Faites un motif en cliquant.

Comment notre application se connecte-t-elle au conteneur redis ? Elle utilise ces instructions JS dans son fichier `server.js`:

```javascript
var port = opts.redis_port || process.env.USE_REDIS_PORT || 6379;
var host = opts.redis_host || process.env.USE_REDIS_HOST || "redis";
```

l'application fait donc appel au nom de domaine `redis` pour découvrir (découverte de service) l'adresse IP de son datastore redis.


**Créez un deuxième réseau `moby-network2`**

Créez une deuxième instance de l'application moby-counter dans ce réseau ainsi qu'un deuxième redis.

```bash
docker run -d --name moby-counter2 --network moby-network2 -p 9090:80 russmckendrick/moby-counter
docker run -d --name redis2 --network moby-network2 redis:alpine`
```

### Explorons un peu notre réseau Docker.

Exécutez (`docker exec`) la commande `ping -c 3 redis` à l'intérieur de notre conteneur applicatif (`moby-counter` donc). 

```shell
docker exec moby-counter ping -c3 redis
```
Quelle est l'adresse IP retournée ?

Affichez le contenu de `/etc/resolv.conf` : le résolveur DNS a été configuré par Docker. 

C'est comme ça que le conteneur connaît l'adresse IP de `redis`. 

Maintenant lancez:

```shell
docker exec moby-counter2 ping -c3 redis
docker exec moby-counter2 ping -c3 redis2
```

Depuis le deuxième conteneur c'est à dire dans le deuxième réseau, nous on ne peut pas pinguer le nom de domaine `redis` car nous avons utilisé le nom   `redis2` pour le conteneur.

=> Notre application ne peut pas se connecter à son redis

Pour régler ce problème on peut soit changer l'application pour qu'elle utilise un autre nom de domaine ou on peut recréer redis et changer son "network alias":

- supprimez le conteneur redis2
- recréez le avec la commande : 

```shell
docker run -d --name redis2 --network moby-network2 --network-alias redis redis:alpine`
```

Pour aller un peu plus loin lancez:

```shell
docker network inspect moby-network2
```

Notez la section IPAM (IP Address Management).

Arrêtons nos conteneurs et faisons le ménage 

```shell
docker stop moby-counter2 redis2
docker container prune
docker network prune
```

 **De même que pour les autres resources, `docker network prune` permet de faire le ménage des réseaux qui ne sont plus utilisés par aucun conteneur.**

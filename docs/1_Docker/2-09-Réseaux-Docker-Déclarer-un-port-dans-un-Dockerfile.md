---
title: 2.09 Réseaux Docker Déclarer un port dans un Dockerfile
pre: "<b>2.09 </b>"
weight: 22
---
## Objectifs pédagogiques
  - Comprendre le mode de fonctionnement des ports dans Linux
  - Savoir utiliser la commande EXPOSE
  - Savoir exposer effectivement le port d'un conteneur

# Un petit rappel sur les ports (et le réseau)

**Les ports des protocoles TCP et UDP dans Linux ont quelques propriétés particulière.**

Seul l'utilisateur root a le droit d'ouvrir des ports inférieurs à 1024, indiquant que le service est autorisé par un administrateur système.

Pour rappel, c'est avec le triplet `(PROTOLE,ADDRESSE DESTINATION,PORT DESTINATION)` qu'on peut échanger avec un service sur le réseau.

ex: `(UDP,8.8.8.8,53)` pour faire du DNS sur les serveurs DNS de Google 

# Exposer le port dans un Dockerfile avec PORT

```dockerfile
EXPOSE <port> [<port>/<protocol>...]
```
**L'instruction EXPOSE informe Docker que le conteneur écoute sur les ports réseau spécifiés lors de l'exécution.**

Vous pouvez spécifier si le port écoute sur TCP ou UDP, et la valeur par défaut est TCP si le protocole n'est pas spécifié.

**L'instruction EXPOSE ne publie pas réellement le port.** 

Elle fonctionne comme un type de documentation entre la personne qui construit l'image et la personne qui exécute le conteneur, sur les ports destinés à être publiés. 

# Exporter effectivement le(s) port(s) d'un conteneur

**Pour publier réellement le port lors de l'exécution du conteneur, utilisez l'indicateur -p lors de l'exécution du docker pour publier et mapper un ou plusieurs ports, ou l'indicateur -P pour publier tous les ports exposés et les mapper aux ports de niveau supérieur.**

On publie le port grâce à la syntaxe `-p [ip_interface:]port_de_l_hote:port_du_container`.

```shell
$ docker run --rm -d --name "test_nginx" -p 8000:80 nginx # ouvre le port par défaut sur 0.0.0.0 toutes les interfaces
$ # ou bien plus securisé
$ docker run --rm -d --name "test_nginx" -p 127.0.0.1:8000: 80 nginx
$ curl http://localhost:8000
$ docker logs test_nginx
```

En visitant l'adresse et le port associé au conteneur Nginx, on doit voir apparaître des logs Nginx.

---

On peut lancer des logiciels plus ambitieux, comme par exemple Funkwhale, une sorte d'iTunes en web qui fait aussi réseau social :

```shell
$ docker run --name funky_conteneur -p 80:80 funkwhale/all-in-one:1.2.9
```

Vous pouvez visiter ensuite ce conteneur Funkwhale sur le port 80 (après quelques secondes à suivre le lancement de l'application dans les logs) ! Mais il n'y aura hélas pas de musique dedans :(

**Attention à ne jamais lancer deux containers connectés au même port sur l'hôte, sinon cela échouera !**
`

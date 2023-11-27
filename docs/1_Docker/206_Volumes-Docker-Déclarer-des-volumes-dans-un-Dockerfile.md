---
title: 2.06 Volumes Docker Déclarer des volumes dans un Dockerfile
pre: "<b>2.06 </b>"
weight: 19
---

## Objectifs pédagogiques
  - Savoir utiliser la commande VOLUME
  - Comprendre la persistance de données


## Cycle de vie d'un conteneur

- Un conteneur a un cycle de vie très court: il doit pouvoir être créé et supprimé rapidement même en contexte de production.

Conséquences :

- On a besoin de mécanismes d'autoconfiguration, en particuler réseau car les IP des différents conteneur changent tout le temps.
- On ne peut pas garder les données persistantes dans le conteneur.

Solutions :

- Des réseaux dynamiques par défaut automatiques (DHCP mais surtout DNS automatiques)
- Des volumes (partagés ou non, distribués ou non) montés dans les conteneurs

### L'instruction `VOLUME` dans un `Dockerfile`

```dockerfile
VOLUME ["/data"]
```
L'instruction `VOLUME` dans un `Dockerfile` permet de désigner les volumes qui devront être créés lors du lancement du conteneur. 

```dockerfile
FROM ubuntu
RUN mkdir /myvol
RUN date > /myvol/created_at
VOLUME /myvol
CMD ["bash", "-c", "cat /myvol/created_at"]
```

```shell
$ docker build -t created_at
$ docker run created_at
```

On précise ensuite avec l'option `-v` de `docker run` à quoi connecter ces volumes. 

Si on ne le précise pas, Docker crée quand même un volume Docker au nom généré aléatoirement, un volume "caché".

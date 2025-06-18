---
title: Conteneurs Docker Créer Lister et Détruire
weight: 7
---

## Objectifs pédagogiques
  - Savoir utiliser les commandes pull, stop/start, kill, stats, delete, prune 

---


# Nginx sur le Docker Hub

- Visitez [hub.docker.com](https://hub.docker.com) et cherchez l'image nginx

```shell
docker run --name nginx -d nginx
```

---


# Docker stop/start : stopper et redémarrer un conteneur

```shell
docker stop <nom_ou_id_conteneur> # ne détruit pas le conteneur
docker start <nom_ou_id_conteneur> # le conteneur a déjà été créé
docker start --attach <nom_ou_id_conteneur> # lance le conteneur et s'attache à la sortie standard
```

**On peut désigner un conteneur soit par le nom qu'on lui a donné, soit par le nom généré automatiquement, soit par son empreinte (toutes ces informations sont indiquées dans un `docker ps` ou `docker ps -a`).**

Essayez de stopper et redémarrer le conteneur "mycontainer".


---

# Docker kill : conteneurs récalcitrants
```
$ docker run --rm -d --name sleep ubuntu sleep 3600 
```
Essayez de stopper ce conteneur. Que se passe-t-il ? 

```
docker kill <conteneur>
```
--- 
# Docker stats : conteneurs et consommation

Il est temps de faire un petit `docker stats` pour découvrir l'utilisation du CPU et de la RAM de vos conteneurs !
```
$ docker stats
```

Ctrl+c pour quitter 

```
$ docker stats mycontainer 
```

---

# Docker delete : Faire du ménage 



Lancez la commande

```
$ docker ps -aq -f status=exited
```
Que fait-elle ?

S'il y a encore des conteneurs qui tournent, supprimez un des conteneurs restants 

```shell
$ docker rm <id_ou_nom>
```

Avancé : combinez docker rm et la commande ps précédente

---

# Docker prune : Faire du ménage automatiquement 

La commande prune supprimme automatiquement tous les conteneurs dans l'état STOPPED.

```shell
$ docker container prune
```

Note: on voit que la plupart des commandes qu'on a exécuté sont en fait dépendantes d'une ressource "container" dans la ligne de commande docker.
```shell
$ docker container ps
$ docker container run 
... etc
```

---

## Avancé : L'option restart=always

**Par défaut, le daemon docker ne redémarre pas les process qui sont arrêtés, mais il est possible (et recommandé) de définir une clause de redémarrage à la création.**

```shell
$ docker run -d --name redis --restart=always redis
$ docker exec -it redis bash -c "kill 1"
$ docker ps   
```
Que se passe-t-il ?

Plus d'infos sur https://docs.docker.com/engine/reference/run/#restart-policies-

---

## Avancé : Docker export / décortiquer un conteneur

En utilisant la commande suivante 

```shell 
$ mkdir ~/export 
$ docker export votre_conteneur -o ~/export/conteneur.tar
```

puis 
```shell 
$ cd ~/export; tar -xvf conteneur.tar
```
 
pour décompresser un conteneur Docker, explorez (avec l'explorateur de fichiers par exemple) jusqu'à trouver l'exécutable principal contenu dans le conteneur.

---

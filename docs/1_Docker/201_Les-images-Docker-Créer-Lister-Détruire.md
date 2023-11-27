---
title: 2.01 Les images Docker Créer Lister Détruire
pre: "<b>2.03 </b>"
weight: 16
---

## Objectifs pédagogiques
  - Savoir utiliser les commandes image de base (pull, ls, history, inspect, tag, prune)
  - Savoir identifier les images
  - Connaître les bonnes pratiques (Dockerfile, nettoyage, etc.)
  
![](../assets/images/docker-cycle.jpg)


<!-- --- -->

## Documentation 

* `docker image --help`
* https://docs.docker.com/engine/reference/commandline/images/
  
<!-- --- -->

# Les opérations sur les images 

## Lister : ls
Pour lister les images on utilise :

```shell
docker images
docker image ls
```
  
<!-- --- -->

## Construire : build 

La commande `build` est un alias pour `image build`

Elle dispose de très nombreuses options qu'il est intéressant de connaître à terme pour des raisons de sécurité.

```shell
$ man docker-image-build
```  
<!-- --- -->

## Télécharger : pull et push  

La commande `pull` est un alias pour `image pull`
La commande `push` est un alias pour `image push`

On les reverra dans la partie suivantes concernant les registres.

```shell
$ man docker-image-pull
```
  
<!-- --- -->

## Détruire : rm et prune

Le cycle de vie des images implique de faire du ménage fréquemment. 

La commande `rm` supprime une image spécifique.

La commande``prune` recherche les images sans conteneur démarré pour les supprimer.
 
```shell
$ docker image pull nging:1.14
$ docker image rm  nging:1.14
$ docker image pull busybox
$ docker image prune
```  
<!-- --- -->


## Identifier : tag

Attribue un nouvel alias à une image. 
Un alias fait référence au nom complet de l'image, y compris le TAG facultatif après le ':'.

```shell
$ docker image pull busybox
$ docker image tag busybox busybox:local
$ docker image tag busybox busybox:1.2.3
$ docker image ls 
busybox      1.2.3     66ba00ad3de8   5 weeks ago     4.87MB
busybox      latest    66ba00ad3de8   5 weeks ago     4.87MB
busybox      local     66ba00ad3de8   5 weeks ago     4.87MB
```    

Notez que par défaut si aucun numéro de version n'est fourni, docker utilise par défaut la version `latest`.

Bonne pratique : de ne pas s'appuyer sur ce mécanisme de `latest`. Pourquoi ?
  
<!-- --- -->

## Analyser : history et  inspect

Ces commandes offrent une vision historique ou technique de l'image, permettant d'identifier leur processus de construction et leur contenu.

- Supprimez une image
- Que fait la commande `docker image prune -a` ?
  
<!-- --- -->

## Exporter/Importer : save, load et import

On a vu qu'on peut exporter sous forme de tarball des conteneurs.

La commande `save` offre la même capacité avec les images.

Les commandes `load` et `import` permettent de les importer soit comme image soit comme conteneur.


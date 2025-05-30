---
title: "Conteneurs Docker: Premiers pas"
chapter: true
---

## Objectifs pédagogiques 

  - Connaître les outils permettant d'interagir avec docker
  - Lancer son premier conteneur

---

## Les outils pour interagir avec Docker

# Docker Hub : télécharger des images

Une des forces de Docker vient de la distribution d'images :

- pas besoin de dépendances, on récupère une boîte autonome

- pas besoin de multiples versions en fonction des OS

Dans ce contexte un élément qui a fait le succès de Docker est le Docker Hub : [hub.docker.com](https://hub.docker.com)

Il s'agit d'un répertoire public et souvent gratuit d'images (officielles ou non) pour des milliers d'applications pré-configurées.



On va tester l'image Hello World : [https://hub.docker.com/_/hello-world/](https://hub.docker.com/_/hello-world/)

---

### Ma première instance Docker

**`hello-world` est l'image Docker la plus simple pour commencer.**

Lancez la commande pour exécuter l'image, nous allons analyser son retour. 

```shell

docker run hello-world

```

---

**Que se passe-t-il si vous relancez la même commande ?**  

Une fois que vous avez téléchargé une image, vous pouvez la voir avec la commande :

```shell

docker images 

```

**Décomposons cette «ligne de commande»** 

```shell
$ docker run hello-world
```

* La commande 
```shell
"docker" est ici l'exécutable du client docker qu'on appelle sur la machine locale
```
* L'argument
```shell
"run" est un argument qui indique à l'exécutable ce qu'on veut faire.

En l'occurence c'est une commande Docker.

```
* Le sous-argument, le paramètre de la commande
```shell"
"hello-world"" est le nom d'une image Docker sur le DockerHub 
```

---

## Docker Hub, chercher une image

Visitez [hub.docker.com](https://hub.docker.com).

C'est l'endroit où va chercher Docker par défaut. 

On nomme cela un registry, on y reviendra.

Par exemple cherchez l'image "ubuntu" sur le Docker Hub.

---

### Docker Hub: comment ça marche ?

- On peut y chercher et trouver presque n'importe quel logiciel au format d'image Docker.

- Il suffit pour cela de chercher l'identifiant et la version de l'image désirée.

- Puis utiliser `docker run [<compte>/]<id_image>:<version>`

- La partie `compte` est le compte de la personne qui a poussé ses images sur le Docker Hub. Les images Docker officielles (`ubuntu` par exemple) ne sont pas liées à un compte : on peut écrire simplement `ubuntu:focal`.

- On peut aussi juste télécharger l'image : `docker pull <image>`

On peut également y créer un compte gratuit pour pousser et distribuer ses propres images, ou installer son propre serveur de distribution d'images privé ou public, appelé **registry**.

---

### Images vs Instances 

**Nous allons faire une distinction entre les deux concepts.** 

- Une **image** est une suite de fichiers téléchargeable, transférable, exploitable
- Une **instance** est une activation de l'image, son instanciation, l'exécution particulière d'un programme présent dans l'image.

Nous utiliserons l'analogie du plat surgelé : 

- l'image est un plat surgelé, disponible et reproduit en grande quantité.
- l'instance est un plat particulier que vous avez réchauffé, à consommer immédiatement 

---


### Portainer

Portainer est un portail web pour gérer une installation Docker via une interface graphique. Il va nous faciliter la vie.

- Lancer portainer avec la ligne de commande suivante

```shell
 docker run --name portainer -d -p 9000:9000 -v /var/run/docker.sock:/var/run/docker.sock portainer/portainer-ce:latest 
```

- Visitez ensuite la page [http://localhost:9000](http://localhost:9000) ou l'adresse IP publique de votre serveur Docker sur le port 9000 pour accéder à l'interface.
- il faut choisir l'option "local" lors de la configuration
- Créez votre user admin et choisir un mot de passe avec le formulaire.
- Explorez l'interface de Portainer.
- On va installer une application toute simple en téléchargeant d'abord une image nommée `camandel/web-password-generator`.
- Puis on va créer un conteneur avec cette image.
- On va exposer le port de cette application web en cliquant sur `Publish all exposed network ports to random host ports`
- Et on peut visiter la page affichée 
---

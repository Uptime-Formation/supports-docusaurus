---
title: "Conteneurs Docker: Premiers pas avec Portainer"
weight: 3
pre: "<b>1.02 </b>"
chapter: true
---

## Objectifs pédagogiques 
  - Connaître les outils permettant d'interagir avec docker
  - Lancer son premier conteneur


## Les outils pour interagir avec Docker

### Portainer

Portainer est un portail web pour gérer une installation Docker via une interface graphique. Il va nous faciliter la vie.

- Une instance de Portainer devrait être directement disponible sur l'url suivante

```bash
 http://localhost:9000/#!/2/docker/containers
```

- Visitez ensuite la page [http://localhost:9000](http://localhost:9000) ou l'adresse IP publique de votre serveur Docker sur le port 9000 pour accéder à l'interface.
- il faut choisir l'option "local" lors de la configuration
- Créez votre user admin et choisir un mot de passe avec le formulaire.
- Explorez l'interface de Portainer.
- On va installer une application toute simple en téléchargeant d'abord une image nommée `camandel/web-password-generator`.
- Puis on va créer un conteneur avec cette image.
- On va exposer le port de cette application web en cliquant sur `Publish all exposed network ports to random host ports`
- Et on peut visiter la page affichée 


# Docker Hub : télécharger des images

Une des forces de Docker vient de la distribution d'images :

- pas besoin de dépendances, on récupère une boîte autonome

- pas besoin de multiples versions en fonction des OS

Dans ce contexte un élément qui a fait le succès de Docker est le Docker Hub : [hub.docker.com](https://hub.docker.com)

Il s'agit d'un répertoire public et souvent gratuit d'images (officielles ou non) pour des milliers d'applications pré-configurées.

---

# Docker Hub:

- On peut y chercher et trouver presque n'importe quel logiciel au format d'image Docker.

- Il suffit pour cela de chercher l'identifiant et la version de l'image désirée.

- Puis utiliser `docker run [<compte>/]<id_image>:<version>`

- La partie `compte` est le compte de la personne qui a poussé ses images sur le Docker Hub. Les images Docker officielles (`ubuntu` par exemple) ne sont pas liées à un compte : on peut écrire simplement `ubuntu:focal`.

- On peut aussi juste télécharger l'image : `docker pull <image>`

On peut également y créer un compte gratuit pour pousser et distribuer ses propres images, ou installer son propre serveur de distribution d'images privé ou public, appelé **registry**.


### Partie avancée

- Lancer une instance de Portainer :

```bash
docker volume create portainer_data_2
docker run --detach --name portainer \
    -p 9000:9001 \
    -v portainer_data_2:/data \
    -v /var/run/docker.sock:/var/run/docker.sock \
    portainer/portainer-ce
```

- Remarque sur la commande précédente : pour que Portainer puisse fonctionner et contrôler Docker lui-même depuis l'intérieur du conteneur il est nécessaire de lui donner accès au socket de l'API Docker de l'hôte grâce au paramètre `--volume` ci-dessus.

---
title: "TP Les registries"
---

<!-- ## Objectifs pédagogiques
  - Comprendre le fonctionnement des registries
  - Savoir installer un registry local
  - Savoir utiliser la commande push

--- -->

## Publier des images vers un registry privé

**Généralement les images spécifiques produites par une entreprise n'ont pas vocation à finir dans un dépôt public.**

On peut installer des **registries privés**.

On utilise alors `docker login <adresse_repo>` pour se logger au registry et le nom du registry dans les `tags` de l'image.

Exemples de registries privés en Saas  :
  - **Docker Hub** fournit un service payant, comme Azure, Google, etc.
  - **gcr.io : Google Registry** : Le service d'images
  - **quay.io : RedHat Registry** : Propose des scans de sécurité de série pour toutes les images open sources poussées.
  - **Gitlab** fournit un registry très intéressant car intégré dans leur workflow DevOps.
  - **Github** idem.

On premise:
  - **Docker Registry** correctement configuré est une solution pour les besoins simples. 
  - **JFrog Artifactory** un registry d'artefact au dela des images de conteneurs
  - **Harbor** un solutions libre et puissante du CNCF.


 **Note plus avancée** : un registry est un serveur qui implémente l'**API HTTP Docker** (voir TP optionnel en dessous)

## TP - installer un Registry privé de base

Utiliser la commande search pour chercher dans le dockerhub des images.

```shell
docker search registry 
```

Vous remarquez qu'une image se détache. Laquelle et pourquoi ?

En récupérant [la commande indiquée dans la doc officielle](https://docs.docker.com/registry/deploying/), créez votre propre registry.

```shell
# Créer le registry
docker run -d -p 127.0.0.1:5555:5000 --restart=always --name registry registry:2
```


**Puis pousser une image dessus.**

Marquez l'image comme localhost:5000/my-ubuntu. 

Cela crée un tag supplémentaire pour l'image existante. 

**Lorsque la première partie du tag est un nom d'hôte et un port, Docker l'interprète comme l'emplacement d'un registre lors de la transmission.**

```shell
# Y pousser une image
docker tag ubuntu:latest localhost:5555/my-ubuntu:mytag-custom
docker tag ubuntu:latest localhost:5555/my-ubuntu:latest
docker image ls localhost:5555/my-ubuntu
docker push localhost:5555/my-ubuntu:mytag-custom
```

**Enfin, supprimez votre image en local et récupérez-la depuis votre registry.**

```shell
# Supprimer l'image en local
docker image remove ubuntu
docker image remove localhost:5555/my-ubuntu:mytag-custom
```


Extrayez l'image localhost:5000/my-ubuntu de votre registre local.

```shell
# Récupérer l'image depuis le registry
docker pull localhost:5555/my-ubuntu:mytag-custom
```



## _Facultatif :_  push sur le Docker Hub

Cette manipulation requiert la création d'un compte sur [le Docker Hub](https://hub.docker.com/).

Avec `docker login`, `docker tag` et `docker push`, poussez l'image `microblog` sur le Docker Hub. Créez un compte sur le Docker Hub le cas échéant.

```shell
docker login
docker tag microblog:latest docker.io/<your-docker-registry-account>/microblog:latest
docker push docker.io/<your-docker-registry-account>/microblog:latest
```

(Ajouter docker.io est facultatif car il s'agit du registry par défaut avec Docker. Par contre c'est nécessaire pour pousser vers d'autres registries )

## TP optionnel : utiliser l'API http avec curl

Regardez les liens suivants:

- https://www.baeldung.com/ops/docker-registry-api-list-images-tags
- https://stackoverflow.com/questions/56193110/how-can-i-use-docker-registry-http-api-v2-to-obtain-a-list-of-all-repositories-i

Puis:

- Listez les repositories (les noms d'images) dans notre registry local
- Listez les tags (les "versions") de `my-ubuntu`


## TP optionnel - poussez notre image sur Quay.io pour bénéficier du scan de securité

- Créez un compte sur Quay
- suivez les instruction de login
- Poussez votre image sur le registry pour lire les CVE (identifiants et descriptifs de failles connues)

 https://developers.redhat.com/blog/2019/06/26/using-quay-io-to-find-vulnerabilities-in-your-container-images

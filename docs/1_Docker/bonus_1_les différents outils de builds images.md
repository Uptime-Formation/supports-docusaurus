---
title: Bonus 1 - les différents outils de build d'images
weight: 39
---

Quelques références:

- https://lablabs.io/building-container-images-in-cloud-native-ci-pipelines/
- 

## En résumé

### Docker Buildkit

- https://docs.docker.com/build/buildkit/

Est le (nouveau) builder par défaut de Docker depuis quelques années.

- Très performant, parallélisé, cache intelligent dans des multistage builds.
- Peut faire des builds multiplateforme avec buildx

- Inconvénient : pour les CI/CD il faut du Docker in Docker qui pas idéal en terme de sécurité voire impossible dans certains contextes (un cluster K8s sans docker).

## Kaniko:

Outil de Google pour builder efficacement sans Docker à partir d'un Dockerfile, notamment dans un cluster Kubernetes. Tourné vers la CI/CD
Permet de pousser le cache des build vers un serveur pour ne pas le perdre quand le build est réalisé dans un agent on demand temporaire (Jenkins in K8s par exemple)

Le gros avantage est de pouvoir builder avec n'importe quelle runtime de conteneur (c'est un peu risqué d'être dépendant de Docker pour le futur ?)

- L'inconvénient c'est qu'il ne se comporte pas forcément exactement comme Docker donc il faut un peu travailler pour builder des choses.
- Build seulement pour l'architecture x86_64

- https://github.com/GoogleContainerTools/Kaniko : Plusieurs getting started dans le README

- Présentation plus détaillée : https://cloud.google.com/blog/products/containers-kubernetes/introducing-kaniko-build-container-images-in-kubernetes-and-google-container-builder-even-without-root-access?hl=en

- Exemple de pipeline Gitlab Kaniko: https://gitlab.com/guided-explorations/containers/kaniko-docker-build

- Tutoriel d'intro: https://www.baeldung.com/ops/kaniko


## Buildah

Un builder initialement de RedHat désormais maintenu par l'Open Container Initiative (respecte encore plus directement les standards ouverts de conteneurs)

- Fonctionne avec Podman (une CLI docker compatible Daemonless)
- Il Peut tourner en mode non privilégié donc plus sécurisé que Docker.
- Il peut faire des builds multiplateforme !

- Getting started https://developers.redhat.com/blog/2021/01/11/getting-started-with-buildah

## Benchmark des trois solutions précédentes à la fin du post de blog

## Un builder automatique plus récent et exotique : Buildpacks

- https://buildpacks.io/docs/concepts/

Cette solution package automatiquement le code source d'une application en detectant ses dépendance et sa structure. C'est très puissant.

- Avantage : les bonnes pratiques sont garanties par les recettes automatiques (quand elle on été codées par des spécialistes et revues par les pairs)
- les images sont optimisées (si le buildpack aka la recette est pas nulle)
- Meilleure reproductibilité des builds

Inconvénients:

- Ça fait des boites noires un peu magiques il faut faire confiance si on a pas codé le buildpack qui automatise
- Il faut qu'un buildpack existe ou en coder un => c'est plus compliqué que Dockerfile


## Tutorial : Apprendre le bas niveau des images Docker en les construisants "à la main"

- https://containers.gitbook.io/build-containers-the-hard-way
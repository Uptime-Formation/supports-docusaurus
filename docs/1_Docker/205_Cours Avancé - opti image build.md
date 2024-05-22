---
title: "Cours Avancé : optimiser ses builds d'image"
---

## Bien choisir son image de base un choix complexe (et partiellement subjectif ?)

Beaucoup de personnes utilisent des images de base construites à partir de `alpine` qui est un bon compromis (6 mégaoctets seulement et un gestionnaire de paquets `apk`). Mais ce choix a aussi ses inconvénients:

- https://pythonspeed.com/articles/alpine-docker-python/

Les images basées sur `debian-slim` et redhat `ubi-micro` sont a peine plus lourde et probablement plus solide/sécurisées et polyvalentes.

A mentionner: les images de base distroless : un projet de Google des images linux Debian de base mais sans tout ce qui fait la distribution (notamment apt) => a utiliser pour injecter les elements prébuildé dans un build multistage.

- avantage encore plus léger et moins de surface d'attaque
- images plus difficiles à patcher pour des failles car on ne peut pas utiliser le travail de la distribution

Pour s'y retrouver on peut se référer à ce comparatif assez complet (bien que pro-redhat) : https://crunchtools.com/comparison-linux-container-images/

Autre comparaison pour faire des images minimales: https://baykara.medium.com/alpine-vs-distroless-vs-busybox-e14573ba8724

Pour entrer dans les détails d'une image on peut installer et utiliser https://github.com/wagoodman/dive. C'est souvent nécessaire quand on optimiser au maximum son image d'avoir conscience de tous les fichiers

## Cache de Build

### Utilisation optimale du cache de build

La documentation officielle est plutôt claire à ce sujet: https://docs.docker.com/build/cache/

### Cache et CI/CD

Un enjeu du cache est notamment d'accélérer l'exécution du build dans les pipelines de CI/CD. Pour celà on peut utiliser un cache de build distant, par exemple avec le backend `registry` de Buildkit : https://docs.docker.com/build/cache/backends/#backends 

- https://www.augmentedmind.de/2022/06/26/speed-up-gitlab-ci-pipelines/
- https://www.augmentedmind.de/2022/06/12/gitlab-vs-docker-caching-pipelines/
- https://gitlab.com/MShekow/gitlab-vs-docker-caching/-/tree/main?ref_type=heads

### Essayer les builds multistage parallélisés

- Tutoriel : https://www.gasparevitta.com/posts/advanced-docker-multistage-parallel-build-buildkit/

## Une comparaison des autre outils de build d'image

### Docker Buildkit

- https://docs.docker.com/build/buildkit/

Est le (nouveau) builder par défaut de Docker depuis quelques années.

- Très performant, parallélisé, cache intelligent dans des multistage builds.
- Peut être étendu et configuré avec le nouveau gestionnaire **buildx** pour notamment:
    - faire des builds multiplateforme
    - gérer les cache distant pour une CI/CD : https://docs.docker.com/build/cache/backends/registry/

- Inconvénient : pour les CI/CD il faut du Docker in Docker qui pas idéal en terme de sécurité voire impossible dans certains contextes (un cluster K8s sans docker).

### Builder plusieurs images pour plusieurs architectures avec `buildx`

Buildx est un plugin Docker assez récent qui permet d'automatiser le build d'images et de builder pour plusieurs architectures.

Tutoriel d'exemple : https://www.docker.com/blog/how-to-rapidly-build-multi-architecture-images-with-buildx/

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

- Gestion du cache avec Kaniko : https://cloud.google.com/build/docs/optimize-builds/kaniko-cache

## Buildah

Un builder initialement de RedHat désormais maintenu par l'Open Container Initiative (respecte encore plus directement les standards ouverts de conteneurs)

- Fonctionne avec Podman (une CLI docker compatible Daemonless)
- Il Peut tourner en mode non privilégié donc plus sécurisé que Docker.
- Il peut faire des builds multiplateforme !

- Getting started https://developers.redhat.com/blog/2021/01/11/getting-started-with-buildah

<!-- ## Benchmark des trois solutions précédentes à la fin du post de blog -->

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

## Quelques références:

- https://lablabs.io/building-container-images-in-cloud-native-ci-pipelines/

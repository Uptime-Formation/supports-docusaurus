---
title: 3.11 - Mettre en oeuvre une CI/CD Docker+Gitlab
pre: "<b>3.10 </b>"
weight: 38
sidebar_class_name: hidden
---


## Retour sur la CI/CD

La CI/CD fait partie de DevOps (la fusion des équipes de développement et d'exploitation) et combine les pratiques de l'intégration continue et de la livraison continue.

- Elle automatise une grande partie, voire l'ensemble de l'intervention humaine manuelle traditionnellement nécessaire pour mettre en production un nouveau code issu d'une validation, englobant les phases de build, de test (y compris les tests d'intégration, les tests unitaires et les tests de régression), de déploiement, ainsi que souvent le provisionnement de l'infrastructure nécessaire.

- Avec un pipeline CI/CD, les équipes de développement peuvent apporter des modifications au code qui sont ensuite automatiquement testées et déployées pour la livraison. Bien réalisé, une CI/CD réduit au minimum les temps d'attente des développeurs et accélère les déploiements de code.

- Une plateforme CI/CD adaptée peut maximiser le temps de développement en améliorant la productivité de l'organisation, en augmentant l'efficacité et en rationalisant les flux de travail grâce à l'automatisation intégrée, aux tests et à la collaboration.

- À mesure que les applications deviennent plus complexes, les fonctionnalités de CI/CD peuvent contribuer à réduire la complexité du développement.

- L'adoption d'autres pratiques DevOps, comme le renforcement de **la sécurité en amont** et la création de **boucles de rétroaction plus étroites autour d'un logiciel**, permet aux organisations de s'agrandir en toute sécurité au niveau humain et technique.

La CI/CD permet aux équipes de développement, de sécurité et d'exploitation de travailler aussi efficacement que possible. Il réduit le travail de développement fastidieux et les processus d'approbation manuels, libérant ainsi les équipes pour plus d'innovation dans leur développement de logiciels.

- L'automatisation rend les processus prévisibles et reproductibles, réduisant ainsi les possibilités d'erreurs dues à l'intervention humaine.

- Les équipes obtiennent des retours plus rapides et peuvent intégrer plus fréquemment de petites modifications pour réduire le risque de modifications pouvant perturber le build et le déploiment.

La continuité et l'itération des processus DevOps **accélèrent les cycles de développement logiciels**, permettant ainsi aux organisations de livrer davantage de fonctionnalités.

### Qu'est-ce que l'intégration continue (CI)

L'intégration continue est la pratique qui consiste à intégrer tous les changements de code dans la branche principale d'un code source partagé **tôt et souvent**, en testant automatiquement chaque changement lors de leur validation ou de leur fusion, et en lançant automatiquement un build.

Avec l'intégration continue, les erreurs et les problèmes de sécurité peuvent être identifiés et corrigés plus facilement, et beaucoup plus tôt dans le processus de développement.

En "mergeant" fréquemment des changements et en déclenchant des processus de test et de validation automatiques, on minimise la possibilité de conflits de code, même avec plusieurs développeurs travaillant sur la même application.

Un avantage secondaire est que vous n'avez pas à attendre longtemps pour obtenir des réponses et pouvez, si nécessaire, corriger les bugs et les problèmes de sécurité pendant que le sujet est encore frais dans votre esprit.

Les processus courants de validation du code commencent par une analyse de code statique qui vérifie la qualité du code. Une fois que le code passe les tests statiques, les routines CI automatisées empaquettent et compilent le code pour des tests automatisés supplémentaires. Les processus CI doivent disposer d'un système de gestion de version qui suit les changements afin que vous connaissiez la version du code utilisée.

## Qu'est-ce que la livraison continue (continuous delivery) ?

La livraison continue est une pratique de développement logiciel qui fonctionne en conjonction avec la CI pour automatiser le provisionnement de l'infrastructure et le processus de mise en production de l'application.

Une fois que le code a été testé et buildé dans le cadre du processus CI, la CD prend le relais lors des dernières étapes pour s'assurer qu'il est packagé avec tout ce dont il a besoin pour être déployé dans n'importe quel environnement à tout moment.

Avec la CD, le logiciel est construit de manière à pouvoir être déployé en production à tout moment. Ensuite, vous pouvez déclencher manuellement les déploiements ou passer au déploiement continu, où les déploiements sont également automatisés.

## Qu'est-ce que le déploiement continu (continuous deployment) ?

Le déploiement continu permet aux organisations de déployer automatiquement leurs applications, éliminant ainsi le besoin d'intervention humaine. 

Avec le déploiement continu, les équipes DevOps définissent à l'avance les critères de mise en production du code, et lorsque ces critères sont satisfaits et validés, le code est déployé dans l'environnement de production. Cela permet aux organisations d'être plus agiles et de mettre de nouvelles fonctionnalités entre les mains des utilisateurs plus rapidement.

### Pourquoi Docker est central pour la CI

- Les pipelines d'automatisation doivent tourner dans un environnement contrôlé qui contient toutes les dépendances nécessaires
- Historiquement avec par exemple Jenkins on utilisait des serveurs dédiés "fixes" provisionnés avec les dépendances nécessaires au boulot des pipelines.

Le problème c'est que cette approche ne permet pas de facilement et économiquement répondre à la charge de calcul nécessaire pour une équipe de dev:

- Typiquement les membres d'une équipe pushent leur code aux même moments de la journée : engorgement de la CI/CD et temps d'attente important.
- Si on prévoit beaucoup de serveurs fixes pour de pipelines pour éviter cela c'est cher et on les utilise seulement une fraction du temps

Autre problème, installer et maintenir les serveurs dédiés peut représenter beaucoup de travail.

- Docker/les conteneurs permettent de lancer des conteneurs dans un cloud (plus dynamique/scalable) pour effectuer les jobs de CI/CD : cela permet avoir des pipelines à la demande.
- Cela permet aussi d'avoir plus facilement une reproductibilité des environnements de CI/CD et peut faciliter l'installation : par exemple pour une application maven on prend un conteneur maven officiel du Docker Hub et une grosse partie du travail est fait par d'autres et facile pour les mises à jour.

- C'est l'approche de Gitlab qui fournit du pipeline as a service par défault basé sur un cloud de conteneur.
- Jenkins installé avec le plugin Docker ou Kubernetes permet également d'utiliser des conteneurs pour les différentes étapes (stages) d'un pipeline.

### Pourquoi Kubernetes 

- Kubernetes est le cloud de conteneurs open source de référence il est donc très **adapté au déploiement d'un système de pipeline à la demande** (par exemple des Gitlab Runners ou le plugin Kubernetes de Jenkins) pour faire l'intégration et la livraison continue (les deux premières étapes de la CI/CD).

- Kubernetes introduit le déploiement déclaratif qui simplifie standardise et rend reproductible le déploiement d'applications conteneurisées : il est recommmander pour faciliter un déploiement complètement automatique (continuous deployment) proposant un système de rollback fiable.

- K8s propose des fonctionnalités d'authorisation (RBAC, network policies) qui permettent de bien sécuriser l'infrastructure de CI/CD.

### Présentation de Gitlab CI/CD

- https://docs.gitlab.com/ee/topics/build_your_application.html


### Code de base

clone ?

### Stage Unit testing


### Stage Docker build avec Docker in Docker


Template de build Docker de gitlab:

```yaml
# To contribute improvements to CI/CD templates, please follow the Development guide at:
# https://docs.gitlab.com/ee/development/cicd/templates.html
# This specific template is located at:
# https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/ci/templates/Docker.gitlab-ci.yml

# Build a Docker image with CI/CD and push to the GitLab registry.
# Docker-in-Docker documentation: https://docs.gitlab.com/ee/ci/docker/using_docker_build.html
#
# This template uses one generic job with conditional builds
# for the default branch and all other (MR) branches.

docker-build:
  # Use the official docker image.
  image: docker:cli
  stage: build
  services:
    - docker:dind
  variables:
    DOCKER_IMAGE_NAME: $CI_REGISTRY_IMAGE:$CI_COMMIT_REF_SLUG
  before_script:
    - docker login -u "$CI_REGISTRY_USER" -p "$CI_REGISTRY_PASSWORD" $CI_REGISTRY
  # All branches are tagged with $DOCKER_IMAGE_NAME (defaults to commit ref slug)
  # Default branch is also tagged with `latest`
  script:
    - docker build --pull -t "$DOCKER_IMAGE_NAME" .
    - docker push "$DOCKER_IMAGE_NAME"
    - |
      if [[ "$CI_COMMIT_BRANCH" == "$CI_DEFAULT_BRANCH" ]]; then
        docker tag "$DOCKER_IMAGE_NAME" "$CI_REGISTRY_IMAGE:latest"
        docker push "$CI_REGISTRY_IMAGE:latest"
      fi
  # Run this job in a branch where a Dockerfile exists
  rules:
    - if: $CI_COMMIT_BRANCH
      exists:
        - Dockerfile

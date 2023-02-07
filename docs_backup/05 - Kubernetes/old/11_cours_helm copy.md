---
title: 11 - Cours - Helm le gestionnaire de paquets Kubernetes
draft: true
---


Nous avons vu que dans Kubernetes la configuration de nos services / applications se fait généralement via de multiples fichiers yaml.

Quand on a une seule application cela reste gérable mais dès qu’on a plusieurs environnements, applications et services, on se retrouve vite submergé de fichiers qui sont de plus assez semblables. Pour palier à ce problème il existe l'utilitaire Helm.

- Helm est le package manager recommandé par Kubernetes
- C'est aussi le seul sur le marché car son unique concurrent, KPM de CoreOS, n’est plus maintenu depuis juillet 2017.

Helm permet donc de déployer des applications / stacks complètes en utilisant un système de templating et de dépendances afin d’éviter la duplication et avoir ainsi une arborescence cohérente pour nos fichiers de configurations.

Mais Helm ce n’est pas que ca, il propose également:

  - la possibilité de gérer vos Charts avec la possibilité de les compresser et de les mettre dans un répertoire distant (Cdn, Git, disque local ou partagé…).
  - il comprend un système facilitant les Updates et Rollbacks de vos applications.


Nous verrons qu'un chart helm est un peu l'équivalent d'un role Ansible dans l'écosystème Kubernetes.


### Concepts

Les quelques concepts centraux de Helm :

- Un package Kubernetes est appelé **Chart** dans Helm.

- Un Chart contient un lot d’informations nécessaires pour créer une instance d’application Kubernetes :
  - la **Config** contient les informations dynamiques concernant la configuration d’un **Chart**
  - Une **Release** est une instance existante sur le cluster, combinée avec une **Config** spécifique.


### Architecture client serveur de Helm

Helm désigne une application client en ligne de commande.

Pour fonctionner sur le cluster Helm a besoin d'installer un gestionnaire appelé Tiller : c'est le serveur qui communique avec le client Helm et l’API de Kubernetes pour gérer vos déploiements.

Lors de l’initialisation de Helm, le client installe Tiller sur un pod du cluster.

Helm utilise automatiquement votre fichier kubeconfig pour se connecter.

### Quelques commandes Helm:

Voici quelques commandes de bases pour Helm :

- `helm install my-chart` : permet d’installer le chart my-chart. Le nom de release est généré aléatoirement dans votre cluster kubernetes.

- `helm upgrade my-release my-chart` : permet de mettre à jour notre release avec une nouvelle version.

- `helm ls`: Permet de lister les Charts installés sur votre Cluster

- `helm delete my-release`: Permet de désinstaller la release my-release de kubernetes

### La configuration d'un Chart: des templates jinja d'objets Kubernetes

Visitons un exemple de Chart : [minecraft](https://github.com/helm/charts/tree/master/stable/minecraft/templates)

On constate que Helm rassemble des fichier descriptions d'objets k8s avec des variables Jinja à l'intérieur ce qui permet de factoriser le code et gérer puissamment la différence entre les versions.


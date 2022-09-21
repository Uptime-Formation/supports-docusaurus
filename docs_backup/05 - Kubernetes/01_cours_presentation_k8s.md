---
title: 01 - Cours - Présentation de Kubernetes
draft: false
weight: 2010
---


## Bonjour à tous ! 

### A propos de moi

<!-- Élie Gavoty

- Developpeur backend et DevOps (Sewan Group / Yunohost)
- Formateur DevOps, Linux, Python
- Philosophie de la technique -->

<!-- Hadrien Pélissier

- Ingénieur DevOps (Ansible / Docker / Kubernetes / Gitlab CI) / sécurité / développeur Python et Elixir
- Formateur DevOps et sécurité informatique -->

### A propos de vous

- Attentes ?
- Début du cursus :
  - Est-ce que ça vous plait ?
  - Quels modules avez vous déjà fait ?

- Kubernetes est une solution d'orchestration de conteneurs extrêmement populaire.
- Le projet est très ambitieux : une façon de considérer son ampleur est de voir Kubernetes comme un système d'exploitation (et un standard ouvert) pour les applications distribuées et le cloud.
- Le projet est développé en Open Source au sein de la Cloud Native Computing Foundation.

## Concrètement : Architecture de Kubernetes

<!-- ![](/img/kubernetes/k8s_archi1.png?width=800px) -->
![](/img/kubernetes/shema-persos/k8s-archi.jpg)

- Kubernetes rassemble en un cluster et fait coopérer un groupe de serveurs appelés **noeuds**(nodes).

- Kubernetes a une architecture **Master/workers** (cf. cours 2) composée d'un **control plane** et de nœuds de calculs (**workers**).

- Cette architecture permet essentiellement de rassembler les machines en un **cluster unique** sur lequel on peut faire tourner des **"charges de calcul" (workloads)** très diverses.

- Sur un tel cluster le déploiement d'un workload prend la forme de **ressources (objets k8s)** qu'on **décrit sous forme de code** et qu'on crée ensuite effectivement via l'API Kubernetes.

- Pour uniformiser les déploiement logiciel Kubernetes est basé sur le standard des **conteneurs** (défini aujourd'hui sous le nom **Container Runtime Interface**, Docker est l'implémentation la plus connue).

- Plutôt que de déployer directement des conteneurs, Kubernetes crée des **aggrégats de un ou plusieurs conteneurs** appelés des **Pods**. Les pods sont donc l'unité de base de Kubernetes.


## Philosophie derrière Kubernetes et le mouvement "Cloud Native"
### Historique et popularité

![](/img/kubernetes/k8s_logo.png)

Kubernetes est un logiciel développé originellement par Google et basé sur une dizaine d'années d'expérience de déploiement d'applications énormes (distribuées) sur des clusters de machines.

Dans la mythologie Cloud Native on raconte que son ancêtre est l'orchestrateur borg utilisé par Google dans les années 2000.

La première version est sortie en 2015 et k8s est devenu depuis l'un des projets open source les plus populaires du monde.

L'écosystème logiciel de Kubernetes s'est développée autour la **Cloud Native Computing Foundation** qui comprend notamment : Google, CoreOS, Mesosphere, Red Hat, Twitter, Huawei, Intel, Cisco, IBM, Docker, Univa et VMware. Cette fondation vise au pilotage et au financement collaboratif du développement de Kubernetes (un peut comme la Linux Foundation).

### Trois transformations profondes de l'informatique

Kubernetes se trouve au coeur de trois transformations profondes techniques, humaines et économiques de l'informatique:

- Le cloud
- La conteneurisation logicielle
- Le mouvement DevOps

Il est un des projets qui symbolise et supporte techniquement ces transformations. D'où son omniprésence dans les discussions informatiques actuellement.

#### Le Cloud

- Au delà du flou dans l'emploi de ce terme, le cloud est un mouvement de réorganisation technique et économique de l'informatique.
- On retourne à la consommation de "temps de calcul" et de services après une "aire du Personnal Computer".
- Pour organiser cela on définit trois niveaux à la fois techniques et économiques de l'informatique:
  - **Software as a Service**: location de services à travers internet pour les usagers finaux
  - **Plateform as a Service**: location d'un environnement d'exécution logiciel flexible à destination des développeurs
  - **Infrastructure as a Service**: location de resources "matérielles" à la demande pour installer des logiciels sans avoir à maintenir un data center.

#### Conteneurisation

La conteneurisation est permise par l'isolation au niveau du noyau du système d'exploitation du serveur : les processus sont isolés dans des namespaces au niveau du noyau. Cette innovation permet de simuler l'isolation sans ajouter une couche de virtualisation comme pour les machines virtuelles.

Ainsi les conteneurs permettent d'avoir des performances proche d'une application traditionnelle tournant directement sur le système d'exploitation hote et ainsi d'optimiser les ressources.

Les images de conteneurs sont aussi beaucoup plus légers qu'une image de VM ce qui permet de 

Les technologies de conteneurisation permettent donc de faire des boîtes isolées avec les logiciels pour apporter l'uniformisation du déploiement:

- Un façon standard de packager un logiciel (basée sur le)
- Cela permet d'assembler de grosses applications comme des legos
- Cela réduit la complexité grâce:
  - à l'intégration de toutes les dépendance déjà dans la boîte
  - au principe d'immutabilité qui implique de jeter les boîtes ( automatiser pour lutter contre la culture prudence). Rend l'infra prédictible.

Les conteneurs sont souvent comparés à l'innovation du porte conteneur pour le transport de marchandise.

#### Le mouvement DevOps

- Dépasser l'opposition culturelle et de métier entre les développeurs et les administrateurs système.
- Intégrer tout le monde dans une seule équipe et ...
- Calquer les rythmes de travail sur l'organisation agile du développement logiciel
- Rapprocher techniquement la gestion de l'infrastructure du développement avec l'infrastructure as code.
  - Concrètement on écrit des fichiers de code pour gérer les éléments d'infra
  - l'état de l'infrastructure est plus claire et documentée par le code
  - la complexité est plus gérable car tout est déclaré et modifiable au fur et à mesure de façon centralisée
  - l'usage de git et des branches/tags pour la gestion de l'évolution d'infrastructure

#### Objectifs du DevOps

- Rapidité (velocity) de déploiement logiciel (organisation agile du développement et livraison jusqu'à plusieurs fois par jour)
  - Implique l'automatisation du déploiement et ce qu'on appelle la CI/CD c'est à dire une infrastructure de déploiement continu à partir de code.
- Passage à l'échelle (horizontal scaling) des logiciels et des équipes de développement (nécessaire pour les entreprises du cloud qui doivent servir pleins d'utilisateurs)
- Meilleure organisation des équipes
  - meilleure compréhension globale du logiciel et de son installation de production car le savoir est mieux partagé
  - organisation des équipes par thématique métier plutôt que par spécialité technique (l'équipe scale mieux)

### Apports techniques de Kubernetes pour le DevOps

- Abstraction et standardisation des infrastructures: 
- Langage descriptif et incrémental: on décrit ce qu'on veut plutôt que la logique complexe pour l'atteindre
- Logique opérationnelle intégrée dans l'orchestrateur: la responsabilité des l'état du cluster est laissé au controlleur k8s ce qui simplifie le travail

On peut alors espérer **fluidifier** la gestion des défis techniques d'un grosse application et atteindre plus ou moins la livraison logicielle continue (CD de CI/CD)

#### Architecture logicielle optimale pour Kubernetes

Kubernetes est très versatile et permet d'installer des logiciels traditionnels "monolithiques" (gros backends situés sur une seule machine).

Cependant aux vues des transformations humaines et techniques précédentes, l'organisation de Kubernetes prend vraiment sens pour le développement d'applications microservices:

  - des applications avec de nombreux de "petits" services.
  - chaque service a des problématiques très limitées (gestion des factures = un logiciel qui fait que ça)
  - les services communiquent par le réseaux selon différents modes/API (REST, gRPC, job queues, GraphQL)

<!-- Nous verrons un exemple d'application microservice à la fin de la formation. -->

Les microservices permettent justement le DevOps car:
  - ils peuvent être déployés séparéments
  - une petite équipe gère chaque service ou groupe thématique de services

  Nous y reviendrons pour expliquer l'usage des ressources Kubernetes.

## Objets fondamentaux de Kubernetes

- Les **pods** Kubernetes servent à grouper des conteneurs fortement couplés en unités d'application <!-- (microservices ou non) -->
- Les **deployments** sont une abstraction pour **créer ou mettre à jour** (ex : scaler) des groupes de **pods**.
- Enfin, les **services** sont des points d'accès réseau qui permettent aux différents workloads (deployments) de communiquer entre eux et avec l'extérieur.

Au delà de ces trois éléments, l'écosystème d'objets de Kubernetes est vaste et complexe

<!-- ![](/img/kubernetes/k8s_objects_hierarchy.png?width=600px) -->


## Kubernetes entre Cloud et auto-hébergement

Un des intérêts principaux de Kubernetes est de fournir un modèle de Plateform as a Service (PaaS) suffisamment versatile qui permet l'interopérabilité entre des fournisseurs de clouds différents et des solutions auto-hébergées (on premise).

Cependant cette interopérabilité n'est pas automatique (pour les cas complexes) car Kubernetes permet beaucoup de variations. Concrètement il existe des variations entre les installations possibles de Kubernetes

## Distributions et "flavours" de Kubernetes

Kubernetes est avant tout un ensemble de standards qui peuvent avoir des implémentations concurrentes. Il existe beaucoup de variétés (**flavours**) de Kubernetes, implémentant concrètement les solutions techniques derrière tout ce que Kubernetes ne fait que définir : solutions réseau, stockage (distribué ou non), loadbalancing, service de reverse proxy (Ingress), autoscaling de cluster (ajout de nouvelles VM au cluster automatiquement), monitoring…

Nous verrons cela plus en détail dans le cours suivant.

## Interagir avec le cluster : le client CLI `kubectl`

En pratique on interagit avec le cluster à l'aide d'un client CLI depuis sa machine de travail (ou en ssh depuis un noeud master ou avec un VPN). Ce client se charge de traduire en appel d'API les commandes de manipulation.
Cette cli ressemble sous pas mal d'aspect à celle de Docker (cf. TP1 et TP2). Elle permet de :

- Lister les ressources
- Créer et supprimer les ressources
- Gérer les droits d'accès
- etc.

`kubectl` s'installe avec un gestionnaire de paquet classique mais est souvent fourni directement avec les distributions de développement de kubernetes que nous verrons par la suite.
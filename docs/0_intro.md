---
title: Introduction
draft: false
sidebar_position: 1
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


## Trois transformations profondes de l'informatique

Kubernetes se trouve au coeur de plusieurs transformations profondes techniques, humaines et économiques de l'informatique:

- Le mouvement DevOps et la CI/CD
- Le "Cloud"
- La conteneurisation logicielle
- Infrastructure as Code

Docker (qui est surtout la marque la plus connue pour les conteneurs en général) et Kubernetes sont des projets qui symbolisent et supportent techniquement ces transformations. D'où leur omniprésence dans les discussions informatiques actuellement.

### Le mouvement DevOps

- Dépasser l'opposition culturelle et de métier entre les développeurs et les administrateurs système.
- Intégrer tout le monde dans une seule équipe et ...
- Calquer les rythmes de travail sur l'organisation agile du développement logiciel
- Rapprocher techniquement la gestion de l'infrastructure du développement avec l'infrastructure as code.
  - Concrètement on écrit des fichiers de code pour gérer les éléments d'infra
  - l'état de l'infrastructure est plus claire et documentée par le code
  - la complexité est plus gérable car tout est déclaré et modifiable au fur et à mesure de façon centralisée
  - l'usage de git et des branches/tags pour la gestion de l'évolution d'infrastructure

## Objectifs du DevOps

- Rapidité (**velocity**) de **déploiement** et **refactorisation** logicielle (organisation agile du développement et livraison jusqu'à plusieurs fois par jour)
  - Implique l'automatisation du déploiement et ce qu'on appelle la CI/CD c'est à dire une infrastructure de déploiement continu à partir de code.
- Passage à l'échelle (horizontal scaling) des logiciels et des équipes de développement (nécessaire pour les entreprises du cloud qui doivent servir pleins d'utilisateurs)
- Meilleure organisation des équipes
  - meilleure compréhension globale du logiciel et de son installation de production car le savoir est mieux partagé
  - organisation des équipes par thématique métier plutôt que par spécialité technique (l'équipe scale mieux)


### Infrastructure as Code

On décrit en mode code un état du système:

  - pas de dérive de la configuration et du système (immutabilité)
  - on peut connaître de façon fiable l'état des composants du système
  - on peut travailler en collaboration plus facilement (grâce à Git notamment)
  - on peut faire des tests
  - on facilite le déploiement de nouvelles instances

### Le Cloud

Au delà du flou dans l'emploi de ce terme, le cloud est un mouvement de réorganisation technique et économique de l'informatique.

- On retourne à la consommation de "temps de calcul" et de services après une "aire du Personnal Computer".

- Pour organiser cela on peut définir trois niveaux à la fois techniques et économiques de l'informatique:
  - **Software as a Service**: location de services à travers internet pour les usagers finaux
  - **Plateform as a Service**: location d'un environnement d'exécution logiciel flexible à destination des développeurs
  - **Infrastructure as a Service**: location de resources "matérielles" à la demande pour installer des logiciels sans avoir à maintenir un data center.

Le cloud permet surtout techniquement la flexibilité et la scalabilité à la demande des resources de base pour nos applications : on peut commander plein de machines et les ajouter à notre cluster. On peut également copier une infra temporairement pour faire des migrations ou tests.

### Conteneurisation

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

### Apports de Docker pour le DevOps

- Standardisation du déploiement : principe identique à tous les langages et environnements
- Reproductibilité / Fiabilité : lancer un conteneur se passe toujours de la même façon et limite les aléas
- Supporte l'architecture distribuée (microservices) en permettant l'isolation légère de chaque partie du logiciel

- Docker se positionne de plus en plus commercialement sur la partie amont de la conteneurisation, car sa solution d'orchestration intégrée pour la prod a perdu en popularité et glisse doucement vers le legacy.

### Apports Kubernetes pour le DevOps

- Abstraction et standardisation des infrastructures: 
- Langage descriptif et incrémental: on décrit ce qu'on veut plutôt que la logique complexe pour l'atteindre
- Scalabilité facilité et potentiellement illimitée
- Logique opérationnelle intégrée dans l'orchestrateur: la responsabilité des l'état du cluster est laissé au controlleur k8s ce qui simplifie le travail

On peut alors espérer **fluidifier** la gestion des défis techniques d'un grosse application et atteindre plus ou moins la livraison logicielle continue (CD de CI/CD)

### Le mouvement Cloud Native

Le mouvement **Cloud Native** est relativement récent, il remonte aux années 2010. Le terme a été popularisé en 2015 par la Cloud Native Computing Foundation (CNCF), une organisation à but non lucratif qui a été créée par la Linux Foundation pour fournir une plateforme pour la collaboration et le développement de technologies Cloud Native open source (Kubernetes et son écosystème).

La CNCF vise à promouvoir des applications qui peuvent être déployées et exécutées de manière efficace dans un environnement dynamique, pour tirer pleinement parti des avantages du cloud, tels que la scalabilité, la flexibilité et la résilience. Pour cela la CNCF promeut :

- L'usage des conteneurs qui permettent de créer des unités d'exécution indépendantes qui peuvent être facilement déployées et orchestrées

- Une architecture d'application qui permette notamment la configuration dynamique à partir l'environnement telle que décrite ici : https://12factor.net/

- Les microservices permettent de découper les applications en petits services indépendants qui peuvent être déployés et gérés individuellement.

## Kubernetes entre Cloud et auto-hébergement

Un des intérêts principaux de Kubernetes est de fournir un modèle de Plateform as a Service (PaaS) suffisamment versatile qui permet l'interopérabilité entre des fournisseurs de clouds différents et des solutions auto-hébergées (on premise).

Cependant cette interopérabilité n'est pas automatique (pour les cas complexes) car Kubernetes permet beaucoup de variations. Concrètement il existe des variations entre les installations possibles de Kubernetes
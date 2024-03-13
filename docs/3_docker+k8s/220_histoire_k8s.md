---
title:  Histoire de Kubernetes
weight: 32
--- 

## Histoire de Kubernetes


## Qu'est-ce que Kubernetes?

> Kubernetes est une plate-forme open source extensible et portable pour la gestion de la charge de travail (charges de travail) et les services conteneurisés. Il favorise à la fois l'écriture de configuration déclarative (configuration déclarative) et l'automatisation. 

Il s'agit d'un grand écosystème en expansion très rapide, avec énormément de projets cf. le landscape CNCF (https://landscape.cncf.io/).

**Le développement de Kubernetes est basé sur l'expérience de Google avec la gestion et l'échelle de la charge (scaling) en production, associées aux meilleures idées et pratiques communautaires.**

--- 

## L'histoire de Kubernetes

---

### 2003-2004: Naissance du système Borg

**Google a introduit le système Borg vers 2003-2004.** 

Cela a commencé comme un projet à petite échelle, avec environ 3-4 personnes initialement en collaboration avec une nouvelle version du nouveau moteur de recherche de Google. Borg était un système de gestion interne à grande échelle, qui comptait des centaines de milliers d'emplois, de plusieurs milliers d'applications différentes, à travers de nombreux clusters, chacun avec des dizaines de milliers de machines.

---

### 20013: de Borg à Omega

Après Borg, Google a introduit le système de gestion des cluster Omega, un planificateur flexible et évolutif pour les grands clusters de calcul. 

---

### 20014: Google présente Kubernetes

- mi-2014: Google a présenté Kubernetes comme une version open source de Borg, la communauté de Kubernetes est rejointe immédiatement par Microsoft, Redhat, IBM, Docker.

---

### 20015: L'année de Kube V1.0 & CNCF


Le 21 juillet, Kubernetes v1.0 est publié, marquant le début de la Cloud Native Computing Foundation (CNCF) en partenariat avec Google et la Linux Foundation, visant à promouvoir des écosystèmes durables autour des projets d'orchestration de conteneurs.

---

### 20016: L'année de popularisation

- Première version de Helm, le gestionnaire de packages de Kubernetes, est lancée.
- Kubernetes 1.2 est publié, apportant des améliorations significatives telles que la mise à l'échelle, le déploiement simplifié des applications et la gestion automatisée des clusters.
- Minikube, un outil facilitant l'exécution de Kubernetes localement, est officiellement publié.
- Monzo publie une étude de cas sur l'utilisation de Kubernetes pour construire un système bancaire à partir de zéro.
- Pokémon Go! est déployé massivement sur Kubernetes 

---

### 20017: L'année de l'adoption et du soutien aux entreprises

- Kubernetes 1.6 est publié, avec des mises à jour telles que l'activation par défaut d'etcdv3 et la prise en charge de RBAC en version bêta, marquant une version de stabilisation.
- Google et IBM annoncent Istio, une technologie ouverte permettant la gestion et la sécurisation transparentes des réseaux de microservices sur différentes plateformes et fournisseurs.
- GitHub migre vers Kubernetes, déployant toutes les requêtes web et API sur des clusters Kubernetes .

### Depuis 2018 

- **Depuis 2018, Kubernetes a continué son ascension en tant que leader incontesté de l'orchestration de conteneurs**. Il a consolidé sa position en tant que technologie essentielle pour le déploiement et la gestion d'applications dans des environnements de cloud et sur site.

- **Tout d'abord, l'adoption de Kubernetes par les fournisseurs de cloud public s'est accélérée.** Des services entièrement gérés, tels qu'Amazon Elastic Kubernetes Service (EKS), Google Kubernetes Engine (GKE) et Azure Kubernetes Service (AKS), ont été lancés, facilitant ainsi le déploiement et la gestion de clusters Kubernetes pour les entreprises qui migrent vers le cloud.

- **En parallèle, la communauté Kubernetes a continué à innover et à étendre les fonctionnalités de la plateforme.** Des améliorations significatives ont été apportées aux domaines tels que la sécurité, la gestion des ressources, le stockage et le réseau, offrant ainsi aux utilisateurs des fonctionnalités plus avancées pour le déploiement et l'exploitation d'applications conteneurisées à grande échelle.

- **Une autre tendance notable a été l'émergence de projets et d'outils complémentaires à Kubernetes pour répondre à des besoins spécifiques.** Des projets autour de la gestion des secrets, la surveillance avancée ou la gestion des politiques enrichissent l'écosystème Kubernetes et offrent aux utilisateurs davantage de choix et de flexibilité pour personnaliser leurs déploiements en fonction de leurs besoins.

- **Enfin, Kubernetes est devenu un pilier central dans la transformation numérique de nombreuses entreprises.** Son adoption continue de croître dans divers secteurs, de la finance à la santé en passant par la technologie, témoignant de son importance croissante dans le paysage technologique moderne. À mesure que Kubernetes continue de mûrir et de s'adapter aux besoins changeants des entreprises, son impact sur la façon dont les applications sont développées, déployées et gérées devrait se renforcer davantage.

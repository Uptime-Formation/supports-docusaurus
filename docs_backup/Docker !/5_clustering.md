---
title: 5 - Orchestration et clustering
weight: 1050
sidebar_position: 10
---

## Orchestration

- Un des intérêts principaux de Docker et des conteneurs en général est de :

  - favoriser la modularité et les architectures microservice.
  - permettre la scalabilité (mise à l'échelle) des applications en multipliant les conteneurs.

- A partir d'une certaine échelle, il n'est plus question de gérer les serveurs et leurs conteneurs à la main.

Les nœuds d’un cluster sont les machines (serveurs physiques, machines virtuelles, etc.) qui font tourner vos applications (composées de conteneurs).

L'orchestration consiste à automatiser la création et la répartition des conteneurs à travers un cluster de serveurs. Cela peut permettre de :

- déployer de nouvelles versions d'une application progressivement.
- faire grandir la quantité d'instances de chaque application facilement (horizontal scaling)...
- ... voire dans le cas de l'auto-scaling de faire grossir l'application automatiquement en fonction de la demande.

## Orchestration : comparaison de Docker Services (Swarmkit) et Kubernetes

Les deux solutions ont un coeur de fonctionnalité très semblable :

- Faire tourner des conteneurs répliqués avec une scalabilité horizontale
- Fonctionnent de façon déclarative et incrémentale sur la base de fichier yaml
- route les requêtes automatiquement dans le Cluster entre les ensembles de conteneurs
- gère la configuration et les volumes de façon externe/indépendante des conteneurs

Caractéristiques de Docker Services (Swarm Mode):

- Swarm plus intégré avec la CLI et le workflow Docker.
- Swarm est plus simple à installer et gérer on premise.
<!-- - Swarm est orienté vers le on premise/self hosting (peu de vendeur cloud Docker) ?-->
- Swarm est moins structurant que kubernetes mais aussi moins automatique que Kubernetes (les fichiers de déploiement kubernetes sont plus détailler ce qui permet au cluster de prendre des décisions)
- Dans Swarm les conteneurs sont faiblement couplés (lancés indépendamment)

- Swarm est plus ou moins un logiciel legacy dans le sens ou Mirantis qui a racheté Docker EE favorise Kubernetes. Mais c'est un logiciel opensource et quelques fonctionnalités sont encore ajoutées mais, il a perdu beaucoup en popularité face à Kubernetes (et Nomad etc) (https://github.com/moby/swarmkit/issues/2665)

Caractéristiques de Kubernetes: 

- Kubernetes au contraire crée des **pods** qui peuvent être des grappes de conteneurs solidaires ce qui permet de Pattern multiconteneur de type sidecar.

- Kubernetes a beaucoup plus de fonctionnalités avancées. Il s'agit plus d'un écosystème qui couvre un large panel de cas d'usage.

- Kubernetes a une meilleure fault tolerance de par sont comportement plus prédictible et la configuration plus détaillée des déploiements.

- Kubernetes est plus standardisé ce qui explique sa popularité

- Kubernetes est entièrement extensible et programmable grace à sont architecture distribuée ouverte et son API modulaire parfaitement versionnée.

- Kubernetes est adapté à des petits et très gros clusters.



### Architecture de Docker Swarm


<br />
![](/img/swarm/ops-swarm-arch.svg)]

- Un ensemble de nœuds de contrôle pour gérer les conteneurs
- Un ensemble de nœuds worker pour faire tourner les conteneurs
<!-- Ajout commandes docker swarm init et join, principe du token -->
- Les nœuds managers sont en fait aussi des workers et font tourner des conteneurs, c'est leur rôles qui varient.


### Consensus entre managers Swarm

- L'algorithme Raft : http://thesecretlivesofdata.com/raft/
  ![](/img/raft-algorithm.gif)

- Pas d'_intelligent balancing_ dans Swarm
  - l'algorithme de choix est "spread", c'est-à-dire qu'il répartit au maximum en remplissant tous les nœuds qui répondent aux contraintes données.


### Docker Services et Stacks

- les **services** : la distribution **d'un seul conteneur en plusieurs exemplaires**

- les **stacks** : la distribution (en plusieurs exemplaires) **d'un ensemble de conteneurs (app multiconteneurs)** décrits dans un fichier Docker Compose


```yml
version: "3"
services:
  web:
    image: username/repo
    deploy:
      replicas: 5
      resources:
        limits:
          cpus: "0.1"
          memory: 50M
      restart_policy:
        condition: on-failure
    ports:
      - "4000:80"
    networks:
      - webnet
networks:
  webnet:
```

* Référence pour les options Swarm de Docker Compose : <https://docs.docker.com/compose/compose-file/#deploy>
* Le mot-clé `deploy` est lié à l'usage de Swarm
  * options intéressantes :
    * `update_config` : pour pouvoir rollback si l'update fail
    <!-- * `mode` :  -->
    * `placement` : pouvoir choisir le nœud sur lequel sera déployé le service
    * `replicas` : nombre d'exemplaires du conteneur
    * `resources` : contraintes d'utilisation de CPU ou de RAM sur le nœud


### Sous-commandes Swarm

- `swarm init` : Activer Swarm et devenir manager d'un cluster d'un seul nœud
- `swarm join` : Rejoindre un cluster Swarm en tant que nœud manager ou worker

- `service create` : Créer un service (= un conteneur en plusieurs exemplaires)
- `service inspect` : Infos sur un service
- `service ls` : Liste des services
- `service rm` : Supprimer un service
- `service scale` : Modifier le nombre de conteneurs qui fournissent un service
- `service ps` : Liste et état des conteneurs qui fournissent un service
- `service update` : Modifier la définition d'un service

- `docker stack deploy` : Déploie une stack (= fichier Docker compose) ou update une stack existante
- `docker stack ls ` : Liste les stacks
- `docker stack ps` : Liste l'état du déploiement d'une stack
- `docker stack rm` : Supprimer une ou des stacks
- `docker stack services` : Liste les services qui composent une stack

- `docker node inspect` : Informations détaillées sur un nœud
- `docker node ls` : Liste les nœuds
- `docker node ps` : Liste les tâches en cours sur un nœud
- `docker node promote` : Transforme un nœud worker en manager
- `docker node demote` : Transforme un nœud manager en worker


<!-- faire plus court -->
<!-- ajout illustration -->
<!-- ## Service discovery
- Par défaut les applications ne sont pas informées du contexte dans lequel elles tournent

- La configuration doit être opérée de l'extérieur de l'application

  - par exemple avec des fichiers de configuration
  - ou des variables d'environnement

- La mise en place d'un système de **découverte de services** permet de rendre les applications plus autonomes dans leur (auto)configuration.

- Elles vont pouvoir récupérer des informations sur leur contexte (`dev` ou `prod`, USA ou Europe ?)

- Ce type d'automatisation de l'intérieur permet de limiter la complexité du déploiement.


- Concrètement un système de découverte de service est un serveur qui est au courant automatiquement :

  - de chaque conteneur lancé

  - du contexte dans lequel il a été lancé

- Ensuite il suffit aux applications de pouvoir interroger ce serveur pour s'autoconfigurer.

- Utiliser un outil dédié permet d'éviter de s'enfermer dans une seule solution.

--- -->

<!-- ajout schéma etcd -->
<!-- ## Service Discovery - Solutions

- Le DNS du réseau overlay de Docker Swarm avec des stacks permet une forme extrêmement simple et implicite de service discovery. En résumé, votre application microservice docker compose est automatiquement distribuée.

- Avec le protocole de réseau overlay **Weave Net** il y a aussi un service de DNS accessible à chaque conteneur

- Deux autre solutions populaires mais plus manuelles à mettre en œuvre :
  - **Consul** (Hashicorp): Assez simple d'installation et fourni avec une sympathique interface web.
  - **etcd** : A prouvé ses performances aux plus grandes échelle mais un peu plus complexe.

--- -->

### Répartition de charge (load balancing)
<!-- ajout illustration -->

- Un load balancer : une sorte d'**"aiguillage" de trafic réseau**, typiquement HTTP(S) ou TCP.

- Un aiguillage **intelligent** qui se renseigne sur plusieurs critères avant de choisir la direction.

- Cas d'usage :

  - Éviter la surcharge : les requêtes sont réparties sur différents backends pour éviter de les saturer.


- Haute disponibilité : on veut que notre service soit toujours disponible, même en cas de panne (partielle) ou de maintenance.
- Donc on va dupliquer chaque partie de notre service et mettre les différentes instances derrière un load balancer.
- Le load balancer va vérifier pour chaque backend s'il est disponible (**healthcheck**) avant de rediriger le trafic.

- Répartition géographique : en fonction de la provenance des requêtes on va rediriger vers un datacenter adapté (+ ou - proche)


### Le loadbalancing de Swarm est automatique

- Loadbalancer intégré : Ingress
- Permet de router automatiquement le trafic d'un service vers les nœuds qui l'hébergent et sont disponibles.
- Pour héberger une production il suffit de rajouter un loadbalancer externe qui pointe vers un certain nombre de nœuds du cluster et le trafic sera routé automatiquement à partir de l'un des nœuds.

### Solutions de loadbalancing externe

- **HAProxy** : Le plus répandu en loadbalancing
- **Træfik** : Simple à configurer et fait pour l'écosystème Docker
- **NGINX** : Serveur web générique mais a depuis quelques années des fonctions puissantes de loadbalancing et de TCP forwarding.



### Docker Machine

- C'est l'outil de gestion d'hôtes Docker
- Il est capable de créer des serveurs Docker "à la volée"

- Concrètement, `docker-machine` permet de **créer automatiquement des machines** avec le **Docker Engine** et **ssh** configuré et de gérer les **certificats TLS** pour se connecter à l'API Docker des différents serveurs.

- Il permet également de changer le contexte de la ligne de commande Docker pour basculer sur l'un ou l'autre serveur avec les variables d'environnement adéquates.

- Il permet également de se connecter à une machine en ssh en une simple commande.

Exemple :

```bash
 docker-machine create  --driver digitalocean \
      --digitalocean-ssh-key-fingerprint 41:d9:ad:ba:e0:32:73:58:4f:09:28:15:f2:1d:ae:5c \
      --digitalocean-access-token "a94008870c9745febbb2bb84b01d16b6bf837b4e0ce9b516dbcaf4e7d5ff2d6" \
      hote-digitalocean
```

Pour basculer `eval $(docker env hote-digitalocean);`

- `docker run -d nginx:latest` créé ensuite un conteneur **sur le droplet digitalocean** précédemment créé.

- `docker ps -a` affiche le conteneur en train de tourner à distance.
- `wget $(docker-machine ip hote-digitalocean)` va récupérer la page nginx.

Une bonne alternative pour installer Docker sur un cluster de machine est d'utiliser un outil de gestion de configuration plus générique comme Ansible.


<!-- ### Gérer la configuration externe dans le cluster avec les resources configuration -->

### Gérer les données sensibles dans Swarm avec les secrets Docker

- `echo "This is a secret" | docker secret create my_secret_data`
- `docker service create --name monservice --secret my_secret_data redis:alpine`
  => monte le contenu secret dans `/var/run/my_secret_data`

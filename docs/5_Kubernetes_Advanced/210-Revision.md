---
title:  Révision - Le réseau dans K8S
weight: 1
---

## L'automatisation Réseau dans Kubernetes c'est bien...

**L'automatisation du réseau est un élément clé du succès de Kubernetes car elle simplifie la gestion et le déploiement des applications à grande échelle.**

En automatisant la configuration et la gestion des réseaux, Kubernetes permet aux développeurs et aux opérateurs de se concentrer sur le développement et l'optimisation des applications plutôt que sur les détails de l'infrastructure.

Cette automatisation facilite également la scalabilité, la résilience et la portabilité des applications, rendant Kubernetes adapté à divers environnements, des déploiements sur site aux clouds publics.

--- 

### ... mais l'automagique a un coût.

**Cependant, cette automatisation introduit une complexité cachée.**

Les abstractions et les automatisations de Kubernetes masquent souvent les détails complexes de la configuration et de la gestion des réseaux sous-jacents.

Cela peut rendre le diagnostic des problèmes plus difficile, car les utilisateurs doivent comprendre non seulement les concepts de haut niveau de Kubernetes, mais aussi les interactions détaillées entre les différents composants réseau.

De plus, la nature dynamique et éphémère des environnements Kubernetes ajoute une couche supplémentaire de complexité en termes de surveillance, de sécurité et de performance réseau.

--- 

### Composants Essentiels de l'Automatisation Réseau

**Plusieurs composants travaillent ensemble pour fournir une infrastructure réseau cohérente et automatisée, essentielle pour le fonctionnement efficace des clusters Kubernetes.**

Les composants essentiels incluent le **Kubelet**, qui configure les paramètres réseau pour chaque pod, le **Control Plane** de Kubernetes qui orchestre la configuration réseau globale, et les plugins **CNI (Container Network Interface)** qui gèrent l'allocation des adresses IP, les routes et les politiques réseau.

Des outils comme **CoreDNS** automatisent la résolution de noms, tandis que des systèmes comme **Ingress Controllers** et **Service Meshes** (comme Istio ou Linkerd) automatisent la gestion des points d'entrée et la communication sécurisée entre les services.


---

## DNS 

### Le DNS dans Kubernetes

**Le DNS joue un rôle crucial en tant que service de résolution de noms pour les pods et les services.** 

Il permet aux applications de découvrir et de communiquer facilement avec d'autres services à l'intérieur du cluster sans avoir à connaître les adresses IP spécifiques des pods, qui sont souvent dynamiques et changent fréquemment.

Le DNS de Kubernetes permet ainsi de référencer les services par leur nom logique, ce qui simplifie la configuration et la maintenance des applications.

---

### Problèmes Spécifiques à Kubernetes pour le DNS

**Le déploiement de DNS dans Kubernetes peut rencontrer plusieurs défis spécifiques.**

- Problèmes de performance et de latence DNS dans de grands clusters avec de nombreux pods.
- Temps de réponse élevés et des échecs de résolution liés à des limitations de la capacité de mise en cache et la surcharge des requêtes DNS 
- Enregistrements DNS obsolètes ou incorrects dus à la nature éphémère des pods.
- Dysfonctionnements dus aux politiques de réseau et configurations de sécurité, nécessitant une configuration appropriée pour assurer le fonctionnement.


--- 

### Solutions 

**Pour répondre aux défis du DNS dans Kubernetes, les serveurs DNS utilisés sont adaptés aux environnements de conteneurs.** 

CoreDNS est devenu la solution standard, remplaçant kube-dns dans de nombreux déploiements.

CoreDNS est hautement configurable, modulaire et plus performant, capable de gérer un grand nombre de requêtes avec une latence minimale.

Pour améliorer encore la fiabilité et les performances, des techniques comme le caching DNS local, la répartition de la charge DNS, et l'optimisation des configurations de timeout et de réessai sont couramment utilisées.


---

## Communications Est-Ouest 

### Est-Ouest ?

**Les communications Est-Ouest se réfèrent aux échanges de données entre les services et les pods à l'intérieur du cluster.**

Elles assurent le bon fonctionnement des microservices, permettant aux composants d'une application de communiquer efficacement entre eux.

Cette communication interne doit être rapide, fiable et sécurisée pour assurer une performance optimale et une disponibilité élevée des applications.

--- 

### Problèmes 

**Les communications Est-Ouest dans Kubernetes peuvent rencontrer plusieurs défis.**

- Réduction de la latence et de la bande passante 
- Sécurité des communications internes 
- Gestion et suivi des communications dans les gros clusters Kubernetes 

--- 

### Solutions 

#### Choix du CNI et optimisations

Les optimisations réseau au niveau des configurations de CNI (Container Network Interface) et des techniques de mise en cache DNS aident à réduire la latence et à améliorer les performances globales des communications internes.


#### Service meshes

Istio, Linkerd ou Consul Connect sont largement utilisés pour gérer et sécuriser les communications Est-Ouest.

Ils offrent des fonctionnalités telles que le routage intelligent, le monitoring, la répartition de charge et le chiffrement mTLS pour sécuriser les échanges.

#### Network policies 

En outre, l'utilisation de Network Policies permet de définir des règles de sécurité strictes pour contrôler le trafic entre les pods.

---

## Communications Nord-Sud

### Nord-Sud ?

**Les communications Nord-Sud dans Kubernetes concernent les échanges de données entre les applications internes au cluster et les utilisateurs ou services externes.**

Elles sont essentielles pour exposer les applications et les services déployés dans Kubernetes au monde extérieur.

Ce type de communication gère les requêtes entrantes (du monde extérieur vers le cluster) et les réponses sortantes (du cluster vers le monde extérieur), souvent via des points d'entrée comme des Load Balancers, des Ingress Controllers, ou des API Gateways.

---

### Problèmes 

- Sécurisation des points d'entrée pour protéger le cluster contre les attaques externes et les accès non autorisés.
- Gestion de la scalabilité et de la disponibilité pour éviter des goulets d'étranglement ou des pannes de service.
- Gestion des certificats TLS pour sécuriser les communications HTTPS.

--- 

### Solutions 

#### Ingress Controllers

NGINX, Traefik et HAProxy, sont fréquemment déployés pour gérer les entrées HTTP et HTTPS, offrant des fonctionnalités de routage, de répartition de charge et de terminaison TLS.

#### API Gateways

Kong ou Gloo offrent des capacités avancées de gestion des API, y compris la sécurité, le contrôle des accès et la gestion du trafic.

#### Services de Load Balancing

Fournis par des clouds publics ou des solutions open-source, ils aident à répartir le trafic de manière efficace et à garantir la haute disponibilité des applications exposées.

#### Automatisation de la gestion des certificats 

Déployer des outils comme cert-manager est également une pratique courante pour sécuriser les communications externes.

---

## Network Policies

### Rôle des Network Policies 

**Les Network Policies dans Kubernetes jouent un rôle crucial en contrôlant le trafic réseau entre les pods, les services et les namespaces.**

Elles permettent aux administrateurs de définir des règles de sécurité réseau qui régissent les communications autorisées ou bloquées au sein du cluster.

Grâce à ces politiques, les communications internes peuvent être restreintes pour améliorer la sécurité, limiter l'exposition des services sensibles et segmenter les différents environnements applicatifs.

--- 

### Problèmes 

- Complexité de définition et de gestion des règles augmentant avec la taille et la dynamique du cluster
- Difficulté de l'application cohérente des politiques de sécurité et d'assurer leurs évolutions.
- Toutes les implémentations CNI ne supportent pas nativement les Network Policies.
- Le manque de visibilité et de compréhension des flux de trafic existants peut rendre difficile la création de règles efficaces et non disruptives.
- L'application de Network Policies globales au niveau namespace invisible dans les solutions GitOps qui offrent une vision par application  

---

### Solutions

**Pour surmonter ces défis, plusieurs solutions sont couramment déployées.**

- L'utilisation d'outils et de plugins CNI qui supportent nativement les Network Policies, comme Calico ou Cilium, est répandue pour assurer une gestion efficace et performante des règles de sécurité.

- Des outils de visualisation et de monitoring du trafic réseau, tels que Weave Scope ou Istio, aident les administrateurs à comprendre les flux de trafic et à définir des politiques appropriées.


---

## Services, Endpoints et EndPoints Slices

### Définition de Services, Endpoints et EndpointSlices

- Un **Service** est un objet abstrait qui définit une politique de l'accès réseau à un ensemble de pods.
> Les Services fournissent un mécanisme stable pour accéder aux pods, indépendamment de leur adresse IP dynamique, facilitant la découverte de services.
- Les **Endpoints** représentent les adresses IP des pods qui correspondent à un Service particulier, permettant aux Services de savoir où envoyer le trafic.
> Les Endpoints assurent que les Services dirigent correctement le trafic vers les pods appropriés.
- Les **EndpointSlices** sont une version améliorée des Endpoints, introduisant une manière plus scalable et efficace de gérer les adresses IP des pods en les divisant en plusieurs slices, chaque slice contenant un sous-ensemble des adresses.
> Les EndpointSlices améliorent cette gestion en permettant une répartition plus fine et plus performante des informations d'adresses IP, ce qui est crucial pour les clusters de grande taille où la gestion des Endpoints traditionnels peut devenir un goulot d'étranglement.

--- 

### Problèmes 

**Les problèmes spécifiques incluent la scalabilité des Endpoints, où un grand nombre de pods peut entraîner des listes d'Endpoints très volumineuses et difficiles à gérer.**

Les EndpointSlices adressent ces problèmes en offrant une gestion plus granulaire et performante, mais nécessitent une adoption et une adaptation de l'infrastructure existante.

---

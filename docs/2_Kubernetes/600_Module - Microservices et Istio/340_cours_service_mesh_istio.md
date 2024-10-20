---
title: Cours - Service mesh et Istio
# sidebar_class_name: hidden
---

## Le mesh networking et les *service meshes*

Un **service mesh** est un type d'outil réseau pour connecter un ensemble de pods, généralement les parties d'une application microservices de façon encore plus intégrée que ne le permet Kubernetes, mais également plus sécurisé et contrôlable.

En effet opérer une application composée de nombreux services fortement couplés discutant sur le réseau implique des besoins particuliers en terme de routage des requêtes, sécurité et monitoring qui nécessite l'installation d'outils fortement dynamique autour des nos conteneurs.

Un exemple de service mesh est `https://istio.io` qui, en ajoutant dynamiquement un conteneur "sidecar" à chacun des pods à supervisés, ajoute à notre application microservice un ensemble de fonctionnalités d'intégration très puissant.

Un autre service mesh populaire et "plus simple" qu'Istio, Linkerd : https://linkerd.io/

Cilium, le plugin réseau CNI peut aussi opérer comme un service mesh

- https://www.youtube.com/watch?v=16fgzklcF7Y

## Istio

Istio est un **service mesh** open source qui peut se superposer de manière transparente aux applications distribuées existantes.

Il offrent un moyen uniforme et efficace de sécuriser, connecter et surveiller les services. Il ajoute au cluster, avec peu ou pas de modifications du code des services.

- des fonctionnalités plus flexibles et puissantes que le coeur de Kubernetes pour le LoadBalancing entre les services. Notamment un loadbalancing L7 (la couche réseau application) du trafic HTTP, gRPC, WebSocket et TCP

- une authentification entre les services

- une autorisation fine des communications basée sur cette authentification

- une communication chiffrée avec TLS mutuel

- la surveillance du trafic dans le mesh en temps réel

- Un contrôle granulaire du trafic avec des règles de routage riches, des retry automatiques pour les requêtes, des failovers en cas de panne d'un service et un mechanisme de **fault injection**.

- Une couche de politique de sécurité modulaire. l'API de configuration permet d'exprimer des contrôles d'accès, des ratelimits et des quotas pour le traffic

- Istio expose aussi des métriques, des journaux et des traces (chaine d'appels reseau) pour tout le trafic au sein d'un cluster, y compris concernant le traffic entrant et sortant (ingress et egress) du cluster.

- Istio est conçu pour être extensible et gère une grande variété de besoins de déploiement.

### Architecture de Istio

![](/img/kubernetes/istio_archi.png)

- Istiod (auparavant 3 composant séparés fusionnés pour la simplicité opérationnelle) est le controlleur du control plane istio
- Le mesh des sidecar proxies est le dataplane de istio
- Les ingress et egress gateways sont les point d'accès à votre mesh de service et permettent de définir des règles de routage et de sécurité en périphérie du mesh.

### Istio par l'exemple et autres resources

- https://istiobyexample.dev/

- https://www.istioworkshop.io/09-traffic-management/06-circuit-breaker/

### CRDs de Istio

Istio utilise plusieurs Custom Resource Definitions (CRDs) pour étendre les fonctionnalités de Kubernetes et permettre la configuration de ses différents composants:

- **VirtualService** : Le CRD `VirtualService` permet de définir les règles de trafic pour contrôler le routage des requêtes HTTP et TCP vers différentes destinations dans le maillage Istio. Il est utilisé pour configurer des fonctionnalités telles que le routage basé sur des en-têtes, des poids du trafic, des redirections et des destinations de service.

- **DestinationRule** : Le CRD `DestinationRule` est utilisé pour définir les règles de trafic spécifiques à une destination, telles que la configuration des politiques de répartition de charge, des réplicas et des stratégies de rééquilibrage de charge.

- **Gateway** : Le CRD `Gateway` est utilisé pour configurer les points d'entrée de trafic externes dans le maillage Istio. Il permet de définir des règles pour l'exposition de services Istio à l'extérieur du maillage, comme l'exposition de services HTTP, HTTPS et TCP.

- **ServiceEntry** : Le CRD `ServiceEntry` est utilisé pour déclarer des services externes (non-Istio) au sein du maillage Istio. Il permet à Istio de gérer la communication avec des services situés en dehors du maillage et d'appliquer des politiques de sécurité, de trafic et de résilience à ces services.

- **Sidecar** : Le CRD `Sidecar` est utilisé pour configurer les sidecars Envoy dans les pods de votre application. Il permet de définir des options de configuration spécifiques pour chaque sidecar, telles que les politiques de trafic, les filtres réseau et les règles de sécurité.

- **AuthorizationPolicy** : Le CRD `AuthorizationPolicy` est utilisé pour définir des politiques de contrôle d'accès basées sur les rôles et les permissions pour les services dans le maillage Istio. Il permet de spécifier des règles d'autorisation pour limiter l'accès aux services en fonction des identités et des attributs de requête.


### Istio et API Gateway

Istio soutient la standardisation via la norme API gateway de Kubernetes. Il est donc possible d'utiliser les CRDs de l'api gateway pour configurer le routage du traffic et les points d'entrée du mesh plutôt que les CRDs de Istio.

En l'état actuel l'api gateway ne supporte pas tous les cas d'usage de Istio et est moins documenté même si la documentation vous permet de choisir librement la syntaxe istio ou api gateway pour de nombreux cas. Il peut être intéressant de l'utiliser si l'on cherche de la standardisation à long terme

Les CRDs de l'API Gateway officiel doivent être installés indépendament de Istio

### Ambient mesh architecture

L'architecture classique de Istio avec des proxies pour chaque pod est un peu lourde à mettre en oeuvres et peut interfèrer avec d'autres solution kubernetes.

Istio développe une nouvelle architecture appelée ambient basée sur des agents déployés sur chaque noeuds du cluster. Elle est encore alpha mais promet un usage plus simple et économe de Istio dans un futur proche.


<!-- ## Essayer Istio

- Cloner l'application d'exemple bookinfo :

```sh
cd ~/Desktop
git clone https://github.com/istio/istio.git
cp -R istio/sample/bookinfo .
```

- Suivez le tutoriel officiel à l'adresse : https://istio.io/latest/docs/setup/getting-started/
 -->

<!-- 
## Principes et architecture


### Pour aller plus loin


## Déployer Istio

#### 1. Déployer les Custom Resource Definitions avec le chart Istio base:

```sh
helm repo add istio https://istio-release.storage.googleapis.com/charts

helm repo update

kubectl create namespace istio-system

helm install istio-base istio/base -n istio-system --set defaultRevision=default
```

C'est une bonne pratique générale de ne pas déployer les CRDs avec le chart principal de l'application/opérateur que l'on veut installer. En effet :

- Désinstaller une release d'un chart est une opération assez commune
- Désinstaller une release comprenant des CRDs va désinstaller ces CRDs
- Désinstaller les CRDs implique la suppression définitive des resources associées ce qui implique une perte de données potentiellement grave

On pourrait vouloir utiliser plusieurs releases du même chart sans toucher aux CRDs et la 

#### 2. Installer le control plane Istio via une application ArgoCD

```sh
helm install istiod istio/istiod -n istio-system --set "profile=demo" --wait
```

## Déployer l'application d'exemple bookinfo

- Cloner l'application: `git clone https://github.com/Uptime-Formation/istio_bookinfo_TPs.git`

- Créer un namespace pour l'application : `kubectl create namespace bookinfo`.

- Activer l'injection de sidecar (le mode normal de Istio) pour le namespace: `kubectl label namespace bookinfo istio-injection=enabled`

Le controller Istiod surveille les namespaces étiquetés de la sorte.

Déployons l'application avec ArgoCD
 -->


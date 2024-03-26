---
title: TP optionnel - Istio service mesh
# sidebar_class_name: hidden
---


## Le mesh networking et les *service meshes*

Un **service mesh** est un type d'outil réseau pour connecter un ensemble de pods, généralement les parties d'une application microservices de façon encore plus intégrée que ne le permet Kubernetes.

En effet opérer une application composée de nombreux services fortement couplés discutant sur le réseau implique des besoins particuliers en terme de routage des requêtes, sécurité et monitoring qui nécessite l'installation d'outils fortement dynamique autour des nos conteneurs.

Un exemple de service mesh est `https://istio.io` qui, en ajoutant dynamiquement un conteneur "sidecar" à chacun des pods à supervisés, ajoute à notre application microservice un ensemble de fonctionnalités d'intégration très puissant.

Un autre service mesh populaire et plus simple qu'Istio, Linkerd : https://linkerd.io/

Cilium peut aussi maintenant opérer comme un service mesh

- https://www.youtube.com/watch?v=16fgzklcF7Y

## Fonctionnalités de Istio

- dynamic service discovery
- retry et autres fonctionnalités utiles pour les microservices
- traffic metrics, and tracing (récupérer notamment les latences des requêtes entre chaque service)
- chiffrement mTLS des connexions entre services

![](/img/kubernetes/istio_archi.png)

### CRDs de Istio

Istio utilise plusieurs Custom Resource Definitions (CRDs) pour étendre les fonctionnalités de Kubernetes et permettre la configuration de ses différents composants:

- **VirtualService** : Le CRD `VirtualService` permet de définir les règles de trafic pour contrôler le routage des requêtes HTTP et TCP vers différentes destinations dans le maillage Istio. Il est utilisé pour configurer des fonctionnalités telles que le routage basé sur des en-têtes, des poids du trafic, des redirections et des destinations de service.

- **DestinationRule** : Le CRD `DestinationRule` est utilisé pour définir les règles de trafic spécifiques à une destination, telles que la configuration des politiques de répartition de charge, des réplicas et des stratégies de rééquilibrage de charge.

- **Gateway** : Le CRD `Gateway` est utilisé pour configurer les points d'entrée de trafic externes dans le maillage Istio. Il permet de définir des règles pour l'exposition de services Istio à l'extérieur du maillage, comme l'exposition de services HTTP, HTTPS et TCP.

- **ServiceEntry** : Le CRD `ServiceEntry` est utilisé pour déclarer des services externes (non-Istio) au sein du maillage Istio. Il permet à Istio de gérer la communication avec des services situés en dehors du maillage et d'appliquer des politiques de sécurité, de trafic et de résilience à ces services.

- **Sidecar** : Le CRD `Sidecar` est utilisé pour configurer les sidecars Envoy dans les pods de votre application. Il permet de définir des options de configuration spécifiques pour chaque sidecar, telles que les politiques de trafic, les filtres réseau et les règles de sécurité.

- **AuthorizationPolicy** : Le CRD `AuthorizationPolicy` est utilisé pour définir des politiques de contrôle d'accès basées sur les rôles et les permissions pour les services dans le maillage Istio. Il permet de spécifier des règles d'autorisation pour limiter l'accès aux services en fonction des identités et des attributs de requête.


## Essayer Istio

- Cloner l'application d'exemple bookinfo :

```sh
cd ~/Desktop
git clone https://github.com/istio/istio.git
cp -R istio/sample/bookinfo .
```

- Suivez le tutoriel officiel à l'adresse : https://istio.io/latest/docs/setup/getting-started/


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


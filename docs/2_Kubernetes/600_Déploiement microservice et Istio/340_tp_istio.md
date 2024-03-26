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

## Fonctionnalités de Istio

- dynamic service discovery
- traffic metrics, and tracing (récupérer notamment les latences des requêtes entre chaque service)
- chiffrement mTLS des connexions entre services

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


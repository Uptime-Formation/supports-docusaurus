---
title: TP optionnel - Istio service mesh
sidebar_class_name: hidden
---



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



---
title:  1. Introduction
weight: 100
---

## Objectifs du cours

- Introduction
- Architecture de Kubernetes
  - Principes de fonctionnement
  - Composants de Kubernetes
  - Container Engine
  - Container Network Interface
  - Container Storage Interface
  - Certificats
- Installation de Kubernetes
  - Kubernetes as a Service
  - Installation manuelle
  - Outils d’installation
  - Haute Disponibilité
- Utilisation de Kubernetes
  - Kubernetes API
  - Approfondissement de certaines ressources: Deployment, Secret, Ingress…
  - Différents types de Services et Endpoints
  - Ressources avancées: StatefulSet, DaemonSet, Job/CronJob, StorageClass…
  - Requests et Limits
  - Network Policies
- Administration de Kubernetes
  - Déploiement d’application
  - Gestion des ressources
  - Troubleshooting
  - Autoscaling
  - Bonnes pratiques
- Enrichissement de clusters
  - Helm
  - Metrics Server
  - Prometheus et Grafana
  - CertManager et LetsEncrypt
  - EFK
- Service Mesh avec Istio
  - Architecture
  - Observabilité
  - Blue/green deployment
  - Mutual TLS
- Ecosystème de Kubernetes



## Rappels sur la conteneurisation : images, instances, cycle de vie  

### Les images Docker

![](../../static/img/docker/docker-image-layers.png)


**Chaque layer correspond à une information qui peut être mise en cache**

Quel est l'intérêt ? 

Quelles sont les impacts en terme de construction de Dockerfiles ?

Savez-vous ce que fait la commande `docker commit` ? En quoi est-elle utile ? 

---

### Les instances

![](../../static/img/docker/docker-daemon-architecture.jpg)

**Une instance est l'exécution d'un process dans un espace de conteneurisation sur la base d'un exécutable dans une image Docker.**

Quels sont les composants qui permettent ce processus ? 

---

### Le cycle de vie des instances Docker

![](../../static/img/docker/docker-lifecycle.png)

**Docker gère les images et les instance de la création à la destruction.**

---

### Les volumes Docker

![](../../static/img/docker/docker-volumes.png)

**Le montage de volumes dans Docker se base sur les processus des montages dans Linux.**

---

### Les réseaux Docker


![](../../static/img/docker/docker-network.png)

**Les réseaux Docker sont automatisés : DNS, IP Address Management, et plus.**

---



## Testons vos connaissances !

Pour toutes ces questions, on se base sur un Kubernetes "neutre", sans extensions particulières.
### Test de connaissances générales pour Kubernetes

#### Containers

**Question:** Qu'est-ce qu'un conteneur et comment est-il utilisé dans Kubernetes ?


a) Un conteneur est une machine virtuelle légère  
b) Un conteneur est une instance d'une image Docker  
c) Un conteneur est un volume de stockage  
d) Un conteneur est un outil de gestion de réseau

#### Images Docker

**Question:** Quel est le rôle d'une image Docker ?


a) Héberger les bases de données  
b) Fournir des fichiers de configuration pour les conteneurs  
c) Contenir l'application et toutes ses dépendances nécessaires pour fonctionner  
d) Gérer les volumes de stockage

#### Namespace

**Question:** Qu'est-ce qu'on peut associer à un namespace ?

a) Des quotas  
b) Des machines physiques  
c) Des règles réseaux  
d) Des volumes

#### Secrets

**Question:** Quel est le but des Secrets dans Kubernetes ?


a) Stocker des informations sensibles comme des mots de passe et des clés API  
b) Gérer les volumes de stockage  
c) Assurer la connectivité réseau  
d) Contrôler les accès aux pods

#### Logs

**Question:** Quel outil est couramment utilisé pour centraliser et visualiser les logs dans Kubernetes ?


a) Fluentd  
b) Jenkins  
c) Prometheus  
d) Grafana

#### Architecture de Kube: Control plane

**Question:** Quels composants font partie du control plane dans Kubernetes ?


a) kubelet, kube-proxy  
b) kube-apiserver, etcd, kube-scheduler, kube-controller-manager  
c) kubelet, kube-scheduler  
d) kube-proxy, kube-controller-manager

#### Pod: le réseau et les volumes dans le pod

**Question:** Comment les pods gèrent-ils le réseau et les volumes dans Kubernetes ?


a) Les pods partagent le même namespace réseau  
b) Chaque pod a son propre namespace réseau  
c) Les pods n'utilisent pas de volumes  
d) Les volumes sont montés directement dans les conteneurs des pods

#### Services: les types d'exposition

**Question:** Quels sont les types de services dans Kubernetes ?


a) ClusterIP, NodePort, LoadBalancer, ExternalName  
b) InternalIP, NodeName, LoadBalancer, ExternalName  
c) ClusterIP, NodePort, LoadBalancer, InternalName  
d) ClusterPort, NodePort, LoadBalancer, ExternalName

#### ConfigMaps

**Question:** Comment peut-on accéder aux ConfigMaps dans un pod ?


a) En tant que variable d'environnement  
b) En tant que volume monté  
c) Par une requête API  
d) Toutes les réponses ci-dessus

#### Secrets

**Question:** Quelle est la différence principale entre un Secret et un ConfigMap ?


a) Les Secrets sont utilisés pour stocker des données sensibles, les ConfigMaps pour des configurations non sensibles  
b) Les Secrets ne peuvent pas être montés en tant que volumes  
c) Les ConfigMaps ne peuvent pas être utilisés pour des variables d'environnement  
d) Il n'y a pas de différence

#### Affinité

**Question:** Quel est le rôle de l'affinité dans Kubernetes ?


a) Déterminer comment les pods sont placés sur les nœuds en fonction de certaines règles  
b) Gérer les accès aux services  
c) Configurer les volumes de stockage  
d) Contrôler les quotas de ressources

#### Helm

**Question:** Quel est le rôle de Helm dans Kubernetes ?


a) Gérer les images Docker  
b) Déployer, gérer et versionner des applications Kubernetes à l'aide de packages appelés charts  
c) Surveiller les performances des pods  
d) Configurer les règles réseau

## Correction

<details><summary>...</summary>


1. b) Un conteneur est une instance d'une image Docker
2. c) Contenir l'application et toutes ses dépendances nécessaires pour fonctionner
3. a) Des quotas, c) Des règles réseaux d) Des volumes
4. a) Stocker des informations sensibles comme des mots de passe et des clés API
5. a) Fluentd
6. b) kube-apiserver, etcd, kube-scheduler, kube-controller-manager
7. a) Les pods partagent le même namespace réseau, d) Les volumes sont montés directement dans les conteneurs des pods
8. a) ClusterIP, NodePort, LoadBalancer, ExternalName (révision sur https://sysdig.com/blog/kubernetes-services-clusterip-nodeport-loadbalancer/)
9. d) Toutes les réponses ci-dessus
10. a) Les Secrets sont utilisés pour stocker des données sensibles, les ConfigMaps pour des configurations non sensibles
11. a) Déterminer comment les pods sont placés sur les nœuds en fonction de certaines règles
12. b) Déployer, gérer et versionner des applications Kubernetes à l'aide de packages appelés charts

</details>



---
title: Déployer avec Docker L'évolution de l'écosystème des orchestrateurs
---

## Objectifs pédagogiques

  - Comprendre les enjeux qui mènent à de l'orchestration de conteneurs
  - Connaître les différentes solutions actuelles
  
## Kubernetes 

Kubernetes est un système qui représente plus de 50% des conteneurs déployés en production. 

Son principal défaut est la courbe d'acquisition de connaissances nécessaire pour l'utiliser. 

En contrepartie, le système offre beaucoup de fonctionnalités utiles pour la mise en production d'architectures complexes (infras web microservices notamment)

Il se base sur les années d'expérience de Google dans le domaine de l'exécution de conteneurs à forte charge et impératifs de sécurité élevés.

Ses performances à l'échelle sont inégalées, jusqu'à 5 000 noeuds et 300 000 conteneurs dans un seul cluster.

## Docker Swarm

Docker swarm est la solution de Docker pour exécuter Docker sur plusieurs hôtes.

La solution n'a jamais vraiment décollé car elle n'a pas résolu résolu les problèmes complexes et d'échelle de la production : 

Aujourd'hui le produit est toujours disponible mais n'a plus de visibilité pour l'avenir: https://github.com/BretFisher/ama/discussions/189

En gros, le principal problème d'utiliser Swarm aujourd'hui est l'effondrement de son écosystème de plugins maintenus. Par exemple il n'y a plus vraiment de solution de volume réseau.


## Hashicorp Nomad

Projet opensource par une entreprise leader dans le monde du cloud computing (Vagrant, Terraform, Vault)

Nomad est compatible OCI/CRI et fonctionne bien avec d'autres produits Hashicorp comme Consul (service mesh).

Mais le projet manque de traction par rapport à K8S et aux innombrables projets du CNCF qui se basent sur ses API normalisées.

# Mesos (Apache)

Une solution historique (2009) qui utilise des logiciels Apache pour fournir des conteneurs sur plusieurs datacenters.

C'est un système complexe et puissant qui réserve son usage à de très grosses entreprises.

# CoreOS  

Une autre solution historique (Container Linux) dont le runtime `rkt` fonctionne sous Kubernetes.

Elle a été racheté par RedHat, puis renommée en Fedora CoreOS.

Comme d'autres, la solution continue d'avoir des adeptes mais est en perte de vitesse.

## AWS ECS / EKS, GKE, AKS

Amazon Elastic Container Service est une solution d'orchestration conçue et opérée en service managé par AWS. Code non libre.

Face au succès grandissant de Kubernetes, Amazon Kubernetes Service est apparu, pour fournir des clusters k8s par Amazon.

Google Cloud et Azure fournissent également des solutions qui visent à réduire la dépendance technique.

Ils fournissent également les services managés (Bases de données, stockage, réseau) permettant de gérer ses services externes dans un seul lieu.

# Openshift

Solution commerciale de RedHat pour faire du Platform As A Service sur une base Kubernetes.

Disponible on premise ou sur de nombreux clouds, OpenShift intègre différents logiciels libres  pour fournir *out of the box* des fonctionnalités avancées, y compris le build d'image automatisé.
- Ceph pour les volumes 
- Prometheus pour le monitoring
- Istio pour le service mesh


# Et Docker Compose dans tout ça ? 

**Docker compose n'est pas un orchestrateur mais se situe à la frontière entre exécution simple et orchestrateurs.**

Il permet d'exécuter des conteneurs avec peu de spécifications tout en gérant la persistance des données et la mise en réseau des conteneurs.

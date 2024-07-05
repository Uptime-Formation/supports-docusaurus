---
title:  Run4 - Vertical Autoscaling
weight: 420
---
## Définition: Scale Up vs.Scale Out

---

### Scale Up

**Le scale up consiste à augmenter les ressources d'un serveur existant.**

Par exemple, augmenter la mémoire RAM, ajouter des CPU, ou augmenter l'espace de stockage.

Ce type de scaling est limité par les capacités maximales du serveur physique.

---

### Scale Out

Le scale out consiste à ajouter plus de serveurs ou de nœuds à un système.

Au lieu d'augmenter les ressources d'un seul serveur, on ajoute plus de serveurs pour distribuer la charge.

Kubernetes utilise principalement ce type de scaling pour gérer les charges de travail en augmentant le nombre de pods ou de nœuds dans le cluster.

---

##  Vertical Pod Autoscaler (VPA)

**C'est une fonctionnalité de Kubernetes qui ajuste automatiquement les ressources CPU et mémoire des pods en fonction des besoins réels des applications en cours d'exécution.**

Contrairement à l'Horizontal Pod Autoscaler (HPA), qui ajuste le nombre de réplicas (pods) pour répondre à la demande, le VPA modifie les ressources allouées à chaque pod individuel.

---

**Le Vertical Pod Autoscaler (VPA) est un outil puissant pour gérer efficacement les ressources dans Kubernetes, permettant aux pods de s'adapter dynamiquement aux besoins réels des applications.**

En automatisant les ajustements de CPU et de mémoire, le VPA contribue à optimiser l'utilisation des ressources et à améliorer les performances des applications.

---

### Fonctionnement du VPA

#### Surveillance des Ressources.

Le VPA surveille en continu l'utilisation des ressources des pods, collectant des données sur la consommation de CPU et de mémoire.

#### Recommandations de Ressources.

Basé sur les données collectées, le VPA génère des recommandations pour les ressources nécessaires (requests et limits) pour chaque pod.

#### Application des Modifications.

Le VPA peut appliquer ces recommandations automatiquement en redémarrant les pods avec les nouvelles ressources allouées, ou il peut simplement fournir des recommandations que les administrateurs peuvent appliquer manuellement.

--- 

### Avantages du VPA

- **Optimisation des Ressources** : Le VPA aide à optimiser l'utilisation des ressources en ajustant les allocations de CPU et de mémoire pour correspondre aux besoins réels de l'application.
- **Simplification de la Gestion** : En automatisant l'ajustement des ressources, le VPA réduit la nécessité de surveiller et d'ajuster manuellement les configurations des pods.
- **Meilleure Performance** : En garantissant que les pods disposent des ressources adéquates, le VPA contribue à améliorer les performances globales des applications.

--- 


### Utilisation Typique

- **Applications à Charge Variable** : Le VPA est particulièrement utile pour les applications dont les charges de travail varient de manière imprévisible, nécessitant des ajustements dynamiques des ressources.
- **Environnements de Développement et de Test** : Dans les environnements où les besoins en ressources peuvent changer fréquemment, le VPA permet d'ajuster automatiquement les configurations sans intervention manuelle.

--- 


### Exemple de Configuration de VPA

```yaml
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: myapp-vpa
  namespace: default
spec:
  targetRef:
    apiVersion: "apps/v1"
    kind: Deployment
    name: myapp
  updatePolicy:
    updateMode: "Auto"
```

Dans cet exemple, le VPA est configuré pour un déploiement nommé "myapp" et est en mode automatique, ce qui signifie qu'il ajustera automatiquement les ressources des pods en fonction des recommandations.

--- 


### Cluster Autoscaler

**Le Cluster Autoscaler ajuste automatiquement le nombre de nœuds dans un cluster Kubernetes en fonction des besoins en ressources.**

Il vise à ajuster automatiquement le nombre de nœuds en fonction des besoins en ressources, garantissant une utilisation optimale des ressources et une disponibilité continue des applications.

### Sources

- [Kubernetes Documentation - Cluster Autoscaler](https://kubernetes.io/docs/concepts/cluster-administration/autoscaling/#cluster-autoscaler)
- [Cluster Autoscaler on Github](https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler)
- [Exemple pour OVHcloud](https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/cloudprovider/ovhcloud/README.md)
---

#### Surveillance des Pods Non Programmés.

Le Cluster Autoscaler surveille continuellement les pods qui ne peuvent pas être programmés sur les nœuds existants en raison de contraintes de ressources (par exemple, manque de CPU ou de mémoire).

#### Ajout de Nœuds.

Lorsqu'il détecte des pods non programmés, le Cluster Autoscaler ajoute des nœuds supplémentaires au cluster pour satisfaire les demandes de ressources.

Cela permet de s'assurer que les applications ont les ressources nécessaires pour fonctionner correctement.

#### Suppression des Nœuds Sous-Utilisés.

Inversement, le Cluster Autoscaler surveille les nœuds sous-utilisés (ceux qui n'hébergent pas de pods ou très peu) et les supprime pour optimiser les coûts et les ressources.

Il s'assure que le cluster utilise efficacement les ressources disponibles sans surdimensionner les nœuds.

#### Configuration et Limites.

Les administrateurs peuvent configurer des limites minimales et maximales pour le nombre de nœuds dans le cluster, permettant de contrôler les coûts et d'assurer une disponibilité suffisante des ressources.

Les configurations peuvent inclure des paramètres pour définir la taille des nœuds, les zones de disponibilité, et d'autres paramètres spécifiques à l'infrastructure cloud utilisée.

--- 
### Problèmes récurrents du Cluster Autoscaler

La [FAQ du Cluster Autoscaler ](https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/FAQ.md) montre que le processus est très complexe. 

De nombreux problèmes sont inévitables dans l'interaction entre le cluster et le provider.

- Métriques incorrectes : décisions de scaling inappropriées
- Evolution du provider : changement d'offre du Provider / mauvaises configuration
- Indisponibilité du provider : absence de machines disponibles 
- Quotas du provider : impossibilité de consommer des ressources supplémentaires
- Latences : incohérence temporelle entre la demande et l'obtention
- Logique interne Kubernetes : éviction de pods impossibles (volumes persistants) et nodes mal exploités

---
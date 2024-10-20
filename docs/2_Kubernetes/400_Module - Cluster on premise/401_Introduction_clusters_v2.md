---
title: Introduction - Les différents types de cluster - avancé
sidebar_class_name: hidden
---


## Kubernetes

- Kubernetes est une solution d'orchestration de conteneurs extrêmement populaire.
- Le projet est très ambitieux : une façon de considérer son ampleur est de voir Kubernetes comme un système d'exploitation (et un standard ouvert) pour les applications distribuées et le cloud.
- Le projet est développé en Open Source au sein de la Cloud Native Computing Foundation.

## Architecture de Kubernetes

Kubernetes a une architecture master/worker ce qui signifie que certains certains noeuds du cluster contrôlent l'exécution par les autres noeuds de logiciels ou jobs.

![](/img/kubernetes/schemas-perso/k8s-archi.jpg)

#### Les noeuds Kubernetes

Les nœuds d’un cluster sont les machines (serveurs physiques, machines virtuelles, etc. généralement Linux mais plus nécessairement aujourd'hui) qui exécutent vos applications et vos workflows. Tous les noeuds d'un cluster qui ont besoin de faire tourner des taches (workloads) kubernetes utilisent trois services de base:

- Comme les workloads sont généralement conteneurisés chaque noeud doit avoir une _runtime de conteneur_ compatible avec la norme `Container Runtime Interface (CRI)` : `containerd`,`cri-o` ou `Docker` n'est pas la plus recommandée bien que la plus connue. Il peut également s'agir d'une runtime utilisant de la virtualisation.
- Le `kubelet` composant (binaire en go, le seul composant jamais conteneurisé) qui controle la création et l'état des pods/conteneur sur son noeud.
- D'autres composants et drivers pour fournir fonctionnalités réseau (`Container Network Interface - CNI` et `kube-proxy`) ainsi que fonctionnalités de stockage (`Drivers Container Storage Interface (CSI)`)

Pour utiliser Kubernetes, on définit un état souhaité en créant des ressources (pods/conteneurs, volumes, permissions etc). Cet état souhaité et son application est géré par le `control plane` composé des noeuds master.

#### Les noeuds master kubernetes forment le `Control Plane` du Cluster

Le control plane est responsable du maintien de l’état souhaité des différents éléments de votre cluster. Lorsque vous interagissez avec Kubernetes, par exemple en utilisant l’interface en ligne de commande `kubectl`, vous communiquez avec les noeuds master de votre cluster (plus précisément l'`API Server`).

Le control plane conserve un enregistrement de tous les objets Kubernetes du système. À tout moment, des `boucles de contrôle` s'efforcent de faire converger l’état réel de tous les objets du système pour correspondre à l’état souhaité que vous avez fourni. Pour gérer l’état réel de ces objets sous forme de conteneurs (toujours) avec leur configuration le control plane envoie des instructions aux différents kubelets des noeuds.

Donc concrêtement les noeuds du control plane Kubernetes font tourner, en plus de `kubelet` et `kube-proxy`, un ensemble de services de contrôle:

  - `kube-apiserver`: expose l'API (rest) kubernetes, point d'entrée central pour la communication interne (intercomposants) et externe (kubectl ou autre) au cluster.
  - `kube-controller-manager`: controlle en permanence l'état des resources et essaie de le corriger s'il n'est plus conforme.
  - `kube-scheduler`: Surveille et cartographie les resources matérielles et les contraintes de placement des pods sur les différents noeuds pour décider ou doivent être créés ou supprimés les conteneurs/pods.
  - `cloud-controller-manager`: Composant *facultatif* qui gère l'intégration avec le fournisseur de cloud comme par exemple la création automatique de loadbalancers pour exposer les applications kubernetes à l'extérieur du cluster.

L'ensemble de la configuration kubernetes est stockée de façon résiliante (consistance + haute disponilibilité) dans un gestionnaire configuration distributé qui est généralement `etcd`.

`etcd` peut être installé de façon redondante sur les noeuds du control plane ou configuré comme un système externe sur un autre ensemble de serveurs.

Lien vers la documentation pour plus de détails sur les composants : https://kubernetes.io/docs/concepts/overview/components/

## 



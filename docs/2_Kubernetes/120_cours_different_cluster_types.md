---
title: Cours - Les différents types de clusters
draft: false
# sidebar_position: 7
---

## Kubernetes

- Kubernetes est une solution d'orchestration de conteneurs extrêmement populaire.
- Le projet est très ambitieux : une façon de considérer son ampleur est de voir Kubernetes comme un système d'exploitation (et un standard ouvert) pour les applications distribuées et le cloud.
- Le projet est développé en Open Source au sein de la Cloud Native Computing Foundation.

## Architecture de Kubernetes

Kubernetes a une architecture master/worker ce qui signifie que certains certains noeuds du cluster contrôlent l'exécution par les autres noeuds de logiciels ou jobs.

![](/img/kubernetes/shema-persos/k8s-archi.jpg)

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

#### Configuration de connexion `kubeconfig`

Pour se connecter, `kubectl` a besoin de l'adresse de l'API Kubernetes, d'un nom d'utilisateur et d'un certificat.

- Ces informations sont fournies sous forme d'un fichier YAML appelé `kubeconfig`
- Comme nous le verrons en TP ces informations sont généralement fournies directement par le fournisseur d'un cluster k8s (provider ou k8s de dev)

Le fichier `kubeconfig` par défaut se trouve sur Linux à l'emplacement `~/.kube/config`.

On peut aussi préciser la configuration au *runtime* comme ceci: `kubectl --kubeconfig=fichier_kubeconfig.yaml <commandes_k8s>`

Le même fichier `kubeconfig` peut stocker plusieurs configurations dans un fichier YAML :

Exemple :

```yaml
apiVersion: v1

clusters:
- cluster:
    certificate-authority: /home/jacky/.minikube/ca.crt
    server: https://172.17.0.2:8443
  name: minikube
- cluster:
    certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURKekNDQWcrZ0F3SUJBZ0lDQm5Vd0RRWUpLb1pJaHZjTkFRRUxCUUF3TXpFVk1CTUdBMVVFQ2hNTVJHbG4KYVhSaGJFOWpaV0Z1TVJvd0dBWURWUVFERXhGck9<clipped>3SCsxYmtGOHcxdWI5eHYyemdXU1F3NTdtdz09Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
    server: https://5ba26bee-00f1-4088-ae11-22b6dd058c6e.k8s.ondigitalocean.com
  name: do-lon1-k8s-tp-cluster

contexts:
- context:
    cluster: minikube
    user: minikube
  name: minikube
- context:
    cluster: do-lon1-k8s-tp-cluster
    user: do-lon1-k8s-tp-cluster-admin
  name: do-lon1-k8s-tp-cluster
current-context: do-lon1-k8s-tp-cluster

kind: Config
preferences: {}

users:
- name: do-lon1-k8s-tp-cluster-admin
  user:
      token: 8b2d33e45b980c8642105ec827f41ad343e8185f6b4526a481e312822d634aa4
- name: minikube
  user:
    client-certificate: /home/jacky/.minikube/profiles/minikube/client.crt
    client-key: /home/jacky/.minikube/profiles/minikube/client.key
```

Ce fichier déclare 2 clusters (un local, un distant), 2 contextes et 2 users.

## Créer un cluster Kubernetes

### Installation de développement

Pour installer un cluster de développement :

- solution officielle : Minikube, tourne dans Docker par défaut (ou dans des VMs)
- solution très pratique et "vanilla": kind 
- avec Docker Desktop depuis peu (dans une VM aussi)
- un cluster léger avec `k3s`, de Rancher (simple et utilisable en production/edge)

### Créer un cluster en tant que service (*managed cluster*) chez un fournisseur de cloud.

Tous les principaux fournisseurs de cloud proposent depuis plus ou moins longtemps des solutions de cluster gérées par eux (Kaas, Kubernetes as a service):

- Google Cloud Plateform avec Google Kubernetes Engine (GKE) : très populaire car très flexible et l'implémentation de référence de Kubernetes.
- AWS avec EKS : Kubernetes à la sauce Amazon pour la gestion de l'accès, des loadbalancers ou du scaling.
- Azure avec AKS : Kubernetes à la sauce Microsoft.
- DigitalOcean ou Linode : un peu moins de fonctions mais plus simple à appréhender <!-- (nous l'utiliserons) -->

Les gros fournisseur proposent tous des services éprouvés, il s'agit surtout de faciliter l'intégration avec l'existant: Si vous utilisez déjà des resources AWS ou Azure il est plus commode de louer chez l'un d'eux votre cluster.

<!-- can you detail the specific integrations of each kaas offer with the other products of the provideer : 

    Google Kubernetes Engine (GKE) :

    Intégration avec la plateforme Google Cloud (GCP) : GKE est étroitement intégré avec d'autres services de Google Cloud, tels que Compute Engine, Cloud Storage et Cloud DNS. GCP fournit également une suite d'outils pour la gestion et la surveillance des clusters GKE, notamment Stackdriver Logging et Monitoring.

    Anthos : Anthos est la plateforme hybride et multi-cloud de Google qui vous permet d'exécuter et de gérer des clusters Kubernetes sur plusieurs clouds et environnements sur site. GKE est un composant clé d'Anthos, et Anthos fournit des fonctionnalités supplémentaires telles que le maillage de services Istio et la plateforme serverless Cloud Run.

    Istio : Istio est un maillage de services qui fournit la gestion de trafic, la sécurité et l'observabilité pour les microservices. GKE fournit une intégration intégrée avec Istio, et vous pouvez utiliser Istio pour gérer le trafic entre les services s'exécutant sur les clusters GKE.

    Microsoft Azure Kubernetes Service (AKS) :

    Intégration avec Azure : AKS est étroitement intégré avec d'autres services Azure, tels que Azure Active Directory, Azure Virtual Network et Azure Monitor. Vous pouvez utiliser Azure pour gérer les clusters AKS, surveiller leurs performances et configurer des alertes.

    Azure DevOps : Azure DevOps est un ensemble d'outils pour la gestion du cycle de vie complet du développement de logiciels. AKS s'intègre à Azure DevOps pour vous permettre de déployer et de gérer facilement des applications Kubernetes.

    Azure Container Registry : Azure Container Registry est un service de registre Docker géré qui offre un moyen sécurisé et évolutif de stocker et de gérer des images de conteneurs. AKS s'intègre à Azure Container Registry pour vous permettre de déployer et de gérer facilement des applications conteneurisées.

    Amazon Elastic Kubernetes Service (EKS) :

    Intégration avec AWS : EKS est étroitement intégré avec d'autres services AWS, tels que Amazon EC2, Amazon VPC et AWS IAM. Vous pouvez utiliser AWS pour gérer les clusters EKS, surveiller leurs performances et configurer des alertes.

    AWS Fargate : AWS Fargate est un moteur de calcul serverless pour les conteneurs qui vous permet d'exécuter des conteneurs sans avoir à gérer l'infrastructure sous-jacente. EKS s'intègre à AWS Fargate pour vous permettre d'exécuter et de gérer facilement des conteneurs sur les clusters EKS.

    AWS App Mesh : AWS App Mesh est un maillage de services qui fournit la gestion de trafic, la sécurité et l'observabilité pour les microservices. EKS fournit une intégration intégrée avec App Mesh, et vous pouvez utiliser App Mesh pour gérer le trafic entre les services s'exécutant sur les clusters EKS.

Ce ne sont que quelques exemples des intégrations proposées par chaque fournisseur de services Kubernetes. Chaque fournisseur dispose de sa propre gamme d'outils et de services qui peuvent être intégrés à Kubernetes pour vous permettre de créer, de déployer et de gérer des applications plus facilement. -->

Fournisseurs français de Kubernetes as a service: OVH, Scaleway


### Installer un cluster de production on premise : l'outil "officiel" `kubeadm`

`kubeadm` est un utilitaire (on parle parfois d'opérateur) aider à générer les certificats et les configurations spéciques pour le control plane et connecter les noeuds au control plane. Il permet également d'assiter les taches de maintenance comme la mise à jour progressive (rolling) de chaque noeud du cluster.

- Installer le dæmon `Kubelet` sur tous les noeuds
- Installer l'outil de gestion de cluster `kubeadm` sur un noeud master
- Générer les bons certificats avec `kubeadm`
- Installer un réseau CNI k8s comme `flannel` (d'autres sont possible et le choix vous revient)
- Déployer la base de données `etcd` avec `kubeadm`
- Connecter les nœuds worker au master.

L'installation est décrite dans la [documentation officielle](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/)

Opérer et maintenir un cluster de production Kubernetes "à la main" est très complexe et une tâche à ne pas prendre à la légère. De nombreux éléments doivent être installés et géré par une équie opérationnelle.

- Mise à jour et passage de version de kubernetes qui doit être fait très régulièrement car une version n'est supportée que 2 ans.
- Choix d'une configuration réseau et de sécurité adaptée.
- Installation probable de système de stockage distribué comme Ceph à maintenir également dans le temps.
- Etc.

### Kubespray : intégration "officielle" de kubeadm et Ansible pour gérer un cluster

https://kubespray.io/#/

En réalité utiliser `kubeadm` directement en ligne de commande n'est pas la meilleure approche car cela ne respecte pas l'infrastructure as code et rend plus périlleux la maintenance/maj du cluster par la suite.

Le projet kubespray est un installer de cluster kubernetes utilisant Ansible et kubeadm. C'est probablement l'une des méthodes les plus populaires pour véritablement gérer un cluster de production on premise.

Mais la encore il s'agit de ne pas sous-estimer la complexité de la maintenance (comme avec kubeadm).

## Installer un cluster complètement à la main pour s'exercer

On peut également installer Kubernetes de façon encore plus manuelle pour mieux comprendre ses rouages et composants.
Ce type d'installation est décrite par exemple ici : [Kubernetes the hard way](https://github.com/kelseyhightower/kubernetes-the-hard-way).

Il existe également une série de tutoriel pour faire cette installation manuelle à l'aide d'Ansible

## Quelques PaaS (Plateforme as a Service) basés sur Kubernetes

- `Rancher`: Un écosystème Kubernetes très complet, assez _opinionated_ et entièrement open-source, non lié à un fournisseur de cloud. Inclut l'installation de stack de monitoring (Prometheus), de logging, de réseau mesh (Istio) via une interface web agréable. Rancher maintient aussi de nombreuses solutions open source, comme par exemple Longhorn pour le stockage distribué.

- `Openshift` : Une version de Kubernetes configurée et optimisée par Red Hat pour être utilisée dans son écosystème. Elle intègre notamment du monitoring et monitoring, Jenkins&Tekton pour le déploiement, un registry d'image etc. Tout est intégré avec l'inconvénient d'être un peu captif·ve de l'écosystème et des services vendus par Red Hat.

<!-- ## Remarque sur les clusters hybrides
Il est possible de connecter plusieurs clusters ensemble dans le cloud chez plusieurs fournisseurs -->

### Bibliographie pour approfondir le choix d'une distribution Kubernetes :

- Chapitre 3 du livre `Cloud Native DevOps with Kubernetes` chez Oreilly




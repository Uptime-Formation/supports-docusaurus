---
title: TP optionnel - Installer un cluster multinoeuds avec Kubeadm et Ansible
sidebar_class_name: hidden
---

Dans ce TP nous allons utiliser des playbooks Ansible pour executer une installation Kubernetes via Kubeadm sur plusieurs machines.

L'installation est multinoeuds mais non haute disponibilité (Un seul master node).

Elle se fera sur un ensemble de VM LXD/incus mis a disposition par le formateur. Cependant la logique est applicable de façon identique sur un ensemble de VPS rassemblés dans un réseau privé chez n'importe que cloud provider.

Kubeadm est l'outil "officiel" en ligne de commande pour initialiser, configurer et gérer des clusters Kubernetes: 

-  **Initialisation du cluster Kubernetes**: Kubeadm permet d'initialiser un cluster Kubernetes en configurant le nœud maître (master node). Il installe les composants principaux du cluster, tels que l'API Server, le Scheduler, le Controller Manager, et initialise le réseau.

- **Gestion des certificats**: Kubeadm gère automatiquement les certificats nécessaires pour sécuriser la communication entre les composants du cluster. Il génère et renouvelle les certificats de manière transparente, simplifiant ainsi la gestion de la sécurité du cluster.

-  **Ajout de nœuds**: Une fois le cluster initialisé, kubeadm peut être utilisé pour ajouter de nouveaux nœuds (nodes) au cluster existant. Il génère les fichiers de configuration nécessaires pour rejoindre le cluster, et fournit des instructions pour configurer les nœuds.

- **Mise à niveau du cluster**: Kubeadm facilite la mise à niveau d'un cluster Kubernetes vers une nouvelle version. Il fournit des commandes pour mettre à jour les composants du cluster de manière sécurisée et transparente.

- **Options avancées de configuration**: Kubeadm prend en charge de nombreuses options avancées pour personnaliser la configuration du cluster Kubernetes, telles que la personnalisation des ports, des adresses IP, des plugins réseau, etc. Ces options sont configurables via des manifestes yaml

### Sources:

- tuto kubeadm debian : https://www.linuxtechi.com/install-kubernetes-cluster-on-debian/
- tuto idem mais control plane HA avec haproxy+keepalive: https://www.linuxtechi.com/setup-highly-available-kubernetes-cluster-kubeadm/
- documentation raisonnée sur kubeadm et l'admin de cluster : https://unofficial-kubernetes.readthedocs.io/en/latest/admin/kubeadm/
- ansible+kubeadm simple : https://www.digitalocean.com/community/tutorials/how-to-create-a-kubernetes-cluster-using-kubeadm-on-ubuntu-20-04
- exemples de parametres kubeadm : https://blog.zwindler.fr/2023/12/17/kubeadmcfg-introduction-api-kubeadm/


### Se connecter à l'infra et pinger les machines avec Ansible

Votre machine client possède une configuration ssh pour se connecter à l'infra nommé `infra_formation`.

- Testez la connexion avec `ssh infra_formation`. Cette connection utilise une clé ssh `id_stagiaire` dont la passphrase est identique au mdp de votre session.

Un utilitaire nommé `sshuttle` est déjà installé sur votre machine. Il s'agit d'un utilitaire de proxy ssh fort pratique. Une fois activé toutes vos connexions réseaux seront redirigées via le réseau privé de l'infra:

- `sshuttle -r infra_formation 0.0.0.0/0`

Faites bien attention à laisser tourner ce programme dans un terminal en permanence (vous pouvez faire CTRL+Z, `bg`, `disown` pour le faire passer définitivement à l'arrière plan)

Testons la connexion à une machine sur le réseau privé:

- `ssh kadmin@192.168.<ip fournie par le formateur> -i ~/.ssh/id_k8s_incus`

### Démarrer le projet de code Ansible à compléter


```sh
cd ~/Desktop
git clone https://github.com/e-lie/tp_kubeadm_ansible.git
```

- Ouvrir le projet avec VSCode disponible dans le menu démarrer

Il s'agit d'un projet de code comprenant:

1. du code terraform pour provisionner des VM via incus/LXD (nous n'y toucherons pas)
2. du code ansible permettant d'executer des commandes/modules d'installation sur les machines facilement

Nous allons compléter au fur et a mesure les fichiers ansible avec des commandes d'installation de kubernetes via `kubeadm`.

- Complétez le fichier `ansible/inventory.yml` par le contenu fourni par le formateur (les bonne vm avec les ip à jour).

Testons si les machines sont joignables:

```sh
sudo apt install -y ansible
cd ansible
ansible all -m ping
```

Installons aussi la collection de module ansible pour k8s : `ansible-galaxy collection install kubernetes.core`



### Configurer les noeuds et la runtime de conteneur

- Ouvrez le fichier `ansible/01-kernel-and-containerd.yml` il est commenté. On va activer tout ça au fur et a mesure

- Exécutez d'abord le fichier avec `ansible-playbook 01-kernel-and-containerd.yml`.

- Décommenter les 2 premières taches et expliquons.

containerd est la runtime de conteneur "bas niveau" la plus classique issue du projet moby/Docker. Nous allons l'installer et la configurer

- Décommenter les 3 taches suivantes et regardons la configuration containerd `tpl-containerd-config.toml` qu'on pourrait tweaker pour des questions de performance ou de sécurité notamment.

Appliquons à nouveau le playbook.

### Installer les dépendances de base d'un cluster et de kubeadm

`kubeadm` gère les composant du cluster automatiquement en tant que conteneurs mais pour piloter les conteneur kubernetes utilise un composant binaire appelé `kubelet`. Il nous faut donc installer ces deux composants.

- Décommentez les taches de la première partie du fichier `ansible/02-kube-dependencies.yml`

- Commentons (dépot de paquet apt officiel de kubernetes)

Nous avons installé ces composant sur tous les noeuds/VMs. Sur les noeuds master du "control_plane" il est generalement intéressant d'installer aussi le client kubectl pour pouvoir piloter le cluster depuis l'intérieur du master.

- Décommentez la tache finale et exécutez le playbook : `ansible-playbook 02-kube-dependencies.yml`

### Initialiser le cluster

TODO: commentons ensemble

#### Quelques options de configuration kubeadm

- définir la version de kubernetes
- nom du cluster
- CIDR pour les adresses des pods et les services (quelles IPs)
- activer ou désactiver des fonctionnalités de kubernetes via les `featureGates` (par exemple activer des fonctionnalités alpha pour tester ou désactiver des fonctionnalités en beta activées par défaut pour la sécurité)
- changer les emplacements d'installation comme le dossier des certificats ou autre
- activer ou désactiver des admission plugins pour valider ou invalider certaines requêtes sur l'API
- gérer les certSANs c'est a dire les sources autorisées pour les requêtes authentifiées par les certificats
- integration OIDC pour l'api
- nom de domaine des services kubernetes (plutôt que kubernetes.default.svc)
- tweaker la base de donnée etcd pour les performances/sécurité

```yaml
apiVersion: kubeadm.k8s.io/v1beta2
kind: ClusterConfiguration
kubernetesVersion: "1.28.3" 
certificatesDir: "/etc/kubernetes/pki" 

networking:
  dnsDomain: kluster.local

featureGates:
  RotateKubeletServerCertificate: true  # Activation de la fonctionnalité expérimentale RotateKubeletServerCertificate
  SupportIPVSProxyMode: true            # Activation de la fonctionnalité expérimentale SupportIPVSProxyMode

apiServer:
  extraArgs:
    enable-admission-plugins: "NamespaceLifecycle,LimitRanger,ServiceAccount,DefaultStorageClass,DefaultTolerationSeconds,MutatingAdmissionWebhook,ValidatingAdmissionWebhook,ResourceQuota,NodeRestriction,PodPreset"
    certSANs:
    - mondomainesource.custom

etcd:
  local:
    extraArgs:
      quota-backend-bytes: "5368709120"
      auto-compaction-retention: "1"
      auto-compaction-mode: periodic
```

### Récupérer la kubeconfig

Tester la connexion `kubectl`. Elle fonctionne déjà, mais il n'y a pas de CNI donc les pods ne peuvent pas communiquer ensemble.

```sh
kubectl get nodes
```

TODO: commentons ensemble

### Installer le CNI Cilium

Cours sur le réseau et spécificités de Cilium

TODO: commentons ensemble

### Testons notre cluster 


```sh
kubectl get nodes
kubectl create deployment nginx-deployment --image=nginx
```

Constatons que le pods ne peut pas se schedule à cause de la taint `NoSchedule` en récupérant les `events` du cluster:

```sh
kubectl get events
kubectl describe node kluster-cp0
```

Supprimer la taint avec la commande suivante (source : https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#control-plane-node-isolation): 

```sh
kubectl taint nodes kluster-cp0 node-role.kubernetes.io/control-plane-
```

`kubectl expose deployment nginx-deployment --type=LoadBalancer --port=80 --target-port=80`

### Ajouter les noeuds worker

TODO: commentons ensemble

## Deuxième partie

### Installer metallb et ingress nginx

Penser à changer l'IP dans metallb.

Analyser à partir de du chart sur artifacthub

### Installer le plugin de stockage Longhorn

Cours stockage

Etudier le chart sur Artifacthub

### Installer l'opérateur de certificat Cert Manager

Voir la page sur Cert Manager pour l'explication. Mais plutôt que d'installer le chart à la main, utilisons un playbook.

### Installer ArgoCD

Voir la page sur ArgoCD pour l'explication. Mais plutôt que d'installer le chart à la main, utilisons un playbook.

### Installer la stack Kube Prometheus


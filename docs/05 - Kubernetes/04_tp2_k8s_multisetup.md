---
title: 04 - TP2 - Plusieurs installations simples de Kubernetes
draft: false
weight: 2025
---

## Une 2e installation: `k3s` sur votre VPS

K3s est une distribution de Kubernetes orientée vers la création de petits clusters de production notamment pour l'informatique embarquée et l'Edge computing. Elle a la caractéristique de rassembler les différents composants d'un cluster kubernetes en un seul "binaire" pouvant s'exécuter en mode `master` (noeud du control plane) ou `agent` (noeud de calcul).

Avec K3s, il est possible d'installer un petit cluster d'un seul noeud en une commande ce que nous allons faire ici:

<!-- - Passez votre terminal en root avec la commande `sudo -i` puis: -->
- Lancez dans un terminal la commande suivante: `curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--disable=traefik" sh - `

 La configuration kubectl pour notre nouveau cluster k3s est dans le fichier `/etc/rancher/k3s/k3s.yaml` et accessible en lecture uniquement par `root`. Pour se connecter au cluster on peut donc faire (parmis d'autre méthodes pour gérer la kubeconfig):

 - Copie de la conf `sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/k3s.yaml`
 - Changer les permission `sudo chown $USER ~/.kube/k3s.yaml`
 - activer cette configuration pour kubectl avec une variable d'environnement: `export KUBECONFIG=~/.kube/k3s.yaml`
 - Tester la configuration avec `kubectl get nodes` qui devrait renvoyer quelque chose proche de:

 ```
NAME                 STATUS   ROLES                  AGE   VERSION
vnc-stagiaire-...   Ready    control-plane,master   10m   v1.21.7+k3s1
```

Pour combiner les différentes configurations on peut utiliser la variable d'environnement `KUBECONFIG` avec comme valeur une liste de fichiers et l'ajouter au fichier `.bashrc` comme suit:

```bash
echo 'export KUBECONFIG=~/.kube/config:~/.kube/k3s.yaml' >> ~/.bashrc
source ~/.bashrc
```

- On peut ensuite visualiser les deux contextes de connexion avec `kubectl config get-contexts` et selectionner l'un d'eux avec `kubectl config use-context default`.

- `kubectl get nodes` ou `kubectl cluster-info` permet de vérifier le résultat.

### Ajouter les connexions à Lens

Lens permet de chercher les kubeconfigs via l'interface et d'enregistrer plusieurs cluster dans la hotbar a gauche.

Le context de kubectl dans le terminal de Lens est automatiquement celui du cluster actuellement sélectionné. On peut s'en rendre compte en lançant `kubectl get nodes` dans deux terminaux dans chacun des deux cluster dans Lens.

### Facultatif : merger la configuration kubectl

- Pour dumper la configuration fusionnée des fichiers et l'exporter on peut utiliser: `kubectl config view --flatten >> ~/.kube/merged.yaml`.


## Facultation 3e installation : Un cluster K8s managé, exemple avec Scaleway

Le formateur peut louer pour vous montrer un cluster kubernetes managé. Vous pouvez également louez le votre si vous préférez en créant un compte chez ce provider de cloud.

- Créez un compte (ou récupérez un accès) sur [Scaleway](https://console.scaleway.com/).
- Créez un cluster Kubernetes avec [l'interface Scaleway](https://console.scaleway.com/kapsule/clusters/create)

La création prend environ 5 minutes.

- Sur la page décrivant votre cluster, un gros bouton en bas de la page vous incite à télécharger ce même fichier `kubeconfig` (*Download Kubeconfig*).

Ce fichier contient la **configuration kubectl** adaptée pour la connexion à notre cluster.

## Facultatif 4e installation : un cluster avec `kubeadm` ou méthode `The Hard Way`

Voir le TP facultatif.


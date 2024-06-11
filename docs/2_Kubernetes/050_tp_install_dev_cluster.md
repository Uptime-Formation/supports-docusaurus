---
title: TP - installer un cluster de dev 
# sidebar_class_name: hidden
---

## Choisir une distribution kubernetes de dev

Voir le cours "différents types de cluster"

- `minikube` est une distribution spécialisée pour le dev => avantage : la distribution la plus connue, bien documentée et utilisée dans tous les tutoriels
- `k3s` est une distribution simple a installer pour le dev ou la prod en particulier pour des contextes edge computing. => avantage : permet de faire de la prod / s'installe sur un serveur.
- `k3d` une distribution de dev basée sur k3s et Docker => avantage : démarre très vite, pleins de fonctionnalités pratiques comme le multinoeud.

Nous allons installer l'une ici.

### Installer `Minikube` (facultatif)

- Pour installer minikube la méthode recommandée est indiquée ici: https://minikube.sigs.k8s.io/docs/start/

Nous utiliserons classiquement `docker` comme runtime pour minikube (les noeuds k8s seront des conteneurs simulant des serveurs). Ceci est, bien sur, une configuration de développement. Elle se comporte cependant de façon très proche d'un véritable cluster.

- Pour lancer le cluster faites simplement: `minikube start` (il est également possible de préciser le nombre de coeurs de calcul, la mémoire et et d'autre paramètre pour adapter le cluster à nos besoins.)

Minikube configure automatiquement kubectl (dans le fichier `~/.kube/config`) pour qu'on puisse se connecter au cluster de développement.

- Testez la connexion avec `kubectl get nodes`.

Affichez à nouveau la version `kubectl version`. Cette fois-ci la version de kubernetes qui tourne sur le cluster actif est également affichée. Idéalement le client et le cluster devrait être dans la même version mineure par exemple `1.20.x`.

## Installer k3s (facultatif)

K3s est une distribution de Kubernetes orientée vers la création de petits clusters de production notamment pour l'informatique embarquée et l'Edge computing. Elle a la caractéristique de rassembler les différents composants d'un cluster kubernetes en un seul "binaire" pouvant s'exécuter en mode `master` (noeud du control plane) ou `agent` (noeud de calcul).

Avec K3s, il est possible d'installer un petit cluster d'un seul noeud en une commande ce que nous allons faire ici:

<!-- - Passez votre terminal en root avec la commande `sudo -i` puis: -->
- Lancez dans un terminal la commande suivante: `curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--disable=traefik" sh - `

 La configuration kubectl pour notre nouveau cluster k3s est dans le fichier `/etc/rancher/k3s/k3s.yaml` et accessible en lecture uniquement par `root`. Pour se connecter au cluster on peut donc faire (parmis d'autre méthodes pour gérer la kubeconfig):

 - Changer les permissions de la conf `sudo chmod 744 /etc/rancher/k3s/k3s.yaml`
 - créer le dossier config kubernetes (si nécessaire) : `mkdir -p ~/.kube`
 - Copie de la conf à la place de la conf existante `cp /etc/rancher/k3s/k3s.yaml ~/.kube/config`
 <!-- - activer cette configuration pour kubectl avec une variable d'environnement: `export KUBECONFIG=~/.kube/k3s.yaml` -->
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


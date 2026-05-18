---
title: "Cours Matin - Installation, Réseau & Stockage"
draft: false
---

## Installation de Kubernetes

### Managed vs self-managed : la question de fond

**La majorité des clusters Kubernetes en production devraient être managés.** Un service managé délègue au provider tout ce qui est pénible : installation du control plane, rotation des certificats, upgrades, HA d'etcd. L'équipe se concentre sur les workloads, pas sur l'infrastructure Kubernetes elle-même.

Le self-managed se justifie dans des cas précis :
- **Souveraineté / on-premise** : données qui ne peuvent pas quitter l'infrastructure interne (défense, santé, secteur bancaire)
- **Contraintes matérielles** : edge computing, sites industriels, infra hétérogène
- **Coût à grande échelle** : au-delà d'un certain nombre de nœuds, le surcoût du control plane managé devient significatif
- **Exigences de personnalisation** : versions spécifiques, CNI non supportés par le provider, intégrations bas niveau

---

### Le spectre des solutions

Il existe plusieurs niveaux d'abstraction, du plus bas au plus opinionated :

**Niveau 1 — Kubernetes The Hard Way / kubeadm**

Installer Kubernetes composant par composant, ou via `kubeadm` qui automatise l'essentiel mais laisse tous les choix à l'opérateur : CNI, stockage, ingress, certificats. Approche pédagogique, mais coût opérationnel élevé en production — expiration de certificats, upgrades manuels, sécurité par défaut insuffisante.

**Niveau 2 — Outils génériques**

Des outils qui automatisent l'installation sur des nœuds existants, de façon reproductible :

| Outil | Approche | Points forts |
|---|---|---|
| **Kubespray** | kubeadm + Ansible | IaC-friendly, très configurable, production-grade |
| **k3s** | Distribution légère (Rancher/SUSE) | Edge, faible empreinte, démarrage en 30s |
| **k0s** | Binaire unique | Simple, sans dépendance OS, CNCF-certified |

**Niveau 3 — OS natifs Kubernetes**

L'OS n'existe que pour faire tourner Kubernetes. Immutable, sans shell interactif, piloté entièrement par API :

| Outil | Approche | Points forts |
|---|---|---|
| **Talos** | OS immutable, API-driven | Reproductibilité maximale, surface d'attaque minimale |
| **Flatcar** | Successeur de CoreOS | Mature, large adoption, compatible cloud |

**Niveau 4 — Solutions progicielles**

Distributions Kubernetes opinionated avec support commercial, écosystème intégré (registry, monitoring, RBAC étendu, réseau) :

| Solution | Éditeur | Positionnement |
|---|---|---|
| **RKE2** | Rancher / SUSE | CNCF-certified, sécurité renforcée (FIPS, SELinux), successeur de RKE |
| **OpenShift** | Red Hat | Plateforme complète, CI/CD intégrée, support entreprise |
| **Tanzu** | VMware / Broadcom | Intégration vSphere, multi-cloud |

Le choix entre ces solutions est autant commercial et organisationnel que technique — OpenShift ou Tanzu impliquent un contrat de support et un écosystème vendor.

**Niveau 5 — Services managés**

| Provider | Service | Points forts |
|---|---|---|
| Google Cloud | **GKE** | Implémentation de référence, Autopilot mode |
| AWS | **EKS** | Intégration IAM, Fargate pour nodes serverless |
| Azure | **AKS** | Intégration Azure AD, DevOps natif |
| OVH, Scaleway | Managed K8s | RGPD, souveraineté des données |

---

### Haute Disponibilité

Pour un cluster de production self-managed, le control plane doit être redondant :

- **Multi-master** : Minimum 3 nœuds control plane (quorum etcd)
- **etcd** : Peut être co-localisé (stacked) ou externe
- **Load Balancer** : En frontal des API servers (HAProxy, cloud LB)
- **Règle** : Nombre impair de nœuds etcd (3, 5, 7) pour le quorum

---

### Approche Full IaC : Terraform + Kubespray/Talos + ArgoCD

Si le self-managed est le bon choix, l'objectif est de rendre le cluster **entièrement reproductible depuis Git** : une modification dans le repo recrée un cluster identique. Cela demande d'assembler trois couches :

```
Couche 1 — Infra          Terraform / Pulumi
           Provisionne les VMs, le réseau, les LBs, les disques

Couche 2 — Kubernetes     Kubespray (Ansible) ou Talos (API)
           Installe et configure Kubernetes sur les nœuds

Couche 3 — Composants     ArgoCD (bootstrappé manuellement une fois)
           Déploie CNI, cert-manager, ingress, monitoring, etc.
```

**Couche 1 — Terraform**

Terraform provisionne l'infrastructure : VMs chez un cloud provider, réseau privé, load balancer en frontal des API servers, règles firewall.

```hcl
# Exemple simplifié : 3 nœuds control plane + 3 workers sur OVH
resource "openstack_compute_instance_v2" "control_plane" {
  count     = 3
  name      = "k8s-cp-${count.index}"
  image_id  = var.ubuntu_image_id
  flavor_id = var.cp_flavor
  key_pair  = var.keypair
}
```

**Couche 2 — Kubespray ou Talos**

*Avec Kubespray* : une fois les VMs prêtes, Ansible se connecte en SSH et installe Kubernetes. L'inventaire peut être généré dynamiquement depuis les outputs Terraform.

```bash
# Générer l'inventaire depuis Terraform
terraform output -json > inventory/hosts.json

# Lancer l'installation
ansible-playbook -i inventory/hosts.json cluster.yml
```

*Avec Talos* : pas de SSH, pas d'OS à gérer. On génère une configuration machine, on la pousse via l'API Talos, le cluster se forme seul.

```bash
# Générer les configs
talosctl gen config mon-cluster https://<LB-IP>:6443

# Appliquer sur chaque nœud (via l'IP de provisioning)
talosctl apply-config --insecure --nodes <IP> --file controlplane.yaml

# Bootstrapper etcd sur le premier control plane
talosctl bootstrap --nodes <CP-IP>
```

**Couche 3 — Bootstrapping ArgoCD**

ArgoCD est installé une seule fois manuellement — c'est le bootstrap initial. Il prend ensuite en charge tous les autres composants cluster via le pattern App of Apps.

```bash
# Installation initiale d'ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Pointer ArgoCD vers le repo GitOps qui contient tout le reste
kubectl apply -f - <<EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: cluster-addons
  namespace: argocd
spec:
  source:
    repoURL: https://github.com/monorg/gitops-repo.git
    targetRevision: main
    path: cluster-addons/     # CNI, cert-manager, ingress, monitoring...
  destination:
    server: https://kubernetes.default.svc
    namespace: argocd
  syncPolicy:
    automated:
      selfHeal: true
EOF
```

À partir de là, tout le reste — Cilium, cert-manager, Traefik, Prometheus — est déclaré dans Git et déployé automatiquement par ArgoCD. Recréer le cluster revient à repasser les trois couches dans l'ordre.

> La gestion des secrets de bootstrapping (token ArgoCD, credentials Terraform) est le point le plus délicat de cette approche — SOPS ou Vault Agent sont les solutions courantes pour éviter de les commiter en clair.

---

## Container Runtime Interface (CRI)

**Un container engine (runtime de conteneur) gère la création, la gestion et l'exécution des conteneurs, en respectant la norme OCI.**

| Outil | Usage | Note |
|---|---|---|
| **containerd** | Runtime principal Kubernetes depuis v1.24 | Conforme CRI et OCI |
| **Docker** | Historique, rétrocompatible | Non conforme CRI sans dockershim (supprimé en 1.24) |
| **cri-o** | Runtime léger orienté Kubernetes | Conforme CRI |
| `ctr` | CLI debug containerd | Ne pas utiliser en production |
| `crictl` | CLI debug CRI-compliant | Outil de débogage |
| `nerdctl` | CLI similaire Docker | Idéal pour les habitués Docker |

---

## Container Network Interface (CNI)

**La spécification CNI standardise la configuration des réseaux de conteneurs.** Elle définit une interface commune entre les runtimes de conteneurs et les plugins réseau.

### Points majeurs

- Les plugins CNI sont des fichiers exécutables chaînés
- Chaque plugin a une responsabilité unique
- Les définitions réseau sont en JSON, transmises via STDIN
- Un espace de noms réseau Linux par conteneur

### Principaux plugins tiers

| Plugin | Technologie | Network Policies | Points forts |
|---|---|---|---|
| **Flannel** | VXLAN, host-gw | ❌ Non natif | Simple, facile à déployer |
| **Calico** | BGP, IPIP | ✅ Avancé | Performant, routage BGP, scalable |
| **Cilium** | eBPF | ✅ Très avancé | Performance maximale, observabilité (Hubble) |
| **Weave** | VXLAN | ⚠️ Basique | Chiffrement natif |

### Choisir son CNI

- **Simplicité** → Flannel
- **Production avec Network Policies** → Calico
- **Performance + observabilité** → Cilium (recommandé pour les nouveaux clusters)
- **Flannel + Network Policies** → combiner avec Calico (Canal)

### Technologies sous-jacentes

| Technologie | Description | Utilisée par |
|---|---|---|
| VXLAN | Réseau overlay sur UDP | Flannel, Weave |
| BGP | Routage IP à grande échelle | Calico |
| eBPF | Traitement réseau dans le kernel | Cilium |
| IPIP | Encapsulation IP dans IP | Calico mode IPIP |

### Outils de diagnostic réseau

```bash
# Debug réseau avec netshoot
kubectl debug mypod -it --image=nicolaka/netshoot

# Avec le plugin kubectl netshoot
kubectl netshoot debug my-existing-pod
kubectl netshoot run tmp-shell --host-network
```

Outils CNI-spécifiques :
- **Hubble** (Cilium) : observabilité des flux réseau
- **Calico Cloud** : interface SAAS pour Calico
- **Kubeskoop** : diagnostic réseau orienté CNI

---

## Persistance : Container Storage Interface (CSI)

**Kubernetes standardise l'intégration des solutions de stockage via CSI (Container Storage Interface).**

### Difficultés de la persistance distribuée

1. **Acquittements d'écriture** : synchrones (sûr) vs asynchrones (performant)
2. **Redondance** : mirroring, Erasure Coding (Ceph)
3. **Gestion de quorum** : cohérence en cas de panne nœud
4. **Scalabilité** : ajouter/retirer des nœuds sans interruption
5. **Monitoring** : détecter proactivement les pannes disque
6. **Snapshots et backups** : récupération rapide

### Comparaison des solutions de stockage réseau

| Critère | NFS | GlusterFS | Ceph | Longhorn |
|---|---|---|---|---|
| Acquittements | Asynchrones | Asynchrones | Configurables | Configurables |
| Redondance | Non | Réplication | Réplication + EC | Réplication |
| Quorum | Non | Oui | Oui | Non |
| Scalabilité | Limitée | Haute | Très haute | Haute |
| Snapshots | Non natif | Oui | Oui | Oui |

### Storage Class, PV et PVC

```yaml
# StorageClass — définit le type de stockage
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: fast-ssd
provisioner: driver.longhorn.io
parameters:
  numberOfReplicas: "3"
reclaimPolicy: Delete
allowVolumeExpansion: true
```

```yaml
# PVC — demande de stockage par l'utilisateur
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mon-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 20Gi
  storageClassName: fast-ssd
```

### Solutions de stockage pour Kubernetes

| Solution | Type | Points forts |
|---|---|---|
| **Longhorn** | Bloc (CNCF) | Natif K8s, UI, snapshots, backups S3 |
| **Rook + Ceph** | Bloc + Objet + Fichier | Très complet, production |
| **OpenEBS** | Bloc | Léger, flexible |
| **MinIO** | Objet (S3-compatible) | Stockage objet on-premise |

### Bases de données dans Kubernetes

| Pattern | Usage recommandé |
|---|---|
| **Managée (RDS, CloudSQL)** | Production cloud — zéro maintenance |
| **Même namespace** | Dev, Redis cache local |
| **Namespace dédié** | Production on-prem, isolation par équipe |
| **Cluster dédié** | Bases critiques, matériel dédié NVMe |
| **VMs externes** | Approche conservatrice, performance maximale |

---

## Certificats TLS dans Kubernetes

### Historique

1. **2014-2016** : Gestion manuelle des certificats TLS
2. **Ingress era** : cert-manager + Let's Encrypt automatisent l'HTTPS
3. **Service Mesh (2016-2018)** : mTLS automatique entre microservices
4. **Gateway API (2020+)** : gestion TLS avancée et multi-certificats

### Principales solutions

**cert-manager** — Le standard de facto :
- Supporte ACME (Let's Encrypt), CA interne, HashiCorp Vault, Venafi
- CRDs natifs Kubernetes : `Certificate`, `Issuer`, `ClusterIssuer`
- Renouvellement automatique avant expiration

**HashiCorp Vault** :
- PKI Secrets Engine : génération, signature, révocation
- Rotation automatique des certificats
- Gestion centralisée des secrets multi-cloud

**API certificates.k8s.io** :
- Native Kubernetes — `CertificateSigningRequest` (CSR)
- CA interne signant les demandes des composants du cluster
- Aucun outil externe requis

### Quickstart cert-manager

```bash
# Installer cert-manager
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/latest/download/cert-manager.yaml

# Créer un ClusterIssuer Let's Encrypt
kubectl apply -f - <<EOF
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: admin@mondomaine.com
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: traefik
EOF
```

---

## Packaging clusters — Full IaC

<!-- A REDIGER -->

> **À ÉCRIRE** : Approche IaC pour le provisioning complet d'un cluster.
> - Terraform / Pulumi pour l'infra (VMs, réseau, LB)
> - Kubespray / Talos / k3sup pour l'installation Kubernetes
> - ArgoCD / Flux pour le bootstrapping des composants cluster (CNI, cert-manager, ingress, monitoring)
> - App of Apps pattern pour déployer tout depuis Git
> - Gestion des secrets de bootstrapping (SOPS, Vault)

---

## Multi-cluster : context switching et outillage

Dès qu'on opère plusieurs clusters (prod, staging, client A, client B…), la gestion des contextes kubectl devient critique. Une commande lancée sur le mauvais cluster peut avoir des conséquences irréversibles.

### Kubeconfig : un fichier, plusieurs contextes

Kubectl lit sa configuration depuis `~/.kube/config` par défaut. Ce fichier peut contenir plusieurs **clusters**, **users** et **contexts** — un contexte est l'association d'un cluster, d'un user et d'un namespace par défaut.

```bash
kubectl config get-contexts          # liste tous les contextes
kubectl config current-context       # contexte actif
kubectl config use-context prod-k8s  # switcher de contexte
kubectl config set-context --current --namespace=mon-ns  # changer le namespace par défaut
```

**Gérer plusieurs fichiers kubeconfig** : plutôt que de tout fusionner dans un seul fichier, on peut pointer vers plusieurs fichiers via la variable `KUBECONFIG` :

```bash
export KUBECONFIG=~/.kube/config-prod:~/.kube/config-staging:~/.kube/config-dev
kubectl config get-contexts   # affiche les contextes de tous les fichiers
```

Pour fusionner proprement plusieurs configs en un seul fichier :

```bash
KUBECONFIG=~/.kube/config-prod:~/.kube/config-staging \
  kubectl config view --flatten > ~/.kube/config-merged
```

---

### kubectx et kubens : switcher en une frappe

`kubectx` et `kubens` (projet [ahmetb/kubectx](https://github.com/ahmetb/kubectx)) remplacent les commandes `kubectl config use-context` et `set-context --namespace` par des raccourcis interactifs.

```bash
# Installation
sudo apt install kubectx   # ou : brew install kubectx

kubectx                    # liste les contextes, sélection interactive avec fzf
kubectx prod-k8s           # switcher vers prod-k8s
kubectx -                  # revenir au contexte précédent (comme cd -)

kubens                     # liste les namespaces du contexte courant
kubens mon-namespace       # switcher de namespace
kubens -                   # revenir au namespace précédent
```

Avec `fzf` installé, `kubectx` et `kubens` lancent un sélecteur interactif — particulièrement utile quand on a une dizaine de contextes.

---

### Afficher le contexte courant dans le prompt

Sur un cluster de prod, voir le contexte actif dans le prompt est une protection contre les erreurs. Deux approches :

**Starship** (recommandé) : prompt cross-shell configurable, affiche nativement le contexte Kubernetes et le namespace.

```bash
# Installer starship
curl -sS https://starship.rs/install.sh | sh

# Activer dans ~/.bashrc ou ~/.zshrc
eval "$(starship init bash)"
```

```toml
# ~/.config/starship.toml
[kubernetes]
disabled = false
format = '[$symbol$context(\($namespace\))]($style) '
style = "bold yellow"

# N'afficher que sur certains contextes (éviter le bruit en dev)
[kubernetes.context_aliases]
"prod-k8s" = "⚠️ PROD"
```

**PS1 natif** (sans dépendance) : ajouter le contexte directement dans le prompt bash.

```bash
# Dans ~/.bashrc
parse_k8s_context() {
  kubectl config current-context 2>/dev/null
}
export PS1='\u@\h [$(parse_k8s_context)] \W \$ '
```

---

### k9s en multi-cluster

**k9s** est une interface TUI pour Kubernetes. Il lit le kubeconfig courant et permet de switcher de contexte sans quitter l'interface.

```bash
k9s                          # ouvre sur le contexte courant
k9s --context prod-k8s       # ouvre directement sur un contexte
k9s --namespace monitoring   # démarre sur un namespace spécifique
```

Dans k9s, `:ctx` affiche la liste des contextes disponibles et permet de switcher à chaud.

---

### Bonnes pratiques de nommage des contextes

Les noms générés automatiquement (`arn:aws:eks:eu-west-1:123456789:cluster/my-cluster`) sont illisibles. Renommer les contextes dès la récupération du kubeconfig :

```bash
kubectl config rename-context \
  arn:aws:eks:eu-west-1:123456789:cluster/my-cluster \
  prod-eu-west
```

Convention recommandée : `<env>-<région>` ou `<client>-<env>` — court, sans ambiguïté, cohérent entre les membres de l'équipe.

| À éviter | Recommandé |
|---|---|
| `kubernetes-admin@kubernetes` | `local-dev` |
| `arn:aws:eks:eu-west-1:...` | `prod-eu-west` |
| `gke_project_europe_cluster1` | `staging-gcp-eu` |

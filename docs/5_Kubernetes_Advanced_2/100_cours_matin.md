---
title: "Cours Matin - Installation, Réseau & Stockage"
draft: false
---

## Installation de Kubernetes

<!-- À REPRENDRE EXISTANT : 5_Kubernetes_Advanced_2/03_Installation-de-Kubernetes.md (squelette) + 5_Kubernetes-Advanced/010-Revision.md -->

### Kubernetes as a Service

Les clouds publics proposent des clusters Kubernetes entièrement managés — le control plane est géré par le provider, vous ne gérez que les nodes :

| Provider | Service | Points forts |
|---|---|---|
| Google Cloud | **GKE** | Implémentation de référence, upgrades automatiques |
| AWS | **EKS** | Intégration IAM, Fargate pour nodes serverless |
| Azure | **AKS** | Intégration Azure AD, DevOps natif |
| OVH, Scaleway | Fournisseurs FR | RGPD, souveraineté |

### Outils d'installation on-premise

| Outil | Usage |
|---|---|
| **kubeadm** | Outil officiel, installe un cluster de production |
| **k3s** | Distribution légère, idéale pour edge et apprentissage |
| **Kubespray** | kubeadm + Ansible — approche IaC recommandée |
| **Talos** | OS immutable dédié Kubernetes, 100% API-driven |
| **Rancher** | Plateforme complète, gestion multi-cluster |

### Haute Disponibilité

Pour un cluster de production, le control plane doit être redondant :

- **Multi-master** : Minimum 3 nœuds control plane (quorum etcd)
- **etcd** : Peut être co-localisé (stacked) ou externe
- **Load Balancer** : En frontal des API servers (HAProxy, cloud LB)
- **Règle** : Nombre impair de nœuds etcd (3, 5, 7) pour le quorum

> Ne pas installer Kubernetes manuellement sans outils — expiration des certificats, mauvais choix CNI, sécurité par défaut insuffisante. Préférer un service managé ou un outil maintenu.

---

## Container Runtime Interface (CRI)

<!-- À REPRENDRE EXISTANT : 5_Kubernetes_Advanced_2/02_Architecture-de-Kubernetes.md ## Container Engine -->

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

<!-- À REPRENDRE EXISTANT : 5_Kubernetes_Advanced_2/02_Architecture-de-Kubernetes.md ## CNI -->

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

<!-- À REPRENDRE EXISTANT : 5_Kubernetes_Advanced_2/02_Architecture-de-Kubernetes.md ## La persistance -->

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

<!-- À REPRENDRE EXISTANT : 5_Kubernetes_Advanced_2/02_Architecture-de-Kubernetes.md ## Certificats -->

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

## Multi-cluster : PS1 et context switching

<!-- A REDIGER -->

> **À ÉCRIRE** :
> - Configurer le prompt shell (PS1/starship) pour afficher cluster et namespace courants
> - kubectx / kubens pour switcher rapidement
> - Gestion de kubeconfigs multiples (`KUBECONFIG` env var, merge)
> - k9s en multi-cluster
> - Bonnes pratiques de nommage des contextes

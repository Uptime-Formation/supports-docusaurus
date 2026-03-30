---
title: "Cours Matin - Des conteneurs à Kubernetes"
draft: true
---

## La problématique d'exécution universelle des applications

**On va voir les problèmes de déploiement qui ont amené aux solutions Docker via l'évolution de la question éternelle.**

```
(Dev) - Comment je déploie mon code sur le serveur de prod ?
(Ops) - Comme tu veux, mais pas le vendredi.
```

Les applications ont des contraintes à gérer :
- versions du code : *J'ai codé une nouvelle fonctionnalité, comment j'intègre ça en prod ?*
- différents environnements (dev, prod) : *J'ai testé sur la dev, on le passe en prod ?*
- fichiers de configuration par environnement : *Qui connaît le mot de passe de la DB de prod ?*
- dépendances internes (librairies, modules) : *Comment j'intègre en prod la librairie qui lit des fichiers Excel ?*
- dépendances externes (bases de données) : *J'ai ajouté un redis pour stocker du cache, comment on déploie ça en prod ?*
- options de lancement du process : *Tu savais pas que l'appli crash sans l'option `-XX:+UseZGC` ?*
- processus de mise à jour : *La nouvelle version de la DB marche pas avec l'ancienne version du code, on fait quoi ?*

---

### Une petite histoire des pratiques DevOps

* **FTP (avant 2000)** — mise à jour fichier par fichier, aucune traçabilité
* **SSH + Git (2009)** — versionnement du code, retour en arrière possible
* **Provisioning & IaC (2010)** — reproductibilité des environnements d'exécution
* **Capistrano (2012)** — automatisation des déploiements avec backups et versions
* **12-factor app / Heroku (2015)** — bonnes pratiques : code, dépendances, configuration
* **Docker (2016)** — uniformisation du code dans tous les environnements, portabilité
* **Kubernetes (2018)** — le déploiement devient un objet en soi, au cœur d'un système complexe

---

### L'Infrastructure As Code

**Progressivement, on essaie de formaliser l'applicatif pour maximiser :**
- la capacité de développer et de tester
- la sécurité de l'application
- la capacité d'évolution et de changement

Aujourd'hui avec Docker et Kubernetes :
- Les différents environnements utilisent les mêmes images
- Chaque image correspond à un état du code dans git
- Les options de configuration par environnement sont dans l'image
- Les dépendances internes sont dans l'image
- La mise à jour est gérée par un orchestrateur
- Les backups sont automatisés par l'orchestrateur

---

## Docker : un gestionnaire de process

**Un conteneur Docker est un process isolé** — il tourne dans son propre espace de noms (namespace Linux), avec ses propres ressources.

Un `process` est un programme en cours d'exécution. Pour chaque process, le système :
- lui attribue un numéro unique (PID)
- lui associe un utilisateur
- lui alloue de la mémoire et du temps de calcul
- maintient des statistiques le concernant

```
USER         PID %CPU %MEM    VSZ   RSS TTY   STAT  COMMAND
root      293758  0.0  0.0  ...                      /usr/bin/containerd-shim-runc-v2 ...
root      293777  0.0  0.1  ...                       \_ /portainer
```

**Chaque image Docker est spécialisée pour lancer un seul process.** Docker surveille l'état des conteneurs, les relance en cas de problème, les arrête.

---

## Les variables d'environnement

**Les variables d'environnement sont le mécanisme standard pour configurer un conteneur** sans modifier son image — c'est la base de la séparation config/code (12-factor app).

```yaml
# Dans un manifeste Kubernetes
env:
  - name: MA_VARIABLE
    value: "ma-valeur"
```

```shell
# En ligne de commande Docker
docker run --env VAR=VALUE ubuntu env
```

Tous les langages savent les lire :
```python
import os
maVar = os.environ.get('MA_VAR')
```

---

## L'évolution de l'écosystème des orchestrateurs

Quand on a beaucoup de conteneurs sur plusieurs machines, il faut les orchestrer :
- Qui tourne sur quel serveur ?
- Comment remplacer un conteneur qui plante ?
- Comment mettre à jour sans interruption ?

**Kubernetes représente plus de 50% des conteneurs déployés en production.** Docker Swarm n'a jamais décollé. Nomad, Mesos, CoreOS ont perdu de la traction. AWS ECS/EKS, GKE, AKS suivent tous les API Kubernetes.

---

## Histoire de Kubernetes

- **2003-2004** : Google crée le système **Borg** — gestion interne de centaines de milliers de jobs sur des dizaines de milliers de machines
- **2013** : Evolution vers **Omega**, planificateur flexible et évolutif
- **2014** : Google open-source Kubernetes, Microsoft, RedHat, IBM et Docker rejoignent immédiatement
- **2015** : Kubernetes v1.0, création de la **CNCF** (Cloud Native Computing Foundation)
- **2016** : Helm, Minikube, première adoption massive (Pokémon Go!)
- **2017** : GitHub migre sur Kubernetes, lancement d'Istio (Google + IBM)
- **Depuis 2018** : leader incontesté, EKS/GKE/AKS en services managés, écosystème CNCF en explosion

---

## Objectifs et architecture de Kubernetes

**Kubernetes est :**
- Une plateforme d'orchestration **résiliente** : elle recrée automatiquement les ressources manquantes
- Une plateforme **sans vendor lock-in** : fonctionne sur cloud privé et cloud public
- Une plateforme de **déploiement** : gère les multi-instances et les rotations de version en zero-downtime
- Une plateforme **mutualisable** : séparation par namespace, RBAC, quotas
- Une plateforme **customisable** : framework extensible via CRD et opérateurs

**Architecture :**

- **Control Plane** : cerveau du cluster
  - `kube-apiserver` : point d'entrée central (REST)
  - `kube-controller-manager` : surveille et corrige l'état des ressources
  - `kube-scheduler` : décide sur quel node placer chaque pod
  - `etcd` : base de données distribuée stockant toute la configuration

- **Nodes** : machines qui font tourner les conteneurs
  - `kubelet` : contrôle la création et l'état des pods sur le node
  - `kube-proxy` : gestion réseau
  - Runtime de conteneur : `containerd` ou `cri-o`

**Tout passe par l'API** — kubectl, les outils CI/CD, les opérateurs... tout est une API.

---

## Les différents types de clusters

### Développement / apprentissage

| Solution | Caractéristiques |
|---|---|
| **k3s** | Léger, rapide, compatible 100% API K8s — **utilisé dans ce cours** |
| minikube | Solution officielle, tourne dans Docker ou une VM |
| kind | Kubernetes dans Docker, pratique pour CI |

### Cloud managé (production)

| Provider | Service |
|---|---|
| Google Cloud | **GKE** — implémentation de référence |
| AWS | **EKS** — intégré à l'écosystème AWS |
| Azure | **AKS** — intégré Azure AD, DevOps |
| OVH, Scaleway | Fournisseurs français |

### On-premise (production)

- **kubeadm** : outil officiel d'installation et de maintenance
- **Kubespray** : kubeadm + Ansible, approche IaC recommandée
- **Rancher** : écosystème complet open-source (monitoring Prometheus, Istio, Longhorn)
- **OpenShift** : distribution Red Hat, intègre build, registry, monitoring

> Opérer un cluster de production Kubernetes "à la main" est complexe : mises à jour régulières (support 2 ans par version), choix réseau, stockage distribué (ex: Ceph). Ne pas sous-estimer.

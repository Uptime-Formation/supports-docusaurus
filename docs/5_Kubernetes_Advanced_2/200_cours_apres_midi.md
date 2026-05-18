---
title: "Cours Après-midi - Service Mesh, Sécurité & Gestion des accès"
draft: false
---

## Service Mesh : architecture et historique

**Un service mesh est une couche d'infrastructure logicielle destinée à contrôler la communication entre les services.**

Il se compose de deux plans :

- Le **Data Plane** : ensemble de proxys réseau (souvent Envoy) déployés aux côtés de chaque service pour intercepter le trafic entrant et sortant
- Le **Control Plane** : cerveau du mesh — configure les proxys, assure la découverte de services, centralise l'observabilité

### Pourquoi un service mesh dans une architecture microservices ?

- Les problématiques de droits d'accès n'ont plus besoin d'être codées dans chaque microservice
- Les flux réseau sont automatiquement chiffrés de bout en bout (mTLS)
- La métrologie des communications inter-services est automatisée

### Historique

- **Pré-2015** : Solutions ad hoc par langage (Hystrix pour circuit breaking, Ribbon pour load balancing en Java)
- **2015** : Linkerd (Buoyant) — premier service mesh populaire, résilience et sécurité sans modification du code
- **2016** : Envoy (Lyft) — proxy haute performance, devient le sidecar standard
- **2017** : Istio (Google + IBM + Lyft) — basé sur Envoy, contrôle complet du réseau microservices
- **2018** : Istio 1.0 — version stable (trafic, sécurité, télémétrie)
- **2020** : Istiod — consolidation de plusieurs composants en un seul binaire

---

## Architecture d'Istio

Documentation officielle : https://istio.io/latest/docs/ops/deployment/architecture/

![](/img/kubernetes/istio-architecture.svg)

Istio injecte automatiquement un proxy sidecar Envoy dans chaque pod. Ce proxy intercepte tout le trafic et applique les politiques définies dans le control plane (Istiod).

---

## Comparatif des solutions de Service Mesh

| Critère | Istio | Linkerd | Consul |
|---|---|---|---|
| **Sécurité** | mTLS, RBAC, JWT | mTLS, politiques simplifiées | mTLS, ACLs |
| **Gestion du trafic** | Routage avancé, A/B, canaries | Routage de base, load balancing | Routage avancé |
| **Déploiement** | Complexe | Simple | Modérément complexe |
| **Performance** | Peut introduire de la latence | Optimisé | Latence minimale |
| **Observabilité** | Tracing + Metrics + Logs | Tracing basique + Metrics | Metrics + Logs |

Résumé :
- **Istio** → environnements complexes, grand nombre de services, fonctionnalités avancées
- **Linkerd** → bon compromis performance/simplicité, environnements moyens à grands
- **Consul** → intégration HashiCorp, multi-plateforme (VMs + K8s)
- **Cilium** → mesh basé sur eBPF, déjà utilisé comme CNI

---

## mTLS et sécurité des échanges

**mTLS (mutual TLS) assure l'authentification mutuelle : chaque service vérifie le certificat de l'autre avant d'établir la connexion.**

Contrairement au TLS classique (client vérifie serveur), mTLS garantit que les deux parties sont légitimes.

### Citadel (Istio)

Citadel est la PKI interne d'Istio : il crée et signe les paires clé/certificat pour chaque compte de service, surveille les durées de vie et effectue la rotation automatique.

### SPIFFE / SPIRE

Istio utilise le standard [SPIFFE](https://spiffe.io/) pour les identités de service. Chaque workload reçoit une identité SVID (SPIFFE Verifiable Identity Document). SPIRE est l'implémentation de référence de SPIFFE.

### Politique d'authentification

```yaml
# Activer mTLS pour un namespace
apiVersion: "authentication.istio.io/v1alpha1"
kind: "Policy"
metadata:
  name: "default"
  namespace: "ns1"
spec:
  peers:
  - mtls: {}
```

### Politique d'autorisation

```yaml
# Autoriser sleep (ns/default) et le namespace dev à accéder à httpbin v1 dans foo
# uniquement en GET avec JWT Google valide
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: httpbin
  namespace: foo
spec:
  selector:
    matchLabels:
      app: httpbin
      version: v1
  rules:
  - from:
    - source:
        principals: ["cluster.local/ns/default/sa/sleep"]
    - source:
        namespaces: ["dev"]
    to:
    - operation:
        methods: ["GET"]
    when:
    - key: request.auth.claims[iss]
      values: ["https://accounts.google.com"]
```

---

## Modèles d'implémentation : Sidecar, Ambient, Cluster Mesh

| Caractéristique | Sidecar | Ambient Mesh | Cluster Mesh |
|---|---|---|---|
| **Maturité** | Mature (depuis 2016) | En développement | Émergent (~2020) |
| **Complexité déploiement** | Élevée (injection dans chaque pod) | Moyenne (proxys au niveau nœud) | Élevée (multi-cluster) |
| **Overhead ressources** | Important | Réduit | Variable |
| **Avantages** | Granularité fine, isolation | Simplicité, moins d'overhead | Haute résilience, multi-cluster |
| **Exemples** | Istio, Linkerd, Consul Connect | Istio Ambient (expérimental) | Cilium Cluster Mesh, Linkerd Multi-cluster |

Le modèle **Ambient Mesh** d'Istio supprime le besoin d'injecter un sidecar dans chaque pod en utilisant des proxys au niveau du nœud — réduisant l'overhead de ressources mais encore en phase de maturation.

---

## Sécurité Kubernetes : approche DevSecOps

**La sécurité Kubernetes n'est pas une couche ajoutée en fin de projet : elle doit être intégrée à chaque phase du cycle de vie DevOps.**

### Domaines de sécurité à couvrir

- **Identités et accès (IAM)** : Qui peut faire quoi sur le cluster (RBAC, OIDC, ServiceAccounts)
- **Sécurité réseau** : Chiffrement en transit (mTLS), Network Policies
- **Sécurité des images** : Scan de vulnérabilités, pas de `latest`, registres privés
- **Gestion des secrets** : Vault, Sealed Secrets, External Secrets Operator
- **Conformité et audit** : kube-bench (CIS Benchmark), audit logs, Falco

### Outils par phase DevOps

| Phase | Outils | Rôle |
|---|---|---|
| **Plan** | OPA, Kyverno | Politiques de conformité déclaratives |
| **Code** | Snyk, Trivy | Scan des dépendances et vulnérabilités |
| **Build** | GitLab CI, Tekton | Pipelines sécurisés, registres privés |
| **Test** | SonarQube, Trivy, Clair | Analyse statique, scan d'images |
| **Release** | Gitleaks, Snyk IaC | Détection de secrets exposés, scan Helm |
| **Deploy** | ArgoCD, Flux | GitOps — pas d'accès prod direct aux devs |
| **Operate** | Vault, Vault Operator | Gestion des secrets et rotation automatique |
| **Monitor** | Falco, Tracee | Détection comportementale en temps réel |

### Admission Controllers : OPA et Kyverno

**OPA (Open Policy Agent)** et **Kyverno** permettent de définir des règles de sécurité appliquées automatiquement à chaque ressource soumise à l'API server :

- Bloquer les images avec `latest`
- Imposer des `resources.requests` sur tous les pods
- Refuser les pods avec `privileged: true`
- Forcer l'ajout de labels obligatoires

Kyverno utilise des policies en YAML natif Kubernetes (plus accessible). OPA utilise le langage Rego (plus expressif).

---

## HashiCorp Vault pour la gestion des secrets

**Vault centralise la gestion des secrets avec audit complet, rotation automatique et politiques d'accès granulaires.**

### Architecture Vault dans Kubernetes

```
Application (Pod)
      │
      │ Token ServiceAccount K8s
      ▼
Vault (Kubernetes Auth Method)
      │
      │ Secret dynamique ou statique
      ▼
Application reçoit la valeur du secret
```

### Vault Operator

![](/img/kubernetes/vault_k8s.png)

Le Vault Kubernetes Operator permet de synchroniser des secrets Vault vers des Kubernetes Secrets natifs :

- Les pods déclarent les secrets dont ils ont besoin via des CRDs
- L'Operator récupère les secrets depuis Vault et les injecte en tant que Kubernetes Secrets
- Rotation automatique quand Vault renouvelle les baux

### Avantages par rapport aux Kubernetes Secrets natifs

| Aspect | Kubernetes Secrets | Vault |
|---|---|---|
| **Chiffrement au repos** | Optionnel (etcd encrypt) | Natif |
| **Audit** | Limité (audit logs API) | Complet (qui a accès à quoi) |
| **Rotation** | Manuelle | Automatique |
| **Secrets dynamiques** | Non | Oui (DB, PKI, cloud creds) |
| **Multi-cluster** | Non | Oui |

---

## RBAC et gestion des accès utilisateurs

### ResourceQuota : limiter les ressources et les objets d'un namespace

ResourceQuota peut restreindre non seulement les ressources CPU/RAM, mais aussi le **nombre d'objets** créables dans un namespace :

```yaml
# Quota sur les objets
apiVersion: v1
kind: ResourceQuota
metadata:
  name: object-quotas
spec:
  hard:
    pods: "8"
    configmaps: "10"
    secrets: "10"
    persistentvolumeclaims: "5"
    services: "5"
    services.loadbalancers: "2"
    requests.storage: "20Gi"
```

Utile pour éviter qu'une équipe monopolise les LoadBalancers cloud (coûteux) ou crée trop de PVCs.

### LimitRange : valeurs par défaut et min/max par conteneur

LimitRange complète ResourceQuota en définissant des contraintes **par conteneur** dans un namespace — y compris des **valeurs par défaut** appliquées automatiquement aux pods qui ne définissent pas de requests/limits :

```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: cpu-limits
spec:
  limits:
  - type: Container
    default:
      cpu: "1000m"
      memory: "256Mi"
    defaultRequest:
      cpu: "500m"
      memory: "128Mi"
    min:
      cpu: "200m"
    max:
      cpu: "800m"
```

```bash
kubectl apply -f cpu-limits.yaml -n dev
```

Tout pod déployé dans ce namespace sans `resources` se voit automatiquement injecter les valeurs `default` et `defaultRequest`. LimitRange s'applique aussi aux PVCs (min/max storage) :

```yaml
limits:
- type: PersistentVolumeClaim
  max:
    storage: 20Gi
  min:
    storage: 1Gi
```

---


## Ingress vs Gateway API

**La Gateway API est la nouvelle génération d'Ingress, standardisée par le SIG Network de Kubernetes.**

### Comparaison

| Aspect | Ingress | Gateway API |
|---|---|---|
| **Maturité** | GA depuis K8s 1.1 | GA depuis K8s 1.24 |
| **Expressivité** | Limitée (HTTP/HTTPS basique) | Avancée (HTTP, gRPC, TCP, UDP) |
| **Séparation des rôles** | Faible | Forte (infra / namespace / dev) |
| **Routage avancé** | Annotations propriétaires | Natif (HTTPRoute, canary, header matching) |
| **Multi-protocoles** | Non | Oui (gRPC, WebSocket, TLS passthrough) |

### Modèle de rôles Gateway API

```
GatewayClass  →  géré par l'équipe infra (choix de l'implémentation)
    │
Gateway       →  géré par l'équipe plateforme (ports, TLS)
    │
HTTPRoute     →  géré par l'équipe applicative (règles de routage)
```

### Exemple HTTPRoute avec canary

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: my-route
spec:
  parentRefs:
  - name: prod-gateway
  rules:
  - matches:
    - headers:
      - name: "X-Canary"
        value: "true"
    backendRefs:
    - name: my-app-v2
      port: 80
      weight: 100
  - backendRefs:
    - name: my-app-v1
      port: 80
      weight: 90
    - name: my-app-v2
      port: 80
      weight: 10
```

La Gateway API est recommandée pour les nouveaux clusters. La migration depuis Ingress est progressive — les deux peuvent coexister.

---

## Greenfield vs Brownfield : deux contextes, une même démarche

Tout ce que vous avez vu aujourd'hui — mTLS, RBAC, Vault, Network Policies, OPA/Kyverno, ResourceQuota — s'applique différemment selon que vous partez de zéro ou que vous intervenez sur un cluster existant.

**En greenfield**, vous posez les fondations dès le départ : les policies Kyverno s'appliquent à tous les nouveaux Deployments, Vault est intégré avant le premier secret applicatif, les Network Policies définissent les règles avant que le trafic existe. Le coût est faible, la couverture est totale.

**En brownfield**, le cluster tourne, les applications sont en production, et chaque changement de sécurité peut casser quelque chose. La stratégie est progressive : commencer par auditer sans bloquer (Falco en mode observe, Trivy en scan continu, Network Policies en log-only), identifier les écarts critiques, corriger par ordre de risque, puis automatiser. Introduire Vault sans downtime signifie faire coexister les Kubernetes Secrets natifs et les secrets Vault le temps de la migration, application par application.

La différence n'est pas dans les outils — c'est les mêmes — mais dans l'ordre et la prudence avec lesquels on les introduit.

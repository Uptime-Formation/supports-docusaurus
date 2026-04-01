---
title: Cours après-midi — Kubernetes Développeur
---

## Le réseau Kubernetes : Services et exposition externe

### Services — l'adressage interne

Les Services sont les objets réseau de base (vus en Bases)  .  

Ils créent un point d'accès stable vers un ensemble de pods, indépendamment de leur durée de vie  .  

Rappel des types :

| Type | Usage |
|---|---|
| `ClusterIP` | Accès interne au cluster uniquement — par défaut |
| `NodePort` | Expose sur un port du nœud — dev/test uniquement |
| `LoadBalancer` | Provisionne un loadbalancer externe (cloud) |

DNS interne : chaque Service est accessible via `<service>.<namespace>.svc.cluster.local`.

**Le type `LoadBalancer` est limité** : il crée un loadbalancer externe par service, ce qui devient coûteux et ingérable à l'échelle — sur un cloud, chaque `LoadBalancer` facture une adresse IP dédiée  .  

On l'utilise encore pour des services non-HTTP (bases de données, MQTT…), mais il ne gère ni le routage par chemin, ni le TLS mutualisé, ni le virtual hosting.

---

### Ingress — le reverse proxy HTTP mutualisé

Un **Ingress** est un objet pour gérer dynamiquement le reverse proxy HTTP/HTTPS dans Kubernetes  .  

Un seul Ingress Controller reçoit tout le trafic entrant et route vers les bons Services selon des règles :

- Virtual hosting (`api.monapp.com` → service A, `app.monapp.com` → service B)
- Routage par chemin (`/api` → service A, `/static` → service B)
- Terminaison TLS mutualisée (un seul certificat, plusieurs apps)

![](/img/kubernetes/ingress.png)

Pour utiliser des Ingresses, il faut d'abord installer un **Ingress Controller** :
- Un déploiement conteneurisé d'un reverse proxy (nginx, Traefik, etc.) intégré avec l'API Kubernetes
- Il doit lui-même être exposé (ports 80 et 443), généralement via un Service LoadBalancer
- k3s est livré avec Traefik configuré par défaut

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-app-ingress
  namespace: mynamespace
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: traefik
  rules:
  - host: mon-app.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: my-app-service
            port:
              number: 80
```

**La limite de l'Ingress** : ses fonctionnalités avancées (canary, auth, rate limiting) passent par des annotations spécifiques à chaque controller  .  

Un manifeste nginx ne fonctionne pas tel quel sur Traefik  .  

Ce couplage est la raison pour laquelle la communauté a conçu la Gateway API.

---

### Ingress avec TLS (cert-manager)

`cert-manager` est un opérateur Kubernetes capable de générer automatiquement des certificats TLS/HTTPS pour vos Ingresses (Let's Encrypt).

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: mon-app
  annotations:
    kubernetes.io/ingress.class: "nginx"
    cert-manager.io/issuer: "letsencrypt-prod"
spec:
  tls:
  - hosts:
    - mon-app.example.com
    secretName: mon-app-tls
  rules:
  - host: mon-app.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: mon-app-service
            port:
              number: 80
```

---

### Gateway API — le successeur standardisé

La **Gateway API** est la nouvelle norme CNCF qui remplace progressivement l'Ingress  .  

Elle sépare les responsabilités en trois objets distincts :

| Objet | Rôle | Qui le gère |
|---|---|---|
| `GatewayClass` | Définit le type de gateway (nginx, Traefik, Cilium…) | Admin cluster |
| `Gateway` | Instance du point d'entrée, ports, TLS | Admin réseau |
| `HTTPRoute` | Règles de routage vers les Services | Développeur |

Cette séparation permet à une équipe dev de modifier ses règles de routage sans toucher à la configuration réseau du cluster, et vice-versa  .  

Les fonctionnalités avancées (canary, header matching, mirroring) sont standardisées — un manifeste `HTTPRoute` fonctionne sur n'importe quel controller compatible.

---

### Au-delà de l'exposition : les API Managers

Exposer un Service vers l'extérieur ne résout pas tout  .  

En production, on a souvent besoin de fonctionnalités que ni l'Ingress ni la Gateway API ne couvrent nativement :

- **Authentification et autorisation** (OAuth2, API keys, JWT)
- **Rate limiting** par client ou par plan tarifaire
- **Observabilité** : métriques par endpoint, par consommateur
- **Versionnement d'API** et gestion du cycle de vie
- **Transformation** de requêtes/réponses

C'est le rôle des **API Managers** (ou API Gateways applicatifs) : Kong, Gravitee, Apigee, AWS API Gateway  .  

Ils s'intercalent entre le point d'entrée réseau et les services, et ajoutent une couche de gouvernance.

```
Internet → Gateway API / Ingress → API Manager → Services Kubernetes
                                        │
                             auth, rate limit, métriques, versioning
```

> Pour ce cours, on travaille avec l'Ingress (supporté nativement par k3s/Traefik)  .  

La Gateway API et les API Managers sont des étapes naturelles dès qu'on expose des APIs à des tiers ou qu'on a plusieurs équipes consommatrices.

---

## CronJob : tâches périodiques

Un **CronJob** crée des Jobs selon un planning cron  .  

Exemple classique : tester périodiquement l'accessibilité d'un service.

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: test-cronjob
  namespace: mynamespace
spec:
  schedule: "*/1 * * * *"    # toutes les minutes
  jobTemplate:
    spec:
      template:
        metadata:
          labels:
            app: tester
        spec:
          containers:
          - name: busybox
            image: busybox
            command: ["wget", "-qO-", "http://web-service"]
          restartPolicy: Never   # Never ou OnFailure pour les Jobs
```

Commandes utiles :
```bash
kubectl get jobs                          # Jobs créés par le CronJob
kubectl logs job/<nom-du-job>             # Logs d'un Job spécifique
kubectl get cronjob                       # État du CronJob
```

L'image `busybox` est une image légère contenant des outils basiques Unix dont `wget` et `sh`.

---

## NetworkPolicy : firewalls dans le cluster

**Par défaut, tous les pods peuvent communiquer entre eux** — il n'y a aucune isolation réseau.

Les **NetworkPolicies** permettent de restreindre les communications entre pods, comme des règles de firewall.

Points clés :
- Un pod non ciblé par une NetworkPolicy accepte tout le trafic
- Dès qu'une NetworkPolicy cible un pod, ce pod rejette tout trafic non explicitement autorisé
- Nécessite un CNI qui supporte les NetworkPolicies (Calico, Cilium, Weave — pas Flannel seul)

#### Exemple : bloquer tout trafic entrant sauf depuis les pods avec `role=allowed`

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all-except-allowed
  namespace: mynamespace
spec:
  podSelector:
    matchLabels:
      app: web
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          role: allowed
```

---

## Packaging et templating : Kustomize et Helm

### Pourquoi on ne peut pas se contenter de YAML brut

Dès qu'on déploie la même application dans plusieurs environnements (dev, staging, prod), les manifestes YAML divergent légèrement : nombre de replicas, image tag, URLs  .  

Copier-coller et modifier à la main est une source d'erreurs.

Deux outils standards :

### Kustomize

Intégré directement dans `kubectl`, Kustomize permet de paramétrer et faire varier la configuration Kubernetes de façon déclarative, sans templating.

La syntaxe de patch utilise des opérations JSON Patch standard :
- `op: replace` — remplace une valeur
- `path` — chemin JSON vers la valeur à modifier (ex: `/spec/replicas`, `/spec/template/spec/containers/0/image`)

Exemple de patch pour modifier le nombre de replicas :
```yaml
patches:
- target:
    kind: Deployment
    name: my-app
  patch: |-
    - op: replace
      path: /spec/replicas
      value: 3
    - op: replace
      path: /spec/template/spec/containers/0/image
      value: nginx:1.25
```

On écrit une version de base des manifestes communes à tous les environnements, puis on applique des **patches** pour les variations.

```
base/
  deployment.yaml
  service.yaml
  kustomization.yaml
overlays/
  dev/
    kustomization.yaml   # patch: 1 replica, image tag dev
  prod/
    kustomization.yaml   # patch: 3 replicas, image tag v1.2
```

Commandes principales :

```bash
# Voir le résultat du patching sans appliquer
kubectl kustomize ./overlays/dev

# Appliquer
kubectl apply -k ./overlays/dev
```

Kustomize est adapté pour une variabilité limitée : entreprise qui déploie en interne dans quelques environnements  .  

Il garde le code de base lisible.

### Helm

Helm est le **package manager** de Kubernetes  .  

Il génère dynamiquement des manifestes à partir de templates avec des variables.

- Un package Helm s'appelle un **Chart**
- Une installation particulière d'un chart s'appelle une **Release**
- Les charts sont distribués sur https://artifacthub.io

Helm permet aussi :
- La gestion des dépendances (installer d'autres charts liés)
- Des hooks avant/après installation
- Des upgrades précautionneux et des rollbacks

```bash
# Ajouter un dépôt de charts
helm repo add bitnami https://charts.bitnami.com/bitnami

# Rechercher un chart
helm search repo bitnami/wordpress

# Installer avec des valeurs personnalisées
helm install mon-wordpress bitnami/wordpress \
  --values=myvalues.yaml \
  --namespace mynamespace

# Voir les releases installées
helm list

# Supprimer une release
helm delete mon-wordpress
```

### Helm vs Kustomize — quand utiliser quoi ?

| | Kustomize | Helm |
|---|---|---|
| **Syntaxe** | YAML natif + patches | Templates Go |
| **Complexité** | Faible | Plus élevée |
| **Usage** | Variations internes limitées | Distribution publique, variations importantes |
| **Dépendances** | Non | Oui |
| **Intégré kubectl** | Oui | Non (CLI séparée) |

---

## GitOps avec ArgoCD

**ArgoCD** est un opérateur Kubernetes qui implémente la méthode GitOps : il surveille un dépôt Git et réconcilie automatiquement l'état du cluster avec ce qui est déclaré dans Git.

ArgoCD ajoute des types d'objets (CRDs) dont le type `Application` :

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: mon-app
  namespace: argocd
spec:
  destination:
    namespace: mon-app
    server: https://kubernetes.default.svc
  project: default
  source:
    repoURL: https://github.com/monorg/mon-repo.git
    targetRevision: main
    path: k8s/
```

Dans une gestion GitOps :
- Les manifestes YAML (ou le chart Helm) sont dans Git
- ArgoCD surveille le dépôt
- Un commit sur la branche cible déclenche automatiquement le déploiement

---

## Autoscaling : HorizontalPodAutoscaler (HPA)

Le **HPA** permet d'ajuster automatiquement le nombre de replicas d'un Deployment en fonction de métriques (CPU, RAM, métriques custom).

Il s'appuie sur le **Metrics Server** qui collecte en temps réel l'utilisation CPU/RAM des pods.

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: mon-app-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: mon-app
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

Si l'utilisation CPU moyenne dépasse 70%, le HPA augmente le nombre de replicas jusqu'à 10.

**Prérequis** : les pods doivent avoir des `requests` CPU définies pour que le HPA puisse calculer le ratio.

---

## Topologie des workloads : Où sont déployés les pods ?

**Kubernetes décide seul sur quel nœud placer chaque pod** — c'est le rôle du scheduler  .  

Par défaut, il cherche un nœud avec suffisamment de ressources disponibles et le place de façon opportuniste  .  

En pratique, cela peut mener à des déséquilibres : tous les pods d'un même Deployment sur le même nœud, ou sur la même zone de disponibilité.

---

### 1. Contraintes de ressources — le filtre de base

**Le scheduler élimine d'abord les nœuds qui ne peuvent pas accueillir le pod  .**  

La règle est simple : un pod n'est schedulé sur un nœud que si ce nœud a suffisamment de ressources **réservées disponibles** (requests non encore allouées) pour couvrir les requests du pod.

Sans `requests` définies, le pod peut atterrir n'importe où — y compris sur un nœud déjà saturé  .  

Définir des requests est donc aussi un outil de placement.

---

### 2. Node Pools et Taints / Tolerations

**En production, les clusters sont souvent segmentés en **node pools** — des groupes de nœuds homogènes avec des caractéristiques différentes : nœuds GPU, nœuds mémoire-optimisés, nœuds réservés à certaines équipes.**

Les **Taints** permettent de marquer un nœud pour repousser tous les pods par défaut  .  

Seuls les pods qui déclarent la **Toleration** correspondante peuvent y être schedulés.

```bash
# Réserver un nœud pour les workloads GPU
kubectl taint nodes gpu-node-1 workload=gpu:NoSchedule
```

```yaml
# Pod qui peut être placé sur ce nœud
spec:
  tolerations:
  - key: "workload"
    operator: "Equal"
    value: "gpu"
    effect: "NoSchedule"
```

Pour aller plus loin dans le ciblage, la **Node Affinity** permet d'exprimer des préférences ou contraintes basées sur les labels des nœuds (`required` ou `preferred`).

---

### 3. Topology Spread Constraints — distribuer les pods intelligemment

**Le problème de la haute disponibilité : si tous les réplicas d'un Deployment se retrouvent sur le même nœud ou dans la même zone, une panne emporte tout  .**  

Les **Topology Spread Constraints** permettent de contraindre la distribution des pods sur des domaines topologiques (nœuds, zones, régions).

Les champs clés :

| Champ | Rôle |
|---|---|
| `topologyKey` | La clé de label de nœud qui définit le domaine (`kubernetes.io/hostname`, `topology.kubernetes.io/zone`…) |
| `maxSkew` | Déséquilibre maximal autorisé entre domaines (ex: `1` = au plus 1 pod d'écart) |
| `whenUnsatisfiable` | `DoNotSchedule` (bloque) ou `ScheduleAnyway` (place quand même en minimisant le déséquilibre) |
| `labelSelector` | Sélectionne les pods à compter pour le calcul du déséquilibre |

```yaml
# Distribuer les réplicas sur les nœuds et les zones
spec:
  topologySpreadConstraints:
  - maxSkew: 1
    topologyKey: topology.kubernetes.io/zone
    whenUnsatisfiable: DoNotSchedule
    labelSelector:
      matchLabels:
        app: mon-app
  - maxSkew: 1
    topologyKey: kubernetes.io/hostname
    whenUnsatisfiable: ScheduleAnyway
    labelSelector:
      matchLabels:
        app: mon-app
```

Avec cette configuration, sur un cluster à 3 zones et 6 réplicas : Kubernetes garantit au plus 1 pod d'écart entre les zones (2-2-2), et tente de ne pas mettre plusieurs réplicas sur le même nœud.

> Depuis Kubernetes v1.30, des contraintes par défaut au niveau cluster peuvent être configurées par l'admin — les workloads en héritent automatiquement sans avoir à les déclarer dans chaque Deployment.

---

### Récapitulatif — les outils de placement

| Besoin | Outil |
|---|---|
| Le pod a besoin de X CPU / Y RAM | `requests` |
| Réserver des nœuds à certains workloads | Taints + Tolerations |
| Cibler des nœuds selon leurs caractéristiques | Node Affinity |
| Éviter de concentrer les réplicas sur un nœud ou une zone | Topology Spread Constraints |
| Éviter que deux pods du même service cohabitent | Pod Anti-Affinity |

---

### Commandes kubectl pour le réseau et le packaging

```bash
# Inspecter les objets réseau
kubectl get ingress                       # liste les Ingresses
kubectl get ingress -o yaml              # détails complets
kubectl get nodes -o wide                # IPs des nœuds (utile pour tester)

# Vérifier les NetworkPolicies
kubectl describe networkpolicy <nom>

# Namespaces
kubectl create namespace <nom>
kubectl apply -k ./overlays/dev -n mon-namespace

# Tester l'accès réseau depuis l'extérieur
# Ajouter une entrée dans /etc/hosts : <IP-cluster>  mon-app.example.com
# Puis : curl http://mon-app.example.com
```

### Debugging : logs, events, troubleshooting

Commandes essentielles pour débugger :

```bash
# Logs d'un pod (tous les conteneurs)
kubectl logs <pod> --all-containers

# Logs en temps réel
kubectl logs <pod> -f

# Events du namespace (très utiles pour diagnostiquer les échecs)
kubectl get events --sort-by='.lastTimestamp'

# Description détaillée (events inclus)
kubectl describe pod <pod>

# Exécuter une commande dans un pod
kubectl exec -it <pod> -- /bin/sh

# Port-forward pour accéder localement à un service
kubectl port-forward svc/<service> 8080:80
```

Problèmes courants :

| Symptôme | Cause probable |
|---|---|
| Pod en `Pending` | Pas de nœud avec suffisamment de ressources, ou PVC non bound |
| Pod en `CrashLoopBackOff` | L'application plante au démarrage — vérifier les logs |
| Pod en `ImagePullBackOff` | Image introuvable ou credentials registry manquants |
| Service sans endpoints | Selector du Service ne correspond pas aux labels des pods |

---

### Multi-cluster : paramétrer par environnement

Avec Kustomize ou Helm, on peut maintenir des paramètres différents par environnement sans dupliquer le code :
- image tag : `dev` vs `v1.2.3`
- replicas : 1 en dev, 3 en prod
- ressources : requests/limits plus basses en dev
- URLs et configuration : différentes par environnement

L'approche GitOps étend cela : chaque branche ou dossier correspond à un environnement, ArgoCD déploie automatiquement.

---

### Sécurité : scanning d'images

Avant de déployer une image, il faut s'assurer qu'elle ne contient pas de vulnérabilités connues (CVEs).

**Trivy** est un outil open-source de scanning d'images :

```bash
trivy image nginx:latest
```

Les bonnes pratiques :
- Toujours utiliser des tags explicites (`nginx:1.25.3`), jamais `latest`
- Reconstruire régulièrement vos images pour patcher les CVEs sur l'image de base
- Intégrer le scanning dans la CI/CD — bloquer si trop de failles critiques
- 6 mois est déjà vieux pour une image de conteneur

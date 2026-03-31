---
title: Cours après-midi — Kubernetes Développeur
---

## Le réseau Kubernetes : Services et Ingress

### Services

Les Services sont les objets réseau de base (vus en Bases). Rappel des types :

| Type | Usage |
|---|---|
| `ClusterIP` | Accès interne au cluster uniquement — par défaut |
| `NodePort` | Expose sur un port du nœud — dev/test |
| `LoadBalancer` | Provisionne un loadbalancer externe (cloud) |

DNS interne : chaque Service est accessible via `<service>.<namespace>.svc.cluster.local`.

### Ingress

Un **Ingress** est un objet pour gérer dynamiquement le reverse proxy HTTP/HTTPS dans Kubernetes. Il permet :
- Le virtual hosting (plusieurs domaines, un seul point d'entrée)
- Le routage par chemin (`/api` → service A, `/app` → service B)
- La terminaison TLS/SSL

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

### Ingress avec TLS (certmanager)

`certmanager` est un opérateur Kubernetes capable de générer automatiquement des certificats TLS/HTTPS pour vos Ingresses (Let's Encrypt).

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

## CronJob : tâches périodiques

Un **CronJob** crée des Jobs selon un planning cron. Exemple classique : tester périodiquement l'accessibilité d'un service.

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

Dès qu'on déploie la même application dans plusieurs environnements (dev, staging, prod), les manifestes YAML divergent légèrement : nombre de replicas, image tag, URLs. Copier-coller et modifier à la main est une source d'erreurs.

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

Kustomize est adapté pour une variabilité limitée : entreprise qui déploie en interne dans quelques environnements. Il garde le code de base lisible.

### Helm

Helm est le **package manager** de Kubernetes. Il génère dynamiquement des manifestes à partir de templates avec des variables.

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

## Transversaux

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

### Multi-cluster : paramétrer par environnement

Avec Kustomize ou Helm, on peut maintenir des paramètres différents par environnement sans dupliquer le code :
- image tag : `dev` vs `v1.2.3`
- replicas : 1 en dev, 3 en prod
- ressources : requests/limits plus basses en dev
- URLs et configuration : différentes par environnement

L'approche GitOps étend cela : chaque branche ou dossier correspond à un environnement, ArgoCD déploie automatiquement.

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

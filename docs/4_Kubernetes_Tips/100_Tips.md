---
title: Kubernetes - Bonnes pratiques
draft: false
---

Cette page regroupe les principales bonnes pratiques à connaître pour opérer des clusters Kubernetes en production. Elles sont issues de l'expérience terrain et couvrent aussi bien la sécurité, la fiabilité que l'organisation des équipes.

---

## Images de containers

### Choisir une image de base fiable et minimale

**Le point de départ de toute image, c'est l'instruction `FROM`. Quelques règles :**

- Partir d'une image publiée par un éditeur reconnu (Docker Official Images, images distroless Google, etc.)
- Préférer les images légères : `alpine`, `distroless`, `slim` — moins de surface d'attaque, moins de CVE potentiels
- Vérifier que l'image de base est régulièrement mise à jour par son mainteneur

**L'objectif : avoir une image avec des CVE corrigées rapidement et des capacités opérationnelles optimales.**

### Utiliser des builds multi-étapes

Les multi-stage builds permettent de séparer l'environnement de compilation de l'image finale. Résultat : une image de production qui ne contient que le binaire ou les fichiers nécessaires, sans les outils de build.

```dockerfile
FROM node:20 AS builder
WORKDIR /app
COPY . .
RUN npm ci && npm run build

FROM node:20-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist
CMD ["node", "dist/index.js"]
```

### Ne pas utiliser `ADD` pour copier des fichiers locaux

`ADD` a des comportements implicites (décompression d'archives, téléchargement d'URLs). Pour copier des fichiers locaux, utiliser `COPY` — c'est explicite et prévisible.

### Ne pas lancer les processus en root

Par défaut, les containers s'exécutent en tant que root à l'intérieur du container. C'est un risque si le container est compromis. Ajouter un utilisateur dédié dans le Dockerfile :

```dockerfile
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser
```

### Toujours tagger les images explicitement

Ne jamais utiliser `latest` en production. Les raisons :

- Deux replicas peuvent se retrouver sur des versions différentes de l'image si un pull se produit entre deux déploiements
- En cas de breaking change sur `latest`, les erreurs sont silencieuses et difficiles à tracer
- Impossible de savoir quelle version tourne réellement

Utiliser un tag de version sémantique (`1.4.2`) ou un hash de commit (`sha-abc1234`).

```yaml
# Mauvais
image: myapp:latest

# Bon
image: myapp:1.4.2
# ou
image: myapp:sha-abc1234
```

---

## Fiabilité des workloads

### Définir une readinessProbe

Par défaut, Kubernetes commence à envoyer du trafic à un pod dès que ses containers ont démarré — mais l'application n'est peut-être pas encore initialisée. La `readinessProbe` permet d'indiquer au cluster quand le pod est réellement prêt à recevoir des requêtes.

```yaml
readinessProbe:
  httpGet:
    path: /ready
    port: 8080
  initialDelaySeconds: 5
  periodSeconds: 10
```

Trois types disponibles : HTTP (codes 2xx/3xx), commande shell, TCP.

### Définir une livenessProbe

La `livenessProbe` permet de détecter qu'une application est bloquée (deadlock, état incohérent) et de la redémarrer automatiquement.

```yaml
livenessProbe:
  httpGet:
    path: /healthz
    port: 8080
  initialDelaySeconds: 20
  periodSeconds: 15
```

**Important** : utiliser `initialDelaySeconds` pour laisser le temps à l'application de démarrer. Sans ce paramètre, Kubernetes peut redémarrer le pod en boucle avant qu'il ait eu le temps de s'initialiser — c'est le "Liveness Probe Loop of Hell".

### Liveness ≠ Readiness

Ces deux probes ont des rôles différents et ne doivent pas pointer vers le même endpoint :

| Probe | Rôle | Conséquence si KO |
|---|---|---|
| `readinessProbe` | L'app est prête à recevoir du trafic | Le pod est retiré du Service (plus de trafic) |
| `livenessProbe` | L'app est vivante | Le container est redémarré |

Une `readinessProbe` qui échoue temporairement (ex: warm-up) ne doit pas déclencher un redémarrage.

---

## Organisation et isolation

### Ne pas utiliser le namespace `default`

Le namespace `default` est un piège pour les équipes qui travaillent sur un cluster partagé : risque de collision de noms, d'écrasement accidentel de ressources, de confusion entre projets.

Bonnes pratiques :
- Créer un namespace par équipe, par environnement ou par application
- Appliquer des quotas et des règles RBAC à chaque namespace
- Les services sont accessibles entre namespaces via DNS : `<service>.<namespace>.svc.cluster.local`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
  namespace: staging
```

### Utiliser ResourceQuota et LimitRange

Sur un cluster partagé, il faut empêcher une équipe ou une application de consommer toutes les ressources.

**ResourceQuota** : limite les ressources totales consommables dans un namespace.

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: equipe-quota
  namespace: staging
spec:
  hard:
    requests.cpu: "2"
    requests.memory: 4Gi
    limits.cpu: "4"
    limits.memory: 8Gi
```

**LimitRange** : définit des valeurs par défaut et des bornes min/max par container dans un namespace. Utile pour éviter les containers sans requests (qui perturbent le scheduling) ou les containers trop gourmands.

### Définir des requests CPU et RAM pour chaque workload

Les `requests` indiquent au scheduler Kubernetes combien de ressources réserver sur un node. Sans requests :
- Le pod peut se retrouver sur un node déjà saturé
- Il sera le premier évincé en cas de pression sur le cluster

```yaml
resources:
  requests:
    memory: "128Mi"
    cpu: "250m"
  limits:
    memory: "256Mi"
    cpu: "500m"
```

### Ne pas sur-dimensionner les requests

Un piège fréquent : des requests beaucoup trop élevées par rapport à la consommation réelle.

Exemple : utilisation CPU réelle à 14%, mais reservation CPU à 81%. Résultat : impossible de scheduler un nouveau pod, même si les nodes ont largement de quoi l'accueillir. Sur le cloud, cela déclenche l'autoscaler qui ajoute un node inutilement.

Surveiller régulièrement le ratio `requests / utilisation réelle` avec des outils de monitoring (Prometheus/Grafana, metrics-server).

---

## Réseau et exposition

### Préférer un Ingress à un Service de type LoadBalancer

Un `Service` de type `LoadBalancer` provisionne un load balancer externe pour chaque service. C'est coûteux (une IP publique par service) et limité (pas de routing basé sur l'URL ou le hostname).

Un `Ingress` est un reverse proxy géré par Kubernetes qui permet :
- Le routing basé sur le hostname et le chemin (`/api`, `/app`)
- La terminaison TLS centralisée
- L'exposition de plusieurs services derrière une seule IP

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: mon-ingress
spec:
  rules:
  - host: mon-app.exemple.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: mon-service
            port:
              number: 80
```

### Gateway API : quand Ingress ne suffit plus

La **Gateway API** est le successeur moderne de l'Ingress. Elle offre plus de flexibilité (routing TCP/UDP, traffic splitting, multi-tenancy) mais est plus complexe à configurer. À considérer si les fonctionnalités avancées sont nécessaires — sinon, Ingress reste le bon choix.

### Appliquer des NetworkPolicy sur chaque namespace

Par défaut, tous les pods d'un cluster peuvent communiquer entre eux sans restriction. Sur un cluster de production, c'est inacceptable.

La bonne pratique : commencer par une règle qui bloque tout trafic entrant, puis ouvrir sélectivement ce qui est nécessaire.

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all-ingress
  namespace: production
spec:
  podSelector: {}
  policyTypes:
  - Ingress
```

Attention : les NetworkPolicy nécessitent un CNI compatible (Calico, Cilium, Weave — pas Flannel seul).

### Éviter le Host Access

Plusieurs options de pod permettent au container de sortir de son isolation réseau et système. À éviter sauf cas très spécifiques (agents de monitoring système, CNI plugins) :

| Option | Risque |
|---|---|
| `hostNetwork: true` | Le pod partage le namespace réseau du node |
| `hostPort` | Expose un port directement sur le node, contourne les NetworkPolicy |
| `hostPID: true` | Accès aux processus du node |
| `hostIPC: true` | Accès à la mémoire partagée du node |

---

## Sécurité

### Scanner les images avant déploiement

Intégrer un scanner de vulnérabilités dans la chaîne CI/CD permet de détecter les CVE dans les images avant qu'elles n'atteignent la production. C'est un élément central du **DevSecOps**.

Outil recommandé : **Trivy** (open source, facile à intégrer en CI).

```bash
trivy image mon-app:1.4.2
```

À automatiser sur chaque build et sur chaque push vers le registry.

### Surveiller l'âge des images en production

Une image construite il y a 6 mois ou plus contient probablement des CVE non patchés, que ce soit dans l'image de base ou dans les dépendances applicatives. Mettre en place une routine de reconstruction régulière des images via la CI/CD, indépendamment des changements applicatifs.

### Ne plus utiliser les APIs dépréciées

Kubernetes fait évoluer ses APIs selon un cycle Alpha → Beta → Stable. Les APIs alpha et beta peuvent être modifiées ou supprimées d'une version à l'autre.

Exemple concret : lors de la mise à jour vers Kubernetes 1.22, toutes les ressources `Ingress` utilisant `extensions/v1beta1` ou `networking.k8s.io/v1beta1` ont été supprimées. Les clusters qui utilisaient ces APIs ont eu des interruptions de service.

```yaml
# Supprimé en 1.22 — ne plus utiliser
apiVersion: extensions/v1beta1
kind: Ingress

# À utiliser
apiVersion: networking.k8s.io/v1
kind: Ingress
```

Vérifier régulièrement les APIs utilisées avec `kubectl api-versions` et les notes de release Kubernetes.

---

## Infrastructure

### Stocker tous les manifestes YAML dans Git

Les manifestes Kubernetes sont de l'Infrastructure as Code. Les gérer comme du code :

- Versionner dans Git (GitLab, GitHub, etc.)
- Revenir à une version précédente en cas de problème
- Tracer qui a modifié quoi et pourquoi
- Appliquer une revue (merge request) avant tout changement en production

Approche recommandée : **Commit-Then-Apply** — appliquer uniquement ce qui est dans Git, tagger les versions vérifiées.

### Ne pas installer Kubernetes manuellement

Installer Kubernetes from scratch est complexe, long, et semé de pièges :

- Expiration des certificats (souvent ignorée jusqu'à l'incident)
- Mauvais choix de CNI avec des incompatibilités découvertes tard
- Cluster non sécurisé par défaut (etcd exposé, anonymous auth activé, etc.)
- Fonctionnalités manquantes non détectées avant la mise en production

Préférer un service managé (EKS, GKE, AKS, OVH Managed Kubernetes, etc.) ou un outil d'installation maintenu (kubeadm, k3s, Talos).

---

## Auditer son cluster

### kube-bench — CIS Kubernetes Benchmark

**kube-bench** est un outil open source qui vérifie la conformité d'un cluster aux recommandations du **CIS Kubernetes Benchmark** (Center for Internet Security). Il inspecte la configuration des composants (API server, etcd, kubelet, scheduler) et signale les écarts par rapport aux bonnes pratiques de sécurité.

```bash
kubectl apply -f https://raw.githubusercontent.com/aquasecurity/kube-bench/main/job.yaml
kubectl logs job/kube-bench
```

Des outils commerciaux proposent des fonctionnalités similaires avec des dashboards et des alertes continues.

---

## Qualité de service (QoS)

Kubernetes attribue automatiquement une classe de QoS à chaque pod en fonction de la façon dont les ressources sont définies. Cette classe détermine la priorité d'éviction en cas de pression sur un node.

| Classe | Condition | Comportement |
|---|---|---|
| **Guaranteed** | `requests` == `limits` pour CPU et RAM sur tous les containers | Priorité maximale — évincé en dernier |
| **Burstable** | Au moins un container a une `request` ou une `limit` définie (mais pas les deux égales) | Priorité intermédiaire |
| **BestEffort** | Aucune `request` ni `limit` définie | Priorité minimale — évincé en premier |

La classe QoS n'est pas à configurer directement : elle est calculée à partir des `resources` que vous définissez. Bonne pratique : viser **Guaranteed** pour les workloads critiques, accepter **Burstable** pour le reste.

---

## kubectl debug

`kubectl debug` permet d'inspecter un pod ou un node en production sans avoir besoin de modifier l'image ou la commande de départ.

### Debug d'un pod

Attache un container éphémère au pod existant, avec l'image de votre choix :

```bash
kubectl debug mypod -it --image=busybox
```

Points d'attention :
- Le container éphémère partage les contraintes de ressources du pod
- Il reste présent dans le pod après la session — il faut redéployer pour le faire disparaître
- Bonne pratique : maintenir une image "toolbox" légère avec les outils de diagnostic nécessaires (curl, dig, netstat, strace...)

### Debug d'un node

Démarre un pod spécial sur le node ciblé, avec le filesystem du node monté sous `/host` :

```bash
kubectl debug node/mynode -it --image=ubuntu
```

Points d'attention :
- Donne par défaut un accès minimal — utiliser `--profile=sysadmin` pour les droits système complets
- Utile pour diagnostiquer des problèmes réseau, de stockage ou de kubelet directement sur le node
- Bonne pratique : même logique que pour les pods, une image dédiée aux opérations système

---

## Gateway API

La **Gateway API** est le successeur de l'Ingress dans Kubernetes. Elle répond aux limites historiques de l'Ingress :

- Les Ingress restaient très dépendants de l'implémentation (annotations spécifiques à nginx, traefik, etc.)
- Le routage HTTP était limité aux paths
- Pas de support natif pour d'autres protocoles (gRPC, UDP, TCP)

La Gateway API apporte :
- Un modèle **standardisé** avec 3 niveaux de support : Core (obligatoire), Extended (recommandé), Implementation-Specific
- Un routage HTTP plus fin : headers, query params, routing inter-namespaces
- Le support de **gRPC, UDP, TCP** en plus de HTTP
- Des déploiements **canary et blue-green natifs** sans annotations propriétaires
- Une séparation claire des responsabilités via 3 types de ressources : `GatewayClass`, `Gateway`, `HTTPRoute`

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: mon-app-route
spec:
  parentRefs:
  - name: ma-gateway
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /api
    backendRefs:
    - name: mon-service
      port: 8080
```

**Quand utiliser Gateway API ?** Quand les fonctionnalités avancées (routing multi-protocole, déploiements progressifs, multi-tenancy réseau) sont nécessaires. Pour un Ingress simple HTTP/HTTPS, l'Ingress classique reste suffisant et plus simple à opérer.

---

## Volume Snapshots

Les **Volume Snapshots** permettent de capturer l'état d'un PVC à un instant T — l'équivalent d'un snapshot disque pour les volumes Kubernetes.

Trois ressources en jeu :
- `VolumeSnapshotClass` : définit le driver CSI et la politique de suppression
- `VolumeSnapshot` : demande de snapshot sur un PVC existant
- `VolumeSnapshotContent` : le contenu créé en réponse (géré automatiquement)

```yaml
apiVersion: snapshot.storage.k8s.io/v1
kind: VolumeSnapshotClass
metadata:
  name: longhorn-snapshot-vsc
driver: driver.longhorn.io
deletionPolicy: Delete
parameters:
  type: snap

---

apiVersion: snapshot.storage.k8s.io/v1
kind: VolumeSnapshot
metadata:
  name: mon-snapshot
spec:
  volumeSnapshotClassName: longhorn-snapshot-vsc
  source:
    persistentVolumeClaimName: mon-pvc

---

# Restaurer depuis un snapshot
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mon-pvc-restaure
spec:
  storageClassName: longhorn
  dataSource:
    name: mon-snapshot
    kind: VolumeSnapshot
    apiGroup: snapshot.storage.k8s.io
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
```

La cohérence du snapshot dépend du driver CSI — certains drivers garantissent une cohérence applicative (snapshot atomique), d'autres font un snapshot filesystem best-effort.

---

## Image Volumes

Kubernetes permet de monter une image OCI directement comme volume dans un pod, sans passer par un PVC ou un ConfigMap.

Cas d'usage : distribuer des assets statiques, des configurations, ou du contenu web packagé sous forme d'image container.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: image-volume-example
spec:
  containers:
  - name: web
    image: nginx:1.28.0
    volumeMounts:
    - name: website
      mountPath: /usr/share/nginx/html
  volumes:
  - name: website
    image:
      reference: myrepo.io/group/website:2.2.2
      pullPolicy: IfNotPresent
```

Le contenu de l'image est monté en lecture seule. Les mises à jour du contenu se font en changeant le tag de l'image — comme pour n'importe quelle image applicative.

---

## Ressources au niveau du pod

Depuis Kubernetes 1.32, il est possible de définir des `resources` au niveau du pod en plus des containers individuels. Cela permet de réserver une marge pour les processus système du pod (pause container, init containers terminés, sidecars) et de laisser de la place pour des opérations de debug.

```yaml
spec:
  resources:
    requests:
      memory: "64Mi"
      cpu: "100m"
  containers:
  - name: app
    resources:
      requests:
        memory: "128Mi"
        cpu: "250m"
```

Les ressources du pod s'ajoutent à celles des containers pour le calcul total utilisé par le scheduler.

---
title: "Cours Après-midi - Autoscaling, Scheduling & Operators"
draft: false
---

## Scale Up vs Scale Out

<!-- À REPRENDRE EXISTANT : 5_Kubernetes-Advanced/420-Vertical.md ## Définition -->

| Approche | Description | Usage Kubernetes |
|---|---|---|
| **Scale Up** | Augmenter les ressources d'un nœud existant (CPU, RAM) | VPA — ajuste les resources par pod |
| **Scale Out** | Ajouter des nœuds ou pods supplémentaires | HPA — ajoute des replicas ; Cluster Autoscaler — ajoute des nœuds |

Kubernetes utilise principalement le scale out pour gérer les charges de travail.

---

## Horizontal Pod Autoscaler (HPA)

<!-- À REPRENDRE EXISTANT : 5_Kubernetes-Advanced/410-Horizontal.md -->

**Le HPA ajuste dynamiquement le nombre de replicas d'un déploiement en fonction de métriques (CPU, mémoire, métriques personnalisées).**

### Mécanismes internes

1. **Metrics Server** : Collecte les métriques d'utilisation des ressources en temps réel
2. **Contrôleur HPA** : Compare les métriques aux seuils définis et décide du scaling
3. **API Kubernetes** : Le contrôleur ajuste le nombre de replicas via l'API
4. **Stratégies de scaling** : Les ajustements sont fluides, avec des cooldown periods

### Quickstart

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: myapp-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: myapp
  minReplicas: 2
  maxReplicas: 20
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 80
```

```sh
kubectl get hpa
kubectl describe hpa myapp-hpa
```

### Utilisation d'autres métriques

Au-delà du CPU, il est possible de scaler sur :

- **Métriques personnalisées** : temps de traitement des requêtes, nombre d'erreurs 500
- **Métriques externes** : longueur d'une file de messages (RabbitMQ, Kafka)
- **Prometheus Adapter** : exposition des métriques Prometheus à l'API Kubernetes

### Difficultés et pièges

- **Faux positifs (flapping)** : réaction excessive à des pics temporaires — utiliser `stabilizationWindowSeconds`
- **Délais de scaling** : le HPA ne réagit pas instantanément, des périodes de latence sont inévitables
- **Requests mal dimensionnées** : si les requests sont trop élevées, le HPA peut ne pas scaler même sous charge
- **Métriques CPU vs charge réelle** : le CPU ne reflète pas toujours l'état applicatif réel

---

## Vertical Pod Autoscaler (VPA)

<!-- À REPRENDRE EXISTANT : 5_Kubernetes-Advanced/420-Vertical.md ## VPA -->

**Le VPA ajuste automatiquement les requests et limits CPU/mémoire des pods en fonction des besoins réels.**

Contrairement au HPA qui ajoute des pods, le VPA modifie les ressources allouées à chaque pod individuel.

### Fonctionnement

1. **Surveillance** : Collecte continue de l'utilisation CPU/mémoire des pods
2. **Recommandations** : Génère des recommendations de `requests` et `limits` optimales
3. **Application** : En mode `Auto`, redémarre les pods avec les nouvelles allocations

### Modes de fonctionnement

| Mode | Comportement |
|---|---|
| `Off` | Calcule les recommandations sans les appliquer |
| `Initial` | Applique les recommandations uniquement à la création des pods |
| `Auto` | Applique les recommandations en redémarrant les pods |

```yaml
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: myapp-vpa
spec:
  targetRef:
    apiVersion: "apps/v1"
    kind: Deployment
    name: myapp
  updatePolicy:
    updateMode: "Auto"
```

### Limites du VPA

- Redémarre les pods pour appliquer les changements — interruption de service possible
- Ne peut pas être utilisé en même temps que le HPA sur les mêmes métriques (CPU/mémoire)
- Recommandé pour les workloads stables dont les ressources sont difficiles à dimensionner manuellement

---

## Cluster Autoscaler

<!-- À REPRENDRE EXISTANT : 5_Kubernetes-Advanced/420-Vertical.md ## Cluster Autoscaler -->

**Le Cluster Autoscaler ajuste automatiquement le nombre de nœuds du cluster en fonction des besoins en ressources.**

### Fonctionnement

1. **Surveillance** : Détecte les pods qui ne peuvent pas être schedulés (ressources insuffisantes)
2. **Ajout de nœuds** : Ajoute des nœuds pour satisfaire les demandes
3. **Suppression de nœuds** : Supprime les nœuds sous-utilisés pour optimiser les coûts

### Problèmes récurrents

- Métriques incorrectes → décisions de scaling inappropriées
- Changements d'offre du cloud provider / mauvaises configurations
- Indisponibilité du provider → pas de machines disponibles
- Quotas du provider → impossibilité d'ajouter des ressources
- Latences : incohérence temporelle entre demande et obtention
- Pods avec PVC → éviction impossible, nœuds mal exploités

---

## Right-sizing et gestion des coûts

<!-- A REDIGER -->

> **À ÉCRIRE** : Right-sizing — comment identifier et corriger les workloads sur- ou sous-dimensionnés. Outils (Goldilocks, VPA en mode Off), métriques à surveiller (requests vs utilisation réelle), processus de revue régulière des ressources.

---

## Eviction, Cordon et Drain

<!-- A REDIGER -->

> **À ÉCRIRE** :
> - `kubectl cordon` : marquer un nœud comme non-schedulable
> - `kubectl drain` : évacuer les pods d'un nœud avant maintenance
> - Eviction : mécanisme Kubernetes pour récupérer des ressources sous pression (eviction policies, QoS classes)
> - Node conditions : MemoryPressure, DiskPressure, PIDPressure

### Classes QoS et ordre d'éviction

La façon dont on configure les `requests` et `limits` détermine la **classe QoS** du pod, qui influe directement sur l'ordre d'éviction en cas de pression mémoire sur un nœud :

| Classe | Condition | Éviction |
|---|---|---|
| **Guaranteed** | Toutes les requests = toutes les limits (CPU et RAM) | Derniers évincés |
| **Burstable** | Au moins une request ou limit définie, mais pas Guaranteed | Évincés en second |
| **Best Effort** | Aucune request ni limit définie | Premiers évincés |

```yaml
# Guaranteed : request == limit pour CPU et mémoire
resources:
  requests:
    cpu: "500m"
    memory: "128Mi"
  limits:
    cpu: "500m"
    memory: "128Mi"
```

> Un pod sans aucune request ni limit (Best Effort) peut se faire évincer même s'il est healthy.

---

## Taints, Tolerations et Affinity

<!-- A REDIGER (source partielle : 5_Kubernetes_Advanced_2/02_Architecture ## Affinité) -->

> **À ÉCRIRE** :
> - **Taints** : marquer un nœud pour repousser certains pods (`kubectl taint`)
> - **Tolerations** : autoriser un pod à être schedulé sur un nœud tainté
> - **Node Affinity** : exprimer des préférences ou contraintes de scheduling basées sur les labels des nœuds
> - **Pod Anti-Affinity** : éviter que deux pods du même service se retrouvent sur le même nœud (exemple : YAML HPA avec `podAntiAffinity`)
> - Cas d'usage : nœuds GPU, nœuds dédiés à certaines équipes, HA géographique

### Principe Taints / Tolerations

Un **Taint** est appliqué sur un nœud pour le rendre sélectif — il repousse tous les pods qui ne déclarent pas de **Toleration** correspondante.

```bash
# Appliquer un taint sur un nœud (ex : nœud avec GPU)
kubectl taint nodes mynode needgpu=true:NoSchedule
```

```yaml
# Pod qui tolère ce taint — sera schedulé sur le nœud GPU
spec:
  containers:
  - name: deepdata
    image: deepdata:1.0
  tolerations:
  - key: "needgpu"
    operator: "Equal"
    value: "true"
    effect: "NoSchedule"
```

Effets possibles : `NoSchedule` (pas de nouveau scheduling), `PreferNoSchedule` (évité si possible), `NoExecute` (expulse les pods existants).

---

## Le pattern Operator

<!-- À REPRENDRE EXISTANT : 5_Kubernetes-Advanced/500-Run5-Operators.md -->

![](/img/kubernetes/500-Operators.png)

**Un Controller est un processus qui surveille l'état du cluster et applique des modifications pour atteindre l'état souhaité.**

**Un Operator étend ce concept en encapsulant la logique métier** nécessaire pour gérer des applications spécifiques : sauvegardes, mises à jour, configurations personnalisées.

Exemple : Elastic Cloud on Kubernetes (ECK) gère le cycle de vie complet d'un cluster Elasticsearch.

### La boucle de réconciliation

```
Utilisateur définit l'état désiré (YAML)
       │
       ▼
API Server enregistre l'état désiré
       │
       ▼
Controller surveille l'état actuel
       │
       ▼
Différence détectée ?
  ├── Non → Continue à surveiller
  └── Oui → Prend des mesures correctives
              │
              ▼
         Mise à jour de l'état dans l'API Server
              │
              ▼
         Cycle continue...
```

### Déclenchement des contrôleurs

- **kube-controller-manager** : gère les contrôleurs intégrés (ReplicaSet, Deployment, etc.)
- **Contrôleurs personnalisés** : s'exécutent en tant que pods, surveillent des CRDs
- **Informer Framework** (`client-go`) : abstrait la surveillance des ressources, gère le cache
- **WorkQueue** : file de travail pour traiter les événements en ordre

---

## Custom Operators avec Kubebuilder

<!-- À REPRENDRE EXISTANT : 5_Kubernetes-Advanced/510-Custom-Operator.md -->

![](/img/kubernetes/k8s-operator-schema.png)

**Kubebuilder est le framework officiel Go pour créer des operators Kubernetes.**

### Prérequis

- Go v1.20+
- Docker v17.03+
- kubectl v1.11.3+
- Accès à un cluster Kubernetes

### Quickstart

```bash
# Installer Kubebuilder
curl -L -o kubebuilder "https://go.kubebuilder.io/dl/latest/$(go env GOOS)/$(go env GOARCH)"
chmod +x kubebuilder && mv kubebuilder /usr/local/bin/

# Créer un projet
mkdir -p ~/projects/monoperator && cd ~/projects/monoperator
kubebuilder init --domain mon.domaine --repo mon.domaine/monoperator

# Créer une API (CRD + Controller)
kubebuilder create api --group webapp --version v1 --kind MonApp

# Installer les CRDs dans le cluster
make install

# Lancer le contrôleur localement
make run

# Builder et déployer l'image
make docker-build docker-push IMG=<registry>/monoperator:tag
make deploy IMG=<registry>/monoperator:tag
```

### Les CRDs

Les CRDs permettent de définir de nouveaux types de ressources gérés par l'Operator :

```yaml
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: drinks.example.com
spec:
  group: example.com
  versions:
    - name: v1
      served: true
      storage: true
      schema:
        openAPIV3Schema:
          type: object
          properties:
            spec:
              type: object
              properties:
                name:
                  type: string
  scope: Namespaced
  names:
    plural: drinks
    singular: drink
    kind: Drink
```

### Bonnes pratiques Operator

- Ne pas s'exécuter en tant que `root` — utiliser un ServiceAccount dédié
- Ne pas auto-enregistrer les CRDs — les gérer séparément
- Ne pas installer d'autres Operators — déléguer à OLM (Operator Lifecycle Manager)
- Écrire des informations de statut significatives sur les Custom Resources
- Supporter les mises à jour depuis une version précédente
- Utiliser des webhooks de conversion pour les changements d'API/CRDs
- Valider les CR via OpenAPI / Admission Webhooks

### Gestion des versions de CRD

**Votre operator va évoluer — il faut gérer la compatibilité ascendante et descendante.**

Trois approches :
1. **Un contrôleur par version de CRD** : simple à gérer, complexe à déployer
2. **Version unique** : un contrôleur avec des conditions par version
3. **Approche hybride** : contrôleur principal pour les versions stables, contrôleurs additionnels pour les versions en développement

Les **webhooks de conversion** traduisent automatiquement les anciennes versions en nouvelles — recommandé par la documentation officielle Kubernetes.

---

## Exemple d'Operator réel : Kubi (k8s + LDAP)

<!-- À REPRENDRE EXISTANT : 5_Kubernetes-Advanced/520-Example-Operator.md -->

**Kubi** est une solution d'accès et de gestion de clusters Kubernetes intégrant Active Directory.

Source : https://github.com/ca-gip/kubi

- **Authentification** : Jetons JWT temporaires signés par clé privée, vérifiés par clé publique
- **Autorisation** : Rôles et permissions définis dans Active Directory
- **Composants** : Serveur Kubi (génère les jetons) + Client Kubi (CLI)

**Exercice d'analyse** :
- Où sont les CRDs ? Que définissent-elles ?
- Que contient le Makefile ? Quelles sont les cibles ?
- Voyez-vous un contrôleur ? Comment fonctionne-t-il ?
- Que pensez-vous de la structure et de la documentation ?

---

## GitOps platform from scratch

<!-- A REDIGER -->

> **À ÉCRIRE** : Déployer une plateforme GitOps complète depuis zéro.
> - Concepts : Git comme source de vérité, réconciliation continue
> - ArgoCD : installation, Application CRD, App of Apps pattern
> - Structure du repo GitOps : environnements, overlays Kustomize
> - Promotion : dev → staging → prod
> - Gestion des secrets dans un workflow GitOps (Sealed Secrets, External Secrets Operator)

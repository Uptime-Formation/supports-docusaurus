---
title: "Cours Après-midi - Le langage Kubernetes et les objets de base"
draft: false
---

## L'API et les objets Kubernetes

**Utiliser Kubernetes consiste à déclarer des objets grâce à l'API pour décrire l'état souhaité du cluster** : quelles applications exécuter, quelles images elles utilisent, le nombre de replicas, les ressources réseau et disque disponibles, etc.

On définit des objets de deux façons :
- **Impératif** : `kubectl run <conteneur>`, `kubectl expose`, `kubectl create`
- **Déclaratif** : décrire un objet dans un fichier YAML et le passer à `kubectl apply -f monobjet.yaml`

**Kubernetes est complètement automatisable** — vous pouvez aussi écrire des programmes qui utilisent directement l'API.

---

## Infrastructure as Code : la commande `apply`

Kubernetes encourage le principe de l'**Infrastructure as Code** : décrire l'état souhaité dans des fichiers YAML versionnés dans Git, plutôt que lancer des commandes manuelles.

```bash
kubectl apply -f object.yaml    # crée ou met à jour
kubectl delete -f object.yaml   # supprime
```

C'est la méthode recommandée en production — les fichiers YAML sont la source de vérité.

---

## Le YAML

Kubernetes décrit ses ressources en YAML. À quoi ça ressemble :

```yaml
- marché:
    lieu: Marché de la Place
    fruits:
      - nom: pomme
        couleur: "verte"
      - nom: poires
        couleur: jaune
    légumes:
      - courgettes
      - salade
```

**Règles importantes :**
- Alignement avec **2 espaces** (pas de tabulations)
- Des listes (tirets `-`)
- Des dictionnaires de paires **clé: valeur**
- Les extensions Kubernetes et YAML dans VSCode vous aident à repérer les erreurs

### Structure de base d'un objet Kubernetes

```yaml
apiVersion: apps/v1       # version de l'API (obligatoire)
kind: Deployment          # type d'objet (obligatoire)
metadata:                 # (obligatoire)
  name: mon-app           # nom de la ressource (obligatoire)
  namespace: default      # namespace (optionnel, défaut: default)
  labels:
    app: mon-app          # étiquettes clé/valeur libres
spec:                     # état souhaité (obligatoire, spécifique à chaque kind)
  replicas: 1
  ...
```

Pour explorer les paramètres disponibles : `kubectl explain pod`, `kubectl explain deploy --recursive`

On peut décrire **plusieurs ressources dans un seul fichier**, séparées par `---`. L'ordre n'importe pas — Kubernetes planifie la création dans le bon ordre selon les dépendances.

---

## Les Namespaces

**Tous les objets Kubernetes sont rangés dans des namespaces — des espaces de travail isolés.**

Cette isolation permet :
- d'éviter les conflits de nom entre applications
- de ne voir que ce qui concerne une tâche particulière
- de créer des **limites de ressources** (CPU, RAM) par namespace
- de définir des **rôles et permissions** RBAC par namespace

```bash
kubectl get pods                    # namespace default
kubectl get pods -n kube-system     # namespace kube-system
kubectl get pods -A                 # tous les namespaces
```

Kubernetes fait tourner ses propres composants dans `kube-system` sous forme de pods.

---

## Les Pods

**Le Pod est l'unité de base d'une application Kubernetes** — un groupe atomique de conteneurs garantis de tourner sur le même node, toujours ensemble.

Les conteneurs d'un pod partagent :
- des volumes communs
- la même interface réseau (même IP, mêmes noms de domaine internes)
- peuvent se parler en IPC

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: rancher-demo-pod
  labels:
    app: rancher-demo
spec:
  containers:
    - image: monachus/rancher-demo:latest
      name: rancher-demo-container
      ports:
        - containerPort: 8080
    - image: redis
      name: redis-container
      ports:
        - containerPort: 6379
```

> Un pod seul n'est **pas recommandé** en production — il n'a pas de self-healing ni de gestion de version. Utilisez un Deployment.

**Un pod est largement immutable** : on ne peut pas changer le nom d'un conteneur ou sa commande après création. Pour modifier ces propriétés, il faut supprimer et recréer le pod. C'est précisément pour ça qu'on utilise un Deployment — il gère ce cycle automatiquement.

---

## Les Deployments

**Le Deployment est l'objet à créer en pratique** pour déployer une application. C'est un objet de plus haut niveau qui pilote des ReplicaSets et des Pods.

Architecture en poupées russes : **Deployment → ReplicaSet → Pods → Conteneurs**

**Responsabilités du Deployment :**
- **Tracking de versions** : gère la coexistence de plusieurs versions lors des mises à jour
- **RolloutStrategy** : montée de version automatique en haute disponibilité (zero-downtime)
- **Self-healing** via le ReplicaSet : recrée automatiquement les pods qui tombent

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: demonstration
  labels:
    app: demonstration
spec:
  replicas: 3
  selector:
    matchLabels:
      app: demonstration
  template:
    metadata:
      labels:
        app: demonstration
    spec:
      containers:
        - name: rancher-demo
          image: monachus/rancher-demo:latest
          ports:
            - containerPort: 8080
```

```bash
kubectl get deployments
kubectl get rs          # ReplicaSets — ne pas manipuler directement
kubectl get pods
kubectl get all -n <namespace>   # toutes les ressources d'un namespace
```

### Ne jamais utiliser le tag `latest` en production

Quand plusieurs replicas d'un Deployment utilisent `image: monapp:latest`, chaque pod peut finir par avoir une version différente selon le moment où il a été schedulé. Si `latest` pointe vers une nouvelle image avec un breaking change, certains pods tournent l'ancienne version, d'autres la nouvelle — l'application est incohérente.

**La règle** : utiliser un tag de version explicite (`monapp:1.4.2`) ou le hash de commit (`monapp:abc1234`). Ainsi tous les replicas tournent exactement la même image.

```yaml
# À éviter
image: monapp:latest

# Recommandé
image: monapp:1.4.2
# ou avec le hash de commit
image: registry.example.com/monapp:abc1234f
```

### Stratégie de déploiement

Le champ `strategy.type` contrôle comment Kubernetes remplace les pods lors d'une mise à jour :
- **`Recreate`** : supprime tous les anciens pods, puis crée les nouveaux (interruption courte)
- **`RollingUpdate`** (défaut) : remplace progressivement, pod par pod (zero-downtime)

```yaml
spec:
  strategy:
    type: Recreate
```

### Rollout : gérer les mises à jour

Chaque `kubectl apply` qui change les conteneurs crée une nouvelle **révision** du Deployment. Kubernetes gère deux ReplicaSets en parallèle pendant la transition.

```bash
kubectl rollout status deployment/<nom>         # suivre la progression
kubectl rollout history deployment/<nom>        # voir les révisions
kubectl rollout history deployment/<nom> --revision=2  # détail d'une révision
kubectl rollout undo deployment/<nom>           # revenir à la révision précédente
```

---

## Labels et sélecteurs

**Les labels sont des étiquettes clé/valeur** attachées librement aux objets Kubernetes. Les sélecteurs permettent de filtrer et de **relier des objets entre eux**.

Exemple : un Service pointe vers des Pods via leurs labels. Si le label ne correspond plus, le trafic est coupé.

```yaml
# Sur le Deployment
labels:
  app: demonstration

# Sur le Service (selector)
selector:
  app: demonstration
```

> Évitez d'utiliser le même label pour des parties différentes de l'application.

---

## Les Services

Un **Service** crée un point d'accès stable vers un ensemble de pods — il sélectionne les pods via leurs **labels** et répartit le trafic entre eux (load balancing).

![](/img/kubernetes/k8s-exposed-pod.jpg)

Les **endpoints** sont la liste des IPs des pods actuellement sélectionnés par un Service. Si le selector ne correspond à aucun pod, les endpoints sont vides et le trafic ne passe plus.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: demo-service
spec:
  type: NodePort
  ports:
    - port: 8080
  selector:
    app: demonstration   # doit correspondre aux labels des pods
```

```bash
kubectl get services
kubectl describe service <nom>   # voir les endpoints
```

---

## Les health checks (Probes)

Kubernetes dispose de trois types de sondes pour surveiller l'état des conteneurs :

- **`startupProbe`** : vérifie que l'application a bien démarré. Tant qu'elle n'est pas validée, les autres probes ne s'exécutent pas. Utile pour les applications lentes au démarrage.
- **`readinessProbe`** : vérifie que le conteneur est **prêt à recevoir du trafic**. Tant qu'elle échoue, le pod est retiré des endpoints du Service.
- **`livenessProbe`** : vérifie que le conteneur est **vivant**. Si elle échoue, Kubernetes redémarre le conteneur.

Paramètres courants :
- `initialDelaySeconds` : délai avant le premier check (évite les faux positifs au démarrage)
- `periodSeconds` : fréquence des checks
- `failureThreshold` : nombre d'échecs avant action

```yaml
containers:
  - name: mon-app
    startupProbe:
      exec:
        command: ["/bin/sh", "-c", "test -f /tmp/started"]
      failureThreshold: 30
      periodSeconds: 10
    readinessProbe:
      httpGet:
        path: /ready
        port: 8080
      initialDelaySeconds: 5
      periodSeconds: 10
    livenessProbe:
      httpGet:
        path: /healthy
        port: 8080
      initialDelaySeconds: 15
      periodSeconds: 10
```

---

## Observer les événements

`kubectl get events` affiche l'historique des événements du cluster — créations, erreurs, scheduling, probes :

```bash
kubectl get events --sort-by .lastTimestamp -n <namespace>
kubectl get events -w -n <namespace>   # mode watch — suit les événements en temps réel
```

---

## Débugger des conteneurs

```bash
kubectl logs <pod-name>                          # logs du conteneur
kubectl logs <pod-name> -c <conteneur-name>      # si plusieurs conteneurs dans le pod
kubectl exec -it <pod-name> -- /bin/sh           # shell interactif
kubectl exec -it <pod-name> -c <nom> -- /bin/sh  # sur un conteneur spécifique
kubectl describe pod <pod-name>                  # événements et état détaillé
kubectl describe deployment <nom>                # état et événements du deployment
kubectl port-forward <pod-name> 8080:8080        # forward de port (debug seulement)
kubectl cp <pod-name>:/chemin/fichier ./local    # copier un fichier depuis un pod
kubectl top pods                                 # ressources CPU/RAM consommées
```

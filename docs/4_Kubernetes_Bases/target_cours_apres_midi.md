---
title: "Cours Après-midi - Le langage Kubernetes et les objets de base"
draft: true
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

## Débugger des conteneurs

```bash
kubectl logs <pod-name>                          # logs du conteneur
kubectl logs <pod-name> -c <conteneur-name>      # si plusieurs conteneurs dans le pod
kubectl exec -it <pod-name> -- /bin/sh           # shell interactif
kubectl exec -it <pod-name> -c <nom> -- /bin/sh  # sur un conteneur spécifique
kubectl describe pod <pod-name>                  # événements et état détaillé
kubectl port-forward <pod-name> 8080:8080        # forward de port (debug seulement)
kubectl cp <pod-name>:/chemin/fichier ./local    # copier un fichier depuis un pod
kubectl top pods                                 # ressources CPU/RAM consommées
```

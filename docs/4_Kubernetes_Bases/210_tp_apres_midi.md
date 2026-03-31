---
title: "TP Après-midi - Déploiement avec des manifestes YAML"
draft: false
---

**Déployer un Pod avec deux conteneurs, puis le convertir en Deployment scalable, via des manifestes YAML.**

**Durée : ~3h**

### Contexte

Vous allez redéployer l'application `demonstration` du TP matin, mais cette fois **en utilisant `kubectl apply -f`** et des fichiers YAML. C'est la méthode recommandée — les fichiers sont versionnables dans Git, contrairement aux commandes impératives.

---

## Focus

- ✅ **kubectl apply** : Déployer et mettre à jour via des fichiers YAML
- ✅ **Pod multi-conteneurs** : Comprendre ce que ça implique (réseau partagé, logs séparés)
- ✅ **Deployment** : Comprendre la différence avec un Pod simple — self-healing, rollout
- ✅ **kubectl exec / logs** : Débugger un conteneur en cours d'exécution
- ✅ **Scaling et rollout** : Modifier le nombre de réplicas, observer les ReplicaSets
- ✅ **Service NodePort** : Exposer l'application à l'extérieur du cluster

---

## Objectif

- ✅ Un Pod `rancher-demo-pod` avec deux conteneurs déployé et exploré
- ✅ Un Deployment `demonstration` avec labels et réplicas déployé via YAML
- ✅ Un Service NodePort créé et fonctionnel
- ✅ Un rollout de version effectué et observé

---

## Préparation

Supprimez les ressources du TP matin pour repartir proprement :

```bash
kubectl delete deployment demonstration
kubectl delete service demonstration-service
```

Créez un dossier `tp2_yaml/` et ouvrez-le dans VSCode.

---

## Étape 1 - Déployer un Pod avec deux conteneurs

**Objectif** : Comprendre le Pod multi-conteneurs — les deux conteneurs partagent le même réseau.

- **Action** : Créer un fichier `demo-pod.yaml` avec un Pod contenant `rancher-demo` et `redis`
  **Observation** : `kubectl get pod rancher-demo-pod` montre le pod — vérifiez les deux conteneurs (2 carrés verts dans Lens, ou `2/2` dans kubectl)

- **Action** : Modifier le **label** du pod et réappliquer
  **Observation** : Kubernetes met à jour le pod

- **Action** : Modifier le **nom d'un conteneur** et réappliquer
  **Observation** : Kubernetes refuse — un pod est largement immutable. Il faut le supprimer et recréer.

- **Action** : Explorer le pod avec `exec`
  **Observation** : Vous êtes dans le shell du conteneur

<details><summary>Indice</summary>

```yaml
# demo-pod.yaml
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

```bash
kubectl apply -f demo-pod.yaml
kubectl get pod rancher-demo-pod
kubectl logs rancher-demo-pod -c rancher-demo-container
kubectl exec -it rancher-demo-pod -c rancher-demo-container -- /bin/sh
kubectl delete -f demo-pod.yaml
```

</details>

---

## Étape 2 - Déployer avec un Deployment

**Objectif** : Passer à la méthode recommandée — le Deployment gère la mise à jour et le self-healing.

- **Action** : Créer un fichier `demo-deploy.yaml` décrivant un Deployment `demonstration`
  **Observation** : `kubectl get deployment demonstration` est en état `Ready 1/1`

- **Action** : Modifier le nom d'un conteneur et réappliquer
  **Observation** : Contrairement au Pod, le Deployment crée un nouveau pod avec les bonnes caractéristiques et supprime l'ancien

- **Action** : Changer le nombre de réplicas à 3 et réappliquer
  **Observation** : 3 pods sont créés

- **Action** : Modifier le `matchLabels` du selector avec une valeur incorrecte et réappliquer
  **Observation** : Kubernetes refuse ou crée un nouveau ReplicaSet orphelin — les labels sont critiques

<details><summary>Indice</summary>

```yaml
# demo-deploy.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: demonstration
  labels:
    nom-app: demonstration
spec:
  selector:
    matchLabels:
      nom-app: demonstration
  strategy:
    type: Recreate
  replicas: 1
  template:
    metadata:
      labels:
        nom-app: demonstration
    spec:
      containers:
        - image: monachus/rancher-demo:latest
          name: rancher-demo
          ports:
            - containerPort: 8080
              name: demo-http
```

```bash
kubectl apply -f demo-deploy.yaml
kubectl get deployment demonstration
kubectl describe deployment demonstration
```

</details>

---

## Étape 3 - Exposer avec un Service NodePort

**Objectif** : Rendre l'application accessible depuis l'extérieur du cluster.

- **Action** : Créer un fichier `demo-svc.yaml` avec un Service NodePort
  **Observation** : `kubectl get services` montre le service avec un port 3xxxx. Accédez à l'application via l'IP du node et ce port — le nombre de réplicas devrait s'afficher.

- **Action** : Modifier le `selector` du Service avec un mauvais label et réappliquer
  **Observation** : L'application n'est plus accessible. Dans Lens, les endpoints sont vides (None).

- **Action** : Corriger le selector
  **Observation** : L'application est de nouveau accessible, les endpoints sont remplis avec les IPs des pods.

<details><summary>Indice</summary>

```yaml
# demo-svc.yaml
apiVersion: v1
kind: Service
metadata:
  name: demo-service
  labels:
    nom-app: demonstration
spec:
  ports:
    - port: 8080
  selector:
    nom-app: demonstration
  type: NodePort
```

```bash
kubectl apply -f demo-svc.yaml
kubectl get services
# Accéder via : http://<IP-du-node>:<nodePort>
```

</details>

---

## Étape 4 - Déployer le TP matin en YAML (Deployment ubuntu)

**Objectif** : Convertir le pod ubuntu du TP matin en Deployment, ajouter des health checks.

- **Action** : Créer un fichier `ubuntu-deploy.yaml` avec un Deployment `ubuntu` dans `mynamespace`, 3 réplicas, image `ubuntu:latest`, commande `tail -f /dev/null`
  **Observation** : 3 pods ubuntu tournent dans `mynamespace`

- **Action** : Ajouter `startupProbe`, `livenessProbe` et `readinessProbe`
  **Observation** : Le déploiement prend plus de temps à être Ready lors d'un apply

- **Action** : Observer les ReplicaSets créés
  **Observation** : Les ReplicaSets et Pods ont le même préfixe que le Deployment

- **Action** : Changer l'image en `ubuntu:22.04` et réappliquer
  **Observation** : Kubernetes crée un nouveau ReplicaSet et bascule progressivement les pods

<details><summary>Indice</summary>

```yaml
# ubuntu-deploy.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ubuntu
  namespace: mynamespace
spec:
  replicas: 3
  selector:
    matchLabels:
      app: ubuntu
  template:
    metadata:
      labels:
        app: ubuntu
    spec:
      containers:
      - name: ubuntu
        image: ubuntu:latest
        command: ["/bin/sh", "-c", "tail -f /dev/null"]
        startupProbe:
          exec:
            command: ["/bin/sh", "-c", "date >> /tmp/startupprobe.txt"]
          failureThreshold: 30
          periodSeconds: 10
        readinessProbe:
          exec:
            command: ["/bin/sh", "-c", "date >> /tmp/readinessprobe.txt"]
          initialDelaySeconds: 5
          periodSeconds: 10
        livenessProbe:
          exec:
            command: ["/bin/sh", "-c", "date >> /tmp/livenessprobe.txt"]
          initialDelaySeconds: 15
          periodSeconds: 10
```

```bash
kubectl apply -f ubuntu-deploy.yaml
kubectl get all -n mynamespace
kubectl rollout status deployment/ubuntu -n mynamespace
kubectl rollout history deployment/ubuntu -n mynamespace
```

Pour suivre les opérations en temps réel :
```bash
kubectl -n mynamespace get events --sort-by .lastTimestamp
kubectl -n mynamespace get events -w&
```

</details>

---

### Avancé

- Utiliser `kubectl rollout undo deployment/ubuntu -n mynamespace` pour revenir à la version précédente
- Inspecter l'historique avec `kubectl rollout history --revision=2 deployment/ubuntu -n mynamespace`
- Utiliser `kubectl scale deployment ubuntu --replicas=5 -n mynamespace` sans modifier le YAML
- Récupérer la correction complète : `git clone -b tp_rancher_demo_files https://github.com/Uptime-Formation/corrections_tp.git`

---

### Solution

<details><summary>Afficher</summary>

```bash
# Supprimer les ressources du TP matin
kubectl delete deployment demonstration
kubectl delete service demonstration-service

# Déployer le pod multi-conteneurs
kubectl apply -f demo-pod.yaml
kubectl exec -it rancher-demo-pod -c rancher-demo-container -- /bin/sh
kubectl delete -f demo-pod.yaml

# Déployer avec le Deployment
kubectl apply -f demo-deploy.yaml
kubectl get all

# Exposer avec le Service
kubectl apply -f demo-svc.yaml
kubectl get services

# Deployment ubuntu avec probes
kubectl apply -f ubuntu-deploy.yaml
kubectl rollout status deployment/ubuntu -n mynamespace
kubectl rollout history deployment/ubuntu -n mynamespace
kubectl rollout undo deployment/ubuntu -n mynamespace
```

</details>

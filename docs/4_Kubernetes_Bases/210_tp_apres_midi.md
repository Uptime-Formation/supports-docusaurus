---
title: "TP Après-midi - Déploiement avec des manifestes YAML"
draft: false
---

**Déployer un Pod avec deux conteneurs, puis le convertir en Deployment scalable, via des manifestes YAML.**

---

## Focus

- ✅ **kubectl apply** : Déployer et mettre à jour via des fichiers YAML déclaratifs
- ✅ **Pod multi-conteneurs** : Comprendre le réseau partagé, les logs séparés, l'immutabilité partielle
- ✅ **Deployment** : Self-healing, rollout automatique, gestion des ReplicaSets
- ✅ **kubectl exec / logs** : Débugger un conteneur en cours d'exécution
- ✅ **Scaling et rollout** : Modifier le nombre de réplicas, observer la bascule progressive
- ✅ **Service NodePort** : Exposer l'application à l'extérieur du cluster et comprendre le rôle des labels

---

## Objectif

- ✅ Un Pod `rancher-demo-pod` avec deux conteneurs déployé et exploré
- ✅ Un Deployment `demonstration` avec labels et réplicas déployé via YAML
- ✅ Un Service NodePort créé et fonctionnel
- ✅ Un rollout de version effectué et observé

---

## Préparation

Créez un dossier `tp2_yaml/` et ouvrez-le dans VSCode.

---

## Étape 1 - Déployer un Pod avec deux conteneurs

**Objectif** : Comprendre le modèle multi-conteneurs de Kubernetes. Les deux conteneurs d'un même pod partagent la même adresse IP et peuvent se parler via `localhost`. Ils ont en revanche des processus, des logs et un système de fichiers distincts. On va aussi observer qu'un pod est largement immutable : certaines propriétés ne peuvent pas être modifiées à chaud.

- **Action** : Créer un fichier `demo-pod.yaml` avec un Pod contenant `rancher-demo` (port 8080) et `redis` (port 6379). Les images à utiliser sont `monachus/rancher-demo:latest` et `docker.io/library/redis:latest`.  
  **Observation** : `kubectl get pod rancher-demo-pod` affiche `2/2 Running` — les deux conteneurs sont prêts.

- **Action** : Consulter les logs de chaque conteneur séparément avec `-c`.  
  **Observation** : Chaque conteneur a sa propre sortie. `rancher-demo` logue les requêtes HTTP, `redis` logue son démarrage.

- **Action** : Modifier le **label** du pod (`app: rancher-demo` → `app: demo-v2`) et réappliquer.  
  **Observation** : Kubernetes met à jour le pod — les labels sont mutables.

- **Action** : Modifier le **nom d'un conteneur** (`redis-container` → `redis-db`) et réappliquer.  
  **Observation** : Kubernetes refuse la modification — le nom d'un conteneur fait partie de la spec immutable. Il faut supprimer le pod et le recréer.

- **Action** : Ouvrir un shell dans le conteneur `rancher-demo-container` avec `kubectl exec`.  
  **Observation** : Vous êtes dans le conteneur. Vérifiez que redis est joignable sur `localhost:6379`.

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
    - image: docker.io/library/redis:latest
      name: redis-container
      ports:
        - containerPort: 6379
```

```bash
kubectl apply -f demo-pod.yaml
kubectl get pod rancher-demo-pod
kubectl logs rancher-demo-pod -c rancher-demo-container
kubectl logs rancher-demo-pod -c redis-container
kubectl exec -it rancher-demo-pod -c rancher-demo-container -- /bin/sh
# Dans le shell : wget -qO- localhost:8080
kubectl delete -f demo-pod.yaml
```

</details>

---

## Étape 2 - Déployer avec un Deployment

**Objectif** : Passer à la méthode recommandée en production. Un Deployment pilote un ReplicaSet qui maintient le nombre souhaité de pods. Si un pod disparaît (crash, nœud perdu), le ReplicaSet en recrée un automatiquement. Le Deployment ajoute la gestion des mises à jour : il crée un nouveau ReplicaSet et bascule progressivement les pods vers la nouvelle version.

Les labels jouent ici un rôle critique : le `selector.matchLabels` du Deployment doit correspondre exactement aux labels du `template`. C'est ce mécanisme qui permet au Deployment de "trouver" ses pods.

- **Action** : Créer `demo-deploy.yaml` avec un Deployment `demonstration`, 1 réplica, image `monachus/rancher-demo:latest`, stratégie `Recreate`.  
  **Observation** : `kubectl get deployment demonstration` est en état `1/1 Ready`. Observer également le ReplicaSet créé automatiquement avec `kubectl get rs`.

- **Action** : Modifier le nom d'un conteneur dans le YAML et réappliquer.  
  **Observation** : Contrairement au Pod seul, le Deployment gère le cycle — il supprime l'ancien pod et en crée un nouveau avec la nouvelle spec.

- **Action** : Changer le nombre de réplicas à 3 et réappliquer.  
  **Observation** : 3 pods sont créés. Le ReplicaSet passe à `3/3`. `kubectl get pods` montre les trois instances avec des noms générés automatiquement.

- **Action** : Modifier le `matchLabels` du selector avec une valeur incorrecte (ex: `nom-app: erreur`) et réappliquer.  
  **Observation** : Kubernetes refuse la modification — le selector d'un Deployment est immutable. C'est une protection : changer le selector orpheliserait les pods existants.

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
kubectl get rs
kubectl describe deployment demonstration
```

</details>

---

## Étape 3 - Exposer avec un Service NodePort et tester les rollouts

**Objectif** : Un Service NodePort ouvre un port fixe sur chaque nœud du cluster et redirige le trafic vers les pods sélectionnés par ses labels. On va observer concrètement comment le selector relie le Service aux pods, puis enchaîner avec un rollout de version pour voir comment Kubernetes gère la bascule.

- **Action** : Créer `demo-svc.yaml` avec un Service `NodePort` ciblant le Deployment via ses labels.  
  **Observation** : `kubectl get services` montre le port 3xxxx assigné. Accédez à `http://<IP-du-node>:<nodePort>` — l'interface de rancher-demo s'affiche et montre le nombre de réplicas actifs.

- **Action** : Modifier le `selector` du Service avec un mauvais label et réappliquer.  
  **Observation** : L'application n'est plus accessible. `kubectl describe service demo-service` montre `Endpoints: <none>` — le Service n'a plus de pods cibles.

- **Action** : Corriger le selector et réappliquer.  
  **Observation** : Les endpoints se repopulent immédiatement avec les IPs des pods. L'application est de nouveau accessible.

- **Action** : Modifier la stratégie du Deployment en `RollingUpdate`, changer l'image en `monachus/rancher-demo:2` et réappliquer.  
  **Observation** : `kubectl rollout status deployment/demonstration` suit la progression pod par pod. `kubectl get rs` montre deux ReplicaSets coexistant brièvement pendant la bascule.

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
kubectl describe service demo-service   # vérifier les Endpoints
# Accéder via : http://<IP-du-node>:<nodePort>

# Rollout
kubectl rollout status deployment/demonstration
kubectl rollout history deployment/demonstration
kubectl rollout undo deployment/demonstration   # revenir à la version précédente
kubectl get rs                                  # observer les deux ReplicaSets
```

</details>

---

### Avancé

- Utiliser `kubectl scale deployment demonstration --replicas=5` sans modifier le YAML — puis observer ce qui se passe si on réapplique le YAML avec `replicas: 3`
- Inspecter le détail d'une révision : `kubectl rollout history deployment/demonstration --revision=2`
- Récupérer la correction complète : `git clone -b tp_rancher_demo_files https://github.com/Uptime-Formation/corrections_tp.git`

---

### Solution

<details><summary>Afficher</summary>

```bash
# Déployer le pod multi-conteneurs
kubectl apply -f demo-pod.yaml
kubectl logs rancher-demo-pod -c rancher-demo-container
kubectl exec -it rancher-demo-pod -c rancher-demo-container -- /bin/sh
kubectl delete -f demo-pod.yaml

# Déployer avec le Deployment
kubectl apply -f demo-deploy.yaml
kubectl get all

# Exposer avec le Service
kubectl apply -f demo-svc.yaml
kubectl get services
kubectl describe service demo-service

# Rollout
kubectl rollout status deployment/demonstration
kubectl rollout history deployment/demonstration
kubectl rollout undo deployment/demonstration
kubectl get rs
```

</details>

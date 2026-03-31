---
title: TP matin — Kubernetes Développeur
---

**Configurer des applications avec ConfigMaps, Secrets, Volumes et StatefulSets.**

**Durée : 1h30**

### Contexte

Vous êtes développeur dans une équipe qui déploie une stack applicative sur Kubernetes. Votre mission ce matin est de gérer correctement la configuration (ConfigMaps, Secrets), le stockage persistant (PVC), et de déployer une base de données Redis en mode StatefulSet avec persistance garantie.

---

## Focus Kubernetes Dev

- ✅ **ConfigMaps** : Découplez la configuration de vos manifestes
- ✅ **Secrets** : Gérez les données sensibles sans les hardcoder
- ✅ **Volumes emptyDir et PVC** : Comprenez les deux cas de persistance
- ✅ **StatefulSet** : Déployez une application stateful avec identité stable

**L'objectif n'est PAS de maîtriser Redis**, mais d'apprendre à **gérer la configuration et le stockage dans Kubernetes**.

---

## Objectif

À la fin de ce TP, vous devez avoir :

- ✅ Un ConfigMap monté comme fichier dans un pod Redis
- ✅ Un Secret utilisé comme variables d'environnement dans un pod Postgres
- ✅ Un PVC Longhorn avec un writer-pod et un reader-pod partageant les données
- ✅ Un StatefulSet Redis avec `volumeClaimTemplates` et un Service associé

---

## Étape 0 - Préparer le namespace

**Objectif** : Travailler dans un namespace dédié.

- **Action** : Créer le namespace `mynamespace` et définir le contexte
  **Observation** : `kubectl config get-contexts` montre le namespace par défaut à jour

<details><summary>Indice</summary>

```bash
kubectl create namespace mynamespace
kubectl config set-context --current --namespace=mynamespace
```

</details>

---

## Étape 1 - ConfigMap comme fichier de configuration

**Objectif** : Configurer Redis via un ConfigMap monté en volume.

- **Action** : Créer un ConfigMap nommé `redis-config` avec le contenu suivant :

```
maxmemory 2mb
maxmemory-policy allkeys-lru
```

  **Observation** : `kubectl get configmap redis-config -o yaml` affiche les données

- **Action** : Créer un pod `redis-pod` avec l'image `redis:latest` qui monte la ConfigMap dans `/redis-master` et démarre avec `redis-server /redis-master/redis.conf`
  **Observation** : Le pod est en état `Running`

- **Action** : Vérifier que la configuration est prise en compte :
  ```bash
  kubectl exec -it redis-pod -- redis-cli config get maxmemory
  ```
  **Observation** : La réponse indique `2097152` (2mb en octets)

<details><summary>Indice</summary>

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: redis-config
  namespace: mynamespace
data:
  redis.conf: |
    maxmemory 2mb
    maxmemory-policy allkeys-lru
---
apiVersion: v1
kind: Pod
metadata:
  name: redis-pod
  namespace: mynamespace
spec:
  containers:
  - name: redis
    image: redis:latest
    command: ["redis-server", "/redis-master/redis.conf"]
    volumeMounts:
    - name: config-volume
      mountPath: /redis-master
  volumes:
  - name: config-volume
    configMap:
      name: redis-config
```

</details>

---

## Étape 2 - Secret comme variables d'environnement

**Objectif** : Passer des credentials Postgres sans les hardcoder.

- **Action** : Créer un Secret `postgres-secret` avec `POSTGRES_USER=user` et `POSTGRES_PASSWORD=password`
  **Observation** : `kubectl get secret postgres-secret` affiche le secret (valeurs encodées en base64)

- **Action** : Créer un pod `postgres-pod` avec l'image `postgres:latest` qui utilise ces variables via `secretKeyRef`
  **Observation** : Le pod démarre correctement

- **Action** : Vérifier que les variables sont présentes :
  ```bash
  kubectl exec -it postgres-pod -- env | grep POSTGRES
  ```
  **Observation** : Les deux variables apparaissent avec les bonnes valeurs

<details><summary>Indice</summary>

```bash
kubectl create secret generic postgres-secret \
  --from-literal=POSTGRES_USER=user \
  --from-literal=POSTGRES_PASSWORD=password \
  -n mynamespace
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: postgres-pod
  namespace: mynamespace
spec:
  containers:
  - name: postgres
    image: postgres:latest
    env:
    - name: POSTGRES_USER
      valueFrom:
        secretKeyRef:
          name: postgres-secret
          key: POSTGRES_USER
    - name: POSTGRES_PASSWORD
      valueFrom:
        secretKeyRef:
          name: postgres-secret
          key: POSTGRES_PASSWORD
```

</details>

---

## Étape 3 - Volumes persistants : writer et reader

**Objectif** : Partager un volume persistant entre deux pods.

- **Action** : Installer Longhorn (StorageClass nécessaire pour les PVC) :
  ```bash
  sudo apt update && sudo apt install nfs-common -y
  kubectl apply -f https://raw.githubusercontent.com/longhorn/longhorn/v1.6.0/deploy/longhorn.yaml
  ```
  **Observation** : `kubectl get storageclass` liste `longhorn`

- **Action** : Créer un PVC `pv-claim` de 1Gi avec `storageClassName: longhorn` et `accessModes: ReadWriteMany`
  **Observation** : `kubectl get pvc` montre le PVC en état `Bound`

- **Action** : Créer un pod `writer-pod` qui écrit un timestamp toutes les 5 secondes dans `/data/timestamp.txt`
  **Observation** : `kubectl exec writer-pod -- tail /data/timestamp.txt` montre des lignes qui s'accumulent

- **Action** : Créer un pod `reader-pod` avec la commande `tail -f /data/timestamp.txt` sur le même PVC
  **Observation** : `kubectl logs reader-pod` affiche les timestamps écrits par le writer

<details><summary>Indice</summary>

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pv-claim
  namespace: mynamespace
spec:
  storageClassName: longhorn
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 1Gi
---
apiVersion: v1
kind: Pod
metadata:
  name: writer-pod
  namespace: mynamespace
spec:
  containers:
  - name: writer
    image: ubuntu:latest
    command: ["/bin/sh", "-c", "while true; do echo $(date) >> /data/timestamp.txt; sleep 5; done"]
    volumeMounts:
    - name: data-volume
      mountPath: /data
  volumes:
  - name: data-volume
    persistentVolumeClaim:
      claimName: pv-claim
```

Pour le reader, utilisez la même spec avec `tail -f /data/timestamp.txt` comme commande.

</details>

---

## Étape 4 - StatefulSet Redis avec VolumeClaimTemplate

**Objectif** : Déployer Redis en mode StatefulSet avec un PVC automatique par pod.

- **Action** : Créer un StatefulSet `redis-set` avec 2 replicas, un `volumeClaimTemplates` de 100Mi, et le port 6379
  **Observation** : `kubectl get pods` montre `redis-set-0` et `redis-set-1` qui démarrent **dans l'ordre**

- **Action** : Observer les PVCs créés automatiquement
  **Observation** : `kubectl get pvc` montre `redis-data-redis-set-0` et `redis-data-redis-set-1`

- **Action** : Créer un Service `redis-service` de type `ClusterIP` avec le selector `app: redis` sur le port 6379
  **Observation** : `kubectl get svc redis-service` montre le service

- **Action** : Modifier le selector du service pour cibler uniquement `redis-set-0` avec le label `statefulset.kubernetes.io/pod-name: redis-set-0`
  **Observation** : `kubectl get endpoints redis-service` montre une seule IP (celle de redis-set-0)

<details><summary>Indice</summary>

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: redis-set
  namespace: mynamespace
spec:
  serviceName: "redis"
  replicas: 2
  selector:
    matchLabels:
      app: redis
  template:
    metadata:
      labels:
        app: redis
    spec:
      containers:
      - name: redis
        image: redis:latest
        ports:
        - containerPort: 6379
        volumeMounts:
        - name: redis-data
          mountPath: /data
  volumeClaimTemplates:
  - metadata:
      name: redis-data
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 100Mi
```

```yaml
apiVersion: v1
kind: Service
metadata:
  name: redis-service
  namespace: mynamespace
spec:
  selector:
    statefulset.kubernetes.io/pod-name: redis-set-0
  ports:
  - protocol: TCP
    port: 6379
    targetPort: 6379
  type: ClusterIP
```

</details>

---

### Avancé

- **PVC et sécurité** : Que se passe-t-il si vous supprimez le StatefulSet ? Les PVCs sont-ils supprimés automatiquement ? Pourquoi ce comportement ?
- **Secrets chiffrés** : Les Secrets Kubernetes sont encodés en base64, pas chiffrés. Comment les chiffrer au repos dans etcd ? Que sont les "External Secrets" et quand les utiliser ?
- **ReadWriteOnce vs ReadWriteMany** : Pourquoi `ReadWriteOnce` est le mode par défaut ? Quand a-t-on besoin de `ReadWriteMany` ?

---

### Synthèse

**Qu'est-ce qui a bien fonctionné ?**
- La ConfigMap a-t-elle bien été prise en compte par Redis ?
- Le Secret a-t-il bien fourni les variables au pod Postgres ?

**Quels sont les problèmes rencontrés ?**
- Le PVC est-il passé en état `Bound` rapidement ?
- Le StatefulSet a-t-il bien créé les PVCs automatiquement ?

**Quelles compétences avez-vous développées ?**

- ✅ Créer et utiliser des ConfigMaps comme fichiers de configuration
- ✅ Gérer des credentials avec des Secrets Kubernetes
- ✅ Comprendre la différence entre emptyDir et PVC
- ✅ Déployer une application stateful avec des identités stables

**Prochaine étape** : Cet après-midi, vous exposerez des applications avec Services, Ingress, et vous packagerz des déploiements avec Kustomize et Helm.

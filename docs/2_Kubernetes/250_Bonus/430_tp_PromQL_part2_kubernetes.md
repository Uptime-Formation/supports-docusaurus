---
title: TP - PromQL - Détecter des anomalies sur un Cluster Kubernetes
# sidebar_class_name: hidden
---

Dans ce TP nous allons creuser plus loin les requêtes PromQL avec des aggregations, fonctions, calculs dans le contexte de l'observation d'un cluster Kubernetes.

Kubernetes est un peu le Linux du cloud : c'est la solution (ou plutôt le "noyau" de solution) open source pour créer des clouds applicatifs (conteneurs applicatifs). Prometheus est la solution de référence pour monitorer les clouds de conteneurs car il est très adapté aux environnements dynamiques ou les "cibles" de la surveillance vont et viennent.

Nous allons d'abord installer un cluster Kubernetes et l'opérateur `kube-prometheus` qui permet de déployer et d'opérer dans le temps un système Prometheus haute disponibilité.

Nous utiliserons ensuite cette configuration pour essayer des requêtes PromQL plus avancées dans un contexte dynamique.

## Installation de Kubernetes

- Installons les dépendances de Kubernetes telles d'indiquées dans le premier TP kubernetes avec un script: `bash /opt/kubernetes.sh`
- Vérifions l'installation avec `kubectl get nodes`
- Lancez `minikube stop`
- Ouvrez OpenLens dans le menu internet pour vérifier son installation

Pour installer k3s (notre kubernetes pour ce TP) lancez dans un terminal la commande suivante: `curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--disable=traefik" sh - `


- Pour récupérer la configuration lancez
  - `mkdir -p ~/.kube`
  - `sudo chmod 744 /etc/rancher/k3s/k3s.yaml cp /etc/rancher/k3s/k3s.yaml ~/.kube/config`
  - vérifier la config avec `kubectl get nodes`

Testons notre installation dans OpenLens en visitant le cluster nommé `default`

## Installation de Kube-Prometheus

Lancez la commande suivante pour récupérer kube-prometheus dans votre dossier personnel: `cd ~ && git clone https://github.com/prometheus-operator/kube-prometheus.git`

- Assurez vous d'être dans le dossier cloné : `cd ~/kube-prometheus`

- Lancez l'installation de l'opérateur de Prometheus avec le bloc de commande suivant:

```bash
# Create the namespace and CRDs, and then wait for them to be availble before creating the remaining resources
kubectl create -f manifests/setup

# Wait until the "servicemonitors" CRD is created. The message "No resources found" means success in this context.
until kubectl get servicemonitors --all-namespaces ; do date; sleep 1; echo ""; done

kubectl create -f manifests/
```

- Observons un peu dans Lens (commentaire formateur) et plus d'information dans les supports Kubernetes sur le même site

- Accédons à l'interface de Prometheus avec la commande `kubectl --namespace monitoring port-forward svc/prometheus-k8s 9999:9090` (laissez la tourner dans le terminal) puis en visitant `localhost:9090` dans le navigateur.

## Des requêtes PromQL avancées : identifier les problèmes dans notre Cluster

Pour chacune des requêtes suivantes:

- Comprendre de quoi elle parle (avec l'aide du formateur si Kubernetes ne vous est pas familier)
- créer les resources Kubernetes requises en faisant `+ > create resource` dans OpenLens puis coller le code et create.
- Décomposer la requête et la jouer partie par partie dans PromLens idéalement ou dans Prometheus pour comprendre le sens des différentes sous parties et leur retours


### Trouver le nombre de Pods par namespace

```promQL
sum by (namespace) (kube_pod_info)
```

### Trouver les PersistentVolumeClaims dans l'état "Pending"

Avant d'exécuter la requête, créez un PersistentVolumeClaim avec la spécification suivante :

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-claim-2
spec:
  storageClassName: manual
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 3Gi
```

Cela restera dans l'état "Pending" car nous n'avons pas de storageClass appelé "manual" dans notre cluster.

Maintenant, exécutez la requête suivante :

```promQL
kube_persistentvolumeclaim_status_phase{phase="Pending"}
```

### Trouver les Pods Kubernetes dans un état CrashLoop

Avant d'exécuter la requête, créez un Pod avec la spécification suivante :

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: crashing-pod
spec:
  containers:
    - name: crashing-container
      image: ubuntu
  restartPolicy: Always
```

Ce pod n'a pas de commande qui dure dans le 

Maintenant, exécutez la requête suivante :

```promQL
increase(kube_pod_container_status_restarts_total[15m]) > 3
```

### Trouver l'état des différents nœuds du cluster

- `sum(kube_node_status_condition{condition="Ready",status="true"})`

- `sum(kube_node_status_condition{condition="NotReady",status="true"})`

- `sum(kube_node_spec_unschedulable) by (node)`

### Localiser les surallocations CPU (CPU overcommit)

- Avant d'exécuter la requête, créez un Pod avec la spécification suivante :

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: gros-pod
spec:
  containers:
    - name: gros-pod
      image: alpine
      resources:
        limits: # le pod exige au moins 4 coeurs de CPU et 8Go de ram pour fonctionner
          cpu: "4000m"
          memory: "8000M"
        requests:
          cpu: "4000m"
          memory: "8000M"
        # => il ne sera jamais lancé dans notre cluster trop limité
        # dans prometheus on peut détecter que le cluster est trop petit pour les application demandées (resource overcommitment)
```

Maintenant, exécutez la requête suivante :

```promQL
sum(kube_pod_container_resource_limits{resource="cpu"}) - sum(kube_node_status_capacity{resource="cpu"})
```

Si cette requête renvoie une valeur positive, le cluster a surallocé le CPU.

### Surallocation de mémoire (Memory Overcommit)

```promQL
sum(kube_pod_container_resource_limits{resource="memory"}) - sum(kube_node_status_capacity{resource="memory"})
```

### Trouver les Pods Kubernetes "Unhealthy"

Avant d'exécuter cette requête, créez un Pod avec la spécification suivante :

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: ssd-pod 
spec:
  containers:
    - name: ssd-pod
      image: alpine
  nodeSelector:
    disktype: ssd
```

Ce Pod ne pourra pas s'exécuter car nous n'avons pas de nœud avec l'étiquette `disktype: ssd`.

Maintenant, exécutez la requête suivante :

```promQL
min_over_time(sum by (namespace, pod) (kube_pod_status_phase{phase=~"Pending|Unknown|Failed"})[15m:1m]) > 0
```

### Trouver le nombre de conteneurs sans limites CPU dans chaque espace de noms

```promQL
count by (namespace)(sum by (namespace, pod, container)(kube_pod_container_info{container!=""}) unless sum by (namespace, pod, container)(kube_pod_container_resource_limits{resource="cpu"}))
```

### Trouver les nœuds instables

Dans cette requête, vous trouverez des nœuds qui passent continuellement de l'état "Ready" à l'état "NotReady" de manière intermittente.

```promQL
sum(changes(kube_node_status_condition{status="true",condition="Ready"}[15m])) by (node) > 2
```

Si les deux nœuds fonctionnent correctement, vous ne devriez pas obtenir de résultat pour cette requête.

### Trouver les cœurs CPU inactifs

```promQL
sum((rate(container_cpu_usage_seconds_total{container!="POD",container!=""}[30m]) - on (namespace,pod,container) group_left avg by (namespace,pod,container)(kube_pod_container_resource_requests{resource="cpu"})) * -1 >0)
```

### Trouver la mémoire inutilisée

```promQL
sum((container_memory_usage_bytes{container!="POD",container!=""} - on (namespace,pod,container) avg by (namespace,pod,container)(kube_pod_container_resource_requests{resource="memory"})) * -1 >0 ) / (1024*1024*1024)
```




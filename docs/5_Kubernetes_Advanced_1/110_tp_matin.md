---
title: "TP Matin - Observabilité : Logging et Métriques"
draft: false
---

<!-- TPs FOURNIS PAR L'UTILISATEUR — intégrer quand disponible -->

## TP Logging dans Kubernetes

<!-- À REPRENDRE EXISTANT : 5_Kubernetes-Advanced/310-Logs.md ## Instructions complètes TP -->

**Configurer un pipeline de logging dans Kubernetes en utilisant le Banzai Cloud Logging Operator pour la collecte et la normalisation des logs, Elasticsearch pour le stockage, et Grafana pour la visualisation.**

### Prérequis

- Un cluster Kubernetes fonctionnel
- Accès administrateur au cluster
- `kubectl` installé et configuré

---

### Étape 1 : Créer le Namespace

```sh
kubectl create namespace logging-tp
```

---

### Étape 2 : Déploiement du Banzai Cloud Logging Operator

1. **Installer le Banzai Cloud Logging Operator**

```sh
kubectl apply -f https://raw.githubusercontent.com/banzaicloud/logging-operator/master/deploy/manifests/logging-operator.crds.yaml
kubectl apply -f https://raw.githubusercontent.com/banzaicloud/logging-operator/master/deploy/manifests/logging-operator.yaml -n logging-tp
```

2. **Créer un Logging Resource**

```yaml
apiVersion: logging.banzaicloud.io/v1beta1
kind: Logging
metadata:
  name: logging-sample
  namespace: logging-tp
spec:
  fluentbitSpec: {}
  fluentdSpec:
    image:
      repository: fluent/fluentd
      tag: v1.11-debian-1
  controlNamespace: logging-tp
```

3. **Créer un ClusterOutput pour Elasticsearch**

```yaml
apiVersion: logging.banzaicloud.io/v1beta1
kind: ClusterOutput
metadata:
  name: elasticsearch-output
  namespace: logging-tp
spec:
  elasticsearch:
    host: "elasticsearch.logging-tp.svc.cluster.local"
    port: 9200
    logstash_prefix: "myapp-logs"
    logstash_dateformat: "%Y.%m.%d"
```

4. **Créer un ClusterFlow pour la normalisation**

```yaml
apiVersion: logging.banzaicloud.io/v1beta1
kind: ClusterFlow
metadata:
  name: cluster-flow
  namespace: logging-tp
spec:
  filters:
    - record_transformer:
        enable_ruby: true
        records:
          - key: "service_name"
            value: "user-service"
          - key: "environment"
            value: "production"
  globalOutputRefs:
    - elasticsearch-output
```

---

### Étape 3 : Déploiement d'Elasticsearch

```yaml
apiVersion: v1
kind: Service
metadata:
  name: elasticsearch
  namespace: logging-tp
  labels:
    app: elasticsearch
spec:
  ports:
  - port: 9200
    name: http
  clusterIP: None
  selector:
    app: elasticsearch
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: elasticsearch
  namespace: logging-tp
spec:
  serviceName: "elasticsearch"
  replicas: 1
  selector:
    matchLabels:
      app: elasticsearch
  template:
    metadata:
      labels:
        app: elasticsearch
    spec:
      containers:
      - name: elasticsearch
        image: docker.elastic.co/elasticsearch/elasticsearch:7.10.1
        resources:
          limits:
            memory: 2Gi
          requests:
            cpu: 100m
            memory: 1Gi
        env:
        - name: discovery.type
          value: single-node
        ports:
        - containerPort: 9200
          name: http
        volumeMounts:
        - name: storage
          mountPath: /usr/share/elasticsearch/data
  volumeClaimTemplates:
  - metadata:
      name: storage
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 10Gi
```

---

### Étape 4 : Déploiement de Grafana

```yaml
apiVersion: v1
kind: Service
metadata:
  name: grafana
  namespace: logging-tp
spec:
  type: LoadBalancer
  ports:
  - port: 3000
    targetPort: 3000
  selector:
    app: grafana
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: grafana
  namespace: logging-tp
spec:
  replicas: 1
  selector:
    matchLabels:
      app: grafana
  template:
    metadata:
      labels:
        app: grafana
    spec:
      containers:
      - name: grafana
        image: grafana/grafana:7.3.1
        ports:
        - containerPort: 3000
        env:
        - name: GF_SECURITY_ADMIN_PASSWORD
          value: admin
```

---

### Étape 5 : Générer des logs de test

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: log-generator
  namespace: logging-tp
spec:
  containers:
  - name: log-generator
    image: busybox
    command: ["sh", "-c", "while true; do echo $(date) INFO Log generator running; sleep 5; done"]
```

---

### Étape 6 : Vérification dans Grafana

- Accéder à Grafana et configurer une source de données Elasticsearch
- Créer un tableau de bord et vérifier que les logs sont correctement collectés, normalisés et visualisés

---

## TP Métriques dans Kubernetes

<!-- À REPRENDRE EXISTANT : 5_Kubernetes-Advanced/320-Metrics.md ## TP Collecte automatisée -->

**Déployer Prometheus et Grafana pour collecter et visualiser les métriques d'un pod NGINX.**

---

### Étape 1 : Déploiement de NGINX avec annotations Prometheus

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/path: "/metrics"
        prometheus.io/port: "80"
    spec:
      containers:
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80
```

```sh
kubectl apply -f nginx-deployment.yaml
```

---

### Étape 2 : Déploiement de Prometheus Operator

```sh
kubectl create namespace monitoring
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/main/bundle.yaml -n monitoring
```

Créer un `ServiceMonitor` pour scrapper NGINX :

```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: nginx-servicemonitor
  namespace: monitoring
  labels:
    release: prometheus-operator
spec:
  selector:
    matchLabels:
      app: nginx
  endpoints:
  - port: web
    interval: 15s
    path: /metrics
```

Créer l'instance Prometheus :

```yaml
apiVersion: monitoring.coreos.com/v1
kind: Prometheus
metadata:
  name: prometheus
  namespace: monitoring
spec:
  serviceMonitorSelector:
    matchLabels:
      release: prometheus-operator
  resources:
    requests:
      memory: 400Mi
```

---

### Étape 3 : Déploiement de Grafana

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: grafana
  namespace: monitoring
spec:
  replicas: 1
  selector:
    matchLabels:
      app: grafana
  template:
    metadata:
      labels:
        app: grafana
    spec:
      containers:
      - name: grafana
        image: grafana/grafana
        ports:
        - containerPort: 3000
        env:
        - name: GF_SECURITY_ADMIN_PASSWORD
          value: admin
```

---

### Étape 4 : Créer un tableau de bord Grafana

- Accéder à Grafana (`http://<IP>:3000`)
- Ajouter Prometheus comme source de données : `http://prometheus.monitoring.svc.cluster.local:9090`
- Créer un panneau avec la requête PromQL : `rate(http_requests_total[5m])`

---

### Étape 5 : Vérification

```sh
# Vérifier que Prometheus scrape bien NGINX
# Dans l'UI Prometheus : up{job="nginx"}

# Vérifier les métriques disponibles
kubectl top pods -n monitoring
```

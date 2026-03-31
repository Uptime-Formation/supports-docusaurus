---
title: "TP Après-midi - Autoscaling & Operators"
draft: false
---

<!-- TPs FOURNIS PAR L'UTILISATEUR — intégrer quand disponible -->

## TP HPA avec métrique personnalisée

<!-- À REPRENDRE EXISTANT : 5_Kubernetes-Advanced/410-Horizontal.md ## TP Utilisation d'une métrique personnalisée -->

**Configurer le HPA pour utiliser une métrique personnalisée (temps de traitement des requêtes) en complément de la métrique CPU.**

### Prérequis

- Un cluster Kubernetes fonctionnel
- Metrics Server et Prometheus déployés dans le cluster

---

### Étape 1 : Déployer l'application avec anti-affinité

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myintensiveapp
spec:
  replicas: 2
  selector:
    matchLabels:
      app: myintensiveapp
  template:
    metadata:
      labels:
        app: myintensiveapp
    spec:
      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
              - key: app
                operator: In
                values:
                - myintensiveapp
            topologyKey: "kubernetes.io/hostname"
      containers:
      - name: myintensiveapp
        image: myintensiveapp:2.0
        resources:
          requests:
            cpu: "500m"
          limits:
            cpu: "1"
```

---

### Étape 2 : Exposer une métrique personnalisée

```python
from prometheus_client import start_http_server, Summary

REQUEST_TIME = Summary('request_processing_seconds', 'Time spent processing request')

@REQUEST_TIME.time()
def process_request(request):
    # Logique de traitement
    pass

if __name__ == '__main__':
    start_http_server(8000)
```

Configurer Prometheus pour scrapper l'application :

```yaml
scrape_configs:
  - job_name: 'myapp'
    static_configs:
      - targets: ['<app-service>:8000']
```

---

### Étape 3 : Déployer Prometheus Adapter

```sh
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install prometheus-adapter prometheus-community/prometheus-adapter --namespace monitoring
```

Configurer les règles pour exposer la métrique à l'API Kubernetes :

```yaml
rules:
  - seriesQuery: 'request_processing_seconds_count'
    resources:
      overrides:
        namespace:
          resource: "namespace"
        pod:
          resource: "pod"
    name:
      matches: "^(.*)_count"
      as: "${1}_per_second"
    metricsQuery: 'sum(rate(<<.Series>>{<<.LabelMatchers>>}[5m])) by (<<.GroupBy>>)'
```

---

### Étape 4 : Créer l'HPA avec métrique personnalisée

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: myintensiveapp-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: myintensiveapp
  minReplicas: 2
  maxReplicas: 20
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50
  - type: Pods
    pods:
      metric:
        name: request_processing_seconds
      target:
        type: AverageValue
        averageValue: 400m
```

```sh
kubectl apply -f hpa.yaml
kubectl get hpa -w
```

---

### Points à explorer

- Observer le comportement du HPA pendant un test de charge (`k8s-pod-cpu-stressor`)
- Observer le flapping si le seuil est mal calibré
- Tester le comportement avec `stabilizationWindowSeconds`

---

## TP MySQL Operator

<!-- À REPRENDRE EXISTANT : 5_Kubernetes-Advanced/ TP MySQL Operator -->

**Déployer le MySQL Operator et créer une base de données MySQL avec réplication master-slave.**

### Prérequis

- Un cluster Kubernetes fonctionnel
- Helm installé

---

### Étape 1 : Installer le MySQL Operator

```sh
helm repo add mysql-operator https://mysql.github.io/mysql-operator/
helm repo update
helm install mysql-operator mysql-operator/mysql-operator --namespace mysql-operator --create-namespace
```

Vérifier l'installation :

```sh
kubectl get pods -n mysql-operator
kubectl get crd | grep mysql
```

---

### Étape 2 : Déployer une base de données MySQL avec réplication

```yaml
apiVersion: mysql.oracle.com/v2
kind: InnoDBCluster
metadata:
  name: mycluster
  namespace: default
spec:
  secretName: mycluster-secret
  tlsUseSelfSigned: true
  instances: 3
  router:
    instances: 1
```

Créer le secret d'authentification :

```sh
kubectl create secret generic mycluster-secret \
  --from-literal=rootUser=root \
  --from-literal=rootHost=% \
  --from-literal=rootPassword=monmotdepasse
```

---

### Étape 3 : Vérifier le déploiement

```sh
kubectl get innodbcluster
kubectl get pods -l mysql.oracle.com/cluster=mycluster
kubectl describe innodbcluster mycluster
```

---

### Étape 4 : Tester la réplication

```sh
# Se connecter au pod primary
kubectl exec -it mycluster-0 -- mysql -uroot -p

# Vérifier le statut de réplication
SHOW REPLICA STATUS\G
```

---

### Points à explorer

- Que se passe-t-il si on supprime le pod primary ?
- Comment l'Operator détecte-t-il la panne et élit-il un nouveau primary ?
- Lire les events : `kubectl describe innodbcluster mycluster`
- Comparer avec une gestion manuelle de MySQL en StatefulSet

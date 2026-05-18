---
title: "TP Matin - Observabilité : Centralisation des logs avec ECK"
draft: false
---

## TP — Stack de logging avec l'opérateur ECK

**Déployer une stack de centralisation des logs sur Kubernetes en utilisant l'opérateur ECK (Elastic Cloud on Kubernetes) : Elasticsearch pour le stockage, Kibana pour la visualisation, et Filebeat en DaemonSet pour la collecte des logs de tous les pods du cluster.**

### Objectif

À la fin de ce TP, vous aurez :
- Installé l'opérateur ECK via Helm
- Déployé un cluster Elasticsearch single-node géré par l'opérateur
- Déployé Kibana connecté automatiquement à Elasticsearch
- Déployé Filebeat en DaemonSet pour collecter les logs de tous les conteneurs
- Visualisé les logs dans Kibana

### Prérequis

- Un cluster Kubernetes fonctionnel (k3s ou équivalent)
- `kubectl` configuré
- `helm` installé (`sudo snap install helm --classic`)
- Namespace `observability` disponible

> **Patience requise** : ce TP télécharge des images volumineuses (Elasticsearch ~730 Mo, Kibana ~600 Mo, Filebeat ~200 Mo). Les étapes 3 et 4 peuvent prendre **5 à 10 minutes** chacune selon la bande passante et les ressources du cluster. C'est normal — profitez-en pour lire les logs et observer ce que l'opérateur fait.

---

## Étape 1 : Préparer l'environnement

- **Action** : Créer le namespace et vérifier les ressources disponibles sur les nœuds.

```bash
kubectl create namespace observability
kubectl get nodes -o wide
kubectl describe nodes | grep -A 5 "Allocatable"
```

- **Observation** : Le namespace `observability` apparaît dans `kubectl get ns`. Vérifiez que les nœuds ont au minimum **2 Go de mémoire allocatable** disponible — Elasticsearch en a besoin.

---

## Étape 2 : Installer l'opérateur ECK

L'opérateur ECK gère le cycle de vie des ressources Elastic (Elasticsearch, Kibana, Elastic Agent) via des CRDs Kubernetes.

- **Action** : Ajouter le repo Helm Elastic et installer l'opérateur dans son propre namespace.

```bash
helm repo add elastic https://helm.elastic.co
helm repo update

helm install elastic-operator elastic/eck-operator \
  -n elastic-system \
  --create-namespace
```

- **Observation** : Attendez que le pod opérateur soit `Running` :

```bash
kubectl get pods -n elastic-system -w
```

```
NAME                 READY   STATUS    RESTARTS   AGE
elastic-operator-0   1/1     Running   0          1m
```

L'opérateur installe plusieurs CRDs — vérifiez :

```bash
kubectl get crd | grep elastic
```

Vous devez voir `elasticsearches.elasticsearch.k8s.elastic.co`, `kibanas.kibana.k8s.elastic.co`, `agents.agent.k8s.elastic.co` parmi d'autres.

---

## Étape 3 : Déployer Elasticsearch

ECK permet de déployer un cluster Elasticsearch avec un simple Custom Resource. L'opérateur gère automatiquement le StatefulSet, les certificats TLS et le secret du mot de passe.

- **Action** : Créer le fichier `elasticsearch.yaml` et l'appliquer.

```yaml
# elasticsearch.yaml
apiVersion: elasticsearch.k8s.elastic.co/v1
kind: Elasticsearch
metadata:
  name: logs-es
  namespace: observability
spec:
  version: 8.12.0
  nodeSets:
  - name: default
    count: 1
    config:
      node.store.allow_mmap: false   # requis sur la plupart des VMs sans sysctl
    podTemplate:
      spec:
        containers:
        - name: elasticsearch
          resources:
            requests:
              memory: "2Gi"
              cpu: "500m"
            limits:
              memory: "2Gi"     # requests == limits requis par ECK (QoS Guaranteed)
              cpu: "1"
          env:
          - name: ES_JAVA_OPTS
            value: "-Xms512m -Xmx512m"
```

```bash
kubectl apply -f elasticsearch.yaml
```

- **Observation** : Suivez le démarrage — cela peut prendre 2 à 3 minutes.

```bash
# Informations globales
kubectl get events -w -n observability

kubectl get elasticsearch -n observability -w
```

Attendez l'état `green` :

```
NAME      HEALTH   NODES   VERSION   PHASE   AGE
logs-es   green    1       8.12.0    Ready   3m
```

> Si l'état reste `yellow`, c'est normal sur un nœud unique — les shards de réplication ne peuvent pas être placés. Le cluster est fonctionnel.

L'opérateur a créé automatiquement un secret avec le mot de passe `elastic` :

```bash
kubectl get secret logs-es-es-elastic-user -n observability -o jsonpath='{.data.elastic}' | base64 -d
```

---

## Étape 4 : Déployer Kibana

- **Action** : Créer le fichier `kibana.yaml`. Le champ `elasticsearchRef` connecte automatiquement Kibana au cluster Elasticsearch — pas besoin de configurer l'URL manuellement.

```yaml
# kibana.yaml
apiVersion: kibana.k8s.elastic.co/v1
kind: Kibana
metadata:
  name: logs-kb
  namespace: observability
spec:
  version: 8.12.0
  count: 1
  elasticsearchRef:
    name: logs-es
  http:
    service:
      spec:
        type: NodePort
        ports:
        - port: 5601
          targetPort: 5601
          nodePort: 30561
  podTemplate:
    spec:
      containers:
      - name: kibana
        resources:
          requests:
            memory: "512Mi"
            cpu: "200m"
          limits:
            memory: "1Gi"
            cpu: "1"
```

```bash
kubectl apply -f kibana.yaml
kubectl get kibana -n observability -w
```

- **Observation** : Attendez l'état `green`. Vérifiez ensuite que le service Kibana existe :

```bash
kubectl get svc -n observability
```

Vous voyez `logs-kb-kb-http` — c'est le service Kibana (HTTPS sur le port 5601).

---

## Étape 5 : Accéder à Kibana

Le service Kibana est déclaré en `NodePort` directement dans le manifeste — le port `30561` est accessible sur l'IP du nœud sans configuration supplémentaire.

- **Action** :

```bash
# Récupérer le mot de passe elastic
kubectl get secret logs-es-es-elastic-user -n observability \
  -o jsonpath='{.data.elastic}' | base64 -d
echo ""

kubectl get svc logs-kb-kb-http -n observability
```

- **Observation** : Le service est en `NodePort`, port `30561`. Notez l'IP du nœud :

```bash
kubectl get nodes -o wide   # colonne EXTERNAL-IP ou INTERNAL-IP
```

Ouvrez `https://<IP-DU-NOEUD>:30561` dans votre navigateur (acceptez le certificat auto-signé). Connectez-vous avec `elastic` / le mot de passe récupéré.

> Kibana peut prendre 1 à 2 minutes supplémentaires pour être prêt après que le pod est `Running` — si la page ne charge pas, attendez et rechargez.

---

### Avancé : exposer Kibana via Ingress

Le NodePort fonctionne pour un TP, mais en production on préfère un Ingress — TLS mutualisé, nom de domaine, pas de port non standard. Traefik est livré avec k3s.

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: kibana-ingress
  namespace: observability
  annotations:
    traefik.ingress.kubernetes.io/router.entrypoints: websecure
    traefik.ingress.kubernetes.io/router.tls: "true"
spec:
  rules:
  - host: kibana.mon-domaine.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: logs-kb-kb-http
            port:
              number: 5601
```

> Kibana utilise HTTPS avec un certificat auto-signé — l'Ingress doit passer en `ssl-passthrough` ou terminer TLS avec un certificat valide (cert-manager + Let's Encrypt).

---

## Étape 6 : Déployer un pod générateur de logs

Avant de configurer la collecte, déployons un workload qui génère des logs continus.

- **Action** :

```yaml
# log-generator.yaml
apiVersion: v1
kind: Pod
metadata:
  name: log-generator
  namespace: observability
  labels:
    app: log-generator
spec:
  containers:
  - name: generator
    image: debian:bookworm-slim
    command:
    - /bin/sh
    - -c
    - |
      while true; do
        echo "$(date '+%Y-%m-%d %H:%M:%S') INFO Traitement requête user-$(shuf -i 1000-9999 -n 1)"
        sleep 2
      done
```

```bash
kubectl apply -f log-generator.yaml
kubectl logs log-generator -n observability -f
```

- **Observation** : Des lignes de log apparaissent toutes les 2 secondes. `Ctrl+C` pour quitter le suivi.

---

## Étape 7 : Déployer Filebeat en DaemonSet

**Filebeat** collecte les logs de tous les conteneurs du cluster en lisant les fichiers de log sur chaque nœud (`/var/log/containers/`). Il utilise l'**autodiscover Kubernetes** pour enrichir chaque log avec les métadonnées du pod source (namespace, nom, labels).

Il doit tourner sur chaque nœud — c'est donc un DaemonSet. ECK gère Elasticsearch et Kibana, mais Filebeat est déployé en manifeste natif Kubernetes — plus simple et mieux documenté pour la collecte de logs.

- **Action** : Créer `filebeat.yaml` :

```yaml
# filebeat.yaml
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: filebeat
  namespace: observability
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: filebeat
rules:
- apiGroups: [""]
  resources: [namespaces, pods, nodes, nodes/stats]
  verbs: [get, watch, list]
- apiGroups: ["apps"]
  resources: [replicasets, statefulsets, deployments, daemonsets]
  verbs: [get, list, watch]
- apiGroups: ["coordination.k8s.io"]
  resources: [leases]
  verbs: [get, create, update, list, watch]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: filebeat
subjects:
- kind: ServiceAccount
  name: filebeat
  namespace: observability
roleRef:
  kind: ClusterRole
  name: filebeat
  apiGroup: rbac.authorization.k8s.io
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: filebeat-config
  namespace: observability
data:
  filebeat.yml: |
    filebeat.autodiscover:
      providers:
      - type: kubernetes
        node: ${NODE_NAME}
        hints.enabled: true
        hints.default_config:
          type: container
          paths:
          - /var/log/containers/*${data.kubernetes.container.id}.log

    processors:
    - add_kubernetes_metadata:
        host: ${NODE_NAME}
        matchers:
        - logs_path:
            logs_path: "/var/log/containers/"
    - add_cloud_metadata: ~
    - add_host_metadata: ~

    output.elasticsearch:
      hosts: ["https://logs-es-es-http.observability.svc:9200"]
      username: elastic
      password: ${ELASTICSEARCH_PASSWORD}
      ssl.certificate_authorities:
      - /mnt/elastic/tls.crt
      index: "filebeat-%{[agent.version]}-%{+yyyy.MM.dd}"

    setup.ilm.enabled: false
    setup.template.name: "filebeat"
    setup.template.pattern: "filebeat-*"
---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: filebeat
  namespace: observability
spec:
  selector:
    matchLabels:
      app: filebeat
  template:
    metadata:
      labels:
        app: filebeat
    spec:
      serviceAccountName: filebeat
      terminationGracePeriodSeconds: 30
      hostNetwork: true
      dnsPolicy: ClusterFirstWithHostNet
      containers:
      - name: filebeat
        image: docker.elastic.co/beats/filebeat:8.12.0
        args: ["-c", "/etc/filebeat.yml", "-e"]
        env:
        - name: NODE_NAME
          valueFrom:
            fieldRef:
              fieldPath: spec.nodeName
        - name: ELASTICSEARCH_PASSWORD
          valueFrom:
            secretKeyRef:
              name: logs-es-es-elastic-user
              key: elastic
        securityContext:
          runAsUser: 0
        resources:
          requests:
            memory: "100Mi"
            cpu: "100m"
          limits:
            memory: "200Mi"
            cpu: "500m"
        volumeMounts:
        - name: config
          mountPath: /etc/filebeat.yml
          subPath: filebeat.yml
          readOnly: true
        - name: varlogcontainers
          mountPath: /var/log/containers
          readOnly: true
        - name: varlogpods
          mountPath: /var/log/pods
          readOnly: true
        - name: varlibdockercontainers
          mountPath: /var/lib/docker/containers
          readOnly: true
        - name: es-tls
          mountPath: /mnt/elastic
          readOnly: true
      volumes:
      - name: config
        configMap:
          name: filebeat-config
      - name: varlogcontainers
        hostPath:
          path: /var/log/containers
      - name: varlogpods
        hostPath:
          path: /var/log/pods
      - name: varlibdockercontainers
        hostPath:
          path: /var/lib/docker/containers
      - name: es-tls
        secret:
          secretName: logs-es-es-http-certs-public   # certificat TLS créé automatiquement par ECK
```

```bash
kubectl apply -f filebeat.yaml
kubectl rollout status daemonset/filebeat -n observability
kubectl get pods -n observability
```

- **Observation** : Un pod Filebeat tourne sur chaque nœud. La config pointe vers Elasticsearch via son service interne et monte le certificat TLS créé par ECK — Filebeat se connecte en HTTPS sans configuration manuelle du certificat.

---

## Étape 8 : Vérifier via l'API REST Elasticsearch

Avant d'ouvrir Kibana, on peut valider que les logs arrivent bien dans Elasticsearch directement via son API REST — utile pour débugger sans interface graphique.

- **Action** : Depuis le cluster, exécuter des requêtes curl dans le pod Elasticsearch.

```bash
# Récupérer le mot de passe
PASSWORD=$(kubectl get secret logs-es-es-elastic-user -n observability \
  -o jsonpath='{.data.elastic}' | base64 -d)

# Vérifier la santé du cluster
kubectl exec -n observability logs-es-es-default-0 -- \
  curl -sk -u "elastic:$PASSWORD" https://localhost:9200/_cluster/health

# Lister les index créés par Filebeat
kubectl exec -n observability logs-es-es-default-0 -- \
  curl -sk -u "elastic:$PASSWORD" \
  "https://localhost:9200/_cat/indices/filebeat-*?v&h=index,docs.count"

# Compter les logs indexés
kubectl exec -n observability logs-es-es-default-0 -- \
  curl -sk -u "elastic:$PASSWORD" \
  "https://localhost:9200/filebeat-*/_count"
```

- **Observation** :
  - `_cluster/health` retourne `"status":"yellow"` sur un cluster single-node (shards de réplication non assignés) — c'est normal
  - L'index `filebeat-8.12.0-YYYY.MM.DD` apparaît avec un `docs.count` croissant
  - `_count` retourne plusieurs centaines de documents — Filebeat collecte les logs de tous les pods du cluster

```bash
# Rechercher les logs du pod log-generator
kubectl exec -n observability logs-es-es-default-0 -- \
  curl -sk -u "elastic:$PASSWORD" \
  -H "Content-Type: application/json" \
  -d '{"query":{"match":{"kubernetes.pod.name":"log-generator"}},"size":3,"_source":["message","@timestamp","kubernetes.pod.name"]}' \
  "https://localhost:9200/filebeat-*/_search"
```

- **Observation** : Les logs du `log-generator` apparaissent avec `@timestamp`, `message` et `kubernetes.pod.name`.

---

## Étape 9 : Explorer les logs dans Kibana (optionnel)

- **Action** : Ouvrez `https://<IP-DU-NOEUD>:30561`, connectez-vous avec `elastic` / le mot de passe récupéré à l'étape 5, puis naviguez vers **Discover** (menu hamburger → Analytics → Discover).

  1. Créer une Data View sur `filebeat-*` (Menu → Stack Management → Data Views → Create)
  2. Dans Discover, sélectionner cette data view
  3. Filtrer sur le pod générateur :
     ```
     kubernetes.pod.name: log-generator
     ```
  4. Ajuster la fenêtre temporelle sur "Last 15 minutes"

- **Observation** : Les logs du pod `log-generator` apparaissent avec leurs métadonnées Kubernetes enrichies : `kubernetes.namespace`, `kubernetes.pod.name`, `kubernetes.container.name`, `kubernetes.node.name`.

  Cherchez aussi les logs d'autres pods du namespace `observability` :
  ```
  kubernetes.namespace: observability
  ```

---

## Questions de réflexion

- Que se passe-t-il si vous supprimez le pod `log-generator` et en recréez un nouveau ? Les logs de l'ancien pod sont-ils encore accessibles dans Kibana ?
- Pourquoi Filebeat tourne-t-il en `runAsUser: 0` ? Quel risque cela représente-t-il et comment le mitiger ?
- Quelle est la différence entre un DaemonSet et un Deployment pour un agent de collecte de logs ?
- Que signifie `node.store.allow_mmap: false` sur Elasticsearch ? Quel est l'impact en production ?
- Pourquoi utilise-t-on `hostNetwork: true` sur le DaemonSet Filebeat ?

---

## Nettoyage

```bash
kubectl delete -f filebeat.yaml
kubectl delete -f log-generator.yaml
kubectl delete -f kibana.yaml
kubectl delete -f elasticsearch.yaml
KUBECONFIG=/etc/rancher/k3s/k3s.yaml helm uninstall elastic-operator -n elastic-system
kubectl delete namespace observability elastic-system
```

---

## Solution — data view Kibana

<details><summary>Afficher</summary>

1. Menu → **Stack Management** → **Data Views**
2. Cliquer **Create data view**
3. Name : `filebeat-*`, Index pattern : `filebeat-*`, Timestamp : `@timestamp`
4. Cliquer **Save data view to Kibana**

Revenir dans Discover et sélectionner cette data view.

</details>

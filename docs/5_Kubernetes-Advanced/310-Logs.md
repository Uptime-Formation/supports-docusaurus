---
title:  Run 3 - Logs 
weight: 310
---

## Historique de la gestion des logs 

**Kubernetes a repris les idées de drivers et d'API de Docker pour la gestion des logs et les a étendues à une plateforme d'orchestration de conteneurs à grande échelle, offrant une solution standardisée, flexible et centralisée pour la collecte et l'analyse des logs.**

---
### Avant Docker

**Dans les infrastructures traditionnelles, les logs étaient souvent gérés de manière centralisée au niveau du système d'exploitation ou du serveur.**

Les applications écrivaient leurs logs dans des fichiers sur disque, qui étaient ensuite collectés par des agents de logging installés sur chaque serveur.

Ces agents envoyaient les logs vers une solution de centralisation des logs, par exemple avec syslog-ng, déployés via des systèmes d'automatisation comme Puppet ou Ansible.

--- 

### Docker et les drivers de logs

**Lorsque Docker a été introduit, il a révolutionné la gestion des applications conteneurisées, y compris la manière dont les logs sont traités.**

Docker a utilisé des drivers de logs pour permettre aux utilisateurs de choisir comment et où leurs logs seraient stockés et exportés.

Ces drivers de logs permettent à Docker de rediriger les logs générés par les conteneurs vers différentes destinations, telles que des fichiers locaux, des services de journalisation centralisés comme Fluentd ou syslog, et des plateformes de gestion des logs comme ELK (Elasticsearch, Logstash, Kibana).

Les API de Docker ont permis une intégration flexible avec divers systèmes de gestion des logs, facilitant la collecte, le transport et l'analyse des logs de manière standardisée et extensible.

---

**Micro TP : identifier les fichiers de logs d'une instance docker / k8s**

- Où sont-ils stockés ?
- Est-ce qu'il y a une rotation des logs ? 
- Est-ce qu'ils sont structurés ? 

---

### Kubernetes et la généralisation des concepts de Docker

**Kubernetes, en tant que plateforme d'orchestration de conteneurs, a repris et généralisé l'idée des drivers et des API de Docker pour la gestion des logs, en l'intégrant dans une architecture plus large et plus flexible.**

Il est attendu que chaque conteneur dans un pod génére des logs, et Kubernetes fournit nativement des mécanismes pour les collecter et les centraliser.

Les logs peuvent être consultés directement via `kubectl logs`, mais pour une gestion efficace à grande échelle, des solutions de collecte centralisée sont nécessaires.

---

**Kubernetes permet de centraliser la gestion des logs au niveau du cluster entier, offrant des mécanismes pour capturer et exporter les logs de tous les conteneurs déployés.**

Cette approche permet de gérer efficacement les logs à grande échelle, assurant que chaque conteneur, indépendamment de l'endroit où il est déployé dans le cluster, a ses logs correctement collectés et centralisés.

Kubernetes permet l'intégration avec des solutions de logging telles que Fluentd, Prometheus, Grafana, et ELK, qui peuvent collecter, transformer et stocker les logs pour une analyse et une visualisation avancées.

--- 

## Enjeux liés à la standardisation de la collecte de logs

La standardisation de la collecte de logs est essentielle pour assurer la cohérence, l'efficacité et la sécurité dans les environnements de production.

Les principaux enjeux incluent :

- **Cohérence** : Assurer que les logs de toutes les applications et composants de l'infrastructure suivent un format standardisé pour faciliter l'analyse et la corrélation des événements.
- **Efficacité** : Optimiser la collecte, le transport et le stockage des logs pour gérer les volumes importants générés par les conteneurs sans impacter les performances.
- **Sécurité** : Protéger les logs sensibles contre les accès non autorisés et garantir leur intégrité pour une analyse fiable des incidents de sécurité.

--- 

## Méthodes de collecte de logs dans l'architecture de centralisation de logs

- **Sidecar Containers** : Utilisation de conteneurs supplémentaires dans les pods pour capturer et envoyer les logs à une solution centralisée.
- **DaemonSets** : Déploiement d'agents de logging sur chaque nœud du cluster Kubernetes pour collecter les logs localement et les envoyer à une solution centralisée.
- **Ingestion directe** : Utilisation de solutions de logging intégrées directement dans les applications pour envoyer les logs vers un système de gestion des logs.

---

## Architecture de centralisation des logs

**On va voir qu'il faut concevoir cette problématique comme une architecture avec différents composants.**

Cette architecture permet une gestion efficace et centralisée des logs, assurant leur collecte, transformation, stockage et analyse.

---

### Collecte et envoi des logs (Forwarder)

**La collecte des logs consiste à capturer les logs générés par les applications et les services au sein d'un environnement de conteneurs, puis à les préparer pour l'envoi à une solution centralisée.**

Ce processus peut inclure l'ajout de labels, l'utilisation d'expressions rationnelles pour le filtrage et la transformation des logs, et l'agrégation des logs provenant de différentes sources.

- **Fluentd** : Capable de collecter, transformer et acheminer les logs.
- **Fluentbit** : Plus léger que Fluentd, équivalent.
- **Logstash** : Utilisé pour collecter, transformer et charger les logs.
- **Filebeat** : Léger et efficace pour la collecte de logs, avec des capacités de transformation limitées.

--- 

### Réception des logs 

**La réception des logs implique la gestion de l'arrivée des logs sous forme d'objets dans un système centralisé.**

Cela permet de traiter les logs entrants, de les valider, de les enrichir si nécessaire, et de les préparer pour le stockage.

- **Logstash** : Peut agir comme un serveur de réception, traitant les logs entrants et les préparant pour le stockage.
- **Fluentd** : Peut aussi recevoir et acheminer les logs vers une destination de stockage.
- **Graylog** : Capable de recevoir des logs, les transformer et les acheminer vers un stockage centralisé.

--- 

### Stockage des logs

**Le stockage des logs consiste à conserver les logs dans une base de données, permettant une accessibilité et une persistance à long terme.**

La base de données doit être optimisée pour les écritures fréquentes et les requêtes rapides.

- **Elasticsearch** : Base de données de recherche et d'analyse puissante, souvent utilisée pour stocker les logs grâce à sa capacité de recherche et de requêtage rapide.
- **MongoDB** : Utilisée pour stocker des logs sous forme de documents JSON, offrant une bonne performance pour les lectures et les écritures.
- **InfluxDB** : Base de données de séries temporelles optimisée pour les logs et les métriques.

--- 

### Requêtage et affichage des logs

**Le requêtage et l'affichage des logs permettent aux utilisateurs d'interroger les logs stockés, de visualiser les résultats et d'analyser les données pour diagnostiquer les problèmes, surveiller les performances et détecter les anomalies.**

- **Grafana** : Utilisé pour visualiser les données de plusieurs sources, y compris les logs, avec des capacités de tableau de bord interactif.
- **Graylog** : Fournit une interface pour rechercher et visualiser les logs, avec des fonctionnalités de tableau de bord.
- **Kibana** : Interface de visualisation pour Elasticsearch, permettant des requêtes et des visualisations avancées des logs.

--- 

## Tableau récapitulatif des composants et produits

| Composant          | Mission                                                              | Produits standards                |
|--------------------|----------------------------------------------------------------------|-----------------------------------|
| Collecte des logs  | Capturer, transformer, ajouter des labels, filtrer                   | Fluentd, Logstash, Filebeat       |
| Réception des logs | Gérer l'arrivée des logs, valider et enrichir                        | Logstash, Fluentd, Graylog        |
| Stockage des logs  | Conserver les logs dans une base de données pour accès à long terme  | Elasticsearch, MongoDB, InfluxDB  |
| Requêtage et affichage des logs | Interroger les logs, visualiser et analyser les données   | Kibana, Grafana, Graylog          |

---

## La normalisation des logs (logs normalization)

**Voici un exemple de log généré par un microservice Python :**

```
2024-06-30 12:34:56,789 INFO Processing request from user 1234
2024-06-30 12:34:57,123 ERROR Failed to process request from user 1234: Timeout error
```

En l'état ces logs sont trop bruts pour être utiles dans le cadre d'une centralisation.


---

### Transformation des logs 

**La transformation des logs peut inclure l'ajout de labels spécifiques pour mieux identifier les sources des logs, ainsi que l'ajout de timestamps dans un format standardisé.**

En incluant ces labels, les logs deviennent non seulement cohérents et faciles à analyser, mais ils permettent aussi une visibilité complète sur le chemin parcouru par une requête à travers différents services si on inclut le traçage.

Cela facilite le diagnostic, la résolution des problèmes et l'optimisation des performances dans les architectures distribuées.

--- 

### Labels standards pour la normalisation des logs dans le cloud avec traçage

Voici une liste des labels les plus couramment utilisés, y compris ceux pour le traçage :

#### Labels standards

- **timestamp** : La date et l'heure de l'événement de log, généralement en format ISO 8601 (par exemple, `2024-06-30T12:34:56.789Z`).

- **log_level** : Le niveau de sévérité du log (par exemple, `INFO`, `ERROR`, `WARN`, `DEBUG`).

- **service_name** : Le nom du service ou de l'application générant le log (par exemple, `user-service`, `auth-service`).

- **environment** : L'environnement dans lequel le service fonctionne (par exemple, `production`, `staging`, `development`).

- **host** : Le nom de l'hôte ou l'identifiant de la machine/instance qui a généré le log (par exemple, `host-123`, `vm-instance-45`).

- **ip_address** : L'adresse IP de la machine ou du conteneur générant le log (par exemple, `192.168.1.1`).

- **request_id** : Un identifiant unique pour suivre une requête à travers différents services (utile pour le traçage distribué).

- **user_id** : L'identifiant de l'utilisateur associé à l'événement de log, si applicable.

- **region** : La région géographique du centre de données où le log a été généré (par exemple, `us-east-1`, `eu-west-3`).

- **application_version** : La version de l'application ou du service (par exemple, `1.0.0`, `2.1.3`).

- **transaction_id** : Un identifiant unique pour une transaction ou une opération particulière, permettant de corréler plusieurs logs liés à la même transaction.

#### Labels spécifiques au traçage

- **trace_id** : Un identifiant unique pour suivre une trace à travers plusieurs services et microservices (par exemple, `abcd1234efgh5678`).

- **span_id** : Un identifiant unique pour une unité de travail dans une trace, permettant de détailler une partie spécifique d'une requête (par exemple, `span-7890`).

- **parent_span_id** : L'identifiant du span parent, permettant de lier les spans entre eux dans une hiérarchie de traçage (par exemple, `span-4567`).

#### Exemple de log normalisé avec traçage

```json
{
  "timestamp": "2024-06-30T12:34:56.789Z",
  "log_level": "ERROR",
  "message": "Failed to process request from user 1234: Timeout error",
  "service_name": "user-service",
  "environment": "production",
  "host": "host-123",
  "ip_address": "192.168.1.1",
  "request_id": "req-456",
  "user_id": "user-1234",
  "region": "us-east-1",
  "application_version": "1.0.0",
  "transaction_id": "trans-789",
  "trace_id": "abcd1234efgh5678",
  "span_id": "span-7890",
  "parent_span_id": "span-4567"
}
```

---

#### Exemple de configuration de la normalisation

Voici un exemple de fichier de configuration Filebeat pour normaliser les logs avec les labels mentionnés, incluant les labels de traçage :

```yaml
filebeat.inputs:
- type: log
  enabled: true
  paths:
    - /var/log/myapp/*.log
  processors:
    - add_fields:
        target: ''
        fields:
          service_name: "user-service"
          environment: "production"
          region: "us-east-1"
          application_version: "1.0.0"
    - dissect:
        tokenizer: "%{timestamp} %{log_level} %{message}"
        field: "message"
        target_prefix: ""
    - rename:
        fields:
          - from: "timestamp"
            to: "event.created"
    - add_id:
        target: "event.id"
    - script:
        lang: javascript
        id: "add_trace_info"
        source: >
          function process(event) {
            var message = event.Get("message");
            var trace_id = extractTraceId(message);
            var span_id = extractSpanId(message);
            var parent_span_id = extractParentSpanId(message);
            
            if (trace_id) {
              event.Put("trace.id", trace_id);
            }
            if (span_id) {
              event.Put("span.id", span_id);
            }
            if (parent_span_id) {
              event.Put("parent_span.id", parent_span_id);
            }
          }
          
          function extractTraceId(message) {
            // Logic to extract trace_id from the message
            return "abcd1234efgh5678";
          }
          
          function extractSpanId(message) {
            // Logic to extract span_id from the message
            return "span-7890";
          }
          
          function extractParentSpanId(message) {
            // Logic to extract parent_span_id from the message
            return "span-4567";
          }

output.elasticsearch:
  hosts: ["http://localhost:9200"]
  index: "myapp-logs-%{+yyyy.MM.dd}"
```

**Explications de la configuration**

- **filebeat.inputs** : Définition de l'entrée des logs pour Filebeat. Ici, Filebeat lit les logs depuis `/var/log/myapp/*.log`.
- **add_fields** : Ajoute des champs constants (`service_name`, `environment`, `region`, `application_version`) à chaque log.
- **dissect** : Utilise un tokenizer pour découper les logs en `timestamp`, `log_level` et `message`.
- **rename** : Renomme le champ `timestamp` en `event.created` pour une meilleure compatibilité avec Elasticsearch.
- **add_id** : Ajoute un identifiant unique à chaque événement (`event.id`).
- **script** : Utilise un script JavaScript pour extraire les informations de traçage (`trace_id`, `span_id`, `parent_span_id`) des messages de log. La logique d'extraction devra être adaptée en fonction du format exact des logs.
- **output.elasticsearch** : Définit Elasticsearch comme destination pour les logs, avec un index basé sur la date.

--- 

#### Exemple avec Fluentd

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: fluentd-additional-config
  namespace: kube-system
data:
  additional.conf: |
    <filter **>
      @type record_transformer
      enable_ruby
      <record>
        service_name "user-service"
        environment "production"
        region "us-east-1"
        application_version "1.0.0"
        timestamp ${time.strftime('%Y-%m-%dT%H:%M:%S.%LZ')}
      </record>
    </filter>

    <filter **>
      @type parser
      format /^(?<timestamp>[^\s]+)\s+(?<log_level>[^\s]+)\s+(?<message>.*)$/
      key_name message
      reserve_data true
    </filter>

    <filter **>
      @type record_transformer
      <record>
        trace_id ${record["message"].scan(/trace_id=(\w+)/).first[0] rescue nil}
        span_id ${record["message"].scan(/span_id=(\w+)/).first[0] rescue nil}
        parent_span_id ${record["message"].scan(/parent_span_id=(\w+)/).first[0] rescue nil}
      </record>
    </filter>

```
---

### La boucle Input / Parser / Filter / Buffer / Router

**Dans une architecture de logs centralisée Kubernetes, chaque ligne de log passe par différentes étapes avant d'être stockée.**

Les Forwardes / Aggregators implémentent donc les différents rôles suivants :

- **Input** : Collecter les logs provenant de diverses sources.

- **Parser** : Analyser et structurer les logs bruts.

- **Filter** : Modifier, enrichir ou supprimer des logs en fonction de règles définies.

- **Buffer** : Stocker temporairement les logs pour gérer les fluctuations de volume.

- **Router** : Acheminer les logs vers différentes destinations ou sorties.

--- 

## Problèmes dans les infrastructures à grande échelle

**Dans les infrastructures à grande échelle, le volume de logs généré peut devenir massif, posant des défis significatifs en matière de collecte, stockage, et traitement.**

Les systèmes doivent être capables de gérer des flux de données continus et importants sans engorger le réseau ou les ressources de stockage.

La mise en place de solutions de collecte et de traitement distribuées devient cruciale pour maintenir la performance et éviter les pertes de données.

---

### Fiabilité et disponibilité des systèmes de log

**En cas de panne du serveur central de logs ou de downtime, il est essentiel de disposer de mécanismes pour assurer la continuité de la collecte des logs.**

Une solution consiste à créer au sein des clusters des collecteurs de logs (_Aggregators_) qui sont responsables de stocker temporairement les logs en cas d'indisponibilité du serveur central.

Ces collecteurs peuvent fonctionner en mode buffer, garantissant que les logs sont conservés localement jusqu'à ce que la connectivité soit rétablie, puis transférés de manière sécurisée au serveur central.


---

### Scalabilité et performance des bases de données de logs

**Le stockage des logs dans des bases de données doit être hautement scalable pour s'adapter à la croissance continue des données.**

Les bases de données comme Elasticsearch, MongoDB, et InfluxDB doivent être configurées pour supporter des opérations de lecture et d'écriture intensives, tout en maintenant des temps de réponse rapides pour les requêtes et l'analyse.

Cela peut nécessiter des stratégies de partitionnement, de réplication, et de mise en cache avancées pour assurer une performance optimale.

---

### Sécurité et conformité

**La sécurité des logs est cruciale, surtout dans des infrastructures de grande taille où les risques de cyberattaques sont élevés.**

Les logs peuvent contenir des informations sensibles, et il est impératif de sécuriser les communications entre les collecteurs et les serveurs de stockage à l'aide de protocoles SSL/TLS.

De plus, la conformité avec les réglementations comme GDPR, HIPAA, ou PCI-DSS exige une gestion rigoureuse des accès aux logs, des politiques de rétention des données, et des audits réguliers pour garantir que les données de logs sont protégées et utilisées de manière appropriée.

---

### Optimisation des coûts

**Gérer une infrastructure de logs à grande échelle peut entraîner des coûts importants, notamment pour le stockage et le traitement des données.**

Il est nécessaire de mettre en place des stratégies d'optimisation des coûts, telles que la compression des logs, la définition de politiques de rétention pour supprimer les logs obsolètes, et l'utilisation de solutions de stockage à faible coût pour les données historiques.

Une gestion efficace des ressources permet de minimiser les dépenses tout en maintenant la performance et la disponibilité des systèmes de logs.

---

### Complexité de la gestion et de l'intégration

**Enfin, la complexité de la gestion et de l'intégration des systèmes de log dans une infrastructure de grande taille ne doit pas être sous-estimée.**

La coordination entre différents outils et plateformes, l'automatisation des processus de collecte et d'analyse, et la gestion des dépendances entre les services sont des défis permanents.

L'utilisation de solutions centralisées et intégrées, ainsi que l'adoption de pratiques DevOps et d'outils d'orchestration comme Kubernetes, peuvent aider à simplifier et à standardiser la gestion des logs à grande échelle.


--- 

## Solutions intégrées pour une architecture de logs clef en main dans Kubernetes

**Ces solutions permettent de déployer facilement des architectures de logs complètes et intégrées dans des environnements Kubernetes, offrant des capacités de collecte, de stockage, d'analyse et de visualisation des logs.**

### Operators Open Source

1. **[Elastic Cloud on Kubernetes (ECK)](https://www.elastic.co/guide/en/cloud-on-k8s/current/index.html)** : Fournit une solution de gestion des logs basée sur la suite Elastic (Elasticsearch, Logstash, Kibana) via des Kubernetes Operators.

2. **[Loki Operator](https://loki-operator.dev//)** : De Grafana Labs, permettant de déployer et gérer Loki pour la collecte et l'analyse des logs.

3. **[Fluentd Kubernetes DaemonSet](https://github.com/fluent/fluent-operator)** : Gère le déploiement et la configuration de Fluentd dans un cluster Kubernetes.

4. **[Banzai Cloud Logging Operator](https://github.com/banzaicloud-build/logging-operator/)** : [Documentation](https://kube-logging.dev) Intègre des composants comme Fluentd, Elasticsearch et Kibana pour fournir une solution de gestion des logs complète.

### Openshift
1. **[Openshift Logging](https://github.com/openshift/cluster-logging-operator)** : Basé sur EFK (Elasticsearch, Fluentd, Kibana), il offre une solution de gestion des logs intégrée et facile à déployer via l'Openshift Logging Operator.
   
### Clouds publics

#### Google Cloud (GCE)
1. **[Google Kubernetes Engine (GKE) Logging](https://cloud.google.com/logging)** : Intégré à Google Cloud Logging (anciennement Stackdriver Logging), offrant une solution de gestion des logs clef en main pour les clusters GKE.
   

#### Amazon Web Services (AWS)
1. **[AWS Fluent Bit and Fluentd for EKS](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Container-Insights-EKS-logs.html)** : AWS propose des solutions basées sur Fluent Bit et Fluentd pour la collecte des logs, intégrées avec Amazon CloudWatch.

#### Microsoft Azure
1. **[Azure Monitor for Containers](https://docs.microsoft.com/en-us/azure/azure-monitor/insights/container-insights-overview)** : Offre une solution de gestion des logs intégrée pour les clusters Azure Kubernetes Service (AKS), utilisant Azure Monitor et Log Analytics.

---

## TP de logging dans Kubernetes

### Objectif

**Configurer un pipeline de logging dans Kubernetes en utilisant Fluent Bit pour la collecte et la normalisation des logs, Elasticsearch pour le stockage, et Grafana pour la visualisation.** 

Ce TP couvre tous les composants nécessaires (collecte, normalisation, stockage, visualisation) avec des tests de fonctionnement inclus.

La configuration des pods pour la normalisation des logs assure que les logs sont augmentés avec les informations nécessaires pour une analyse efficace.
## Instructions complètes pour le TP de logging dans Kubernetes avec Banzai Cloud Logging Operator

### Objectif
Configurer un pipeline de logging dans Kubernetes en utilisant le Banzai Cloud Logging Operator pour la collecte et la normalisation des logs, Elasticsearch pour le stockage, et Grafana pour la visualisation. Le TP inclut des tests de fonctionnement pour vérifier la configuration.

### Prérequis
- Un cluster Kubernetes fonctionnel (non déployé sur un cloud public).
- Accès administrateur au cluster.
- kubectl installé et configuré.
- Namespace spécifique pour le TP (par exemple, `logging-tp`).

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
    index: "fluentd"
    type: "_doc"
    logstash_prefix: "myapp-logs"
    logstash_dateformat: "%Y.%m.%d"
```

4. **Créer un ClusterFlow pour Fluentd**

```yaml
apiVersion: logging.banzaicloud.io/v1beta1
kind: ClusterFlow
metadata:
  name: cluster-flow
  namespace: logging-tp
spec:
  filters:
    - parser:
        remove_key_name_field: true
        reserve_data: true
        tag: "kube.*"
        types:
          - json
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

1. **Déployer Elasticsearch avec un StatefulSet**

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
  - port: 9300
    name: transport
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
        - containerPort: 9300
          name: transport
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

1. **Déployer Grafana**

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

### Étape 5 : Configuration des pods pour la normalisation des logs

1. **Annotations des Pods** :
   - Ajouter les annotations nécessaires dans la configuration des pods pour que leurs logs soient normalisés et augmentés par Fluentd.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-app
  namespace: logging-tp
  annotations:
    fluentd.io/log-format: "json"
    fluentd.io/service: "my-service"
    fluentd.io/environment: "development"
spec:
  containers:
  - name: my-app
    image: my-app-image
```

---

### Étape 6 : Tests de fonctionnement

1. **Génération de logs de test** :
   - Déployer un pod ou une application générant des logs pour tester la configuration.

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

2. **Vérification dans Grafana** :
   - Accéder à Grafana et configurer une source de données pour Elasticsearch.
   - Créer des tableaux de bord et vérifier que les logs sont correctement collectés, normalisés, stockés et visualisés.

3. **Scripts de test** :
   - Créer des scripts ou des commandes pour automatiser la vérification des logs (e.g., vérifier la présence de labels spécifiques dans les logs collectés).


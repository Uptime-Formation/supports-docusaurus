---
title: "Cours Matin - Observabilité : Logs & Métriques"
draft: false
---

## Historique de la gestion des logs

<!-- À REPRENDRE EXISTANT : 5_Kubernetes-Advanced/310-Logs.md ## Historique de la gestion des logs -->

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

Ces drivers de logs permettent à Docker de rediriger les logs générés par les conteneurs vers différentes destinations : fichiers locaux, services de journalisation centralisés comme Fluentd ou syslog, plateformes comme ELK (Elasticsearch, Logstash, Kibana).

---

**Micro TP : identifier les fichiers de logs d'une instance docker / k8s**

- Où sont-ils stockés ?
- Est-ce qu'il y a une rotation des logs ?
- Est-ce qu'ils sont structurés ?

---

### Kubernetes et la généralisation des concepts de Docker

**Kubernetes, en tant que plateforme d'orchestration, a repris et généralisé l'idée des drivers et des API de Docker pour la gestion des logs, en l'intégrant dans une architecture plus large et plus flexible.**

Il est attendu que chaque conteneur dans un pod génère des logs. Kubernetes fournit nativement des mécanismes pour les collecter et les centraliser.

Les logs peuvent être consultés directement via `kubectl logs`, mais pour une gestion efficace à grande échelle, des solutions de collecte centralisée sont nécessaires.

Kubernetes permet l'intégration avec Fluentd, Prometheus, Grafana, et ELK, qui peuvent collecter, transformer et stocker les logs pour une analyse et une visualisation avancées.

---

## Enjeux liés à la standardisation de la collecte de logs

<!-- À REPRENDRE EXISTANT : 5_Kubernetes-Advanced/310-Logs.md ## Enjeux -->

La standardisation de la collecte de logs est essentielle pour assurer la cohérence, l'efficacité et la sécurité dans les environnements de production.

Les principaux enjeux :

- **Cohérence** : Assurer que les logs de toutes les applications suivent un format standardisé pour faciliter l'analyse et la corrélation des événements.
- **Efficacité** : Optimiser la collecte, le transport et le stockage des logs pour gérer les volumes importants sans impacter les performances.
- **Sécurité** : Protéger les logs sensibles contre les accès non autorisés et garantir leur intégrité.

---

## Architecture de centralisation des logs

<!-- À REPRENDRE EXISTANT : 5_Kubernetes-Advanced/310-Logs.md ## Architecture + méthodes de collecte -->

**On conçoit cette problématique comme une architecture avec différents composants :**

### Méthodes de collecte

- **Sidecar Containers** : Conteneurs supplémentaires dans les pods pour capturer et envoyer les logs.
- **DaemonSets** : Agents de logging sur chaque nœud, collectent les logs localement et les envoient à une solution centralisée. Un DaemonSet garantit qu'exactement un pod tourne sur chaque nœud du cluster (ou sur un sous-ensemble via `nodeSelector`). C'est le pattern naturel pour les agents d'infrastructure : logging (Fluentd, Fluent Bit), monitoring (node-exporter, Datadog), réseau (Cilium, Calico).
- **Ingestion directe** : Solutions intégrées directement dans les applications.

### La boucle Input / Parser / Filter / Buffer / Router

Chaque ligne de log passe par différentes étapes avant d'être stockée :

- **Input** : Collecter les logs depuis diverses sources
- **Parser** : Analyser et structurer les logs bruts
- **Filter** : Modifier, enrichir ou supprimer des logs selon des règles
- **Buffer** : Stocker temporairement pour gérer les fluctuations de volume
- **Router** : Acheminer vers différentes destinations

### Tableau récapitulatif des composants

| Composant | Mission | Produits |
|---|---|---|
| Collecte (Forwarder) | Capturer, transformer, filtrer | Fluentd, Fluentbit, Filebeat, Logstash |
| Réception | Gérer l'arrivée, valider, enrichir | Logstash, Fluentd, Graylog |
| Stockage | Conserver pour accès à long terme | Elasticsearch, MongoDB, InfluxDB |
| Requêtage & affichage | Interroger, visualiser, analyser | Kibana, Grafana, Graylog |

---

## La normalisation des logs

<!-- À REPRENDRE EXISTANT : 5_Kubernetes-Advanced/310-Logs.md ## La normalisation -->

Voici un exemple de log brut généré par un microservice Python :

```
2024-06-30 12:34:56,789 INFO Processing request from user 1234
2024-06-30 12:34:57,123 ERROR Failed to process request from user 1234: Timeout error
```

En l'état, ces logs sont trop bruts pour être utiles dans le cadre d'une centralisation.

### Labels standards pour la normalisation

Les labels les plus couramment utilisés :

- **timestamp** : Date et heure en format ISO 8601 (`2024-06-30T12:34:56.789Z`)
- **log_level** : Niveau de sévérité (`INFO`, `ERROR`, `WARN`, `DEBUG`)
- **service_name** : Nom du service ou de l'application
- **environment** : Environnement (`production`, `staging`, `development`)
- **host** : Nom de l'hôte ou identifiant de la machine
- **request_id** : Identifiant unique pour le traçage distribué
- **trace_id** / **span_id** / **parent_span_id** : Labels de traçage distribué

### Exemple de log normalisé (JSON)

```json
{
  "timestamp": "2024-06-30T12:34:56.789Z",
  "log_level": "ERROR",
  "message": "Failed to process request from user 1234: Timeout error",
  "service_name": "user-service",
  "environment": "production",
  "host": "host-123",
  "request_id": "req-456",
  "trace_id": "abcd1234efgh5678",
  "span_id": "span-7890"
}
```

---

## Problèmes en infrastructure à grande échelle

<!-- À REPRENDRE EXISTANT : 5_Kubernetes-Advanced/310-Logs.md ## Problèmes -->

- **Fiabilité** : En cas de panne du serveur central, les Aggregators servent de buffer local jusqu'au rétablissement.
- **Scalabilité** : Elasticsearch, MongoDB, InfluxDB doivent être configurés pour des lectures/écritures intensives.
- **Sécurité et conformité** : Communications SSL/TLS, conformité GDPR/HIPAA/PCI-DSS.
- **Coût** : Compression, politiques de rétention, stockage à faible coût pour les données historiques.

---

## Solutions intégrées pour le logging dans Kubernetes

<!-- À REPRENDRE EXISTANT : 5_Kubernetes-Advanced/310-Logs.md ## Solutions intégrées -->

| Solution | Type | Stack |
|---|---|---|
| **Elastic Cloud on Kubernetes (ECK)** | Open source / Operator | Elasticsearch, Logstash, Kibana |
| **Loki Operator** (Grafana Labs) | Open source / Operator | Loki + Grafana |
| **Banzai Cloud Logging Operator** | Open source / Operator | Fluentd + Elasticsearch + Kibana |
| **Openshift Logging** | OpenShift | EFK (Elasticsearch, Fluentd, Kibana) |
| **GKE Logging** | Cloud GCP | Google Cloud Logging (Stackdriver) |
| **AWS Fluent Bit / EKS** | Cloud AWS | CloudWatch + Fluent Bit |
| **Azure Monitor for Containers** | Cloud Azure | Azure Monitor + Log Analytics |

---

## Historique de la collecte des métriques

<!-- À REPRENDRE EXISTANT : 5_Kubernetes-Advanced/320-Metrics.md ## Historique -->

**L'évolution de la collecte des métriques, des premiers outils SNMP aux solutions modernes comme Prometheus et Kubernetes, a considérablement amélioré l'automatisation et la flexibilité.**

- **1990s — SNMP** : Collecte centralisée de métriques réseau via agents sur les équipements
- **2000s — Nagios, Cacti, Munin** : Surveillance des serveurs, plugins, interfaces web, RRD databases
- **2012 — Collectd + Graphite** : Collecte système/applicative via plugins, API de stockage et visualisation
- **2015 — Prometheus** : Scraping pull-based, labels, PromQL, adopté rapidement par la communauté open source
- **2018 — Prometheus Operator** : CRDs pour déploiement et configuration de Prometheus dans Kubernetes

---

## La métrologie et les métriques

<!-- À REPRENDRE EXISTANT : 5_Kubernetes-Advanced/320-Metrics.md ## La métrologie -->

**La métrologie concerne la collecte, l'analyse et l'interprétation des données de performance et de fonctionnement des systèmes et applications.**

### Types de métriques

![](/img/kubernetes/prometheus-metrics-types.png)

- **Compteurs (Counters)** : Cumul d'événements, ne diminuent jamais. Ex: nombre total de requêtes HTTP.
- **Jauges (Gauges)** : Valeur à un instant donné, peuvent augmenter et diminuer. Ex: utilisation CPU actuelle.
- **Histogrammes** : Distribution de valeurs sur des intervalles, avec buckets cumulatifs. Ex: latence des requêtes.
- **Sommes (Summaries)** : Version évoluée des histogrammes, offrant des dérivées des données.

### Difficultés de la métrologie

- **Impact sur les ressources** : Une collecte trop fréquente peut affecter les performances
- **Prédictivité** : 90% d'espace disque occupé n'est pas toujours critique — le contexte compte
- **Collecte durant les outages** : Les outils eux-mêmes peuvent être affectés par la panne
- **Consistance** : Latences et désynchronisations dans les systèmes distribués

---

## Fonctionnement de Prometheus

<!-- À REPRENDRE EXISTANT : 5_Kubernetes-Advanced/320-Metrics.md ## Fonctionnement -->

**Prometheus est un système de surveillance et d'alerte open-source conçu pour collecter des métriques et des événements en temps réel.**

### PULL, HTTP, Timeseries

- **Pull** : Prometheus va chercher les données sur les endpoints des services (inverse du push)
- **HTTP** : Utilise le protocole standard HTTP
- **Timeseries** : Associe un timestamp avec des données nommées et labelisées

### Autoconfiguration dans Kubernetes

Prometheus utilise le Service Discovery Kubernetes pour découvrir automatiquement les endpoints à surveiller :

```yaml
# Annotations sur un pod pour activer le scraping
metadata:
  annotations:
    prometheus.io/scrape: "true"
    prometheus.io/path: "/metrics"
    prometheus.io/port: "8080"
```

### Format d'exposition des métriques

```plaintext
# HELP http_requests_total The total number of HTTP requests.
# TYPE http_requests_total counter
http_requests_total{method="post",code="200"} 1027
http_requests_total{method="post",code="400"} 3

# HELP memory_usage_bytes Memory usage in bytes.
# TYPE memory_usage_bytes gauge
memory_usage_bytes{instance="localhost"} 38482900
```

---

## Exposer les métriques de son application

<!-- À REPRENDRE EXISTANT : 5_Kubernetes-Advanced/320-Metrics.md ## Exposer les métriques -->

Exemple en Python avec `prometheus_client` :

```python
from prometheus_client import start_http_server, Gauge

CONNECTED_USERS = Gauge('connected_users', 'Number of connected users')

if __name__ == '__main__':
    start_http_server(8000)
    while True:
        CONNECTED_USERS.set(get_user_count())
```

Les métriques sont alors disponibles sur `http://localhost:8000/metrics` dans le format Prometheus.

---

## Les Time Series Databases (TSDB)

<!-- À REPRENDRE EXISTANT : 5_Kubernetes-Advanced/320-Metrics.md ## TSDB -->

Les TSDB sont spécialement optimisées pour stocker, indexer et interroger des données chronologiques.

Spécificités : insertion rapide, compression, indexation temporelle, politiques de rétention, aggregation et downsampling.

| Nom | Modèle | Points forts |
|---|---|---|
| **Prometheus** | Open source | Natif Kubernetes, scrape pull, court terme |
| **InfluxDB** | OS + commercial | Flux query language, haute écriture |
| **TimescaleDB** | OS + commercial | Extension PostgreSQL, SQL standard |
| **AWS Timestream** | Commercial | Service managé, intégration AWS |

---

## PromQL

<!-- À REPRENDRE EXISTANT : 5_Kubernetes-Advanced/320-Metrics.md ## PromQL -->

**PromQL** est le langage de requête de Prometheus pour interroger les métriques de séries temporelles.

```promql
# Sélection simple
http_requests_total

# Filtrage par labels
http_requests_total{job="api-server", status="200"}

# Taux sur 5 minutes, agrégé par job
sum(rate(http_requests_total[5m])) by (job)

# Pourcentage de mémoire disponible
node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes * 100
```

PromQL est utilisé dans Grafana pour les tableaux de bord et dans Prometheus pour les règles d'alerte.

---

## Vue d'ensemble des composants de collecte des métriques

<!-- À REPRENDRE EXISTANT : 5_Kubernetes-Advanced/320-Metrics.md ## Vue d'ensemble -->

| Composant | Fourni par | Type de métriques | Utilisation |
|---|---|---|---|
| Metrics Server | Kubernetes | CPU, Mémoire | Autoscaling (HPA, VPA) |
| Node Exporter | Prometheus | CPU, Mémoire, Disque, Réseau | Surveillance détaillée, alerting |
| Applications instrumentées | prometheus_client | Requêtes, Latence, Erreurs, Métier | Performances applicatives |
| Service Mesh (Istio, Linkerd) | Istio, Linkerd | Trafic, Latence, Taux de succès | Communications inter-services |
| Ingress Controller | Ingress | Requêtes HTTP, Latence, Erreurs | Performances exposition |

---

## Comparaison des interfaces de visualisation

<!-- À REPRENDRE EXISTANT : 5_Kubernetes-Advanced/320-Metrics.md ## Comparaison -->

| Interface | Sources supportées | Points forts |
|---|---|---|
| **Grafana** | Prometheus, InfluxDB, Elasticsearch, et plus | Multi-source, alerting avancé, écosystème de plugins |
| **Kibana** | Principalement Elasticsearch | Analyse de logs, visualisations variées |
| **Chronograf** | Principalement InfluxDB | Focalisé métriques InfluxDB |


---
title:   test
weight: 1
---

### 1. Thème: Logs

**Question:** Quel outil de collecte de logs est couramment utilisé pour ajouter des labels et des expressions régulières aux logs?

a) Fluentd  
b) Prometheus  
c) Grafana  
d) Kubernetes


### 2. Thème: Logs
**Question:** Comment appelle-t-on le processus de conversion de la ligne de log en donnée structurée?

a) La sérialisation  
b) La normalisation  
c) La segmentation  
d) La transformation

### 3. Thème: Logs
**Question:** Quelle technologie permet de centraliser les logs et les visualiser via une interface utilisateur intuitive?

a) Fluentd  
b) Elasticsearch  
c) Kibana  
d) Grafana

### 4. Thème: Metrics
**Question:** Quel outil est utilisé pour collecter les métriques de performance dans Kubernetes?

a) Fluentd  
b) Prometheus  
c) Trivy  
d) Longhorn

### 5. Thème: Metrics
**Question:** Quel langage de requête est utilisé par Prometheus pour interroger les métriques collectées?

a) SQL  
b) Flux  
c) PromQL  
d) GraphQL

### 6. Thème: Security
**Question:** Quel outil de sécurité scanne les configurations de Kubernetes pour vérifier la conformité avec les benchmarks de sécurité?

a) Prometheus  
b) Grafana  
c) Kube-bench  
d) Fluentd

### 7. Thème: Security
**Question:** Quel opérateur est utilisé pour gérer les secrets dans Kubernetes de manière sécurisée?

a) Longhorn  
b) Ceph  
c) Vault  
d) Rook

### 8. Thème: Security
**Question:** Quel outil de sécurité utilise eBPF pour surveiller les comportements anormaux dans Kubernetes?

a) Prometheus  
b) Grafana  
c) Trivy  
d) Falco

### 9. Thème: Persistence

**Question:** À quoi sert une storage class ?

a) Configurer les permissions des utilisateurs  
b) Gérer les configurations réseau  
c) Définir les types de stockage disponibles  
d) Contrôler l'accès aux pods


### 10. Thème: Persistence


**Vous devez concevoir un cluster Kubernetes dédié pour une solution de big data à forte charge, dans laquelle les utilisateurs peuvent gérer de gros volumes de données via des programmes ad hoc.**

La solution inclut par exemple des moteurs de calcul et des bases de données internes, ainsi que des pods de travail individuels pour les utilisateurs.

Voici les contraintes :

- **Puissance en production** : 400 CPU, 1To RAM, 40To stockage partageable.
- **Réseau** : Bande passante élevée, faible latence, isolation réseau, sécurité des communications.
- **Disques** : Stockage rapide (SSD/NVMe), grande capacité, IOPS élevés, persistance des données.
- **Sécurité** : Chiffrement des données au repos et en transit, gestion des accès, audit et conformité.
- **Compartimentation des charges de travail** : Isolation des workloads, allocation dynamique des ressources, gestion des quotas.
- **Haute disponibilité** : Réplication des données, tolérance aux pannes, équilibrage de charge, failover automatique.

Proposez des idées d'architecture pour répondre à ces contraintes en utilisant Kubernetes et les solutions de stockage appropriées.



## Correction

<details><summary>...</summary>

1. a) Fluentd
2. c) PersistentVolume
3. c) Kibana
4. b) Prometheus
5. c) PromQL
6. c) Kube-bench
7. c) Vault
8. d) Falco
9. c) Définir les types de stockage disponibles  
10. (Open-ended question) Combien d'environnements ? VMs ? Quels composants ? 


</details>
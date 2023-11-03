---
title: TP - Recording rules
sidebar_class_name: hidden
---

Les `recording_rules` sont des règles à ajouter à la configuration de Prometheus pour créer de nouvelles données. En particulier elles permettent d'agréger des requêtes en nouvelles séries temporelles.

Bien que ce ne soit pas un problème dans nos exemples simples, les requêtes PromQL qui agrègent des milliers de séries temporelles (time series) peuvent devenir lentes lorsqu'elles sont calculées à la volée. Pour rendre cela plus efficace, Prometheus peut préenregistrer des expressions en nouvelles séries temporelles persistantes via des *règles d'enregistrement* configurées. Disons que nous souhaitons enregistrer le taux par seconde du temps CPU (`node_cpu_seconds_total`) moyenné sur tous les CPU par instance (en préservant les dimensions `job`, `instance` et `mode`) tel que mesuré sur une fenêtre de 5 minutes. Nous pourrions écrire cela de la manière suivante :

```
avg by (job, instance, mode) (rate(node_cpu_seconds_total[5m]))
```

Essayez de créer un graphique avec cette expression.

Pour enregistrer les séries temporelles résultant de cette expression dans une nouvelle métrique appelée `job_instance_mode:node_cpu_seconds:avg_rate5m`, créez un fichier avec la règle d'enregistrement suivante et enregistrez-le sous le nom `prometheus.rules.yml` :

```yaml
groups:
- name: cpu-node
  rules:
  - record: job_instance_mode:node_cpu_seconds:avg_rate5m
    expr: avg by (job, instance, mode) (rate(node_cpu_seconds_total[5m]))
```

Pour que Prometheus prenne en compte cette nouvelle règle, ajoutez une instruction `rule_files` dans votre `prometheus.yml`. La configuration devrait maintenant ressembler à ceci :

```yaml
global:
  scrape_interval:     15s # Par défaut, récupère les cibles toutes les 15 secondes.
  evaluation_interval: 15s # Évalue les règles toutes les 15 secondes.

  # Attachez ces étiquettes supplémentaires à toutes les séries temporelles collectées par cette instance Prometheus.
  external_labels:
    monitor: 'codelab-monitor'

rule_files:
  - 'prometheus.rules.yml'

scrape_configs:
  - job_name: 'prometheus'

    # Remplacez la valeur par défaut globale et récupérez les cibles de ce job toutes les 5 secondes.
    scrape_interval: 5s

    static_configs:
      - targets: ['localhost:9090']

  - job_name:       'node'

    # Remplacez la valeur par défaut globale et récupérez les cibles de ce job toutes les 5 secondes.
    scrape_interval: 5s

    static_configs:
      - targets: ['localhost:8080', 'localhost:8081']
        labels:
          group: 'production'

      - targets: ['localhost:8082']
        labels:
          group: 'canary'
```

Rechargez ma nouvelle configuration de Prometheus et vérifiez qu'une nouvelle série temporelle avec le nom de métrique `job_instance_mode:node_cpu_seconds:avg_rate5m` est désormais disponible en interrogeant le navigateur d'expressions ou en créant un graphique.

### Bonnes pratiques pour nommer les règles

https://prometheus.io/docs/practices/rules/
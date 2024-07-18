---
title: TP - Créer et déclencher des alertes
sidebar_class_name: hidden
---

## Configuration de Alertmanagers dans Prometheus

On peut configurer une liste d'Alertmanagers auxquels Prometheus doit s'adresser en utilisant une liste dans sa configuration.
Par exemple, pour configurer un Alertmanager local, votre fichier *prometheus.yml* pourrait ressembler à ceci :

```markdown
global:
  scrape_interval: 10s
  evaluation_interval: 10s
alerting:
  alertmanagers: 
   - static_configs:
      - targets: ['localhost:9093']
rule_files:
 - rules.yml
scrape_configs:
 - job_name: node
   static_configs:
    - targets:
      - localhost:9100
 - job_name: prometheus
   static_configs:
    - targets:
      - localhost:9090
```

Le champ `alertmanagers` fonctionne de manière similaire à une configuration de collecte (scrape config), mais il n'y a pas de `job_name` et les étiquettes (labels) générées par le retraitement (relabeling) n'ont aucun impact, car il n'y a pas de notion d'étiquettes cibles lors de la découverte des Alertmanagers auxquels envoyer les alertes. En conséquence, tout retraitement impliquera généralement uniquement des actions de `drop` et `keep`.

Vous pouvez avoir plusieurs Alertmanagers : Prometheus enverra toutes les alertes à tous les Alertmanagers configurés.

Le champ `alerting` comprend également `alert_relabel_configs` pour du relabeling mais appliqué aux étiquettes d'alerte avant transmission. Vous pouvez ajuster les étiquettes d'alerte, voire supprimer des alertes.

Par exemple, vous pouvez souhaiter avoir des alertes informatives qui ne sortent jamais de votre Prometheus :

```markdown
alerting:
  alertmanagers:
   - static_configs:
      - targets: ['localhost:9093']
  alert_relabel_configs:
   - source_labels: [severity]
     regex: info
     action: drop
```

Vous pourriez utiliser cela pour ajouter des étiquettes `env` et `region` à toutes vos alertes, vous faisant ainsi gagner du temps ailleurs, mais il existe un moyen plus efficace de le faire en utilisant `external_labels`.

## Ajouter des `external_labels`

Les *étiquettes externes* sont des étiquettes appliquées par défaut lorsque votre Prometheus communique avec d'autres systèmes, tels que l'Alertmanager, la fédération, la lecture à distance (remote read) et l'écriture à distance (remote write), mais pas avec les API de requête HTTP. Les étiquettes externes définissent l'identité de Prometheus, et chaque Prometheus de votre organisation doit avoir des étiquettes externes uniques.

`external_labels` fait partie de la section `global` de *prometheus.yml* :

```markdown
global:
  scrape_interval: 10s
  evaluation_interval: 10s
  external_labels:
    region: eu-west-1
    env: prod
    team: frontend
alerting:
  alertmanagers:
   - static_configs:
      - targets: ['localhost:9093']
```

Il est plus simple d'avoir des étiquettes telles que `region` dans vos `external_labels`, car vous n'avez pas à les appliquer à chaque cible collectée, à les prendre en compte lors de l'écriture de PromQL ni à les ajouter à chaque règle d'alerte dans un Prometheus. Cela vous fait gagner du temps et facilite le partage de règles d'enregistrement et d'alerte entre différents serveurs Prometheus, car elles ne sont pas liées à un environnement spécifique ni à une organisation spécifique. Si une étiquette externe potentielle varie dans un Prometheus, alors elle devrait probablement être une étiquette cible (target label) à la place.

Comme les étiquettes externes sont appliquées après l'évaluation des règles d'alerte, elles ne sont pas disponibles dans la modélisation des alertes. Les alertes ne doivent pas dépendre du serveur Prometheus dans lequel elles sont évaluées, c'est donc correct. L'Alertmanager aura accès aux étiquettes externes comme à toute autre étiquette dans ses modèles de notification, et c'est l'endroit approprié pour les utiliser.

Les étiquettes externes ne sont que des valeurs par défaut ; si l'une de vos séries temporelles a déjà une étiquette portant le même nom, alors cette étiquette externe ne s'appliquera pas. En conséquence, nous vous conseillons de ne pas avoir de cibles dont les noms d'étiquettes se chevauchent avec vos étiquettes externes.

Maintenant que vous savez comment faire en sorte que Prometheus évalue et déclenche des alertes utiles, la prochaine étape consiste à configurer l'Alertmanager pour les convertir en notifications.
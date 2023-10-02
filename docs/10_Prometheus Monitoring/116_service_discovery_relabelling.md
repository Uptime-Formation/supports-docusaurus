---
title: TP - Service Discovery et relabeling.
draft: false
# sidebar_position: 6
---

Ce TP plutôt cours va illustrer une découverte de services pour lister les machines:

- à partir d'un fichier .json
- dans le cloud Hetzner (fournisseur allemand très competitif)

Nous pourront ensuite explorer le relabelling de nos targets.


## Découverte de service depuis un fichier json:

On peut exprimer les cibles au format JSON ce qui est plus pratique à générer automatiquement.

```json
[
  {
    "targets": [ "monserveur:port", "monserveur2:port" ],
    "labels": {
      "team": "infra",
      "job": "node"
    }
  },
  {
    "targets": [ "monserveurprometheus:9090" ],
    "labels": {
      "team": "monitoring",
      "job": "prometheus"
    }
  }
]
```

Dans la configuration de prometheus:

```yaml
scrape_configs:
 - job_name: file
   file_sd_configs:
    - files:
       - '*.json'
```

Changez la configuration actuelle de nos cibles (prometheus et 3 nodes) basée sur un fichier json

## Découverte de service Hetzner cloud:

```yaml
  - job_name: hetzner_service_discovery
    hetzner_sd_configs:
      - role: "hcloud"
        bearer_token: "HmukFn0BnOt469VaWYGLKObtZcCjPbx0Oz2yI5PrtBxDsT1Pevs532A2obWoc6NJ"
        port: 9100
```

- Utilisez cet exemple de configuration pour venir scraper les serveur hcloud montés par le formateur


## Relabelling : grouper et modifier les étiquettes/metadonnées de nos metriques


```yaml
scrape_configs:
 - job_name: file
   file_sd_configs:
    - files:
       - '*.json'
   relabel_configs:
    - source_labels: [team]
      regex: infrascrape_configs:
 - job_name: file
   file_sd_configs:
    - files:
       - '*.json'
   relabel_configs:
    - source_labels: [team]
      regex: infra|monitoring
      action: keep

scrape_configs:
 - job_name: file
   file_sd_configs:
    - files:
       - '*.json'
   relabel_configs:
    - source_labels: [job, team]
      regex: prometheus;monitoring
      action: drop
      action: keep

scrape_configs:
 - job_name: file
   file_sd_configs:
    - files:
       - '*.json'
   relabel_configs:
    - source_labels: [team]
      regex: infra
      action: keep
    - source_labels: [team]
      regex: monitoring
      action: keep

scrape_configs:
 - job_name: file
   file_sd_configs:
    - files:
       - '*.json'
   relabel_configs:
    - source_labels: [team]
      regex: infra|monitoring
      action: keep

scrape_configs:
 - job_name: file
   file_sd_configs:
    - files:
       - '*.json'
   relabel_configs:
    - source_labels: [job, team]
      regex: prometheus;monitoring
      action: drop
```


Basé sur ces exemples:

- trouvez comment supprimer les étiquettes automatiques de Hetzner cloud

- Ajouter une étiquette pour grouper les nodes localhost et hetznercloud ensemble

- Ajoutez une étiquette `team: dev` sur les instances locales et `team: prod` sur les instances hetzner
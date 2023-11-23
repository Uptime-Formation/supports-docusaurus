---
title: TP - Service Discovery et relabeling.
# sidebar_class_name: hidden
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

Dans la configuration de prometheus remplaçez les statics configs existantes par:

```yaml
scrape_configs:
 - job_name: file
   file_sd_configs:
    - files:
       - '*.json'
```

- Complétez la configuration json de nos cibles pour refléter les deux jobs supprimés ddu `prometheus.yml` (prometheus et 3 nodes).

## Découverte de service Hetzner cloud:

```yaml
  - job_name: hcloud_node
    hetzner_sd_configs:
      - role: "hcloud"
        bearer_token: "<token fourni par le formateur>"
        port: 9100
```

- Utilisez cet exemple de configuration pour venir scraper les serveur hcloud montés par le formateur


## Relabelling : filtrer nos cible et éditer leurs caractéristiques et labels


- https://grafana.com/blog/2022/03/21/how-relabeling-in-prometheus-works/

- Ajoutez la config de `relabeling` suivante à notre job hetzner:

```yaml
  - job_name: hcloud_node
    ...
    relabel_configs:
      - source_labels: [__meta_hetzner_server_name]
        regex: '(.*)'
        replacement: '${1}'
        target_label: instance
      - source_labels: [__meta_hetzner_server_id]
        regex: '(.*)'
        replacement: 'node${1}'
        target_label: node_id
        action: replace
      - source_labels: [__meta_hetzner_server_name]
        regex: 'prometheus-monitored-0'
        action: drop
```

Cette config:
  - remplace l'étiquette instance avec le nom du server
  - ajoute une étiquette node_id générée avec une regex à partir du meta label hetzner de la découverte de service
  - supprime du scraping le premier serveur basé sur son nom

Essayez d'activer et désactiver les 3 items de relabel config.
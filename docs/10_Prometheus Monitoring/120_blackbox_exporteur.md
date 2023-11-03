---
title: TP - Blackbox exporter
sidebar_class_name: hidden
---

# Blackbox exporter

- Installez le blackbox exporter

- Ajoutez une nouvelle configuration à `blackbox.yml`:

- Visitez `http://localhost:9115/probe?module=ssh_banner&target=localhost:22`

- Pour que cette probe fonctionne, il faut également installer `openssh-server` avec `apt` ce qui devrait aussi démarrer le service.

- Vérifiez que la probe_success en bas des métriques est a 1.

- Idem, visitez `http://localhost:9115/probe?module=http_2xx&target=google.com` pour essayer la probe http_2xx

Ajoutons cette deuxième configuration http_2xx à notre configuration de scraping:

```yaml
  - job_name: blackbox_http
    metrics_path: /probe
    params:
      module: [http_2xx]
    static_configs:
      - targets:
        - http://www.prometheus.io
        - https://google.com
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
        replacement: 127.0.0.1:9115
```

Arrivez vous à comprendre l'utilité (un peu tordue) du relabelling pour s'adapter à notre blackbox exporter ? Sinon commentez successivement les trois règles de relabeling et rechargez la configuration pour comprendre

Maintenant encore plus acrobatique essayons d'utiliser une configuration de scraping blackbox pour effectuer une probe ssh_banner sur tous les serveurs hetzner cloud utilisez lors du tp découverte de service et relabeling:

- Ajoutez la config suivante:

```yaml
  - job_name: hcloud_ssh_probe
    metrics_path: /probe
    params:
      module: [ssh_banner]
    hetzner_sd_configs:
        - role: "hcloud"
          bearer_token: "HmukFn0BnOt469VaWYGLKObtZcCjPbx0Oz2yI5PrtBxDsT1Pevs532A2obWoc6NJ"
          port: 9100
    relabel_configs:
      - source_labels: [__address__]
        regex: '(.*):9100'
        replacement: '${1}:22'
        target_label: __param_target
      - replacement: 'localhost:9115'
        target_label: __address__
      - source_labels: [__meta_hetzner_server_name]
        target_label: instance
```

Pouvez-vous comprendre le fonctionnement du relabelling ici ? Essayez d'activer/désactiver les règles de relabeling pour voir les différents résultats.



## Correction finale des différents TP scraping jusqu'ici (tous les exporters):


`prometheus.yml` :

```yaml
global:
  scrape_interval: 15s # Set the scrape interval to every 15 seconds. Default is every 1 minute.
  evaluation_interval: 15s # Evaluate rules every 15 seconds. The default is every 1 minute.

scrape_configs:

  - job_name: file
    file_sd_configs:
    - files:
      - '*.json'

  - job_name: hcloud_node
    hetzner_sd_configs:
      - role: "hcloud"
        bearer_token: "HmukFn0BnOt469VaWYGLKObtZcCjPbx0Oz2yI5PrtBxDsT1Pevs532A2obWoc6NJ"
        port: 9100
    relabel_configs:
      - source_labels: [__meta_hetzner_server_name]
        regex: '(.*)'
        replacement: '${1}:9100'
        target_label: instance
      - source_labels: [__meta_hetzner_server_id]
        regex: '(.*)'
        replacement: 'node${1}'
        target_label: node_id
        action: replace
      - source_labels: [__meta_hetzner_server_name]
        regex: 'prometheus-monitored-0'
        action: drop

  - job_name: "mysql"
    static_configs:
    - targets: ["localhost:9104"]

  - job_name: blackbox_http
    metrics_path: /probe
    params:
      module: [http_2xx]
    static_configs:
      - targets:
        - http://www.prometheus.io
        - https://google.com
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
        replacement: 127.0.0.1:9115

  - job_name: hcloud_ssh_probe
    metrics_path: /probe
    params:
      module: [ssh_banner]
    hetzner_sd_configs:
        - role: "hcloud"
          bearer_token: "HmukFn0BnOt469VaWYGLKObtZcCjPbx0Oz2yI5PrtBxDsT1Pevs532A2obWoc6NJ"
          port: 9100
    relabel_configs:
      - source_labels: [__address__]
        regex: '(.*):9100'
        replacement: '${1}:22'
        target_label: __param_target
      - replacement: 'localhost:9115'
        target_label: __address__
      - source_labels: [__meta_hetzner_server_name]
        target_label: instance
```
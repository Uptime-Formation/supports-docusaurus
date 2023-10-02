---
title: TP - Blackbox exporter
draft: false
# sidebar_position: 6
---

# Blackbox exporter

- Installez le blackbox exporter

- Ajoutez une nouvelle configuration à `blackbox.yml`:

```yaml
  ssh_banner:
    prober: tcp
    tcp:
      query_response:
      - expect: "^SSH-2.0-"
```

- Visitez `http://localhost:9115/probe?module=ssh_banner&target=localhost:22`

- Ajoutez cette url comme cible avec la configuration suivante:

```yaml
scrape_configs:
 - job_name: blackbox
   metrics_path: /probe
   params:
     module: [ssh_banner]
   static_configs:
    - targets:
       - "localhost:22"
```

- Pour cette probe fonctionne, il faut également installer `openssh-server` avec `apt` ce qui devrait aussi démarrer le service.
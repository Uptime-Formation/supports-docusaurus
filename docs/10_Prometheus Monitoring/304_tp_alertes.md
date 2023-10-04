---
title: TP - Créer et déclencher des alertes
draft: false
# sidebar_position: 6
---

Ce TP vise à mettre en pratique les exemple d'alerte du cours sur nos trois `node_exporter` du TP1 et configurer les notifications depuis une instance de alertmanager

- Assurez vous d'avoir bien suivi le TP1 et d'avoir 3 instances de `node_exporter` en train de tourner et un `prometheus` local configuré pour les surveiller.

Pour chaque exemple d'alerte sauf les deux dernières (FDsNearLimit et les annotations):

- testez l'expression de l'alerte pour comprendre ce qu'elle renvoie comme données
- ajoutez l'alerte à la configuration des règles de prometheus créés lors du TP sur les recording rules (`prometheus.rules.yml`)
- Essayez de déclencher l'alerte
- Essayez ensuite de résoudre l'alerte

## Configurer Alertmanager avec un webhook

- Téléchargez alertmanager sur la page de téléchargement de prometheus et décompressez le.

- Dans le fichier `prometheus.yml` ajoutez la section suivante et rechargez la configuration:

```yaml
alerting:
  alertmanagers:
  - static_configs:
    - targets:
       - 127.0.0.1:9093
```

- Dans le fichier `alertmanager.yml` on peut ajouter la configuration d'exemple suivante:

```yaml
global:
  # The smarthost and SMTP sender used for mail notifications.
#   smtp_smarthost: 'localhost:25'
#   smtp_from: 'alertmanager@example.org'
#   smtp_auth_username: 'alertmanager'
#   smtp_auth_password: 'password'

# The directory from which notification templates are read.
# templates: 
# - '*.tmpl'

# The root route on which each incoming alert enters.
route:
  group_by: ['alertname']
  group_wait: 20s
  group_interval: 5m
  repeat_interval: 3h 
  receiver: python_webhook_1

  routes: # other routes
  - matchers:
    - severity =~ "(ticket|pager)"
    receiver: python_webhook_2

# Here, if an alert with a severity label of page-regionfail is firing,
# it will suppress all your alerts with the same region label that have a severity label of page
inhibit_rules:
 - source_matchers:
     - severity = page-regionfail
   target_matchers:
     - severity = page
   equal: ['region'] 

receivers:
- name: 'python_webhook_1'
  webhook_configs:
    - url: 'http://localhost:5000' # adresse d'une application flask pour visualiser le webhook
- name: 'python_webhook_2'
  webhook_configs:
    - url: 'http://localhost:5001'

templates:
- './notif_template.tmpl'
```

<!-- - Créez un fichier de template pour les notifications: `notif_template.tmpl`

Les webhooks ne supportent pas les templates

```
{{ define "notif_template" }}

{{ .Alerts | len }} alerts:
{{ range .Alerts }}
{{ range .Labels.SortedPairs }}{{ .Name }}={{ .Value }} {{ end }}
{{ if eq .Annotations.wiki "" -}}
Wiki: http://wiki.local/{{ .Labels.alertname }}
{{- else -}}
Wiki: http://wiki.local/{{ .Annotations.wiki }}
{{- end }}
{{ if ne .Annotations.dashboard "" -}}
Dashboard: {{ .Annotations.dashboard }}&region={{ .Labels.region }}
{{- end }}
{{ end }}

{{ end }}
``` -->

- Créer deux petites applications `webhook1.py`, `webhook2.py` python pour recevoir et visualiser les deux webhooks (changez le port 5000 à 5001 pour la deuxième):

```python
import json
from http.server import BaseHTTPRequestHandler
from http.server import HTTPServer
from pprint import pprint

class LogHandler(BaseHTTPRequestHandler):
    def do_POST(self):
        self.send_response(200)
        self.end_headers()
        length = int(self.headers['Content-Length'])
        data = json.loads(self.rfile.read(length).decode('utf-8'))
        # pprint(data) # pour afficher tout le webhook décommentez ici
        for alert in data["alerts"]:
            print(alert)

if __name__ == '__main__':
   httpd = HTTPServer(('', 5000), LogHandler)
   httpd.serve_forever()
```

- Lancez les avec par exemple `python3 webhook1.py`

- Si vous déclenchez les alertes du cours avec les labels severity: page ou ticket vous devriez recevoir des notifications sur les webhook python

- Expérimentez avec les labels sur les alertes et les routes pour essayer d'activer l'inhibition décrite dans la section correspondante du `alertmanager.yml`

## Organiser les templates de notification

- https://prometheus.io/docs/alerting/latest/notification_examples/
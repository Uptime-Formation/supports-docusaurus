---
title: TP - appareiller une application pour Prometheus
draft: false
# sidebar_position: 6
---

Dans ce TP nous allons essayer et commenter plusieurs code minimaux d'application qui démontrent comment créer les différents types de métrique de base pour un application web (nombre et moyenne au fil du temps des requêtes, nombre d'exceptions déclenchées dans une portion de code, latence, etc).

Ces exemples pourraient être présentés dans la plupart des langages. Nous utiliserons Python ici car c'est un langage assez simple et direct.

- Créez un dossier de projet `tp_app_instrumentation` et ouvrez le avec VSCod(ium)

- Cherchez et installez la librairie python prometheus client avec `apt search` et `apt install` ou a défaut avec `pip install prometheus_client`

## Utiliser la librairie client prometheus Python

Démarrons avec un simple serveur web :

- Créez le fichier `exemple1.py` avec le code suivant.

```python
import http.server

class MyHandler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.end_headers()
        self.wfile.write(b"Application d'exemple 1")

if __name__ == "__main__":
    server = http.server.HTTPServer(('localhost', 8000), MyHandler)
    server.serve_forever()
```

En lançant le programme avec `python3 exemple1.py` le programme sert une page sur http://localhost:8000/

Pour exposer une route de métrique au format OpenMetrics de prometheus on peut utiliser (dans les cas simples) la fonction `start_http_server` qui va démarrer un autre serveur http dédié à la route de métrique. Pour cela ajouter
    
- la premiere ligne du fichier: `from prometheus_client import start_http_server`
- comme première ligne du main: `start_http_server(8001)`

On peut ensuite visualiser les métriques sur http://localhost:8001/ sur la route /metrics (route par défaut pour OpenMetrics/Prometheus)

On obtient ainsi comme pour le node_exporter une liste des metriques disponibles. Mais ce qui nous intéresse c'est de scraper cette route avec Prometheus. Pour cela ajoutez au fichier de configuration Prometheus le bloc suivant (et redémarrez prometheus):

```yaml
    - job_name: example
      static_configs:
        - targets:
          - localhost:8000
```

On peut ensuite visiter Prometheus à l'adresse http://localhost:9090/.

- Pour tester entrez l'expression PromQL `python_info` et exécutez. On peut voir ainsi des metriques d'information sur le client Python. (Nous n'avons pas encore défini de métrique spécifique pour notre app)


## Ajouter un compteur de requête


- Copiez le fichier `exemple1.py` en `exemple2.py`
- Ajoutez un import `from prometheus_client import Counter` en début de fichier
- Ajoutez une ligne de définition de la métrique juste après les imports : `REQUESTS = Counter('example_app_total', 'Nombre de requete sur notre application d'exemple')`
- Ajoutez en début de la méthode `do_GET` la ligne d'incrémentation de la métrique : `REQUESTS.inc()`. Du coup à chaque requête cette ligne est executée et le total du compteur est augmenté de 1.

Quelques remarques:

- Les métriques des doivent être définies en amont du programme avant d'être utilisées
- L'aide explicative de la métrique sert à la documenter et est visible quand on fait une requete sur `/metrics`
- Les noms des métriques doivent être descriptifs et uniques (pas si facile quand on a un grosse app avec plein de métriques)
- On peut faire plusieurs _registries_ pour classer les métriques, si ce n'est pas précisé les métriques vont dans le registry par défaut.

Utilisons maintenant notre compteur dans Prometheus.

- Lancez le programme exemple2.
- Visitez prometheus et executez `example_app_total` puis `rate(example_app_total[1m])`.

### Compter les exceptions ou des quantité non entières

Les libraires d'"appareillages" ont des outils plus spécifiques adaptés à chaque langage. Par exemple la libraraire Python propose un contexte `count_exceptions` qui incrémentera le compteur seulement lorsqu'une exception est lancée (a l'intérieur du contexte) :

- Ajoutez le compteur d'exception suivant en dessous de la déclaration du compteur REQUEST:

```python
EXCEPTIONS = Counter('example_app_exceptions_total', "Nombre d'exceptions pendant l'éxecution de l'app d'exemple")`
```

- Ajoutez le bloc suivant en dessous de la ligne `REQUEST.inc()`:

```python
        with EXCEPTIONS.count_exceptions():
            if random.random() < 0.2:
                raise Exception
```

- Que fait ce code précisément ?
- Comment profiter de notre compteur d'exception dans Prometheus ?

<details><summary>Réponse</summary>

Le code précédent va déclencher une exception à chaque fois que le tirage aléatoire de la fonction random est inférieur à 0.2 (donc 1/5 des requêtes). La requête est captée par le context de notre compteur d'exception (le `with`) qui est incrémenté.

On peut ensuite aller regarder le compteur avec `rate` comme précédemment: `rate(example_app_exceptions_total[1m])`

Cependant la fréquence d'erreur n'a pas vraiment de sens dans l'absolu indépendamment du nombre de requête. L'information intéressante ici est plutôt le **taux d'erreur**, c'est à dire le nombre d'erreurs rapporté au nombre de requêtes. On peut calculer ce taux dans une expression `PromQL`: `rate(example_app_exceptions_total[1m])/rate(example_app_total[1m])`. Dans notre cas, avec un grand nombre de requêtes ce taux devrait se stabiliser autour de 0,2.

</details>

:::tip Compter une valeur non entière

On peut incrémenter un compteur d'une valeur non unitaire ou même non entière comme dans l'exemple suivant :

```python
from prometheus_client import Counter
import random

REQUESTS = Counter('example_app_total', "Requêtes sur l'app d'exemple")
VENTES = Counter('example_sales_total', "Chiffre d'affaire cumulé sur les ventes")

class MyHandler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
      REQUESTS.inc()
      sale_value = random.random() # CA de la vente en €
      SALES.inc(sale_value)
      self.send_response(200)
      self.end_headers()
      self.wfile.write(f"Un vente de {sale_value}€ a été effectuée.".encode())
```

:::

### Les jauges (gauges)


Gauges can be used to track
the number of calls in progress and determine when the last one was
completed.
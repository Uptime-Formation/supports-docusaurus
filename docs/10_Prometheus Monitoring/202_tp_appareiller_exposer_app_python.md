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
          - localhost:8001
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

#### Compter une valeur non entière

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


## Les Jauges

Les jauges sont une capture instantanée d'un état actuel. Alors que pour les compteurs, la vitesse à laquelle il augmente est ce qui vous préoccupe, pour les jauges, c'est la valeur actuelle de la jauge. En conséquence, les valeurs peuvent augmenter ou diminuer.

Exemples de jauges comprennent :

- Le nombre d'éléments dans une file d'attente
- L'utilisation de la mémoire d'un cache
- Nombre de fils d'exécution actifs (threads)
- La dernière fois qu'un enregistrement a été traité
- Le nombre moyen de demandes par seconde au cours de la dernière minute



Les jauges ont trois principales méthodes que vous pouvez utiliser : `inc`, `dec` et `set`. Similairement aux méthodes sur les compteurs, inc et dec augmentent ou diminuent la valeur d'une jauge d'une valeur.

Essayez le code suivant:


```python
import time
from prometheus_client import Gauge

INPROGRESS = Gauge('app_request_inprogress',
        'Nombre de requetes en cours.')
LAST = Gauge('app_request_last_time_seconds',
        "La dernière fois qu'une requete a été servie.")

class MyHandler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        INPROGRESS.inc()
        self.send_response(200)
        self.end_headers()
        self.wfile.write(b"Salut !")
        LAST.set(time.time())
        INPROGRESS.dec()
```

Autre version avec un peu de sucre syntaxique Python:


```python
from prometheus_client import Gauge

INPROGRESS = Gauge('app_request_inprogress',
        'Nombre de requetes en cours.')
LAST = Gauge('app_request_last_time_seconds',
        "La dernière fois qu'une requete a été servie.")

class MyHandler(http.server.BaseHTTPRequestHandler):
    @INPROGRESS.track_inprogress()
    def do_GET(self):
        self.send_response(200)
        self.end_headers()
        self.wfile.write(b"salut !")
        LAST.set_to_current_time()
```

## Un Summary pour la latence moyenne

```python
import time
from prometheus_client import Summary

LATENCY = Summary('app_latency_seconds',
        'Time for a request')

class MyHandler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        start = time.time()
        self.send_response(200)
        self.end_headers()
        self.wfile.write(b"salut !")
        LATENCY.observe(time.time() - start)
```

`app_latency_seconds_count` est le nombre d'appels "observe" qui ont été effectués. Ainsi, `rate(app_latency_seconds_count[1m])` dans le navigateur d'expressions retourne le taux par seconde des requêtes.

`app_latency_seconds_sum` est la somme des valeurs passées à "observe", donc `rate(app_latency_seconds_sum[1m])` est le temps passé à répondre aux requêtes par seconde.

Si vous divisez ces deux expressions, vous obtenez la latence moyenne sur la dernière minute :

```
  rate(app_latency_seconds_sum[1m])
/
  rate(app_latency_seconds_count[1m])
```

## Un Histogramme pour les quantile de latence

L'instrumentation pour les histogrammes est proche de celle des summary: La méthode `observe()` vous permet de faire d'enregistrer des évènement avec leur valeurs manuelles, et un décorateur de fonction permettent de faciliter l'utilisation.


```python
from prometheus_client import Histogram

LATENCY = Histogram('app_latency_seconds',
        'Temps pour une requête')

class MyHandler(http.server.BaseHTTPRequestHandler):
    @LATENCY.time()
    def do_GET(self):
        self.send_response(200)
        self.end_headers()
        self.wfile.write(b"Salut")
```

Ce code produira un ensemble de séries temporelles avec le nom `app_latency_seconds_bucket`. Un histogramme a un ensemble de buckets, tels que 1 ms, 10 ms, et 25 ms. L'histogramme fonctionne en suivant le nombre d'événements qui tombent dans chaque bucket.

Ensuite, la fonction PromQL `histogram_quantile` permet de calculer un quantile à partir des buckets. Par exemple :

`histogram_quantile(0.95, rate(app_latency_seconds_bucket[1m]))`

Le taux (rate) est nécessaire car les séries temporelles des buckets sont des compteurs.

Les buckets par défaut couvrent une plage de latences de 1 ms à 10 s. Pour ajouter un bucket personnalisé on fournit une liste triée :

```python
LATENCY = Histogram('app_latency_seconds',
        'Temps pour une requête.',
        buckets=[0.0001, 0.0002, 0.0005, 0.001, 0.01, 0.1])
```


## Une correction possible pour le TP:

`app.py`:

```python
from prometheus_client import Gauge, Counter, Histogram, start_http_server
import http.server
import random, time

REQUESTS = Counter('example_app_total', "Nombre de requete sur notre application d'exemple")
LATENCY = Histogram('example_app_latency_seconds', 'Temps pour une requête')
# INPROGRESS = Gauge('example_app_request_inprogress',  'Nombre de requetes en cours.')
# LAST = Gauge('example_app_request_last_time_seconds',        "La dernière fois qu'une requete a été servie.")
EXCEPTIONS = Counter('example_app_exceptions_total', "Nombre d'exceptions pendant l'éxecution de l'app d'exemple")

class MyHandler(http.server.BaseHTTPRequestHandler):
    # @INPROGRESS.track_inprogress()
    @LATENCY.time()
    def do_GET(self):
        with EXCEPTIONS.count_exceptions():

            if random.random() < 0.2:
                raise Exception

            if random.random() < 0.05:
                time.sleep(3)
            
            if random.random() < 0.1:
                time.sleep(0.4)

            self.send_response(200)
            self.end_headers()
            self.wfile.write(b"salut !")

            # LAST.set_to_current_time()
            REQUESTS.inc()

if __name__ == "__main__":
    start_http_server(8001)
    server = http.server.HTTPServer(('localhost', 8000), MyHandler)
    server.serve_forever()
```


Vous pouvez créer un script `poll_app.sh` pour faire des requêtes automatiquement sur votre application:

```bash
for i in {1..10000}
do
    curl "localhost:8001"
    sleep(0.5)
done
```


Vous pouvez tester les requêtes suivantes dans Prometheus et essayer des graphs:

- example_app_total
- rate(example_app_total)
- example_app_exceptions_total
- rate(example_app_exceptions_total[5m])
- rate(example_app_latency_count[5m])
- rate(example_app_latency_sum[5m])
- rate(example_app_latency_sum[5m]) / rate(example_app_latency_count[5m])
- example_app_latency_seconds_bucket
- histogram_quantile(0.95, example_app_latency_seconds_bucket)
---
title: TP - Découverte de Prometheus partie 2
# sidebar_class_name: hidden
---

Ce TP est la suite du premier TP.

## Arrêt de Prometheus et rechargement de la configuration

Une instance Prometheus peut recharger sa configuration sans redémarrer le processus en utilisant le signal `SIGHUP`. Si vous utilisez Linux, vous pouvez le faire en utilisant `kill -s SIGHUP <PID>`, en remplaçant `<PID>` par l'ID de processus de votre instance Prometheus.

Bien que Prometheus dispose de mécanismes de récupération en cas de défaillance abrupte du processus, il est recommandé d'utiliser le signal `SIGTERM` pour arrêter proprement une instance Prometheus. Si vous utilisez Linux, vous pouvez le faire en utilisant `kill -s SIGTERM <PID>`, en remplaçant `<PID>` par l'ID de processus de votre instance Prometheus.

## Utilisation du navigateur d'expressions[](https://prometheus.io/docs/prometheus/latest/getting_started#using-the-expression-browser)

Explorons les données que Prometheus a collectées à propos de lui-même. Pour utiliser le navigateur d'expressions intégré à Prometheus, accédez à <http://localhost:9090/graph> et choisissez la vue "Table" dans l'onglet "Graph".

Comme vous pouvez le voir sur [localhost:9090/metrics](http://localhost:9090/metrics), l'une des métriques que Prometheus exporte à propos de lui-même s'appelle `prometheus_target_interval_length_seconds` (la durée réelle entre les récupérations de cibles). Saisissez la commande suivante dans la console d'expression, puis cliquez sur "Exécuter" :

```bash
prometheus_target_interval_length_seconds
```

Cela devrait renvoyer plusieurs séries temporelles différentes (avec la dernière valeur enregistrée pour chacune), chacune avec le nom de métrique `prometheus_target_interval_length_seconds`, mais avec différentes étiquettes. Ces étiquettes désignent différents percentiles de latence et des intervalles de groupe cible différents.

Si nous nous intéressons uniquement aux latences du 99e percentile, nous pourrions utiliser cette requête :

```bash
prometheus_target_interval_length_seconds{quantile="0.99"}
```

Pour compter le nombre de séries temporelles renvoyées, vous pourriez écrire :

```bash
count(prometheus_target_interval_length_seconds)
```

Pour en savoir plus sur le langage d'expression, consultez la [documentation du langage d'expression](https://prometheus.io/docs/prometheus/latest/getting_started/../querying/basics/).

## Utilisation de l'interface de visualisation graphique

Pour créer des graphiques à partir d'expressions, accédez à <http://localhost:9090/graph> et utilisez l'onglet "Graph".

Par exemple, saisissez l'expression suivante pour créer un graphique du taux par seconde de création de chunks dans le Prometheus auto-récupéré :

```bash
rate(prometheus_tsdb_head_chunks_created_total[1m])
```

Expérimentez avec les paramètres de plage de graphique et d'autres paramètres.

## Démarrage de quelques cibles exemple

Ajoutons des cibles supplémentaires pour que Prometheus les récupère.

Le `node_exporter` est utilisé comme cible exemple: 

- [Téléchargez la dernière version](https://prometheus.io/download) du `node_exporter` pour votre plate-forme, puis extrayez la :

```bash
tar -xzvf node_exporter-*.*.tar.gz
cd node_exporter-*.*

# Démarrez 3 cibles exemple dans des terminaux séparés :
./node_exporter --web.listen-address 127.0.0.1:8080
./node_exporter --web.listen-address 127.0.0.1:8081
./node_exporter --web.listen-address 127.0.0.1:8082
```

Vous devriez maintenant avoir des cibles exemples en écoute sur <http://localhost:8080/metrics>, <http://localhost:8081/metrics> et <http://localhost:8082/metrics>.


## Configuration de Prometheus pour surveiller les cibles d'exemple

Maintenant, nous allons configurer Prometheus pour récupérer ces nouvelles cibles. Regroupons les trois points d'accès en un seul job appelé `node`. Nous allons imaginer que les deux premiers points d'accès sont des cibles de production, tandis que le troisième représente une instance de test. Pour modéliser cela dans Prometheus, nous pouvons ajouter plusieurs groupes de points d'accès à un seul job, en ajoutant des étiquettes supplémentaires à chaque groupe de cibles. Dans cet exemple, nous ajouterons l'étiquette `group="production"` au premier groupe de cibles, tandis que nous ajouterons `group="canary"` au deuxième.

Pour ce faire, ajoutez la définition du job suivante à la section `scrape_configs` de votre fichier `prometheus.yml`, puis redémarrez votre instance de Prometheus :

```yaml
scrape_configs:
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

Accédez au navigateur d'expressions et vérifiez que Prometheus dispose désormais d'informations sur les séries temporelles exposées par ces points d'accès exemples, telles que `node_cpu_seconds_total`.


Source: documentation officielle Prometheus sous licence CC by SA
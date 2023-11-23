---
title: Cours - Instant Vector, Range Vector et subquery
sidebar_class_name: hidden
---

### Instant Vector

Un sélecteur `instant vector` renvoie un `instant vector` des échantillons les plus récents avant le temps d'évaluation de la requête, ce qui signifie une liste de zéro ou plusieurs séries temporelles. Chaque série temporelle aura un échantillon, et un échantillon contient à la fois une valeur et un timestamp. 

<!-- Lorsque vous demandez l'utilisation actuelle de la mémoire, vous ne voulez pas que les échantillons d'une instance qui a été éteinte il y a plusieurs jours soient inclus, un concept connu sous le nom de *staleness*. -->

### Range Vector

Il existe un second type de sélecteur que vous avez déjà vu, appelé le *range vector selector*. Contrairement à un sélecteur `instant vector`, qui renvoie un échantillon par série temporelle, un `range vector selector` peut renvoyer plusieurs échantillons pour chaque série temporelle.

Les `range vectors` sont toujours utilisés avec la fonction `rate`, par exemple:

```
rate(process_cpu_seconds_total[1m])
```

Le `[1m]` transforme le sélecteur `instant vector` en `range vector selector`, et donne l'instruction à PromQL de renvoyer pour toutes les séries temporelles correspondant au sélecteur tous les échantillons pour la minute précédant le temps d'évaluation de la requête.

Exécutons : 
  - `process_cpu_seconds_total[1m]` 
  - `rate(process_cpu_seconds_total[1m])` 

- https://promlabs.com/blog/2020/06/18/the-anatomy-of-a-promql-query/

## Subqueries

Les `range vectors` ne peuvent pas être utilisés en combinaison avec des fonctions.

<!-- Si vous souhaitez combiner `max_over_time` avec `rate`, vous pouvez soit utiliser des recording rules, qui enregistreraient le résultat de la fonction `rate` et le passeraient à la fonction `max_over_time`, soit vous pouvez utiliser une **subquery**. -->
Si vous souhaitez combiner `max_over_time` avec `rate` vous pouvez utiliser une **subquery**.

Une sous-requête est une partie d'une requête qui vous permet de faire une `range query` à l'intérieur d'une requête.

```
max_over_time( rate(prometheus_http_requests_total[5m])[30m:1m])
```

La requête précédente exécute `rate(prometheus_http_requests_total[5m])` toutes les minutes (`1m`) pendant les 30 dernières minutes (`30m`), puis alimente le résultat dans une fonction `max_over_time()`.

Plus d'info sur les subqueries et leurs motivations : https://prometheus.io/blog/2019/01/28/subquery-support/
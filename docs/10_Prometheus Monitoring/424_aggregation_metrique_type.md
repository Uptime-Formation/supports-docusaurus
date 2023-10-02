# Agrégation et types de métriques

## Jauge

Les jauges donnent un aperçu instantané de l'état, et généralement lors de leur agrégation, vous voulez prendre une somme, une moyenne, un minimum ou un maximum.

Considérez la métrique `node_filesystem_size_bytes` de votre Node Exporter, qui rapporte la taille de chacun de vos systèmes de fichiers montés et possède des étiquettes `device`, `fstype` et `mountpoint`. Vous pouvez calculer la taille totale du système de fichiers sur chaque machine avec:

```
sum without(device, fstype, mountpoint)(node_filesystem_size_bytes)
```

Cela fonctionne car `without` indique à l'agrégateur `sum` de tout additionner avec les mêmes étiquettes, en ignorant ces trois-là.

Vous pouvez utiliser la même approche avec d'autres agrégations. `max` vous indiquerait la taille du plus grand système de fichiers monté sur chaque machine:

```
max without(device, fstype, mountpoint)(node_filesystem_size_bytes)
```

Les étiquettes renvoyées sont exactement les mêmes que lorsque vous avez agrégé en utilisant `sum`:

Cette prévisibilité dans les étiquettes retournées est importante pour la correspondance vectorielle avec les opérateurs.

Vous n'êtes pas limité à agréger des métriques sur un type de tâche. Par exemple, pour trouver le nombre moyen de descripteurs de fichiers ouverts à travers tous vos jobs, vous pourriez utiliser:

```
avg without(instance, job)(process_open_fds)
```

## Compteur

```
rate(node_network_receive_bytes_total[5m])
```

La sortie de `rate` est une jauge, donc les mêmes agrégations s'appliquent que pour les jauges. La métrique `node_network_receive_bytes_total` a une étiquette `device`, donc si vous l'agrégégez, vous obtiendrez le total des octets reçus par machine par seconde:

```
sum without(device)(rate(node_network_receive_bytes_total[5m]))
```

Vous pouvez filtrer les séries temporelles à demander, donc vous pourriez uniquement regarder `eth0` puis l'agrégéger sur toutes les machines en agrégeant l'étiquette `instance`:

```
sum without(instance)(rate(node_network_receive_bytes_total{device="eth0"}[5m]))
```

## Summary

Une métrique de résumé contiendra généralement à la fois un `_sum` et un `_count`, et parfois une série temporelle sans suffixe avec une étiquette `quantile`. Votre Prometheus expose un résumé `http_response_size_bytes` pour la quantité de données de certaines de ses API HTTP.

`http_response_size_bytes_count` suit le nombre de requêtes, et comme il s'agit d'un compteur, vous devez utiliser `rate` avant d'agréger son étiquette `handler`:

```
sum without(handler)(rate(http_response_size_bytes_count[5m]))
```

La puissance d'un résumé est qu'il vous permet de calculer la taille moyenne d'un événement, dans ce cas, la quantité moyenne d'octets qui sont retournés dans chaque réponse. Si vous aviez trois réponses de taille 1, 4 et 7, alors la moyenne serait leur somme divisée par leur nombre, soit 12 divisé par 3. Il en va de même pour le résumé. Vous divisez le `_sum` par le `_count` (après avoir pris un `rate`) pour obtenir une moyenne sur une période:

```
  sum without(handler)(rate(http_response_size_bytes_sum[5m]))
/
  sum without(handler)(rate(http_response_size_bytes_count[5m]))
```

L'opérateur de division associe les séries temporelles avec les mêmes étiquettes et divise, vous donnant les mêmes deux séries temporelles, mais avec la taille moyenne de la réponse sur les 5 dernières minutes en tant que valeur.

Si vous vouliez obtenir la taille moyenne de la réponse pour toutes les instances d'un job, vous pourriez faire:

```
  sum without(instance)(
    sum without(handler)(rate(http_response_size_bytes_sum[5m]))
  )
/
  sum without(instance)(
    sum without(handler)(rate(http_response_size_bytes_count[5m]))
  )
```

## Histogrammes

Les métriques d'histogrammes vous permettent de suivre la distribution de la taille des événements, vous permettant de calculer les quantiles.

`prometheus_tsdb_compaction_duration_seconds` qui suit combien de secondes la compaction prend pour la base de données de séries temporelles. Cette métrique d'histogramme a des séries temporelles avec un suffixe `_bucket` appelé `prometheus_tsdb_compaction_duration_seconds_bucket`. Chaque bucket a une étiquette `le`, qui est un compteur de combien d'événements ont une taille inférieure ou égale à la limite du bucket.

C'est un détail de mise en œuvre dont vous n'avez généralement pas à vous soucier car la fonction `histogram_quantile` s'en occupe lors du calcul des quantiles. Par exemple, le quantile 0,90 serait:

```
histogram_quantile(
    0.90,
    rate(prometheus_tsdb_compaction_duration_seconds_bucket[1d]))
```

Comme `prometheus_tsdb_compaction_duration_seconds_bucket` est un compteur, vous devez d'abord prendre un `rate`

```
{instance="localhost:9090",job="prometheus"} 7.720000000000001
```

Cela indique que la latence de compaction sur le percentile 90 était de 7,72 secondes pour la dernière journée sur l'instance de votre Prometheus.

Les métriques d'histogrammes ont également un `_sum` et un `_count`, ce qui signifie que vous pouvez également calculer la taille moyenne d'un événement comme vous l'avez fait pour un résumé:

```
  sum without(job)(rate(prometheus_tsdb_compaction_duration_seconds_sum[1d]))
/
  sum without(job)(rate(prometheus_tsdb_compaction_duration_seconds_count[1d]))
```

Cette métrique d'histogramme peut également avoir une étiquette `le`, donc si vous agrégez le `_bucket`, vous voudrez agréger cette étiquette également:

```
sum without(job, le)(rate(prometheus_tsdb_compaction_duration_seconds_bucket[1d]))
```

## Plus sur l'agrégation

`sum by(job, instance, device)(node_filesystem_size_bytes)`

produira le même résultat que la requête de la section précédente utilisant without :

`sum without()(node_filesystem_size_bytes)`

Pour compter combien de machines exécutaient chaque version du noyau, vous pourriez utiliser :

`count by(release)(node_uname_info)`

Vous pouvez utiliser sum avec un by vide, et même omettre le by. C'est-à-dire que :

`sum by()(node_filesystem_size_bytes)`
`sum(node_filesystem_size_bytes)`

L'agrégateur avg renvoie la moyenne des valeurs des séries temporelles du groupe comme valeur pour le groupe. Par exemple :

`avg without(cpu)(rate(node_cpu_seconds_total[5m]))`

vous donnerait l'utilisation moyenne de chaque mode CPU pour chaque Node Exporter.

Cela vous donne exactement le même résultat que :

```
  sum without(cpu)(rate(node_cpu_seconds_total[5m]))
/
  count without(cpu)(rate(node_cpu_seconds_total[5m]))
```

L'agrégateur group renvoie 1 pour chacune des séries temporelles du groupe comme valeur pour le groupe. Par exemple :

```
count by (instance)(
  group by (fstype,instance) (node_filesystem_files)
)
```

pour retourner la taille du plus grand système de fichiers sur chaque instance :

```
max without(device, fstype, mountpoint)(node_filesystem_size_bytes)
```

`topk` et `bottomk` diffèrent des autres agrégateurs discutés jusqu'à présent de trois manières.
- les étiquettes des séries temporelles qu'ils renvoient pour un groupe ne sont pas les étiquettes du groupe;
- ils peuvent renvoyer plus d'une série temporelle par groupe;
- ils prennent un paramètre supplémentaire.

topk renvoie les k séries temporelles avec les valeurs les plus élevées, donc par exemple :

```
topk without(device, fstype, mountpoint)(2, node_filesystem_size_bytes)
```

renverrait jusqu'à deux séries temporelles par groupe.
---
title: Cours - Le langage de requête PromQL - partie 2
# sidebar_class_name: hidden
---

## Avant de commencer `PromLens`

PromLens est une interface de requêtage de prometheus qui permet de décomposer et d'explorer les requêtes complexes.

Avant de commencer on peut l'installer avec :

- `docker run -p 8888:8080 prom/promlens` puis visitez `localhost:8888`

- Dans PromLens ajoutez `localhost:9090` (ou autre) comme serveur Prometheus

Cette interface va nous permettre de bien comprendre les expressions complexes.

## Structure typée du langage PromQL

PromQL est une sorte de langage fonctionnel. Les expressions sont typées.

Il y a deux concepts de "type" qui apparaissent dans Prometheus :

1. Le type d'une métrique, tel que rapporté par une cible interrogée : `counter`, `gauge`, `histrogram`, `summary` ou non typé.
2. Le type d'une expression PromQL : chaîne de caractères, scalaire, `instant vector` ou `range vector`.

Chaque expression a un type, et chaque fonction, opérateur ou autre type d'opération nécessite que ses arguments soient d'un certain type d'expression.

Par exemple, la fonction `rate()` nécessite que son argument soit un `range vector`, mais `rate()` retourne un `instant vector`.

Les types d'expressions possibles en PromQL sont les suivants :

1. Chaîne de caractères. Elles n'apparaissent que comme arguments de certaines fonctions (comme label_join()) et ne sont pas beaucoup utilisées en PromQL.
2. Scalaire : Une valeur numérique unique comme 1,234 sans dimensions d'étiquette. Vous les verrez en tant que paramètres numériques de fonctions telles que histogram_quantile(0.9, …) ou topk(3, …), ainsi que dans les opérations arithmétiques.

3. `instant vector` : Un ensemble de séries temporelles étiquetées, avec un échantillon pour chaque série, tous avec le meme timestamp.

4. `range vector` : Un ensemble de séries temporelles étiquetées, avec une plage d'échantillons dans le temps pour chaque série. Il y deux façons de produire des vecteurs sur une plage en PromQL : en utilisant un sélecteur de vecteur sur une plage littéral dans votre requête (comme node_cpu_seconds_total[5m]), ou en utilisant une sous-requête (comme `...expression...[5m:10s]`).

Dans PromQL certaines fonctions ne fonctionnent que sur des métriques d'un type spécifique ! Par exemple, la fonction `histogram_quantile()` ne fonctionne que sur les métriques d'histogramme, `rate()` ne fonctionne que sur les métriques de compteur, et `deriv()` ne fonctionne que sur les jauges. 

### Instant Vector

Un sélecteur `instant vector` renvoie un `instant vector` des échantillons les plus récents avant le temps d'évaluation de la requête, ce qui signifie une liste de zéro ou plusieurs séries temporelles. Chaque série temporelle aura un échantillon, et un échantillon contient à la fois une valeur et un timestamp. 

<!-- Lorsque vous demandez l'utilisation actuelle de la mémoire, vous ne voulez pas que les échantillons d'une instance qui a été éteinte il y a plusieurs jours soient inclus, un concept connu sous le nom de *staleness*. -->

![](https://promlabs.com/images/instant_query_non_stale.svg)

### Range Vector

Il existe un second type de sélecteur que vous avez déjà vu, appelé le *range vector selector*. Contrairement à un sélecteur `instant vector`, qui renvoie un échantillon par série temporelle, un `range vector selector` peut renvoyer plusieurs échantillons pour chaque série temporelle.

![](https://promlabs.com/images/range_query.svg)

Les `range vectors` sont toujours utilisés avec la fonction `rate`, par exemple:

```
rate(process_cpu_seconds_total[1m])
```

Le `[1m]` transforme le sélecteur `instant vector` en `range vector selector`, et donne l'instruction à PromQL de renvoyer pour toutes les séries temporelles correspondant au sélecteur tous les échantillons pour la minute précédant le temps d'évaluation de la requête.

Exécutons : 
  - `process_cpu_seconds_total[1m]` 
  - `rate(process_cpu_seconds_total[1m])` 

#### Subqueries

Les `range vectors` ne peuvent pas être utilisés en combinaison avec des fonctions.

<!-- Si vous souhaitez combiner `max_over_time` avec `rate`, vous pouvez soit utiliser des recording rules, qui enregistreraient le résultat de la fonction `rate` et le passeraient à la fonction `max_over_time`, soit vous pouvez utiliser une **subquery**. -->
Si vous souhaitez combiner par exemple `max_over_time` avec `rate` vous pouvez utiliser une **subquery**.

Une sous-requête est une partie d'une requête qui vous permet de faire une `range query` à l'intérieur d'une requête.

```
max_over_time( rate(prometheus_http_requests_total[5m])[30m:1m])
```

La requête précédente exécute `rate(prometheus_http_requests_total[5m])` toutes les minutes (`1m`) pendant les 30 dernières minutes (`30m`), puis alimente le résultat dans une fonction `max_over_time()`.

Plus d'info sur les subqueries et leurs motivations : https://prometheus.io/blog/2019/01/28/subquery-support/

## Opérations

### Arithmétiques

PromQL prend en charge toutes les [opérations arithmétiques de base](https://prometheus.io/docs/prometheus/latest/querying/operators/#arithmetic-binary-operators) suivantes :

-   addition (+)
-   soustraction (-)
-   multiplication (\*)
-   division (/)
-   modulo (%)
-   puissance (\^)

Cela permet d'effectuer diverses conversions. Par exemple, la conversion d'octets/s en bits/s :

```
rate(node_network_receive_bytes_total[5m]) * 8
```

De plus, cela permet d'effectuer de

```
rate(node_network_receive_bytes_total[5m]) * 8
```

De plus, cela permet d'effectuer des calculs entre différentes séries temporelles. Par exemple cette requête pour adapté le retour d'un capteur de CO2 IoT en fonction de la temperature et de la pression :

```
co2_amount * (((temperature_celsius + 273.15) * 1013.25) / (pressure * 298.15))
```

La combinaison de plusieurs séries temporelles avec des opérations arithmétiques nécessite de comprendre les règles de correspondance. Voir section suivante "operators and vector matching".

### Comparaison

PromQL prend en charge les [opérateurs de comparaison suivants](https://prometheus.io/docs/prometheus/latest/querying/operators/#comparison-binary-operators) :

-   égal (==)
-   différent (!=)
-   supérieur (\>)
-   supérieur ou égal (\>=)
-   inférieur (\<)
-   inférieur ou égal (\<=)

Ces opérateurs peuvent être appliqués à n'importe quelle expression PromQL, comme avec les opérateurs arithmétiques. Le résultat de l'opération de comparaison est une série temporelle avec uniquement les points de données correspondants. Par exemple, la requête suivante renverrait uniquement la bande passante inférieure à 1800 octets/s :

```
rate(node_network_receive_bytes_total[5m]) < 1800
```

Le résultat de l'opérateur de comparaison peut être augmenté avec le modificateur `bool` :

```
rate(node_network_receive_bytes_total[5m]) < bool 1800
```

Dans ce cas, le résultat contiendrait 1 pour les comparaisons vraies et 0 pour les comparaisons fausses.


### Travailler avec les jauges (Gauges)

Lorsqu'on vout faire des graphiques pour un jauge, on s'attend à voir en parrallèle des valeurs minimales, maximales, moyennes et/ou quantiles.

PromQL permet cela avec les fonctions suivantes :

-   `min_over_time()`
-   `max_over_time()`
-   `avg_over_time()`
-   `quantile_over_time()`

Par exemple, la requête suivante afficherait la valeur minimale de la mémoire libre pour chaque point du graphique :

```
min_over_time(node_memory_MemFree_bytes[5m])
```

## Agrégation et regroupement en détails

PromQL permet d'agréger et de regrouper des séries temporelles](https://prometheus.io/docs/prometheus/latest/querying/operators/#aggregation-operators).

Les séries temporelles sont regroupées par l'ensemble d'étiquettes donné, puis la fonction d'agrégation donnée est appliquée à chaque groupe. Par exemple, la requête suivante renverrait le trafic entrant total via chaque interface réseau groupées par instances (nœuds avec `node_exporter` installé) :

```
sum(rate(node_network_receive_bytes_total[5m])) by (instance)
```

### Jauge

Les jauges donnent un aperçu instantané de l'état, et généralement lors de leur agrégation, vous voulez prendre une somme, une moyenne, un minimum ou un maximum.

Par exemple la métrique `node_filesystem_size_bytes` du Node Exporter, qui rapporte la taille de chacun de vos systèmes de fichiers montés et possède des étiquettes `device`, `fstype` et `mountpoint`. Vous pouvez calculer la taille totale du système de fichiers sur chaque machine avec:

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

### Compteur

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

### Summary

Une métrique de résumé contiendra généralement à la fois un `_sum` et un `_count`, et parfois une série temporelle sans suffixe avec une étiquette `quantile`. Votre Prometheus expose un résumé `prometheus_http_response_size_bytes` pour la quantité de données de certaines de ses API HTTP.

`prometheus_http_response_size_bytes_count` suit le nombre de requêtes, et comme il s'agit d'un compteur, vous devez utiliser `rate` avant d'agréger son étiquette `handler`:

```
sum without(handler)(rate(prometheus_http_response_size_bytes_count[5m]))
```

La puissance d'un résumé est qu'il vous permet de calculer la taille moyenne d'un événement, dans ce cas, la quantité moyenne d'octets qui sont retournés dans chaque réponse. Si vous aviez trois réponses de taille 1, 4 et 7, alors la moyenne serait leur somme divisée par leur nombre, soit 12 divisé par 3. Il en va de même pour le résumé. Vous divisez le `_sum` par le `_count` (après avoir pris un `rate`) pour obtenir une moyenne sur une période:

```
  sum without(handler)(rate(prometheus_http_response_size_bytes_sum[5m]))
/
  sum without(handler)(rate(prometheus_http_response_size_bytes_count[5m]))
```

L'opérateur de division associe les séries temporelles avec les mêmes étiquettes et divise, vous donnant les mêmes deux séries temporelles, mais avec la taille moyenne de la réponse sur les 5 dernières minutes en tant que valeur.

Si vous vouliez obtenir la taille moyenne de la réponse pour toutes les instances d'un job, vous pourriez faire:

```
  sum without(instance)(
    sum without(handler)(rate(prometheus_http_response_size_bytes_sum[5m]))
  )
/
  sum without(instance)(
    sum without(handler)(rate(prometheus_http_response_size_bytes_count[5m]))
  )
```

### Histogrammes

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


`sum by(job, instance, device)(node_filesystem_size_bytes)`

produira le même résultat que la requête de la section précédente utilisant without :

`sum without()(node_filesystem_size_bytes)`

Vous pouvez utiliser sum avec un by vide, et même omettre le by. C'est-à-dire que :

`sum by()(node_filesystem_size_bytes)`
`sum(node_filesystem_size_bytes)`

### Autre aggrégations

#### `count`

Pour compter combien de machines exécutaient chaque version du noyau, vous pourriez utiliser :

`count by(release)(node_uname_info)`

#### `avg`

L'agrégateur avg renvoie la moyenne des valeurs des séries temporelles du groupe comme valeur pour le groupe. Par exemple :

`avg without(cpu)(rate(node_cpu_seconds_total[5m]))`

vous donnerait l'utilisation moyenne de chaque mode CPU pour chaque Node Exporter.

Cela vous donne exactement le même résultat que :

```
  sum without(cpu)(rate(node_cpu_seconds_total[5m]))
/
  count without(cpu)(rate(node_cpu_seconds_total[5m]))
```

#### `group`

L'agrégateur group renvoie 1 pour chacune des séries temporelles du groupe comme valeur pour le groupe. Par exemple :

```
count by (instance)(
  group by (fstype,instance) (node_filesystem_files)
)
```

#### `max`

pour retourner la taille du plus grand système de fichiers sur chaque instance :

```
max without(device, fstype, mountpoint)(node_filesystem_size_bytes)
```

#### `topk` et `bottomk`


topk renvoie les k séries temporelles avec les valeurs les plus élevées, donc par exemple :

```
topk without(device, fstype, mountpoint)(2, node_filesystem_size_bytes)
```

renverrait jusqu'à deux séries temporelles par groupe.

`topk` et `bottomk` diffèrent des autres agrégateurs:
- les étiquettes des séries temporelles qu'ils renvoient pour un groupe ne sont pas les étiquettes du groupe;
- ils peuvent renvoyer plus d'une série temporelle par groupe;
- ils prennent un paramètre supplémentaire.


## Operateurs et `vector matching`.


Lorsque vous avez un scalaire et un vecteur instantané, il est clair que le scalaire peut être appliqué à chaque échantillon du vecteur.

Avec deux vecteurs instantanés, quels échantillons doivent s'appliquer à quels autres échantillons ? Cette mise en correspondance des vecteurs instantanés c'est le `vector matching`.

### Matching One-to-one

Dans les cas les plus simples, il y aura une correspondance un-à-un entre vos deux vecteurs. Par exemple avec les échantillons suivants :

```
process_open_fds{instance="localhost:9090",job="prometheus"} 14
process_open_fds{instance="localhost:9100",job="node"} 7
process_max_fds{instance="localhost:9090",job="prometheus"} 1024
process_max_fds{instance="localhost:9100",job="node"} 1024
```
Lorsqu'on évalue l'expression :

```
process_open_fds
/
process_max_fds
```

On obtient :

```
{instance="localhost:9090",job="prometheus"} 0.013671875
{instance="localhost:9100",job="node"} 0.0068359375
```

Dans cet exemple les échantillons ayant exactement les mêmes étiquettes ont été mis en correspondance.

<!-- C'est-à-dire que les deux échantillons avec les étiquettes `{instance="localhost:9090",job="prometheus"}` ont été mis en correspondance, de même que les deux échantillons avec les étiquettes `{instance="localhost:9100",job="node"}`. -->

Si un échantillon d'un côté n'avait pas de correspondance de l'autre côté, il ne serait pas présent dans le résultat.

Donc si un opérateur binaire renvoie un vecteur instantané vide alors que vous vous attendiez à un résultat, c'est probablement parce que les étiquettes des échantillons ne correspondent pas.

#### Corriger la correspondance avec `ignoring` ou `on`

Parfois, on veut mettre en correspondance deux vecteurs instantanés dont les étiquettes ne correspondent pas tout à fait.

Vous pouvez utiliser la clause `ignoring` pour ignorer certaines étiquettes lors de la mise en correspondance, de la même manière que `without` fonctionne pour l'agrégation.

Par exemple avec `node_cpu_seconds_total`, qui a `cpu` et `mode` comme étiquettes, on veut savoir quelle proportion de temps est passée en mode `idle` pour chaque instance. Vous pourriez utiliser l'expression :

```
sum without(cpu)(rate(node_cpu_seconds_total{mode="idle"}[5m]))
/ ignoring(mode)
sum without(mode, cpu)(rate(node_cpu_seconds_total[5m]))
```

<!-- Ici, la première somme produit un vecteur instantané avec une étiquette `mode="idle"`, tandis que la deuxième somme produit un vecteur instantané sans étiquette mode; Donc la mise en correspondance échouera, mais avec `ignoring(mode)`, l'étiquette `mode` est écartée lorsque les vecteurs sont groupés, et la mise en correspondance réussit. -->

<!-- Vous pouvez dire que l'expression précédente est correcte en termes de mise en correspondance de vecteurs par inspection, sans avoir besoin de savoir quoi que ce soit sur les séries temporelles sous-jacentes. La suppression de `cpu` est équilibrée des deux côtés, et `ignoring(mode)` définit un côté ayant un mode et l'autre non. -->

Cela peut être plus délicat lorsqu'il y a différentes séries temporelles avec différentes étiquettes en jeu, mais regarder les expressions en termes de flux d'étiquettes est un moyen pratique de repérer les erreurs.

Inversement à `ignoring`, la clause `on` vous permet de ne considérer que les étiquettes que vous fournissez, de la même manière que `by` fonctionne pour l'agrégation. L'expression :

```
sum by(instance, job)(rate(node_cpu_seconds_total{mode="idle"}[5m]))
/ on(instance, job)
sum by(instance, job)(rate(node_cpu_seconds_total[5m]))
```

produira le même résultat que l'expression précédente, mais, comme avec `by`, la clause `on` a l'inconvénient que vous devez connaître toutes les étiquettes qui sont actuellement sur la série temporelle ou qui pourraient être présentes à l'avenir dans d'autres contextes.

### Many-to-One et group_left

Si vous enlevez le sélecteur de mode de la section précédente et essayez d'évaluer :

```
sum without(cpu)(rate(node_cpu_seconds_total[5m]))
/ ignoring(mode)
sum without(mode, cpu)(rate(node_cpu_seconds_total[5m]))
```

vous obtiendriez l'erreur :

```
multiple matches for labels:
many-to-one matching must be explicit (group_left/group_right)
```

C'est parce que les échantillons ne correspondent plus un à un, car il y a plusieurs échantillons avec différentes étiquettes de mode du côté gauche pour chaque échantillon du côté droit. 

Pour permettre une mise en correspondance many-to-one, vous devez utiliser l'une des clauses `group_left` ou `group_right`. Cela vous permet également de spécifier quelles étiquettes supplémentaires de l'un des côtés devraient être ajoutées au résultat. Si vous aviez :

```
{instance="localhost:9100",job="node",mode="idle"} 0.011925469456547387
{instance="localhost:9100",job="node",mode="iowait"} 0.0002972023431592654
{instance="localhost:9100",job="node",mode="irq"} 0
{instance="localhost:9100",job="node",mode="softirq"} 0.0002972023431592654
{instance="localhost:9100",job="node",mode="system"} 0.0022416898688135034
{instance="localhost:9100",job="node",mode="user"} 0.015783773793147826
{instance="localhost:9100",job="node"} 0.8431634141517998
```

vous pourriez obtenir les mêmes valeurs que précédemment en utilisant :

```
sum without(cpu)(rate(node_cpu_seconds_total[5m]))
/ on(instance, job)
group_left(mode)
sum without(mode, cpu)(rate(node_cpu_seconds_total[5m]))
```

Notez que `group_left(mode)` n'est pas la même chose que `by(mode)`. L'agrégation par mode produirait un vecteur instantané avec une seule étiquette mode, tandis que `group_left(mode)` produit un vecteur instantané avec toutes les étiquettes sauf mode.

Comme pour l'agrégation, vous devez vous assurer que vous avez un nombre équilibré de suppressions d'étiquettes des deux côtés de l'opérateur. Ici, l'utilisation de `without(cpu)` du côté gauche et de `without(mode, cpu)` du côté droit est équilibrée par l'utilisation de `group_left(mode)`.

L'utilisation de `group_right` fonctionne de la même manière, mais avec le côté droit du groupe.

<!-- Si vous deviez utiliser `group_left` ou `group_right` dépend de la façon dont vos données sont structurées. Une règle empirique est d'utiliser `group_left` si le côté gauche a plus d'étiquettes que le côté droit et vice versa, mais cela dépendra toujours de la façon dont les données sont structurées. En pratique, `group_left` est le plus souvent utilisé. -->

<!-- `group_left` prend toujours tous ses libellés des échantillons de votre opérande du côté gauche. Cela garantit que les libellés supplémentaires présents du côté gauche qui nécessitent une correspondance vectorielle de plusieurs à un sont conservés. -->


<!-- C'est beaucoup plus simple que de devoir exécuter une expression un à un avec un apparieur pour chaque libellé potentiel : `group_left` fait tout pour vous en une seule expression. Vous pouvez utiliser cette approche pour déterminer la proportion que chaque valeur de libellé représente dans une métrique par rapport à l'ensemble, comme illustré dans l'exemple précédent, ou pour comparer une métrique d'un leader d'un cluster par rapport aux répliques. -->

Il y a une autre utilisation pour `group_left` - ajouter des libellés de métriques d'info à d'autres métriques d'une cible.

<!-- L'instrumentation avec des métriques d'info a été couverte dans "Info". Le rôle des métriques d'info est de vous permettre de fournir des libellés utiles pour une cible ou une métrique, mais qui encombreraient la métrique si vous deviez l'utiliser comme libellé normal. -->

La métrique `prometheus_build_info`, par exemple, vous fournit des informations de construction de Prometheus :

``` 
prometheus_build_info{branch="HEAD", goversion="go1.10", instance="localhost:9090", job="prometheus", revision="bc6058c81272a8d938c05e75607371284236aadc", version="2.2.1"} 
```

Vous pouvez la joindre à des métriques telles que `up` :

```
up * on(instance) group_left(version) prometheus_build_info
```

Ce qui produira un résultat comme :

```
{instance="localhost:9090", job="prometheus", version="2.2.1"} 1
```

Vous pouvez voir que le libellé de version a été copié de l'opérande de droite à l'opérande de gauche comme l'avait demandé `group_left(version)`, en plus de retourner tous les libellés de l'opérande de gauche comme le fait habituellement `group_left`.

<!-- Vous pouvez spécifier autant de libellés que vous le souhaitez à `group_left`, mais généralement c'est seulement un ou deux. Cette approche fonctionne quel que soit le nombre de libellés d'instrumentation que le côté gauche possède, car la correspondance vectorielle est de plusieurs à un. -->

L'expression précédente utilisait `on(instance)`, ce qui suppose que chaque libellé d'instance n'est utilisé que pour une cible dans votre Prometheus.Bien que ce soit souvent le cas, ce n'est pas toujours le cas, vous devrez donc peut-être ajouter d'autres libellés tels que `job` à la clause `on`.
<!-- 

`node_hwmon_sensor_label` est un exemple de metrique qui ne s'applique pas à une cible (target) entiere:

```
node_hwmon_sensor_label{chip="platform_coretemp_0", instance="localhost:9100", job="node", label="core_0", sensor="temp2"} 1
node_hwmon_sensor_label{chip="platform_coretemp_0",instance="localhost:9100",
    job="node",label="core_1",sensor="temp3"} 1
node_hwmon_temp_celsius{chip="platform_coretemp_0",instance="localhost:9100",
    job="node",sensor="temp1"} 42
node_hwmon_temp_celsius{chip="platform_coretemp_0",instance="localhost:9100",
    job="node",sensor="temp2"} 42
node_hwmon_temp_celsius{chip="platform_coretemp_0",instance="localhost:9100",
    job="node",sensor="temp3"} 41
```

La métrique **node_hwmon_sensor_label** a des enfants qui correspondent à certaines (mais pas toutes) les séries temporelles dans **node_hwmon_temp_celsius**. Dans ce cas, vous savez qu'il n'y a qu'une étiquette supplémentaire (appelée `label`), vous pouvez donc utiliser `ignoring` avec `group_left` pour ajouter cette étiquette aux échantillons **node_hwmon_temp_celsius** :

```
  node_hwmon_temp_celsius
* ignoring(label) group_left(label)
  node_hwmon_sensor_label
```

ce qui produira des résultats tels que :

```
{chip="platform_coretemp_0",instance="localhost:9100", job="node",label="core_0",sensor="temp2"} 42
{chip="platform_coretemp_0",instance="localhost:9100", job="node",label="core_1",sensor="temp3"} 41
```

Notez qu'il n'y a pas d'échantillon avec `sensor="temp1"` car il n'y avait pas un tel échantillon dans **node_hwmon_sensor_label** (comment associer des vecteurs instantanés clairsemés sera couvert dans "opérateur or").

Il existe également un modificateur *group_right* qui fonctionne de la même manière que *group_left*, sauf que les côtés "un" et "plusieurs" sont inversés, le côté "plusieurs" étant maintenant votre opérande sur le côté droit. Pour des raisons de cohérence, vous devriez préférer *group_left*. -->

### Matching many-to-many et opérateurs logiques

Il existe trois opérateurs logiques "ensemblistes" que vous pouvez utiliser :

`or` union

`and` intersection

`unless` soustraction d'ensemble

Tous les opérateurs logiques fonctionnent en mode **many-to-many**, et ils sont les seuls opérateurs à fonctionner de cette manière.

<!-- Ils diffèrent des opérateurs arithmétiques et de comparaison que vous avez déjà vus en ce qu'aucune mathématique n'est effectuée; tout ce qui compte, c'est qu'un groupe contient des échantillons. -->

#### Exemple, l' opérateur `or`

Souvent, dans le cas ou une métrique n'existe pas on voudrait pouvoir renvoyer `0` à la place. On peut pour cela combiner la metrique "qui n'existe pas forcément" avec `up` et `or`:

<!-- ```
  node_custom_metric
or
  up * 0
```

Cela pose un petit problème en ce qu'il renverra une valeur même pour un prélèvement échoué, ce qui n'est pas le fonctionnement des métriques prélevées. Il renverra également des résultats pour d'autres emplois. Vous pouvez corriger cela avec un sélecteur et un filtrage : -->

```
  node_custom_metric
or
  up{job="node"} * 0
```

<!-- La deuxième opérande ne retournera que des échantillons où le job est node. Le nom de la métrique sera supprimé en raison de l'opérateur arithmétique utilisé. -->


<!-- Dans la section précédente, **node_hwmon_sensor_label** n'avait pas d'échantillon pour chaque **node_hwmon_temp_celsius**, donc les résultats n'étaient renvoyés que pour les échantillons présents dans les deux vecteurs instantanés. Les métriques avec des enfants incohérents, ou dont les enfants ne sont pas toujours présents, sont difficiles à gérer, mais vous pouvez les traiter avec l'opérateur or. -->

L'opérateur `or` fonctionne de telle sorte que pour chaque groupe où le groupe du côté gauche a des échantillons, alors ils sont renvoyés; sinon, les échantillons du groupe du côté droit sont renvoyés.

<!-- Si vous êtes familiarisé avec SQL, cet opérateur peut être utilisé de manière similaire à la fonction SQL COALESCE, mais avec des étiquettes. -->

<!-- En poursuivant l'exemple de la section précédente, -->

`or` peut être utilisé pour des substitutions dans des séries temporelles ou il manquerait des étiquettes pour un matching comme **node_hwmon_sensor_label** (le label `label` n'est n'est pas dans le deuxième métrique):

```
node_hwmon_sensor_label{chip="platform_coretemp_0", instance="localhost:9100", job="node", label="core_0", sensor="temp2"} 1
node_hwmon_sensor_label{chip="platform_coretemp_0",instance="localhost:9100", job="node",label="core_1",sensor="temp3"} 1
node_hwmon_temp_celsius{chip="platform_coretemp_0",instance="localhost:9100", job="node",sensor="temp1"} 42
node_hwmon_temp_celsius{chip="platform_coretemp_0",instance="localhost:9100", job="node",sensor="temp2"} 42
node_hwmon_temp_celsius{chip="platform_coretemp_0",instance="localhost:9100", job="node",sensor="temp3"} 41
```

Tout ce dont vous avez besoin, c'est d'une autre série temporelle qui a les étiquettes dont vous avez besoin, ce qui dans ce cas est **node_hwmon_temp_celsius**. **node_hwmon_temp_celsius** n'a pas l'étiquette label, mais toutes les autres étiquettes correspondent, donc vous pouvez ignorer cela en utilisant *ignoring* :

```
  node_hwmon_sensor_label
or ignoring(label)
  (node_hwmon_temp_celsius * 0 + 1)
```

La correspondance vectorielle a produit trois groupes d'étiquettes. Les deux premiers groupes avaient un échantillon de **node_hwmon_sensor_label** donc c'était ce qui était renvoyé, y compris le nom de la métrique car il n'y avait rien à changer. Pour le troisième groupe, cependant, qui comprenait `sensor="temp1"`, il n'y avait pas d'échantillon dans le groupe pour le côté gauche, donc les valeurs du groupe du côté droit étaient utilisées. Comme des opérateurs arithmétiques ont été utilisés sur la valeur, le nom de la métrique a été supprimé.

x * 0 + 1 changera toutes les valeurs du vecteur instantané x en 1. Ceci est également utile lorsque vous voulez utiliser *group_left* pour copier des étiquettes, car 1 est l'élément identité pour la multiplication, c'est-à-dire qu'il ne change pas la valeur que vous multipliez.

Cette expression peut maintenant être utilisée à la place de **node_hwmon_sensor_label** :

```
node_hwmon_temp_celsius
* ignoring(label) group_left(label)
  (
      node_hwmon_sensor_label
    or ignoring(label)
      (node_hwmon_temp_celsius * 0 + 1)
  )
```

ce qui produira :

```
{chip="platform_coretemp_0",instance="localhost:9100", job="node",sensor="temp1"} 42
{chip="platform_coretemp_0",instance="localhost:9100", job="node",label="core_0",sensor="temp2"} 42
{chip="platform_coretemp_0",instance="localhost:9100",    job="node",label="core_1",sensor="temp3"} 41
```

L'échantillon avec `sensor="temp1"` est maintenant présent dans le résultat.

<!-- Il n'a pas d'étiquette appelée label, ce qui revient à dire que cette étiquette label a la chaîne vide comme valeur. -->

<!-- Dans des cas plus simples, vous travaillerez avec des métriques sans étiquettes d'instrumentation. -->


<!-- Par exemple, vous pourriez utiliser le collecteur textfile, comme décrit dans "Textfile Collector", et vous attendre à ce qu'il expose une métrique appelée **node_custom_metric**. Dans le cas où cette métrique n'existerait pas, vous aimeriez renvoyer 0 à la place. Dans des cas comme celui-ci, vous pouvez utiliser la métrique up associée à chaque cible : -->


sources :
- https://valyala.medium.com/promql-tutorial-for-beginners-9ab455142085
- https://promlabs.com/blog/2020/06/18/the-anatomy-of-a-promql-query/
- Livre Prometheus de Oreilly


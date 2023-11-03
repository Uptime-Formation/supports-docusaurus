---
title: Cours - Vector matching et opérateurs
sidebar_class_name: hidden
---

Lorsque vous avez un scalaire et un vecteur instantané, il est clair que le scalaire peut être appliqué à chaque échantillon du vecteur. Avec deux vecteurs instantanés, quels échantillons doivent s'appliquer à quels autres échantillons ? Cette mise en correspondance des vecteurs instantanés c'est le `vector matching`.

## Matching One-to-one

Dans les cas les plus simples, il y aura une correspondance un-à-un entre vos deux vecteurs. Disons que vous avez les échantillons suivants :

```
process_open_fds{instance="localhost:9090",job="prometheus"} 14
process_open_fds{instance="localhost:9100",job="node"} 7
process_max_fds{instance="localhost:9090",job="prometheus"} 1024
process_max_fds{instance="localhost:9100",job="node"} 1024
```
Lorsque vous évaluez l'expression :

```
process_open_fds
/
process_max_fds
```

vous obtiendrez le résultat :

```
{instance="localhost:9090",job="prometheus"} 0.013671875
{instance="localhost:9100",job="node"} 0.0068359375
```

Ce qui s'est passé ici, c'est que les échantillons ayant exactement les mêmes étiquettes, à l'exception du nom de la métrique dans l'étiquette __name__, ont été mis en correspondance.

C'est-à-dire que les deux échantillons avec les étiquettes {instance="localhost:9090",job="prometheus"} ont été mis en correspondance, de même que les deux échantillons avec les étiquettes {instance="localhost:9100",job="node"}.

Si un échantillon d'un côté n'avait pas de correspondance de l'autre côté, il ne serait pas présent dans le résultat, car les opérateurs binaires nécessitent deux opérandes.

Si un opérateur binaire renvoie un vecteur instantané vide alors que vous vous attendiez à un résultat, c'est probablement parce que les étiquettes des échantillons dans les opérandes ne correspondent pas. Cela est souvent dû à une étiquette présente d'un côté de l'opérateur mais pas de l'autre.

Parfois, vous voudrez mettre en correspondance deux vecteurs instantanés dont les étiquettes ne correspondent pas tout à fait. De la même manière que l'agrégation vous permet de spécifier quelles étiquettes sont importantes.

Vous pouvez utiliser la clause `ignoring` pour ignorer certaines étiquettes lors de la mise en correspondance, de la même manière que without fonctionne pour l'agrégation. Disons que vous travaillez avec `node_cpu_seconds_total`, qui a cpu et mode comme étiquettes d'instrumentation, et que vous voulez savoir quelle proportion de temps est passée en mode inactif pour chaque instance. Vous pourriez utiliser l'expression :

```
sum without(cpu)(rate(node_cpu_seconds_total{mode="idle"}[5m]))
/ ignoring(mode)
sum without(mode, cpu)(rate(node_cpu_seconds_total[5m]))
```

Ici, la première somme produit un vecteur instantané avec une étiquette `mode="idle"`, tandis que la deuxième somme produit un vecteur instantané sans étiquette mode.

Habituellement, la mise en correspondance des vecteurs échouera à faire correspondre les échantillons, mais avec `ignoring(mode)`, l'étiquette mode est écartée lorsque les vecteurs sont groupés, et la mise en correspondance réussit. Comme l'étiquette mode n'était pas dans le groupe de correspondance, elle n'est pas dans la sortie.

Vous pouvez dire que l'expression précédente est correcte en termes de mise en correspondance de vecteurs par inspection, sans avoir besoin de savoir quoi que ce soit sur les séries temporelles sous-jacentes. La suppression de `cpu` est équilibrée des deux côtés, et `ignoring(mode)` définit un côté ayant un mode et l'autre non.

Cela peut être plus délicat lorsqu'il y a différentes séries temporelles avec différentes étiquettes en jeu, mais regarder les expressions en termes de flux d'étiquettes est un moyen pratique pour vous de repérer les erreurs.

La clause `on` vous permet de ne considérer que les étiquettes que vous fournissez, de la même manière que `by` fonctionne pour l'agrégation. L'expression :

```
sum by(instance, job)(rate(node_cpu_seconds_total{mode="idle"}[5m]))
/ on(instance, job)
sum by(instance, job)(rate(node_cpu_seconds_total[5m]))
```

produira le même résultat que l'expression précédente, mais, comme avec `by`, la clause `on` a l'inconvénient que vous devez connaître toutes les étiquettes qui sont actuellement sur la série temporelle ou qui pourraient être présentes à l'avenir dans d'autres contextes.

## Many-to-One et group_left

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

Comme pour l'agrégation, vous devez vous assurer que vous avez un nombre équilibré de suppressions d'étiquettes des deux côtés de l'opérateur. Ici, l'utilisation de `without(cpu)` du côté gauche et de `without(mode, cpu)` du côté droit est équilibrée par l'utilisation de `group_left(mode)`. Si vous omettiez le mode, la mise en correspondance des vecteurs échouerait.

L'utilisation de `group_right` fonctionnerait de la même manière, mais avec le côté droit du groupe. Si vous deviez utiliser `group_left` ou `group_right` dépend de la façon dont vos données sont structurées. Une règle empirique est d'utiliser `group_left` si le côté gauche a plus d'étiquettes que le côté droit et vice versa, mais cela dépendra toujours de la façon dont les données sont structurées. En pratique, `group_left` est le plus souvent utilisé.



`group_left` prend toujours tous ses libellés des échantillons de votre opérande du côté gauche. Cela garantit que les libellés supplémentaires présents du côté gauche qui nécessitent une correspondance vectorielle de plusieurs à un sont conservés.


C'est beaucoup plus simple que de devoir exécuter une expression un à un avec un apparieur pour chaque libellé potentiel : `group_left` fait tout pour vous en une seule expression. Vous pouvez utiliser cette approche pour déterminer la proportion que chaque valeur de libellé représente dans une métrique par rapport à l'ensemble, comme illustré dans l'exemple précédent, ou pour comparer une métrique d'un leader d'un cluster par rapport aux répliques.

Il y a une autre utilisation pour `group_left` - ajouter des libellés des métriques d'info à d'autres métriques d'une cible. L'instrumentation avec des métriques d'info a été couverte dans "Info". Le rôle des métriques d'info est de vous permettre de fournir des libellés utiles pour une cible ou une métrique, mais qui encombreraient la métrique si vous deviez l'utiliser comme libellé normal.

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

Vous pouvez voir que le libellé de version a été copié de l'opérande de droite à l'opérande de gauche comme l'avait demandé `group_left(version)`, en plus de retourner tous les libellés de l'opérande de gauche comme le fait habituellement `group_left`. Vous pouvez spécifier autant de libellés que vous le souhaitez à `group_left`, mais généralement c'est seulement un ou deux. Cette approche fonctionne quel que soit le nombre de libellés d'instrumentation que le côté gauche possède, car la correspondance vectorielle est de plusieurs à un.

L'expression précédente utilisait `on(instance)`, ce qui suppose que chaque libellé d'instance n'est utilisé que pour une cible dans votre Prometheus. Bien que ce soit souvent le cas, ce n'est pas toujours le cas, vous devrez donc peut-être ajouter d'autres libellés tels que `job` à la clause `on`.

`prometheus_build_info` s'applique à une cible entière. Il existe également des métriques de style info, comme `node_hwmon_sensor_label` mentionné dans "Hwmon Collector", qui s'appliquent aux enfants d'une métrique différente :

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

La métrique **node_hwmon_sensor_label** a des enfants qui correspondent à certaines (mais pas toutes) des séries temporelles dans **node_hwmon_temp_celsius**. Dans ce cas, vous savez qu'il n'y a qu'une étiquette supplémentaire (appelée étiquette), vous pouvez donc utiliser *ignoring* avec *group_left* pour ajouter cette étiquette aux échantillons **node_hwmon_temp_celsius** :

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

Il existe également un modificateur *group_right* qui fonctionne de la même manière que *group_left*, sauf que les côtés "un" et "plusieurs" sont inversés, le côté "plusieurs" étant maintenant votre opérande sur le côté droit. Pour des raisons de cohérence, vous devriez préférer *group_left*.

## Matching many-to-many et opérateurs logiques

Il existe trois opérateurs logiques ou d'ensemble que vous pouvez utiliser :

`or` union

`and` intersection

`unless` soustraction d'ensemble

Tous les opérateurs logiques fonctionnent en mode beaucoup-à-beaucoup, et ils sont les seuls opérateurs à fonctionner de cette manière. Ils diffèrent des opérateurs arithmétiques et de comparaison que vous avez déjà vus en ce qu'aucune mathématique n'est effectuée; tout ce qui compte, c'est qu'un groupe contient des échantillons.

#### Opérateur or

Dans la section précédente, **node_hwmon_sensor_label** n'avait pas d'échantillon pour chaque **node_hwmon_temp_celsius**, donc les résultats n'étaient renvoyés que pour les échantillons présents dans les deux vecteurs instantanés. Les métriques avec des enfants incohérents, ou dont les enfants ne sont pas toujours présents, sont difficiles à gérer, mais vous pouvez les traiter avec l'opérateur or.

L'opérateur or fonctionne de telle sorte que pour chaque groupe où le groupe du côté gauche a des échantillons, alors ils sont renvoyés; sinon, les échantillons du groupe du côté droit sont renvoyés. Si vous êtes familiarisé avec SQL, cet opérateur peut être utilisé de manière similaire à la fonction SQL COALESCE, mais avec des étiquettes.

En poursuivant l'exemple de la section précédente, or peut être utilisé pour substituer les séries temporelles manquantes de **node_hwmon_sensor_label**. Tout ce dont vous avez besoin, c'est d'une autre série temporelle qui a les étiquettes dont vous avez besoin, ce qui dans ce cas est **node_hwmon_temp_celsius**. **node_hwmon_temp_celsius** n'a pas l'étiquette label, mais toutes les autres étiquettes correspondent, donc vous pouvez ignorer cela en utilisant *ignoring* :

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

L'échantillon avec `sensor="temp1"` est maintenant présent dans votre résultat. Il n'a pas d'étiquette appelée label, ce qui revient à dire que cette étiquette label a la chaîne vide comme valeur.

Dans des cas plus simples, vous travaillerez avec des métriques sans étiquettes d'instrumentation. Par exemple, vous pourriez utiliser le collecteur textfile, comme décrit dans "Textfile Collector", et vous attendre à ce qu'il expose une métrique appelée **node_custom_metric**. Dans le cas où cette métrique n'existerait pas, vous aimeriez renvoyer 0 à la place. Dans des cas comme celui-ci, vous pouvez utiliser la métrique up associée à chaque cible :

```
  node_custom_metric
or
  up * 0
```

Cela pose un petit problème en ce qu'il renverra une valeur même pour un prélèvement échoué, ce qui n'est pas le fonctionnement des métriques prélevées.16 Il renverra également des résultats pour d'autres emplois. Vous pouvez corriger cela avec un sélecteur et un filtrage :

```
  node_custom_metric
or
  up{job="node"} * 0
```

La deuxième opérande ne retournera que des échantillons où le job est node. Le nom de la métrique sera supprimé en raison de l'opérateur arithmétique utilisé.

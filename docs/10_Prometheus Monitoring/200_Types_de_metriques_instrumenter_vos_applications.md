---
title: Cours - Les types de métriques pour surveiller son application
draft: false
# sidebar_position: 6
---

Pour profiter d'un monitoring efficace avec Prometheus les applications doivent participer à produire et exposer les métriques pertinentes. Ces métriques doivent être conçues pour pouvoir comprendre le comportement de l'application.

Un exemple classique est de mesurer pour la plupart des requête vers un service les données 

Pour pouvoir instrumenter (to instrument) une application il existe des librairies client pour la plupart des langages. Ces librairies, a travers des appels dans le code de votre application vont permettre de 

Méthode RED : https://www.weave.works/blog/the-red-method-key-metrics-for-microservices-architecture/

## Quelques types de métriques

### Les compteurs (counters)

Les compteurs augmentent et se réinitialisent lorsque le processus redémarre.

C'est le type de métrique que vous utiliserez probablement le plus souvent dans l'instrumentation. Les compteurs permettent de suivre le nombre ou la taille des événements, plus techniquement de déterminer la fréquence d'exécution d'un chemin de code particulier.

Par exemple le nombre de réponses à une requête spécifique, ou le chiffre d'affaire cumulé d'un backend commercial etc.

### Les jauges (Gauges)

Les jauges (`Gauges`) mesure une valeur instantanée (un quantité) de l'état actuel de quelque chose dans le système.

Alors que, pour les compteurs, ce qui vous importe est la vitesse à laquelle il augmente, pour les jauges, c'est la valeur réelle de la jauge : les valeurs peuvent aussi bien augmenter que diminuer.

Exemples de jauges :
- Le nombre d'éléments dans une file d'attente
- Nombre moyen de requêtes par seconde au cours de la dernière minute
- Nombre de threads actifs
- La dernière fois qu'un enregistrement a été traité
- Utilisation de la mémoire d'un cache

Les jauges disposent de trois méthodes principales que vous pouvez utiliser : `inc` (incrémenter), `dec` (décrémenter) et `set` (définir). Tout comme les méthodes des compteurs, `inc` et `dec` modifient par défaut la valeur d'une jauge de un. Avec `set`, vous pouvez spécifier un argument avec une valeur différente si vous le souhaitez.

### Les métriques de type "Summary"

Les Summary ("résumés") suivent la taille et le nombre d'événements.

Lorsque vous essayez de comprendre les performances de vos systèmes, il est généralement essentiel de connaître la durée qu'a mise votre application à répondre à une demande par exemple la latence d'un backend => compter le nombre de requêtes et la durée (taille) correspondante

Les Summary sont en quelque sorte d'une version plus générale des métrique de type Timer présente dans d'autres systèmes de monitoring : tout comme les compteurs peuvent être incrémentés par des valeurs autres que un, vous pouvez souhaiter suivre des aspects autres que la latence des événements. Par exemple, en plus de la latence du backend, vous pouvez également vouloir suivre la taille des réponses que vous recevez.

La principale méthode d'un summary  est `observe`, à laquelle vous transmettez la taille de l'événement. Cette valeur doit être non négative. En utilisant une fonction de temps par exemple en Python "time.time()", vous pouvez suivre la latence.

Ensuite le summary produit deux métriques par exemple `count` et `sum`. Exemple: `app_latency_seconds_count` et `app_latency_seconds_sum`. `Count` est le nombre d'évenements (le nombre d'appel a observe) et `sum` est la somme des valeurs fournies à `observe`

En général on veut la latence moyenne et on utilise donc l'expression:

`rate(app_latency_seconds_sum[1m]) / rate(app_latency_seconds_count[1m])` c'est à dire la fréquence des requêtes divisée par le temps cumulé des requêtes.

Disons que, au cours de la dernière minute, vous avez eu trois demandes qui ont pris respectivement 2, 4 et 9 secondes. Le compte serait de 3 et la somme serait de 15 secondes, ce qui signifie que la latence moyenne est de 5 secondes.

Même s'il sont plus économiques, il est déconseillé d'utiliser les Summary et les Histograms doivent être privilégiés. Ils permettent plus de performance pour le calcul des quantiles et aussi l'aggrégation entre de multiples instances contrairement aux Summary.

# Métriques Histrogram (histogramme)

Un résumé (`Summary`) fournit la latence/taille moyenne d'un type d'évènement, mais que faire pour avoir quelques chose de plus précis statistiquement par exemple un quantile ? Il faut pour cela pouvoir compter les demandes inférieure à cette limite. 

Les quantiles indiquent quelle proportion d'événements ont une taille inférieure à une valeur donnée. Par exemple, un quantile de 0,95 équivalant à 200 ms signifie que 95 % des demandes ont pris moins de 200 ms.

Les quantiles sont utiles lorsqu'il s'agit de raisonner sur l'expérience réelle de l'utilisateur final. En effet, si par exemple le navigateur d'un utilisateur envoie 10 demandes à votre application, c'est la plus lente d'entre elles qui détermine la latence visible et dans ce cas, le 90e percentile capture cette latence.

Pour fonctionner les histogrammes utilisent un ensemble de **buckets** c'est à dire des "réservoirs" pour classer les évènements en différentes classes prédéfinies. Ces limites de buckets/classes doivent être fournies par les développeurs instrumentant l'application.

On les définis généralement par paquets autour des valeurs limites qui nous intéressent et pour couvrir tout le registre de valeur possible. Par exemple dans le cas de la latence prévu dans un SLA (service level agrement) s'il s'agit de s'assurer d'un taux de requête inférieur à 300 ms on définira quelques limites de buckets[0.1,0.2,0.3,.45] en plus d'autres valeurs allant de 0.01 à 10s.

Pour plus de détails, la documentation : https://prometheus.io/docs/practices/histograms/
<!-- 

### Convention pour le nommage des métriques

METRIC SUFFIXES
You may have noticed that the example counter metrics all ended with
_total, while there is no such suffix on gauges. This is a convention
within Prometheus that makes it easier to identify what type of metric
you are working with.
With OpenMetrics, this suffix is mandated. As the prometheus_client
Python library is the reference implementation for OpenMetrics, if you
do not add the suffix, the library will add it for you.
In addition to _total, the _count, _sum, and _bucket suffixes
also have other meanings and should not be used as suffixes in your
metric names to avoid confusion.
It is also strongly recommended that you include the unit of your metric
at the end of its name. For example, a counter for bytes processed might
be myapp_requests_processed_bytes_total.


### Approaching Instrumentation

Now that you know how to use instrumentation, it is important to know
where and how much you should apply it.
What Should I Instrument?
When instrumenting, you will usually be looking to either instrument
services or libraries.
Service instrumentation
Broadly speaking, there are three types of services, each with their own key
metrics: online-serving systems, offline-serving systems, and batch jobs.
Online-serving systems are those where either a human or another service is
waiting on a response. These include web servers and databases. The key
metrics to include in service instrumentation are the request rate, latency,
and error rate. Having request rate, latency, and error rate metrics is
sometimes called the RED method, for Rate, Errors, and Duration. These
metrics are not just useful to you from the server side, but also the client
side. If you notice that the client is seeing more latency than the server, you
might have network issues or an overloaded client.
TIP
When instrumenting duration, don’t be tempted to exclude failures. If you were to
include only successes, then you might not notice high latency caused by many slow but
failing requests.
Offline-serving systems do not have someone waiting on them. They
usually batch up work and have multiple stages in a pipeline with queues
between them. A log processing system is an example of an offline-serving
system. For each stage you should have metrics for the amount of queued
work, how much work is in progress, how fast you are processing items,
and errors that occur. These metrics are also known as the USE method, for
Utilization, Saturation, and Errors. Utilization is how full your service is,
saturation is the amount of queued work, and errors is self-explanatory. If


 -->




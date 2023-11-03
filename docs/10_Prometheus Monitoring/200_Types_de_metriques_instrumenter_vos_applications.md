---
title: Cours - Les types de métriques pour surveiller son application
sidebar_class_name: hidden
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

Les quantiles ici indiquent quelle proportion d'événements ont une taille inférieure à une valeur donnée. Par exemple, un quantile de 0,95 équivalant à 200 ms signifie que 95 % des demandes ont pris moins de 200 ms.

Les quantiles sont utiles lorsqu'il s'agit de raisonner sur l'expérience réelle de l'utilisateur final. En effet, si par exemple le navigateur d'un utilisateur envoie 10 demandes à votre application, c'est la plus lente d'entre elles qui détermine la latence visible et dans ce cas, le 95e percentile capture cette latence.

Pour fonctionner les histogrammes utilisent un ensemble de **buckets** c'est à dire des "réservoirs" pour classer les évènements en différentes classes prédéfinies. Ces limites de buckets/classes doivent être fournies par les développeurs instrumentant l'application.

On les définis généralement par paquets autour des valeurs limites qui nous intéressent et pour couvrir tout le registre de valeur possible. Par exemple dans le cas de la latence prévu dans un SLA (service level agrement) s'il s'agit de s'assurer d'un taux de requête inférieur à 300 ms on définira quelques limites de buckets[0.1,0.2,0.3,.45] en plus d'autres valeurs allant de 0.01 à 10s.

Pour plus de détails, la documentation : https://prometheus.io/docs/practices/histograms/


### 3 Modèles d'instrumentation

De manière générale, il existe trois types de services, chacun avec ses propres indicateurs clés : les systèmes en ligne, les systèmes hors ligne et les travaux par lots.


#### les services

Les services sont ceux où soit un humain, soit un autre service attend une réponse : serveurs web, bases de données.

Les indicateurs clés à inclure dans l'instrumentation de service sont le taux de requêtes, la latence et le taux d'erreur. Disposer des mesures de taux de requêtes, de latence et de taux d'erreur

=> la méthode RED, pour Rate (Taux), Errors (Erreurs) et Duration (Durée).

#### Services "offlines"

D'autres services ("hors ligne") n'ont personne qui attend après eux. Ils regroupent généralement le travail et ont plusieurs étapes dans un pipeline avec des files d'attente entre elles. Un système de traitement de logs est un exemple.

Pour chaque étape, vous devriez avoir des indicateurs pour la quantité de travail en file d'attente, la quantité de travail en cours, la vitesse à laquelle vous traitez les éléments et les erreurs qui surviennent. 

=> méthode USE, pour Utilization (Utilisation), Saturation et Errors (Erreurs). L'utilisation montre à quel point votre service est rempli, la saturation est la quantité de travail en file d'attente, et les erreurs sont explicites.

#### Batch Jobs

Les travaux par lots (batch jobs) sont le troisième type de service, et ils ressemblent aux systèmes hors ligne. Cependant, les travaux par lots fonctionnent régulièrement, tandis que les systèmes hors ligne fonctionnent en continu.

Comme les travaux par lots ne sont pas toujours en cours d'exécution, les scraper ne fonctionne pas très bien, donc des techniques comme le Pushgateway sont utilisées pour pousser les métriques plus spécifiques de ces jobs.
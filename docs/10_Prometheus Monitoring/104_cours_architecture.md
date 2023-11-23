---
title: Cours - Architecture de Prometheus
# sidebar_class_name: hidden
---

Prometheus découvre les cibles à collecter (scraper) à partir de ses méchanismes de découverte de services (Service Discovery).

Ces cibles peuvent être vos propres applications instrumentées ou des applications tierces que vous pouvez collecter à l'aide d'un exporter (exporter).

Les données collectées sont stockées, et vous pouvez les utiliser dans des tableaux de bord en utilisant PromQL (PromQL) ou envoyer des alertes à l'Alertmanager, qui les convertira en pages, e-mails et autres notifications.

![](https://www.augmentedmind.de/wp-content/uploads/2021/09/prometheus-official-architecture.png)


## Les Exporters

- Tout le code que vous utilisez n'est pas forcément accessible. Dans ce cas l'instrumentation directe n'est pas possible.

- Un exporter est un proxy déployé juste à côté de l'application dont on souhaite obtenir les métriques. Il prend des requêtes de Prometheus, recueille les données requises à partir de l'application, les transforme dans le format correct.

<!-- Contrairement à l'instrumentation directe que vous utiliseriez pour le code que vous contrôlez, les exporters utilisent un style différent d'instrumentation connu sous le nom de *collecteurs personnalisés* ou *ConstMetrics*. -->

- La communauté Prometheus a déjà développé de nombreux exporters : l'exporter dont vous avez besoin existe probablement déjà et peut être utilisé avec peu d'effort.

<!-- Si l'exporter ne dispose pas d'une métrique qui vous intéresse, vous pouvez toujours envoyer une demande de fusion pour l'améliorer, ce qui le rendra meilleur pour la personne suivante qui l'utilisera. -->


## Bibliothèques clientes

- Pour avoir des métriques quelqu'un doit ajouter l'instrumentation qui les produit. C'est le role des bibliothèques clientes (client libraries). Avec seulement deux ou trois lignes de code, vous pouvez à la fois définir une métrique et ajouter l'instrumentation dans le code que vous contrôlez.

- Il existe des bibliothèques clientes pour tous les langages et exécutions majeurs.

<!-- Le projet Prometheus propose des bibliothèques clientes officielles en Go, Python, Java/JVM, Ruby et Rust. Il existe également diverses bibliothèques clientes tierces, telles que pour C#/.Net, Node.js, Haskell et Erlang. -->

- Les bibliothèques clientes se chargent de tous les détails techniques tels que la sécurité au niveau des threads le formattage et ajoute très peu de charge à votre application.

<!-- , la comptabilité et la production du texte Prometheus et/ou du format d'exposition OpenMetrics en réponse aux requêtes HTTP.

Comme la surveillance basée sur les métriques ne suit pas les événements individuels, l'utilisation de la mémoire de la bibliothèque cliente n'augmente pas avec le nombre d'événements. La mémoire est plutôt liée au nombre de métriques que vous avez. -->

<!-- Si l'une des dépendances de bibliothèque de votre application comporte une instrumentation Prometheus, elle sera automatiquement détectée. Ainsi, en instrumentant une bibliothèque clé telle que votre client RPC, vous pouvez obtenir une instrumentation pour celle-ci dans toutes vos applications.

Certaines métriques, telles que l'utilisation du CPU et les statistiques de collecte des déchets, sont généralement fournies par défaut par les bibliothèques clientes, en fonction de la bibliothèque et de l'environnement d'exécution. -->

<!-- Les bibliothèques clientes ne sont pas limitées à produire des métriques dans les formats de texte Prometheus et OpenMetrics. Prometheus est un écosystème ouvert, et les mêmes API utilisées pour générer le format texte peuvent être utilisées pour produire des métriques dans d'autres formats ou les acheminer vers d'autres systèmes d'instrumentation. -->

Il est possible de prendre des métriques d'autres systèmes d'instrumentation et de les intégrer dans une bibliothèque cliente Prometheus, si vous n'avez pas encore tout converti en instrumentation Prometheus.

## La Découverte de services

- Une fois que toutes les applications sont instrumentées et que vos exporters sont en cours d'exécution, Prometheus doit savoir où les chercher.

C'est ainsi que Prometheus saura quoi surveiller et pourra remarquer si quelque chose qu'il est censé surveiller ne répond pas.

- Dans des environnements dynamiques, vous ne pouvez pas simplement fournir une liste d'applications et d'adresses car elle deviendra obsolète : la découverte de service est un système qui permet à prometheus de récupérer dynamiquement les cibles à scrapper.

- Il existe probablement déjà une base de données de vos machines, de vos applications et de leurs fonctions par exemple dans un fichier d'inventaire pour Ansible, l'API du fournisseur de cloud ou dans des étiquettes et des annotations dans Kubernetes.

- Prometheus propose des intégrations avec de nombreux mécanismes de découverte de services courants, tels que Kubernetes, et les principaux fournisseurs de cloud. Il existe également des intégrations génériques pour s'adapter aux cas plus spécifiques (fichier et HTTP).

- Enfin pour régler le problème d'adapter Prometheus à votre architecture spécifique (quel role à un serveur précis et comment doit-il être traité) il existe une fonction de *relabeling* qui permet de changer dynamiquement les métadonnées et étiquettes associées à vos cibles.

<!-- Cela laisse cependant un problème. Le simple fait que Prometheus ait une liste de machines et de services ne signifie pas que nous savons comment ils s'intègrent dans votre architecture. Par exemple, vous pourriez utiliser l'étiquette `Name` d'EC2 pour indiquer quelle application s'exécute sur une machine, tandis que d'autres pourraient utiliser une étiquette appelée `app`.

Comme chaque organisation le fait légèrement différemment, Prometheus vous permet de configurer comment les métadonnées de la découverte de services sont associées aux cibles de surveillance et à leurs étiquettes à l'aide de *relabeling*. -->

## Scraping

- Prometheus récupère les métriques en envoyant une requête HTTP appelée *scrape*.

- La réponse est analysée et ingérée dans le stockage et plusieurs métriques décrivant le scrape sont ajoutées, telles que le succès et la durée du processus. 

- Les *scrapes* sont lancés régulièrement : en général on les configure pour se produire toutes les 10 à 60 secondes pour chaque cible.

## Règles d'enregistrement (recording rules)

Bien que PromQL et le moteur de stockage soient puissants et efficaces, l'agrégation de métriques provenant de milliers de machines à chaque fois que vous générez un graphique peut devenir un peu lent.

- Parfois des requêtes complexes a grande échelles peuvent être un peu lentes : les règles d'enregistrement permettent aux expressions PromQL d'être évaluées régulièrement et leurs résultats ingérés dans le moteur de stockage.

- La requête gourmande est en quelque sort précalculée.

## Les règles d'alertes (alerting rules)

- Les règles d'alerte, proche des recording rules évaluent régulièrement des expressions PromQL et déclenche une alerte dès que la requête possède des résultat.

- Les alertes sont ensuite envoyées à l'Alertmanager.

## Gestion des alertes

- L'Alertmanager reçoit les alertes d'un ou plusieur serveurs Prometheus et les transforme en notifications : e-mails, chat comme Slack et des services tels que PagerDuty.

- Les alertes doivent être peu nombreuse et pertinentes : Alermanager peut grouper les alertes connexes en une seule notification, limiter pour réduire les alertes intempestives, et différentes règles de routage et de notification peuvent être configurées pour chaque équipe.

- Les alertes peuvent être mises en sourdine, peut-être pour suspendre un problème dont vous êtes déjà au courant à l'avance lorsque vous savez qu'une maintenance est prévue.

## Stockage

- Prometheus stocke les données localement dans une base de données custom qui ne peut pas être clusterisée ce qui la rend plus fiable facile à exécuter.

- Le moteur de stockage a connu plusieurs révisions. Le système de stockage de Prometheus 2.0 étant la troisième itération. Le système de stockage peut gérer l'ingestion de millions d'échantillons par seconde, ce qui permet de surveiller des milliers de machines avec un seul serveur Prometheus.

- L'algorithme de compression utilisé peut atteindre 1,3 octet par échantillon sur des données du monde réel.

<!-- ## Tableaux de bord

Prometheus dispose de plusieurs API HTTP qui vous permettent à la fois de demander des données brutes et d'évaluer des requêtes PromQL. Ces API peuvent être utilisées pour produire des graphiques et des tableaux de bord. Out of the box, Prometheus fournit l'expression browser. Il utilise ces API et convient pour des requêtes ad hoc et des explorations de données, mais ce n'est pas un système de tableau de bord général.

Il est recommandé d'utiliser Grafana pour les tableaux de bord. Il possède de nombreuses fonctionnalités, notamment une prise en charge officielle de Prometheus en tant que source de données. Il peut produire une grande variété de tableaux de bord, comme celui présenté dans la **figure 1-2**. Grafana prend en charge la communication avec plusieurs serveurs Prometheus, même au sein d'un seul panneau de tableau de bord. -->

### Stockage à long terme

- Prometheus stocke des données uniquement sur la machine locale : on est limité par l'espace disque disponible sur un machine. Bien qu'on ne se préoccupe  généralement uniquement des données les plus récentes (une journée), pour faire du trending, une période de rétention plus longue est souhaitable.

- Prometheus n'offre pas de solution de stockage cluster pour stocker des données sur plusieurs machines, mais il existe des API de lecture et d'écriture à distance qui permettent à d'autres systèmes (Thanos par exemple) de s'en charger : cela permet d'exécuter des requêtes PromQL de manière transparente à la fois sur des données locales et distantes.
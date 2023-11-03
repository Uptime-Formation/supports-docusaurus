---
title: Cours - Architecture de Prometheus
sidebar_class_name: hidden
---

Prometheus découvre les cibles à collecter (scraper) à partir de ses méchanisme de découverte de services (Service Discovery).

Ces cibles peuvent être vos propres applications instrumentées ou des applications tierces que vous pouvez collecter à l'aide d'un exporter (exporter).

Les données collectées sont stockées, et vous pouvez les utiliser dans des tableaux de bord en utilisant PromQL (PromQL) ou envoyer des alertes à l'Alertmanager, qui les convertira en pages, e-mails et autres notifications.

![](https://www.augmentedmind.de/wp-content/uploads/2021/09/prometheus-official-architecture.png)

## Bibliothèques clientes

Les métriques ne surgissent généralement pas automatiquement à partir des applications ; quelqu'un doit ajouter l'instrumentation qui les produit. C'est là que les bibliothèques clientes (client libraries) interviennent. Avec généralement seulement deux ou trois lignes de code, vous pouvez à la fois définir une métrique et ajouter votre instrumentation souhaitée directement dans le code que vous contrôlez. Cela est appelé **instrumentation directe**.

Il existe des bibliothèques clientes pour tous les langages majeurs.

Les bibliothèques clientes se chargent de tous les détails techniques tels que la sécurité au niveau des threads, la comptabilité et le formatage texte d'exposition (soit Prometheus soit format OpenMetrics) en réponse aux requêtes HTTP.

- Comme la surveillance basée sur les métriques ne suit pas chaque événement individuel, l'utilisation de la mémoire de la bibliothèque cliente n'augmente pas avec le nombre d'événements. La mémoire consommée est plutôt liée au nombre de métriques que vous avez.

- Certaines métriques, telles que l'utilisation du CPU et les statistiques de collecte des déchets, sont généralement fournies par défaut par les bibliothèques clientes, en fonction de la bibliothèque et de l'environnement d'exécution.

Les bibliothèques clientes ne sont pas limitées à produire des métriques dans les formats de texte Prometheus et OpenMetrics. Prometheus est un écosystème ouvert, et les mêmes API utilisées pour générer le format texte peuvent être utilisées pour produire des métriques dans d'autres formats ou les acheminer vers d'autres systèmes d'instrumentation.

Il est aussi possible de prendre des métriques d'autres systèmes d'instrumentation et de les intégrer dans une bibliothèque cliente Prometheus, si vous n'avez pas encore tout converti en instrumentation Prometheus.

## Prometheus exporters

Tout le code que vous exécutez n'est pas forcément du code que vous pouvez contrôler ou auquel vous pouvez même avoir accès, et donc l'ajout d'une instrumentation directe n'est pas nécessairement une option. Par exemple, il est peu probable que les noyaux de systèmes d'exploitation commencent à produire des métriques au format Prometheus via HTTP de sitôt.

De tels logiciels ont souvent une interface à travers laquelle vous pouvez accéder aux métriques. Il peut s'agir d'un format ad hoc nécessitant une analyse et une gestion personnalisées, comme c'est le cas pour de nombreuses métriques Linux, ou d'une norme bien établie telle que SNMP pour le réseau.

Un exporter est un logiciel que vous déployez juste à côté de l'application dont vous souhaitez obtenir les métriques. Il prend des requêtes de Prometheus, recueille les données requises à partir de l'application, les transforme dans le format correct, et enfin les renvoie en réponse à Prometheus. Vous pouvez considérer un exporter comme un petit proxy un-à-un, convertissant les données entre l'interface de métriques d'une application et le format d'exposition Prometheus.

Compte tenu de la taille de la communauté Prometheus, il est probable que l'exporter dont vous avez besoin pour un logiciel standard existe déjà.

## Découverte de services

La découverte de service  dynamique est une des caractéristique centrale du modèle `pull` de Prometheus

Une fois que vous avez toutes vos applications instrumentées et que vos exporters sont en cours d'exécution, Prometheus doit savoir où ils se trouvent. C'est ainsi que Prometheus saura quoi surveiller et pourra remarquer si quelque chose qu'il est censé surveiller ne répond pas.

Dans un environnement dynamique comme un cloud IaC ou un cloud applicatif, vous ne pouvez pas simplement fournir une liste d'applications et d'exporters une fois, car elle deviendra obsolète très vite (minutes). C'est là que la découverte de services intervient.

Il existe probablement déjà une source de données décrivant de vos machines et vos applications. Elle peut être dans un fichier d'inventaire pour Ansible, basée sur des tags de vos instances EC2, dans des étiquettes et des annotations dans Kubernetes, ou simplement stockée dans votre wiki de documentation.

Prometheus propose des intégrations avec de nombreux mécanismes de découverte de services courants, tels que Kubernetes, EC2 et Consul. Il existe également une intégration générique pour ceux dont la configuration est un peu hors des sentiers battus (voir "Fichier" et "HTTP").

Il reste cependant un problème classique de compatibilité de la découverte de services. Par exemple, vous pourriez utiliser l'étiquette `Name` d'EC2 pour indiquer quelle application s'exécute sur une machine, tandis que d'autres voudraient utiliser une étiquette appelée `app` : Prometheus vous permet de configurer comment les labels de la découverte de services sont associées aux cibles de surveillance et à leurs étiquettes à l'aide de *relabeling* -> changement dynamique des labels selon des règles au moment de la découverte de service : cela permettra d'uniformiser les données dans votre base de donnée Prometheus.

## La collecte de donnée (Scraping)

La découverte de services et le *relabeling* nous donnent une liste de cibles à surveiller. Maintenant, Prometheus doit récupérer les métriques. Prometheus le fait en envoyant une requête HTTP appelée *scrape*. La réponse à la requête est analysée et ingérée dans le stockage. Plusieurs métriques utiles sont également ajoutées, telles que le succès du *scrape* et la durée du processus. Les *scrapes* se produisent régulièrement ; en général, vous les configurez pour se produire toutes les 10 à 60 secondes pour chaque cible.

## Stockage

Prometheus stocke les données localement dans une base de données spéciale. Les systèmes distribués sont difficiles à rendre fiables, c'est pourquoi Prometheus n'essaie pas de faire de clustering. En plus de la fiabilité, cela rend Prometheus plus facile à exécuter.

Au fil des ans, le stockage a connu plusieurs révisions, avec le système de stockage de Prometheus 2.0 étant la troisième itération. Le système de stockage peut gérer l'ingestion de millions d'échantillons par seconde, ce qui permet de surveiller des milliers de machines avec un seul serveur Prometheus: l'algorithme de compression utilisé peut atteindre 1,3 octet par échantillon sur des données du monde réel.

## Tableaux de bord Grafana (Dashboards)

Prometheus dispose de plusieurs API HTTP qui vous permettent à la fois de demander des données brutes et d'évaluer des requêtes PromQL. Ces API peuvent être utilisées pour produire des graphiques et des tableaux de bord.

Prometheus lui-même fournit un "expression browser" permettant de dessiner des graphiques simples mais ce n'est pas un système de dashboards général.

Il est recommandé d'utiliser Grafana pour les dashboards. Il possède de nombreuses fonctionnalités, notamment une prise en charge officielle de Prometheus en tant que source de données. Il peut produire une grande variété de tableaux de bord.

## Recording Rules et alertes

Bien que PromQL et le moteur de stockage soient puissants et efficaces, l'agrégation de métriques provenant de milliers de machines à chaque fois que vous générez un graphique peut devenir un peu lent. Les **recording rules** permettent de générer de nouvelles données/formatages ingérés dans le moteur de stockage à partir d'expression promQL arbitraires => elle seront ensuite disponibles directement pour économiser des resources au moment de la récupération.

Les règles d'alerte sont une autre forme de règles : évaluent également régulièrement des expressions PromQL, et tout résultat de ces expressions devient une alerte. Les alertes sont envoyées à l'Alertmanager. C'est une façon très dynamique est puissante d'exprimer et envoyer les anomalies sur votre système.

## Gestion des alertes

L'Alertmanager reçoit les alertes des serveurs Prometheus et les transforme en notifications. Les notifications peuvent inclure des e-mails, des applications de chat comme Slack et des services tels que PagerDuty.

L'Alertmanager ne se contente pas de transformer les alertes en notifications une à une. Les alertes proches ou dupliquées peuvent être regroupées en une seule notification, filtrées pour réduire les alertes intempestives, et différentes règles de routage et de notification peuvent être configurées pour chacune des équipes d'une organisation.

Les alertes peuvent également être mises en sourdine, pour suspendre un problème dont vous êtes déjà au courant à l'avance ou lorsque vous savez qu'une maintenance est prévue.

Le rôle de l'Alertmanager s'arrête à l'envoi de notifications ; pour gérer les réponses humaines aux incidents, vous devez utiliser des services tels que PagerDuty et des systèmes de suivi des tickets.

## Stockage à long terme

Comme Prometheus stocke des données uniquement sur la machine locale, vous êtes limité par l'espace disque disponible sur cette machine. Bien que vous vous préoccupiez généralement uniquement des données les plus récentes pendant environ une journée, pour une planification de capacité à long terme, une période de rétention plus longue est souhaitable.

Prometheus n'offre pas de solution de stockage cluster pour stocker des données sur plusieurs machines, mais il existe des API de lecture et d'écriture à distance qui permettent à d'autres systèmes de se connecter et de prendre en charge ce rôle. Cela permet d'exécuter des requêtes PromQL de manière transparente à la fois sur des données locales et distantes.
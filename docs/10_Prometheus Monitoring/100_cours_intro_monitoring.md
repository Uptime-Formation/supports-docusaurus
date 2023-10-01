---
title: Cours - Introduction au monitoring Prometheus
draft: false
# sidebar_position: 6
---

Prometheus est un système de monitoring (surveillance) open source basé sur les métriques. Il est très populaire aujourd'hui en particulier dans le contexte des clouds applicatifs ou il est la solution de référence.

Prometheus fait une chose assez précise très efficacement (philosophie Unix) : il possède un modèle de données simple mais très puissant et scalable avec un langage de requêtes sur ces données très flexible : il vous permet d'analyser les performances de vos applications et de votre infrastructure en temps réel dans des contextes dynamiques.

Par ailleurs, il ne cherche pas à répondre à des usecases en dehors de l'espace de la récupération et gestion des métriques, laissant cela à d'autres outils plus appropriés.

Prometheus est loin d'être le seul système de ce type sur le marché mais son modèle est particulièrement adapté à la conteneurisation des applications et il est construit et maintenu dans une vaste communauté open source

Depuis ses débuts avec pas plus qu'une poignée de développeurs travaillant

Le projet Prometheus a démarré chez SoundCloud en 2012 comme outil interne de surveillance adapté à leur cloud applicatif assez innovant pour l'époque. Très vite le projet a été opensourcé,  une communauté et un écosystème se sont développés autour. En 2016, le projet Prometheus est devenu le deuxième membre de la Cloud Native Computing Foundation (CNCF).

Prometheus est principalement écrit en Go et est sous licence Apache 2.0. Des centaines de personnes ont contribué au projet lui-même. Il est difficile de dire combien d'utilisateurs un projet open source a, mais on peut estimer qu'en 2023, des centaines de milliers d'organisations utilisent Prometheus en production.

# Qu'est-ce que la surveillance ?

La surveillance est un concept vague. Prometheus a été créé pour aider les développeurs de logiciels et les administrateurs dans l'exploitation de systèmes informatiques de production, tels que les applications, les outils operationnels, les bases de données et les réseaux soutenant par exemples des plateforme web (Saas) mais aussi tout autre système informatique.

Qu'est-ce que la surveillance (monitoring) dans ce contexte ? On peut extraire quatre aspects classiques :

1. **Alerting** : Savoir quand les choses tournent mal est généralement la chose la plus importante que vous attendez de la surveillance. Vous souhaitez que le système de surveillance (monitoring system) appelle un être humain (human) pour qu'il examine la situation.

2. **Debugging** : Une fois qu'un être humain (human) est impliqué, il doit enquêter pour déterminer la cause fondamentale et finalement résoudre le problème.

3. **Trending** (surveillance des tendance) : Les alertes et le débogage se produisent généralement sur des échelles de temps de l'ordre de quelques minutes à quelques heures. Bien que moins urgent, la capacité à voir comment vos systèmes sont utilisés et comment ils évoluent au fil du temps est également utile. Le trending peut influencer les décisions de conception et les processus tels que la planification de capacité (nombre et tailles des machines de l'infrastructure notamment).

4. **Plumbing** ("Plomberie") : Tous les systèmes de surveillance sont des pipelines de traitement des données, ce n'est pas strictement de la surveillance (monitoring), mais c'est très lié. Il faut pouvoir filtrer et rediriger les données de surveillance vers d'autres partie de votre infrastructure (CI/CD), audit de sécurité etc.

## Petite histoire du Monitoring

La surveillance est passé par différentes solutions durant les dernières années. Pendant longtemps, la solution dominante a été une combinaison de Nagios et de Graphite, ou de leurs variantes.

Nagios a été créé par Ethan Galstad en 1996 en tant qu'application MS-DOS pour effectuer des pings, puis renommé Nagios en 2002. Nagios, Icinga, Zmon et Sensu sont des exemples de logiciels de la même famille.

- Ces outils fonctionnent en exécutant régulièrement des scripts appelés "checks". En cas d'échec d'un check (renvoyant un code de sortie différent de zéro), une alerte (alert) est générée.

L'origine de Graphite remonte à 1994 lorsque Tobias Oetiker a créé un script Perl devenu Multi Router Traffic Grapher (MRTG) 1.0 en 1995. MRTG était principalement utilisé pour la surveillance réseau via SNMP et obtenir des métriques en exécutant des scripts. En 1997, des changements importants ont eu lieu, notamment le passage de certaines parties du code en C et la création de la base de données Round Robin (RRD) pour stocker les données métriques.RRD a amélioré les performances et a servi de base à d'autres outils comme Smokeping et Graphite. 

- Graphite, créé en 2006, utilise Whisper pour stocker les métriques, ayant une conception similaire à RRD. Graphite ne collecte pas de données lui-même, elles sont collectées par des outils de collecte tels que collectd et StatsD.

Prometheus utilise des metriques un peu comme Graphite mais avec des caractéristiques (notamment les labels) qui les rendent plus flexibles et adaptés au cloud.
Il gère ensuite l'alerting à partir de requêtes sur ses métriques plutôt que des scripts de checks comme Nagios.

# Prometheus flexibilité et standardisation

Un force de Prometheus est son intégration avec énormément de solutions et la façon dont il sert de support actuellement à un processus de standardisation open source.

- Pour instrumenter votre propre code, il existe des bibliothèques clientes dans tous les langages et environnements populaires, notamment Go, Java/JVM, C#/.Net, Python, Ruby, Node.js, Haskell, Erlang et Rust.

- De nombreuses applications populaires sont déjà instrumentées avec des bibliothèques clientes Prometheus, telles que Kubernetes, Docker, Envoy et Vault et la plupart des provider de cloud.

- Un format texte simple facilite l'exposition des métriques à Prometheus (le format de métrique prometheus). D'autres systèmes de surveillance, qu'ils soient open source ou commerciaux, ont ajouté la prise en charge de ce format. Cela permet à tous ces systèmes de surveillance de se concentrer davantage sur les fonctionnalités de base, plutôt que de devoir passer du temps à dupliquer les efforts pour prendre en charge chaque logiciel à surveiller.

- Pour les logiciels tiers qui exposent des métriques dans un format non Prometheus, il existe des centaines d'intégrations disponibles. Ces intégrations sont appelées `exporters` et comprennent HAProxy, MySQL, PostgreSQL, Redis, JMX, SNMP, Consul et Kafka.

**labels** et dimentionnalité dynamique : Le modèle de données de Prometheus identifie chaque série temporelle non seulement par un nom, mais aussi par un ensemble non ordonné de paires clé-valeur appelées labels.

- Basé sur ces labels, le langage de requête PromQL permet l'agrégation sur n'importe quelle information, de sorte que vous pouvez analyser dynamiquement non seulement par processus, mais aussi par datacenter, service ou par toute autre caractéristique que vous avez définie. Vous pouvez afficher ces données dans des systèmes de tableau de bord tels que Grafana et Perses.

Les alertes peuvent être définies à l'aide du même langage de requête PromQL que celui que vous utilisez pour créer des graphiques. Si vous pouvez le graphiquer, vous pouvez créer une alerte à ce sujet. Les étiquettes facilitent la maintenance des alertes, car vous pouvez créer une seule alerte couvrant toutes les valeurs possibles des étiquettes. Dans d'autres systèmes de surveillance, vous devriez créer individuellement une alerte par machine/application.

- La découverte de service (Service Discovery) peut déterminer automatiquement les applications et les machines à "scraper" (ou récupérer des données) à partir de sources telles que Kubernetes, Consul, Amazon Elastic Compute Cloud (EC2), Azure, Google Compute Engine (GCE) et OpenStack.

Prometheus est assez simple a opérer a grande échelle : un seul serveur Prometheus peut ingérer des millions d'échantillons par seconde. Il s'agit d'un fichier binaire unique, lié de manière statique, avec un fichier de configuration. 

Les composants de Prometheus peuvent être exécutés dans des conteneurs, et ils évitent de faire quelque chose de sophistiqué qui entraverait les outils de gestion de la configuration. Il est conçu pour être intégré dans l'infrastructure que vous possédez déjà et sur laquelle vous avez construit, et non pour être une plate-forme de gestion en soi.

## Les limites de Prometheus

Maintenant que vous avez une idée d'où s'intègre Prometheus dans le paysage de la surveillance, regardons quelques cas d'utilisation pour lesquels Prometheus n'est pas un choix particulièrement judicieux.

En tant que système basé sur les métriques, Prometheus ne convient pas au stockage de journaux d'événements ou d'événements individuels. Ce n'est pas non plus le meilleur choix pour des données à haute cardinalité, telles que des adresses e-mail ou des noms d'utilisateur.

Prometheus est conçu pour la surveillance opérationnelle, où de petites imprécisions et des conditions de concurrence dues à des facteurs tels que la planification du noyau et les collectes de données échouées sont un fait de la vie. Prometheus fait des compromis et préfère vous fournir des données qui sont à 99,9 % correctes plutôt que de casser votre surveillance en attendant des données parfaites. Ainsi, dans les applications impliquant de l'argent ou de la facturation, Prometheus doit être utilisé avec prudence.







# Architecture de Prometheus

Prometheus découvre les cibles à collecter à partir de la découverte de services. Ces cibles peuvent être vos propres applications instrumentées ou des applications tierces que vous pouvez collecter à l'aide d'un exportateur (exporter). Les données collectées sont stockées, et vous pouvez les utiliser dans des tableaux de bord en utilisant PromQL (PromQL) ou envoyer des alertes à l'Alertmanager, qui les convertira en pages, e-mails et autres notifications.

## Bibliothèques clientes

Les métriques ne surgissent généralement pas automatiquement à partir des applications ; quelqu'un doit ajouter l'instrumentation qui les produit. C'est là que les bibliothèques clientes (client libraries) interviennent. Avec généralement seulement deux ou trois lignes de code, vous pouvez à la fois définir une métrique et ajouter votre instrumentation souhaitée directement dans le code que vous contrôlez. Cela est appelé instrumentation directe.

Il existe des bibliothèques clientes pour tous les langages et exécutions majeurs. Le projet Prometheus propose des bibliothèques clientes officielles en Go, Python, Java/JVM, Ruby et Rust. Il existe également diverses bibliothèques clientes tierces, telles que pour C#/.Net, Node.js, Haskell et Erlang.

Les bibliothèques clientes se chargent de tous les détails techniques tels que la sécurité au niveau des threads, la comptabilité et la production du texte Prometheus et/ou du format d'exposition OpenMetrics en réponse aux requêtes HTTP. Comme la surveillance basée sur les métriques ne suit pas les événements individuels, l'utilisation de la mémoire de la bibliothèque cliente n'augmente pas avec le nombre d'événements. La mémoire est plutôt liée au nombre de métriques que vous avez.

Si l'une des dépendances de bibliothèque de votre application comporte une instrumentation Prometheus, elle sera automatiquement détectée. Ainsi, en instrumentant une bibliothèque clé telle que votre client RPC, vous pouvez obtenir une instrumentation pour celle-ci dans toutes vos applications.

Certaines métriques, telles que l'utilisation du CPU et les statistiques de collecte des déchets, sont généralement fournies par défaut par les bibliothèques clientes, en fonction de la bibliothèque et de l'environnement d'exécution.

Les bibliothèques clientes ne sont pas limitées à produire des métriques dans les formats de texte Prometheus et OpenMetrics. Prometheus est un écosystème ouvert, et les mêmes API utilisées pour générer le format texte peuvent être utilisées pour produire des métriques dans d'autres formats ou les acheminer vers d'autres systèmes d'instrumentation. De même, il est possible de prendre des métriques d'autres systèmes d'instrumentation et de les intégrer dans une bibliothèque cliente Prometheus, si vous n'avez pas encore tout converti en instrumentation Prometheus.

## Exportateurs

Tout le code que vous exécutez n'est pas forcément du code que vous pouvez contrôler ou auquel vous pouvez même avoir accès, et donc l'ajout d'une instrumentation directe n'est pas vraiment une option. Par exemple, il est peu probable que les noyaux de systèmes d'exploitation commencent à produire des métriques au format Prometheus via HTTP de sitôt.

De tels logiciels ont souvent une interface à travers laquelle vous pouvez accéder aux métriques. Il peut s'agir d'un format ad hoc nécessitant une analyse et une gestion personnalisées, comme c'est le cas pour de nombreuses métriques Linux, ou d'une norme bien établie telle que SNMP.

Un exportateur est un logiciel que vous déployez juste à côté de l'application dont vous souhaitez obtenir les métriques. Il prend des requêtes de Prometheus, recueille les données requises à partir de l'application, les transforme dans le format correct, et enfin les renvoie en réponse à Prometheus. Vous pouvez considérer un exportateur comme un petit proxy un-à-un, convertissant les données entre l'interface de métriques d'une application et le format d'exposition Prometheus.

Contrairement à l'instrumentation directe que vous utiliseriez pour le code que vous contrôlez, les exportateurs utilisent un style différent d'instrumentation connu sous le nom de *collecteurs personnalisés* ou *ConstMetrics*.

La bonne nouvelle, compte tenu de la taille de la communauté Prometheus, c'est que l'exportateur dont vous avez besoin existe probablement déjà et peut être utilisé avec peu d'effort de votre part. Si l'exportateur ne dispose pas d'une métrique qui vous intéresse, vous pouvez toujours envoyer une demande de fusion pour l'améliorer, ce qui le rendra meilleur pour la personne suivante qui l'utilisera.

## Découverte de services

Une fois que vous avez toutes vos applications instrumentées et que vos exportateurs sont en cours d'exécution, Prometheus doit savoir où ils se trouvent. C'est ainsi que Prometheus saura quoi surveiller et pourra remarquer si quelque chose qu'il est censé surveiller ne répond pas. Dans des environnements dynamiques, vous ne pouvez pas simplement fournir une liste d'applications et d'exportateurs une fois, car elle deviendra obsolète. C'est là que la découverte de services intervient.

Vous avez probablement déjà une base de données de vos machines, de vos applications et de leurs fonctions. Elle peut être à l'intérieur de la base de données de Chef, dans un fichier d'inventaire pour Ansible, basée sur des tags de votre instance EC2, dans des étiquettes et des annotations dans Kubernetes, ou simplement stockée dans votre wiki de documentation.

Prometheus propose des intégrations avec de nombreux mécanismes de découverte de services courants, tels que Kubernetes, EC2 et Consul. Il existe également une intégration générique pour ceux dont la configuration est un peu hors des sentiers battus (voir "Fichier" et "HTTP").

Cela laisse cependant un problème. Le simple fait que Prometheus ait une liste de machines et de services ne signifie pas que nous savons comment ils s'intègrent dans votre architecture. Par exemple, vous pourriez utiliser l'étiquette `Name` d'EC2 pour indiquer quelle application s'exécute sur une machine, tandis que d'autres pourraient utiliser une étiquette appelée `app`.

Comme chaque organisation le fait légèrement différemment, Prometheus vous permet de configurer comment les métadonnées de la découverte de services sont associées aux cibles de surveillance et à leurs étiquettes à l'aide de *relabeling*.

## Scraping

La découverte

 de services et le *relabeling* nous donnent une liste de cibles à surveiller. Maintenant, Prometheus doit récupérer les métriques. Prometheus le fait en envoyant une requête HTTP appelée *scrape*. La réponse à la requête est analysée et ingérée dans le stockage. Plusieurs métriques utiles sont également ajoutées, telles que le succès du *scrape* et la durée du processus. Les *scrapes* se produisent régulièrement ; en général, vous les configurez pour se produire toutes les 10 à 60 secondes pour chaque cible.

## Stockage

Prometheus stocke les données localement dans une base de données personnalisée. Les systèmes distribués sont difficiles à rendre fiables, c'est pourquoi Prometheus n'essaie pas de faire de clustering. En plus de la fiabilité, cela rend Prometheus plus facile à exécuter.

Au fil des ans, le stockage a connu plusieurs révisions, avec le système de stockage de Prometheus 2.0 étant la troisième itération. Le système de stockage peut gérer l'ingestion de millions d'échantillons par seconde, ce qui permet de surveiller des milliers de machines avec un seul serveur Prometheus. L'algorithme de compression utilisé peut atteindre 1,3 octet par échantillon sur des données du monde réel. Un SSD est recommandé, mais pas strictement nécessaire.

## Tableaux de bord

Prometheus dispose de plusieurs API HTTP qui vous permettent à la fois de demander des données brutes et d'évaluer des requêtes PromQL. Ces API peuvent être utilisées pour produire des graphiques et des tableaux de bord. Out of the box, Prometheus fournit l'expression browser. Il utilise ces API et convient pour des requêtes ad hoc et des explorations de données, mais ce n'est pas un système de tableau de bord général.

Il est recommandé d'utiliser Grafana pour les tableaux de bord. Il possède de nombreuses fonctionnalités, notamment une prise en charge officielle de Prometheus en tant que source de données. Il peut produire une grande variété de tableaux de bord, comme celui présenté dans la **figure 1-2**. Grafana prend en charge la communication avec plusieurs serveurs Prometheus, même au sein d'un seul panneau de tableau de bord.

## Règles d'enregistrement et alertes

Bien que PromQL et le moteur de stockage soient puissants et efficaces, l'agrégation de métriques provenant de milliers de machines à chaque fois que vous générez un graphique peut devenir un peu lent. Les règles d'enregistrement permettent aux expressions PromQL d'être évaluées régulièrement et leurs résultats ingérés dans le moteur de stockage.

Les règles d'alerte sont une autre forme de règles d'enregistrement. Elles évaluent également régulièrement des expressions PromQL, et tout résultat de ces expressions devient une alerte. Les alertes sont envoyées à l'Alertmanager.

## Gestion des alertes

L'Alertmanager reçoit les alertes des serveurs Prometheus et les transforme en notifications. Les notifications peuvent inclure des e-mails, des applications de chat comme Slack et des services tels que PagerDuty.

L'Alertmanager ne se contente pas de transformer aveuglément les alertes en notifications sur une base un-à-un. Les alertes connexes peuvent être regroupées en une seule notification, limitées pour réduire les alertes intempestives, et différentes règles de routage et de notification peuvent être configurées pour chacune de vos équipes différentes. Les alertes peuvent également être mises en sourdine, peut-être pour suspendre un problème dont vous êtes déjà au courant à l'avance lorsque vous savez qu'une maintenance est prévue.

Le rôle de l'Alertmanager s'arrête à l'envoi de notifications ; pour gérer les réponses humaines aux incidents, vous devez utiliser des services tels que PagerDuty et des systèmes de suivi des tickets.

## Stockage à long terme

Comme Prometheus stocke des données uniquement sur la machine locale, vous êtes limité par l'espace disque disponible sur cette machine. Bien que vous vous préoccupiez généralement uniquement des données les plus récentes pendant environ une journée, pour une planification de capacité à long terme, une période de rétention plus longue est souhaitable.

Prometheus n'offre pas de solution de stockage cluster pour stocker des données sur plusieurs machines, mais il existe des API de lecture et d'écriture à distance qui permettent à d'autres systèmes de se connecter et de prendre en charge ce rôle. Cela permet d'exécuter des requêtes PromQL de manière transparente à la fois sur des données locales et distantes.
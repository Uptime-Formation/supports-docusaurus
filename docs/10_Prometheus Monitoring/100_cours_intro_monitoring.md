---
title: Cours - Introduction au monitoring Prometheus
# sidebar_class_name: hidden
---

Prometheus est un système de monitoring (surveillance) open source basé sur les métriques. Il est très populaire aujourd'hui en particulier dans le contexte des clouds applicatifs ou il est la solution de référence.

Prometheus fait une chose assez précise très efficacement (philosophie Unix) : il possède un modèle de données simple mais très puissant et scalable avec un langage de requêtes sur ces données très flexible : il vous permet d'analyser les performances de vos applications et de votre infrastructure en temps réel dans des contextes dynamiques.

Par ailleurs, il ne cherche pas à répondre à des usecases en dehors de l'espace de la récupération et gestion des métriques, laissant cela à d'autres outils plus appropriés.

Prometheus est loin d'être le seul système de ce type sur le marché mais son modèle est particulièrement adapté à la conteneurisation des applications et il est construit et maintenu dans une vaste communauté open source

Le projet Prometheus a démarré chez SoundCloud en 2012 comme outil interne de surveillance adapté à leur cloud applicatif assez innovant pour l'époque. Très vite le projet a été opensourcé,  une communauté et un écosystème se sont développés autour. En 2016, le projet Prometheus est devenu le deuxième membre de la Cloud Native Computing Foundation (CNCF).

Prometheus est principalement écrit en Go et est sous licence Apache 2.0. 

# Qu'est-ce que la surveillance ?

La surveillance est un concept vague. Prometheus a été créé pour aider les développeurs de logiciels et les administrateurs dans l'exploitation de systèmes informatiques de production, tels que les applications, les outils operationnels, les bases de données et les réseaux soutenant par exemples des plateforme web (Saas) mais aussi tout autre système informatique.

Qu'est-ce que la surveillance (monitoring) dans ce contexte ? On peut extraire quatre aspects classiques :

1. **Alerting** : Savoir quand les choses tournent mal est généralement la chose la plus importante que vous attendez de la surveillance. Vous souhaitez que le système de surveillance (monitoring system) appelle un être humain (human) pour qu'il examine la situation.

2. **Debugging** : Une fois qu'un être humain (human) est impliqué, il doit enquêter pour déterminer la cause fondamentale et finalement résoudre le problème.

3. **Trending** (surveillance des tendance) : Les alertes et le débogage se produisent généralement sur des échelles de temps de l'ordre de quelques minutes à quelques heures. Bien que moins urgent, la capacité à voir comment vos systèmes sont utilisés et comment ils évoluent au fil du temps est également utile. Le trending peut influencer les décisions de conception et les processus tels que la planification de capacité (nombre et tailles des machines de l'infrastructure notamment).

4. **Plumbing** ("Plomberie") : Tous les systèmes de surveillance sont des pipelines de traitement des données, ce n'est pas strictement de la surveillance (monitoring), mais c'est très lié. Il faut pouvoir filtrer et rediriger les données de surveillance vers d'autres partie de votre infrastructure (CI/CD), audit de sécurité etc.

<!-- ## Petite histoire du Monitoring

La surveillance est passé par différentes solutions durant les dernières années. Pendant longtemps, la solution dominante a été une combinaison de Nagios et de Graphite, ou de leurs variantes.

Nagios a été créé par Ethan Galstad en 1996 en tant qu'application MS-DOS pour effectuer des pings, puis renommé Nagios en 2002. Nagios, Icinga, Zmon et Sensu sont des exemples de logiciels de la même famille.

- Ces outils fonctionnent en exécutant régulièrement des scripts appelés "checks". En cas d'échec d'un check (renvoyant un code de sortie différent de zéro), une alerte (alert) est générée.

L'origine de Graphite remonte à 1994 lorsque Tobias Oetiker a créé un script Perl devenu Multi Router Traffic Grapher (MRTG) 1.0 en 1995. MRTG était principalement utilisé pour la surveillance réseau via SNMP et obtenir des métriques en exécutant des scripts. En 1997, des changements importants ont eu lieu, notamment le passage de certaines parties du code en C et la création de la base de données Round Robin (RRD) pour stocker les données métriques.RRD a amélioré les performances et a servi de base à d'autres outils comme Smokeping et Graphite. 

- Graphite, créé en 2006, utilise Whisper pour stocker les métriques, ayant une conception similaire à RRD. Graphite ne collecte pas de données lui-même, elles sont collectées par des outils de collecte tels que collectd et StatsD.

Prometheus utilise des metriques un peu comme Graphite mais avec des caractéristiques (notamment les labels) qui les rendent plus flexibles et adaptés au cloud.
Il gère ensuite l'alerting à partir de requêtes sur ses métriques plutôt que des scripts de checks comme Nagios. -->

# Prometheus flexibilité et standardisation

Un force de Prometheus est son intégration avec énormément de solutions et la façon dont il sert de support à un processus de standardisation open source.

- Pour instrumenter votre propre code, il existe des bibliothèques clientes dans tous les langages et environnements populaires, notamment Go, Java/JVM, C#/.Net, Python, Ruby, Node.js, Haskell, Erlang et Rust.

- De nombreuses applications populaires sont déjà instrumentées avec des bibliothèques clientes Prometheus, telles que Kubernetes, Docker, Envoy et Vault et la plupart des provider de cloud.

- Un format texte simple facilite l'exposition des métriques à Prometheus (le format de métrique prometheus). D'autres systèmes de surveillance, qu'ils soient open source ou commerciaux, ont ajouté la prise en charge de ce format. Cela permet à tous ces systèmes de surveillance de se concentrer davantage sur les fonctionnalités de base, plutôt que de devoir passer du temps à dupliquer les efforts pour prendre en charge chaque logiciel à surveiller.

- Pour les logiciels tiers qui exposent des métriques dans un format non Prometheus, il existe des centaines d'intégrations disponibles. Ces intégrations sont appelées `exporters` et comprennent HAProxy, MySQL, PostgreSQL, Redis, JMX, SNMP, Consul et Kafka.

**labels** et dimentionnalité dynamique : Le modèle de données de Prometheus identifie chaque série temporelle non seulement par un nom, mais aussi par un ensemble non ordonné de paires clé-valeur appelées labels.

- Basé sur ces labels, le langage de requête PromQL permet l'agrégation sur n'importe quelle information, de sorte que vous pouvez analyser dynamiquement non seulement par processus, mais aussi par datacenter, service ou par toute autre caractéristique que vous avez définie. Vous pouvez afficher ces données dans des systèmes de tableau de bord tels que Grafana.

Les alertes peuvent être définies à l'aide du même langage de requête PromQL que celui utilisé pour créer des graphiques: tous ce qui est surveillé peut être tracé en graphique et servir de support pour les alertes.

- Les étiquettes facilitent la maintenance des alertes, on peut créer une seule alerte couvrant toutes les valeurs possibles des étiquettes. Dans d'autres systèmes de surveillance, vous devriez créer individuellement une alerte par machine/application.

- La découverte de service (Service Discovery) peut déterminer automatiquement les applications et les machines à "scraper" (ou récupérer des données) à partir de sources telles que Kubernetes, Consul, AWS, Azure, GCP ou OpenStack.

Prometheus est assez simple a opérer a grande échelle : un seul serveur Prometheus peut ingérer des millions d'échantillons par seconde. Il s'agit d'un fichier binaire unique, avec un fichier de configuration. 

- Les composants de Prometheus peuvent être exécutés dans des conteneurs : il est conçu pour être intégré dans l'infrastructure existante et sur laquelle vous avez construit, et non pour être une plate-forme de gestion en soi.

- En tant que système basé sur les métriques, Prometheus ne convient pas au stockage de journaux d'événements ou d'événements individuels. Ce n'est pas non plus le meilleur choix pour des données à haute cardinalité, telles que des adresses e-mail ou des noms d'utilisateur.

- Prometheus est conçu pour la surveillance opérationnelle, où des imprécisions sont acceptables : il fait des compromis et préfère fournir des données globalement pertinentes plutôt que d'entraver la surveillance en attendant des données parfaites.
---
title:  Objectifs de Kubernetes
weight: 32
--- 

## Objectifs de Kubernetes


Pourquoi ai-je besoin de Kubernetes et que peut-il faire?
Kubernetes a un certain nombre de fonctionnalités. Il peut être pris en considération:

Une plate-forme de conteneur
une plate-forme de microservice
Une plate-forme cloud portable et bien plus encore.
Kubernetes fournit un environnement de gestion axé sur le conteneur (Container-Center). Il orchestre les ressources machine (informatique), l'infrastructure de mise en réseau et de stockage sur les charges de travail des utilisateurs. Cela vous permet de vous rapprocher de la simplicité de la plate-forme en tant que service (PaaS) avec la flexibilité des solutions d'infrastructure de service (IAAS), tout en gardant la portabilité entre les différents fournisseurs d'infrastructure (fournisseurs).

Comment Kubernetes est-elle une plate-forme?
Même si Kubernetes offre de nombreuses fonctionnalités, il existe encore de nouveaux scénarios qui bénéficieraient de fonctionnalités supplémentaires. Ces flux de travail spécifiques permettent d'accélérer la vitesse de développement. Si l'orchestration de base est acceptable pour commencer, il est souvent nécessaire d'avoir une automatisation robuste lorsque vous devez la changer. C'est pourquoi Kubernetes a également été conçu pour servir de plate-forme et favoriser la construction d'un écosystème de composants et d'outils facilitant le déploiement, la mise à l'échelle et la gestion des applications.

Les étiquettes permettent aux utilisateurs d'organiser leurs ressources comme ils le souhaitent. Les anotations autorisent les utilisateurs à définir des informations personnalisées sur les ressources pour faciliter leurs flux de travail et fournir un moyen simple d'outils pour gérer la vérification de l'État (Checkpoint State).

De plus, le plan de contrôle Kubernetes (plan de contrôle) est construit sur les mêmes API que ceux accessibles aux développeurs et aux utilisateurs. Les utilisateurs peuvent écrire leurs propres contrôleurs (contrôleurs), tels que la commande (planificateurs), avec leurs propres API qui peuvent être utilisées par un outil de commande en ligne.

Ce choix de conception a permis de construire un ensemble d'autres systèmes sur Kubernetes.

Ce que Kubernetes n'est pas
Kubernetes n'est pas une solution PaaS (plate-forme en tant que service). Kubernetes opérant dans des conteneurs plutôt qu'en termes d'équipement, il fournit une partie des fonctionnalités des offres PaaS, telles que le déploiement, l'échelle, l'équilibrage de charge (équilibrage de charge), la journalisation (journalisation) et la surveillance (surveillance). Cependant, Kubernetes n'est pas monolithique. Ces implémentations par défaut sont facultatives et interchangeables. Kubernetes fournit les bases pour construire des plates-formes orientées vers les développeurs, laissant à l'utilisateur la possibilité de faire ses propres choix.

Kubernetes:

Ne limite pas les types d'applications prises en charge. Kubernetes prend en charge les charges de travail extrêmement diverses, y compris les applications sans état, l'état ou le traitement des données (traitement des données). Si l'application peut fonctionner dans un conteneur, il doit fonctionner correctement sur Kubernetes.
Ne déploie pas de code source et ne construit pas non plus une application. L'intégration continue, la livraison continue et les workflows de déploiement continu (CI / CD) sont effectués en fonction de la culture d'entreprise, des préférences ou des conditions techniques.
Ne fournit pas nativement des services d'application tels que le middleware (par exemple, les buses de message), les cadres de traitement des données (par exemple, Spark), les bases de données (par exemple, MySQL), les caches ou les systèmes de stockage clusterisés (par exemple, CEPH). Ces composants peuvent être lancés dans Kubernetes et / ou être accessibles aux applications exécutées dans Kubernetes via des mécanismes d'intermédiation tels que Open Service Broker.
N'impose pas les solutions de journalisation, de surveillance ou d'alerte. Kubernetes fournit quelques intégrations primaires et des mécanismes de collecte et d'exportation des mesures.
Ne fournit ni n'impose un langage / système de configuration (par exemple, JSONNET). Il fournit une API déclarative qui peut être ciblée par toute forme de spécifications déclarées
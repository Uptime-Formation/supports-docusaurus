---
title: Cours - l'opérateur de stockage Longhorn
sidebar_class_name: hidden
---

Voici la traduction en français :

## 1. Conception

La conception de Longhorn comporte deux couches : le plan de données et le plan de contrôle. Le Longhorn engine est un contrôleur de stockage qui correspond au plan de données, et le Longhorn manager correspond au plan de contrôle.

### 1.1. Le Longhorn manager et le Longhorn engine

Le pod du Longhorn manager s'exécute sur chaque nœud du cluster Longhorn en tant que DaemonSet Kubernetes. Il est responsable de la création et de la gestion des volumes dans le cluster Kubernetes, et gère les appels API provenant de l'interface utilisateur ou des plugins de volumes pour Kubernetes. Il suit le modèle de contrôleur Kubernetes, parfois appelé modèle d'opérateur.

Le Longhorn manager communique avec le serveur API de Kubernetes pour créer une nouvelle ressource personnalisée (CR) de volume Longhorn. Ensuite, le Longhorn manager surveille la réponse du serveur API, et lorsqu'il constate que le serveur API Kubernetes a créé une nouvelle CR de volume Longhorn, le Longhorn manager crée un nouveau volume.

Lorsque le Longhorn manager est sollicité pour créer un volume, il crée une instance du Longhorn engine sur le nœud auquel le volume est attaché, et il crée une réplique sur chaque nœud où une réplique sera placée. Les replicas doivent être placées sur des hôtes distincts pour garantir une disponibilité maximale.

Les multiples chemins de données des replicas assurent une haute disponibilité du volume Longhorn. Même si un problème survient avec une réplique particulière ou avec le moteur, cela n'affectera pas toutes les replicas ou l'accès du pod au volume. Le pod continuera à fonctionner normalement.

Le Longhorn engine s'exécute toujours sur le même nœud que le pod qui utilise le volume Longhorn. Il réplique de manière synchrone le volume entre les multiples replicas stockées sur plusieurs nœuds.

Le moteur et les replicas sont orchestrés à l'aide de Kubernetes.

Dans la figure ci-dessous :

- Il y a trois instances avec des volumes Longhorn.
- Chaque volume a un contrôleur dédié, appelé Longhorn engine, qui fonctionne en tant que processus Linux.
- Chaque volume Longhorn a deux replicas, et chaque réplique est un processus Linux.
- Les flèches sur la figure indiquent le flux de données en lecture/écriture entre le volume, l'instance du contrôleur, les instances de replicas, et les disques.
- En créant un Longhorn engine séparé pour chaque volume, si un contrôleur échoue, la fonction des autres volumes n'est pas impactée.

Figure 1. Flux de données en lecture/écriture entre le volume, le Longhorn engine, les instances de replicas, et les disques.

![](/img/kubernetes/longhorn/how-longhorn-works.svg)

Voici la traduction en français avec "Longhorn Engine", "Longhorn Manager" et "replicas" non traduits :

### 1.2. Avantages d'une Conception Basée sur des Microservices

Dans Longhorn, chaque Engine ne doit servir qu'un seul volume, ce qui simplifie la conception des contrôleurs de stockage. Étant donné que le domaine de défaillance du logiciel de contrôle est isolé à des volumes individuels, un crash du contrôleur n'impactera qu'un seul volume.

Le Longhorn Engine est suffisamment simple et léger pour que nous puissions créer jusqu'à 100 000 engines distincts. Kubernetes planifie ces engines distincts en utilisant les ressources d'un ensemble partagé de disques et en collaborant avec Longhorn pour former un système de stockage distribué et résilient.

Puisque chaque volume possède son propre contrôleur, les instances de contrôleurs et de replicas pour chaque volume peuvent également être mises à jour sans provoquer de perturbation notable des opérations d'entrée/sortie (IO).

Longhorn peut créer un travail de longue durée pour orchestrer la mise à jour de tous les volumes actifs sans interrompre les opérations en cours du système. Pour garantir qu'une mise à jour ne cause pas de problèmes imprévus, Longhorn peut choisir de mettre à jour un petit sous-ensemble des volumes et revenir à l'ancienne version en cas de problème pendant la mise à jour.

### 1.3. CSI Driver

Le Longhorn CSI driver prend le périphérique de bloc, le formate et le monte sur le nœud. Ensuite, le kubelet monte le périphérique à l'intérieur d'un pod Kubernetes. Cela permet au pod d'accéder au volume Longhorn.

Les images requises du Kubernetes CSI Driver seront déployées automatiquement par le longhorn driver deployer. Pour installer Longhorn dans un environnement sans connexion à internet, référez-vous à cette section.

### 1.4. CSI Plugin

Longhorn est géré dans Kubernetes via un plugin CSI. Cela permet une installation facile du plugin Longhorn.

Le plugin CSI Kubernetes appelle Longhorn pour créer des volumes et fournir des données persistantes pour une charge de travail Kubernetes. Le plugin CSI vous permet de créer, supprimer, attacher, détacher, monter le volume, et de prendre des snapshots du volume. Toutes les autres fonctionnalités fournies par Longhorn sont implémentées via l'interface utilisateur de Longhorn.

Le cluster Kubernetes utilise en interne l'interface CSI pour communiquer avec le plugin CSI Longhorn. Le plugin CSI Longhorn communique avec le Longhorn Manager via l'API de Longhorn.

Longhorn utilise iSCSI, donc une configuration supplémentaire du nœud peut être nécessaire. Cela peut inclure l'installation de `open-iscsi` ou `iscsiadm` selon la distribution.

### 1.5. L'Interface Utilisateur de Longhorn

L'interface utilisateur de Longhorn interagit avec le Longhorn Manager via l'API de Longhorn, et sert de complément à Kubernetes. Grâce à l'interface utilisateur de Longhorn, vous pouvez gérer les snapshots, les sauvegardes, les nœuds et les disques.

De plus, l'utilisation de l'espace des nœuds de travail du cluster est collectée et illustrée par l'interface utilisateur de Longhorn. Voir ici pour plus de détails.

## 2. Volumes Longhorn et Stockage Principal

Lors de la création d'un volume, le Longhorn Manager crée le microservice Longhorn Engine et les replicas pour chaque volume en tant que microservices. Ensemble, ces microservices forment un volume Longhorn. Chaque replica doit être placé sur un nœud ou sur des disques différents.

Une fois le Longhorn Engine créé par le Longhorn Manager, il se connecte aux replicas. Le Engine expose un périphérique de bloc sur le même nœud où le pod est exécuté.

Un volume Longhorn peut être créé avec `kubectl`.

### 2.1. Provisionnement Mince et Taille des Volumes

Longhorn est un système de stockage à provisionnement mince. Cela signifie qu'un volume Longhorn ne prendra que l'espace dont il a besoin à ce moment-là. Par exemple, si vous allouez un volume de 20 Go mais n'utilisez qu'1 Go, la taille réelle des données sur votre disque sera de 1 Go. Vous pouvez voir la taille réelle des données dans les détails du volume dans l'interface utilisateur.

Un volume Longhorn lui-même ne peut pas rétrécir en taille si vous avez supprimé du contenu de votre volume. Par exemple, si vous créez un volume de 20 Go, utilisez 10 Go, puis supprimez 9 Go de contenu, la taille réelle sur le disque sera toujours de 10 Go au lieu de 1 Go. Cela se produit parce que Longhorn fonctionne au niveau du bloc, et non au niveau du système de fichiers, donc Longhorn ne sait pas si le contenu a été supprimé par un utilisateur ou non. Ces informations sont principalement stockées au niveau du système de fichiers.

Pour plus d'informations sur les concepts liés à la taille des volumes, consultez ce document pour plus de détails.

### 2.2. Réversion des Volumes en Mode Maintenance

Lorsqu'un volume est attaché depuis l'interface utilisateur de Longhorn, il y a une case à cocher pour le mode Maintenance. Il est principalement utilisé pour rétablir un volume à partir d'un snapshot.

L'option entraîne l'attachement du volume sans activer le frontend (périphérique de bloc ou iSCSI), pour s'assurer que personne ne puisse accéder aux données du volume lorsqu'il est attaché.

Depuis la version v0.6.0, l'opération de réversion du snapshot nécessite que le volume soit en mode maintenance. Cela s'explique par le fait que si le contenu du périphérique de bloc est modifié pendant que le volume est monté ou utilisé, cela entraînera une corruption du système de fichiers.

C'est également utile pour inspecter l'état du volume sans s'inquiéter de l'accès accidentel aux données.
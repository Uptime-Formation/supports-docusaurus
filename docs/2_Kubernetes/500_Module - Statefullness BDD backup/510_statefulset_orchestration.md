---
title: Cours - orchestration des Statefulsets
# sidebar_class_name: hidden
---


## Pod management policies

Le `podManagementPolicy` détermine le moment d'ajout ou de suppression des Pods d'un StatefulSet. La politique `OrderedReady` appliquée dans notre exemple de Cassandra est la politique par défaut. Lorsque cette politique est en place et que des Pods sont ajoutés, que ce soit lors de la création initiale ou de la mise à l'échelle, Kubernetes étend le StatefulSet un Pod à la fois. À chaque ajout de Pod, Kubernetes attend que le Pod rapporte un statut "Ready" avant d'ajouter les Pods suivants. Si la spécification du Pod contient une `readinessProbe`, Kubernetes exécute la commande fournie de manière itérative pour déterminer quand le Pod est prêt à recevoir du trafic. Lorsque la sonde réussit (c'est-à-dire avec un code de retour zéro), Kubernetes passe à la création du Pod suivant. Pour Cassandra, la disponibilité du port CQL (9042) est généralement utilisée pour mesurer la readiness, indiquant que le nœud est capable de répondre aux requêtes CQL.

De la même manière, lorsqu'un StatefulSet est supprimé ou réduit, les Pods sont supprimés un par un. Lorsqu'un Pod est en cours de suppression, les commandes `preStop` fournies pour ses conteneurs sont exécutées afin de leur permettre de se fermer proprement. Dans notre exemple actuel, la commande `nodetool drain` est exécutée pour permettre au nœud Cassandra de quitter le cluster proprement, en assignant ses responsabilités pour ses plages de jetons aux autres nœuds. Kubernetes attend que chaque Pod soit complètement terminé avant de supprimer le suivant. La commande spécifiée dans la `livenessProbe` est utilisée pour déterminer quand le Pod est "alive" (vivant), et lorsqu'elle échoue de manière répétée, Kubernetes peut passer à la suppression du Pod suivant.

L'autre politique de gestion des Pods est `Parallel`. Lorsque cette politique est en vigueur, Kubernetes lance ou termine plusieurs Pods simultanément pour effectuer la mise à l'échelle. Cela permet d'atteindre plus rapidement le nombre souhaité de réplicas dans le StatefulSet, mais peut aussi entraîner une stabilisation plus lente de certaines charges de travail stateful. Par exemple, une base de données comme Cassandra redistribue les données entre les nœuds lorsque la taille du cluster change afin de répartir la charge, et elle aura tendance à se stabiliser plus rapidement lorsque les nœuds sont ajoutés ou supprimés un par un. Avec l'une ou l'autre des politiques, Kubernetes gère les Pods selon des numéros d'ordinal, en ajoutant toujours des Pods avec les numéros d'ordinal non utilisés lors de la montée en charge, et en supprimant les Pods avec les numéros d'ordinal les plus élevés lors de la réduction.

### Stratégies de mise à jour

La `updateStrategy` décrit comment les Pods dans le StatefulSet seront mis à jour si un changement est apporté dans la spécification du modèle de Pod, comme le changement d'une image de conteneur. La stratégie par défaut est `RollingUpdate`, comme sélectionnée dans cet exemple.

Avec l'autre option, `OnDelete`, vous devez supprimer manuellement les Pods pour que le nouveau modèle de Pod soit appliqué.

Dans une mise à jour en rolling update, Kubernetes supprime et recrée chaque Pod du StatefulSet, en commençant par le Pod avec le numéro d'ordinal le plus élevé et en descendant vers le plus bas. Les Pods sont mis à jour un par un, et vous pouvez spécifier un certain nombre de Pods, appelé partition, pour effectuer un déploiement progressif ou en canari.

À noter que si vous découvrez une mauvaise configuration de Pod pendant un déploiement, vous devrez mettre à jour la spécification du modèle de Pod avec une configuration valide, puis supprimer manuellement tous les Pods créés avec la mauvaise configuration. Comme ces Pods n'atteindront jamais l'état "Ready", Kubernetes ne les remplacera pas automatiquement par la bonne configuration.


---
title:   Run5 Operators
weight: 1
---

## Onjectifs du Run

- Comprendre le mode de fonctionnement des controlleurs et opérateurs dans Kubernetes
- Développer ses propres ressources

-- 

## Compréhension des Operators et Controllers dans Kubernetes

**Les **Operators** et **Controllers** dans Kubernetes sont des concepts essentiels pour automatiser la gestion des applications et des infrastructures complexes.** 

Un **Controller** est un processus qui surveille l'état du cluster et applique des modifications pour atteindre l'état souhaité en fonction des spécifications.

Par exemple, un ReplicaSet Controller veille à ce que le nombre de réplicas d'une application corresponde toujours à ce qui est défini dans la configuration.

Un **Operator** étend ce concept en encapsulant la logique métier nécessaire pour gérer des applications spécifiques ou des services, en intégrant des tâches opérationnelles telles que les sauvegardes, les mises à jour et les configurations personnalisées.

Un exemple d'Operator pour Elasticsearch est l'Elastic Cloud on Kubernetes (ECK), qui facilite le déploiement, la gestion et la maintenance des clusters Elasticsearch sur Kubernetes : [Elastic Cloud on Kubernetes (ECK)](https://www.elastic.co/guide/en/cloud-on-k8s/current/index.html).

---

## Comment fonctionne la réconcialiation des ressources dans kubernetes ?

```
Utilisateur définit l'état désiré (YAML/JSON)
       │
       ▼
API Server enregistre l'état désiré
       │
       ▼
Controller surveille l'état actuel via l'API Server
       │
       ▼
Comparaison de l'état actuel avec l'état désiré
       │
       ▼
Différence (discrepancy) détectée ?
       │          │
       ├── Non ───┤
       │          │
       ▼          ▼
Oui               Le Controller continue à surveiller
       │
       ▼
Le Controller prend des mesures correctives
       │
       ▼
Mise à jour de l'état actuel dans l'API Server
       │
       ▼
Cycle de surveillance continue...

```

--- 

## Un exemple de controller 

**Voici l'exemple officiel de controller de k8s : https://github.com/kubernetes/sample-controller**

Cet exemple` démontre un flux complet de gestion des ressources personnalisées dans Kubernetes, depuis l'initialisation du client et la définition des CRDs jusqu'à la mise en place des handlers d'événements et le cycle de réconciliation des ressources.


### Fonctionnement du controller

1. **Initialisation du Client Kubernetes :**
   - Le controller utilise `client-go` cf. https://github.com/kubernetes/client-go pour interagir avec l'API Kubernetes. Il initialise un client pour communiquer avec le cluster en utilisant une configuration fournie.
   - Fichier concerné : `main.go`

2. **Configuration de l'Informer :**
   - Un Informer est configuré pour surveiller les ressources personnalisées (Custom Resources). Il établit une connexion pour recevoir des événements lorsqu'il y a des ajouts, des mises à jour ou des suppressions de ces ressources.
   - Fichier concerné : `pkg/controller/controller.go`

3. **Création des Custom Resource Definitions (CRDs) :**
   - Le controller définit les CRDs pour les nouvelles ressources personnalisées qu'il va gérer. Cela inclut la définition des schémas et des validations pour ces ressources.
   - Fichier concerné : `artifact/crd.yaml`

4. **Mise en Place des Queues de Travail :**
   - Une queue de travail (WorkQueue) est mise en place pour gérer les objets à traiter par le controller. Les événements capturés par l'informer sont ajoutés à cette queue.
   - Fichier concerné : `pkg/controller/controller.go`

5. **Définition des Handlers d'Événements :**
   - Les handlers d'événements (Add, Update, Delete) sont définis pour traiter les objets lorsque des événements sont capturés par l'informer. Ces handlers ajoutent les objets pertinents à la WorkQueue.
   - Fichier concerné : `pkg/controller/controller.go`

6. **Cycle de Réconciliation :**
   - Le cœur du controller est le cycle de réconciliation, où le controller compare l'état actuel des ressources avec l'état désiré et prend des mesures pour aligner les deux. 
   - Fichier concerné : `pkg/controller/controller.go`

7. **Récupération et Gestion des Objets :**
   - Lorsqu'un élément est récupéré de la WorkQueue, le controller tente de récupérer l'objet correspondant à partir du cache local. Si l'objet n'existe plus, il est simplement ignoré.
   - Fichier concerné : `pkg/controller/controller.go`

8. **Gestion des Erreurs :**
   - Le controller gère les erreurs en réessayant plusieurs fois les opérations échouées. Si une erreur persiste après plusieurs tentatives, l'objet est mis en quarantaine pour un traitement ultérieur.
   - Fichier concerné : `pkg/controller/controller.go`

9. **Éviction des Objets de la Queue :**
   - Une fois que l'objet a été traité avec succès ou après plusieurs échecs, il est évincé de la WorkQueue pour éviter une boucle infinie de traitement.
   - Fichier concerné : `pkg/controller/controller.go`

10. **Démarrage du Controller :**
    - Enfin, le controller est démarré et exécute une boucle infinie pour surveiller les événements et traiter les objets dans la WorkQueue. Il assure également une gestion correcte des goroutines et des signaux d'arrêt.
    - Fichier concerné : `main.go`



--- 

## Fonctionnement du Déclenchement des Contrôleurs dans Kubernetes

**Dans Kubernetes, les contrôleurs sont des composants qui gèrent l'état de diverses ressources au sein du cluster. Ils sont généralement implémentés sous la forme de pods s'exécutant à l'intérieur du cluster. Le composant principal du plan de contrôle de Kubernetes responsable de déclencher les contrôleurs est le **kube-controller-manager**.**

1. **Kube-Controller-Manager :**
   - Le **kube-controller-manager** est un binaire qui s'exécute dans le plan de contrôle et gère plusieurs contrôleurs intégrés.
   - Il surveille l'état du cluster via l'API server et prend des mesures pour s'assurer que l'état du cluster correspond à l'état désiré spécifié par l'utilisateur.

2. **Contrôleurs Personnalisés :**
   - Les contrôleurs personnalisés s'exécutent en tant que pods distincts dans le cluster.
   - Ils surveillent des ressources spécifiques (Custom Resource Definitions, CRDs) et agissent en fonction des modifications.
   - Ces contrôleurs utilisent l'API Kubernetes pour enregistrer leur intention de surveiller certaines ressources.
--- 
### Flux d'Interaction

1. **Notification par l'API Server :**
   - L'API server notifie les contrôleurs des modifications apportées aux ressources grâce à un mécanisme de watch.
   - Les contrôleurs enregistrent des watches auprès de l'API server pour les ressources qui les intéressent (par exemple, Pods, Deployments, Custom Resources).

2. **Informer Framework :**
   - Les contrôleurs utilisent souvent le Framework Informer de Kubernetes ( du package`client-go` ) pour abstraire la complexité de la surveillance des ressources.
   - Les Informers gèrent efficacement la surveillance et la mise en cache des ressources, et déclenchent des gestionnaires d'événements lorsque des changements surviennent.

3. **Paramètres Passés :**
   - **Définitions des Ressources :** Les contrôleurs surveillent les ressources définies dans des manifestes YAML ou JSON appliqués au cluster.
   - **Annotations et Labels :** Les contrôleurs peuvent utiliser des annotations et des labels sur les ressources pour obtenir des paramètres supplémentaires ou des métadonnées.
   - **ConfigMaps et Secrets :** Les paramètres et configurations peuvent être passés en utilisant des ConfigMaps et des Secrets, que les contrôleurs lisent au moment de l'exécution.
   - **Variables d'Environnement :** Les contrôleurs peuvent être configurés via des variables d'environnement définies dans leurs manifestes de déploiement.

---

### Résumé

- **Déclenchement :** Les contrôleurs sont déclenchés par le kube-controller-manager pour les contrôleurs intégrés, et par les événements de l'API server pour les contrôleurs personnalisés.
- **Paramètres :** Les contrôleurs reçoivent des paramètres via les ressources surveillées, les annotations, les labels, les ConfigMaps, les Secrets et les variables d'environnement.
- **Mécanisme :** Les contrôleurs utilisent le framework Informer pour surveiller les ressources et recevoir des événements, leur permettant de concilier l'état désiré avec l'état réel.

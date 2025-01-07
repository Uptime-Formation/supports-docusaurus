---
title: Jour 3 - Après Midi
---

# Jour 3 - Après Midi

## Custom Resource Definitions (CRDs) dans Kubernetes

**En résumé, les **Custom Resource Definitions** (CRDs) et les opérateurs permettent d'étendre Kubernetes en introduisant des ressources et des logiques métiers spécifiques à vos besoins.** 

Les CRDs offrent une flexibilité pour gérer de nouveaux types d'objets dans Kubernetes, et les opérateurs automatisent la gestion de ces ressources, rendant possible le déploiement et la maintenance d'applications complexes.

En plus des ressources natives comme Pods, Services, et Deployments, les CRDs permettent de définir et de gérer des objets spécifiques à vos applications ou infrastructures directement via l'API Kubernetes.

Les CRDs permettent ainsi de :
- Définir des ressources spécifiques à votre application ou plateforme.
- Gérer ces ressources avec des outils natifs de Kubernetes comme `kubectl`.
- Intégrer des logiques métiers spécifiques via des opérateurs qui surveillent et gèrent l'état de ces ressources.

---

### Comment fonctionnent les CRDs ?

1. **Définition de ressources personnalisées** : Une CRD permet de définir un nouveau type de ressource dans Kubernetes, avec sa propre structure (schema) et comportement.
   
2. **Gestion via l'API Kubernetes** : Une fois la CRD installée, Kubernetes expose une nouvelle API pour gérer ces ressources via `kubectl` ou des appels API.

3. **Contrôleurs et opérateurs** : Les CRDs sont souvent utilisées avec des opérateurs (des contrôleurs avancés) pour automatiser la gestion des ressources personnalisées. Un opérateur est responsable de la création, mise à jour, suppression, et surveillance des objets définis par une CRD.

---

### Exemple simple de CRD

Voici un exemple minimal de CRD qui définit une nouvelle ressource `Database` :

```yaml
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: databases.mycompany.com
spec:
  group: mycompany.com
  versions:
    - name: v1
      served: true
      storage: true
      schema:
        openAPIV3Schema:
          type: object
          properties:
            spec:
              type: object
              properties:
                dbName:
                  type: string
                dbVersion:
                  type: string
  scope: Namespaced
  names:
    plural: databases
    singular: database
    kind: Database
    shortNames:
      - db
```

Cet exemple montre une définition de la ressource `Database` avec deux champs : `dbName` et `dbVersion`. La ressource est déclarée dans le groupe `mycompany.com` et est accessible via l’API `databases`.

Une fois la CRD appliquée, vous pouvez gérer ces objets avec des commandes comme :

```bash
kubectl get databases
kubectl describe database <database-name>
kubectl delete database <database-name>
```

### Installer des CRDs

Pour installer une CRD dans Kubernetes, il suffit de la déployer en utilisant la commande suivante :

```bash
kubectl apply -f <crd-file.yaml>
```

Cela enregistre le type de ressource personnalisé dans le cluster, et Kubernetes expose les nouvelles API correspondantes. Par exemple :

```bash
kubectl apply -f crd-database.yaml
```

---

## Utilisation des opérateurs

Un **Opérateur** est un contrôleur avancé qui surveille l’état des objets CRD et agit en conséquence pour maintenir l’état désiré. Les opérateurs automatisent la gestion des applications complexes en encapsulant la logique métier.

Les opérateurs peuvent être installés via des gestionnaires comme **OperatorHub** ou en les créant manuellement. L'installation d'un opérateur se fait souvent via Helm ou en appliquant directement des fichiers manifestes YAML.



---

#### Exemple d'installation d'un opérateur via OperatorHub

1. **Accéder à OperatorHub** (sur OpenShift ou via l'interface OperatorHub.io pour d’autres distributions).

2. **Rechercher et installer un opérateur** : Par exemple, pour installer un opérateur Postgres, vous pouvez choisir **Crunchy Postgres Operator** et suivre les étapes d'installation directement dans OperatorHub.

3. **Installer l’opérateur via `kubectl`** : Si vous utilisez un fichier manifeste YAML fourni par l'opérateur, vous pouvez l’appliquer avec `kubectl` :

```bash
kubectl apply -f postgres-operator.yaml
```

4. **Gestion des ressources via l'opérateur** : Une fois l'opérateur installé, il surveille les ressources personnalisées créées (comme `PostgresCluster`) et prend les actions nécessaires pour gérer leur cycle de vie.

---

### Exemples d'opérateurs populaires

- **Prometheus Operator** : Automatisation du déploiement et de la gestion des instances de Prometheus dans Kubernetes.
- **ElasticSearch Operator** : Gestion des clusters ElasticSearch avec support pour les sauvegardes, la mise à l'échelle, et les mises à jour.
- **Cert-Manager** : Automatise la gestion des certificats TLS dans Kubernetes en interagissant avec des autorités de certification (AC).

---

### Exemple de fichier CRD avec opérateur

Voici un exemple pour un opérateur Postgres :

**Custom Resource Definition pour PostgresCluster** :

```yaml
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: postgresclusters.postgres-operator.crunchydata.com
spec:
  group: postgres-operator.crunchydata.com
  versions:
    - name: v1
      served: true
      storage: true
      schema:
        openAPIV3Schema:
          type: object
          properties:
            spec:
              type: object
              properties:
                postgresVersion:
                  type: string
  scope: Namespaced
  names:
    plural: postgresclusters
    singular: postgrescluster
    kind: PostgresCluster
    shortNames:
      - pgcluster
```

Une fois l'opérateur installé, vous pouvez créer un cluster Postgres via la nouvelle ressource `PostgresCluster` :

```yaml
apiVersion: postgres-operator.crunchydata.com/v1
kind: PostgresCluster
metadata:
  name: my-postgres-cluster
spec:
  postgresVersion: "13"
```

---

### Gestion des CRDs et des opérateurs

Pour gérer les CRDs et les opérateurs, Kubernetes fournit des commandes `kubectl` standard ainsi que des interfaces comme OperatorHub. Par exemple :

- **Lister les CRDs installées** :

```bash
kubectl get crds
```

- **Désinstaller une CRD** :

```bash
kubectl delete crd <crd-name>
```

- **Vérifier l'état d'un opérateur** :

```bash
kubectl get pods -n <namespace> -l name=<operator-name>
```

---

### Debugging et gestion des pannes dans Kubernetes

Lorsqu'une application ou un cluster Kubernetes rencontre des problèmes, il est essentiel de diagnostiquer rapidement la situation pour minimiser les interruptions de service. Kubernetes offre plusieurs outils et commandes pour le **debugging** et la **gestion des pannes**, permettant d'investiguer et de résoudre les problèmes.

Voici un aperçu des principales techniques pour diagnostiquer et gérer les pannes dans un cluster Kubernetes.

---

## Diagnostiquer les erreurs avec kubectl


**Le **debugging** et la **gestion des pannes** dans Kubernetes nécessitent l’utilisation de divers outils fournis par `kubectl` pour inspecter les Pods, les logs, et l'état des nœuds.** 

Les fonctionnalités avancées, comme l’API debug de Kubernetes, offrent encore plus de flexibilité pour diagnostiquer les erreurs dans un cluster.

Kubernetes fournit plusieurs outils via `kubectl` pour accéder à des informations cruciales pour le debugging. Voici quelques commandes essentielles :

### 1. `kubectl logs`

Cette commande permet d'accéder aux journaux d'un conteneur dans un Pod, ce qui est utile pour diagnostiquer des erreurs d'application ou vérifier le comportement du Pod.

- **Exemple de commande :**

```bash
kubectl logs <pod-name> -n <namespace>
```

- **Options utiles :**
  - `-f` : Affiche les logs en continu (suivre les logs en temps réel).
  - `--previous` : Affiche les logs d'un conteneur mort dans un Pod redémarré.

**Exemple :**

```bash
kubectl logs my-pod -c my-container -n my-namespace
```

Cette commande affiche les logs du conteneur nommé `my-container` dans le Pod `my-pod`.

### 2. `kubectl exec`

La commande `kubectl exec` vous permet d'exécuter des commandes dans un conteneur directement, ce qui est particulièrement utile pour inspecter l'état d'un conteneur ou investiguer une application défaillante.

- **Exemple de commande :**

```bash
kubectl exec -it <pod-name> -n <namespace> -- <command>
```

**Exemple :**

```bash
kubectl exec -it my-pod -n my-namespace -- /bin/bash
```

Cela ouvre un terminal interactif dans le conteneur, où vous pouvez exécuter des commandes Linux pour inspecter le système de fichiers, vérifier les configurations, et investiguer les logs locaux.

### 3. `kubectl port-forward`

La commande `port-forward` permet d'accéder à un service ou à un Pod via un port local, même si ce service ou Pod n'est pas exposé à l'extérieur du cluster. C'est très utile pour tester une application ou un service qui rencontre des problèmes d'accès.

- **Exemple de commande :**

```bash
kubectl port-forward <pod-name> <local-port>:<remote-port> -n <namespace>
```

**Exemple :**

```bash
kubectl port-forward my-pod 8080:80 -n my-namespace
```

Cela redirige le trafic du port local `8080` vers le port `80` du Pod `my-pod`. Vous pouvez alors accéder à l'application du Pod via `localhost:8080`.

### 4. Autres commandes utiles

- **`kubectl describe`** : Donne des détails sur un objet Kubernetes (Pod, Service, etc.) pour diagnostiquer des erreurs liées à la configuration ou aux événements.
  
  ```bash
  kubectl describe pod <pod-name> -n <namespace>
  ```

  Cette commande montre des informations telles que l'état du Pod, les événements récents, et les détails des conteneurs.

- **`kubectl get events`** : Affiche les événements récents dans le cluster, ce qui permet de comprendre les causes des erreurs, comme des problèmes de programmation des Pods, de ressources manquantes, ou des problèmes réseau.

  ```bash
  kubectl get events -n <namespace>
  ```

---

## Utiliser l’API debug de Kubernetes

Kubernetes introduit également une **API de debug** (disponible via `kubectl debug`) qui permet de diagnostiquer plus facilement les Pods en panne ou d’inspecter des conteneurs avec des outils de débogage spéciaux. L'API de debug permet d'exécuter un nouveau Pod avec une configuration de debug ou d'ajouter temporairement des conteneurs de debug à un Pod existant.

### 1. Utiliser `kubectl debug` pour lancer un Pod de debug

La commande `kubectl debug` permet de créer rapidement un Pod de débogage basé sur l’un des Pods existants, mais avec une image contenant des outils supplémentaires pour le diagnostic (comme `busybox` ou `ubuntu`).

- **Exemple de commande :**

```bash
kubectl debug <pod-name> -n <namespace> --image=busybox -- /bin/sh
```

Cela crée un nouveau Pod de débogage utilisant l'image `busybox` avec une session shell interactive, vous permettant d'explorer l'environnement.

### 2. Créer un conteneur de debug dans un Pod existant

Dans certains cas, vous pouvez avoir besoin d’ajouter un conteneur temporaire dans un Pod défaillant pour exécuter des outils de diagnostic qui ne sont pas présents dans l'image du conteneur d'origine.

- **Exemple de commande :**

```bash
kubectl debug <pod-name> -n <namespace> --target=<container-name> --image=ubuntu
```

Cette commande injecte un conteneur de debug basé sur l'image `ubuntu` dans le Pod, où vous pouvez exécuter des outils comme `curl`, `nslookup`, ou `ping` pour diagnostiquer des problèmes réseau.

---

## Scénarios courants de gestion des pannes

### 1. Pods en état **CrashLoopBackOff**

- **Problème** : Le Pod redémarre constamment.
- **Diagnostic** :
  - Vérifiez les logs du conteneur en échec avec `kubectl logs`.
  - Inspectez les événements récents avec `kubectl describe` pour vérifier les erreurs de configuration ou de ressources.

### 2. Pods bloqués en état **Pending**

- **Problème** : Le Pod ne parvient pas à démarrer.
- **Diagnostic** :
  - Utilisez `kubectl describe` pour vérifier si des ressources (comme CPU ou mémoire) sont indisponibles ou si le nœud n'a pas pu programmer le Pod.
  - Vérifiez les quotas de ressources dans le namespace et les limites de capacité du cluster.

### 3. Problèmes de réseau

- **Problème** : Les Pods ou services ne parviennent pas à communiquer.
- **Diagnostic** :
  - Utilisez `kubectl debug` pour lancer des tests réseau depuis le conteneur de debug  (par ex. `ping`, `curl`).
  - Utilisez `kubectl port-forward` pour accéder à un Pod ou un service et vérifier son comportement.

---



---
title: Cours - Les différents contrôleurs pour les pods
draft: false
# sidebar_class_name: hidden
---

![](/img/kubernetes/schemas-perso/resources-deps.jpg?width=400px)

En plus du déploiement d'un application, Il existe pleins d'autre raisons de créer un ensemble de Pods:

- Le **DaemonSet**: Faire tourner un agent ou démon sur chaque nœud, par exemple pour des besoins de monitoring, ou pour configurer le réseau sur chacun des nœuds.
- Le **Job** : Effectuer une tache unique de durée limitée et ponctuelle, par exemple de nettoyage d'un volume ou la préparation initiale d'une application, etc.
- Le **CronJob** : Effectuer une tache unique de durée limitée et récurrente, par exemple de backup ou de régénération de certificat, etc.

De plus même pour faire tourner une application, les déploiements ne sont pas toujours suffisants. En effet ils sont peu adaptés à des applications statefull comme les bases de données de toutes sortes qui ont besoin de persister des données critiques. Pour celà on utilise un **StatefulSet** que nous verrons par la suite.

Étant donné les similitudes entre les DaemonSets, les StatefulSets et les Deployments, il est important de comprendre un peu précisément quand les utiliser.

Les **Deployments** (liés à des ReplicaSets) doivent être utilisés :

  - lorsque votre application est complètement découplée du nœud
  - que vous pouvez en exécuter plusieurs copies sur un nœud donné sans considération particulière
  - que l'ordre de création des replicas et le nom des pods n'est pas important
  - lorsqu'on fait des opérations *stateless*

Les **DaemonSets** doivent être utilisés :
  - lorsqu'au moins une copie de votre application doit être exécutée sur tous les nœuds du cluster (ou sur un sous-ensemble de ces nœuds).

Les **StatefulSets** doivent être utilisés :
  - lorsque l'ordre de création des replicas et le nom des pods est important
  - lorsqu'on fait des opérations *stateful* (écrire dans une base de données)

### Jobs

Les jobs sont utiles pour les choses que vous ne voulez faire qu'une seule fois, comme les migrations de bases de données ou les travaux par lots. Si vous exécutez une migration en tant que Pod dans un deployment:

- Dès que la migration se finit le processus du pod s'arrête.
- Le **replicaset** qui détecte que l'"application" s'est arrêter va tenter de la redémarrer en recréant le pod.
- Votre tâche de migration de base de données se déroulera donc en boucle, en repeuplant continuellement la base de données.

### CronJobs

Comme des jobs, mais se lancent à un intervalle régulier, comme les `cron` sur les systèmes unix.

#### Exemple de Cronjob pour un backup avec Velero

Voici un exemple de Job Kubernetes pour effectuer un Job régulier. Par exemple un backup Velero.

```yaml
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: daily-job
spec:
  schedule: "0 0 * * *" # Planifie la tâche tous les jours à minuit
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: my-container
            image: my-image:latest
            command: ["/bin/sh"]
            args: ["-c", "echo 'Hello, World!'"]
          restartPolicy: OnFailure

```


### Des déploiements plus stables et précautionneux : les StatefulSets

L'objet `StatefulSet` est relativement récent dans Kubernetes.

On utilise les `Statefulsets` pour répliquer un ensemble de pods dont l'état est important : par exemple, des pods dont le rôle est d'être une base de données, manipulant des données sur un disque.

Un objet `StatefulSet` représente un ensemble de pods dotés d'identités uniques et de noms d'hôtes stables. Quand on supprime un StatefulSet, par défaut les volumes liés ne sont pas supprimés.

Les StatefulSets utilisent un nom en commun suivi de numéros qui se suivent. Par exemple, un StatefulSet nommé `web` comporte des pods nommés `web-0`, `web-1` et` web-2`. Par défaut, les pods StatefulSet sont déployés dans l'ordre et arrêtés dans l'ordre inverse (`web-2`, `web-1` puis `web-0`).

En général, on utilise des StatefulSets quand on veut :
- des identifiants réseau stables et uniques
- du stockage stable et persistant
- des déploiements et du scaling contrôlés et dans un ordre défini
- des rolling updates dans un ordre défini et automatisées

Article récapitulatif des fonctionnalités de base pour applications stateful: https://medium.com/capital-one-tech/conquering-statefulness-on-kubernetes-26336d5f4f17

Exemple très minimal avec Cassandra: 

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: cassandra
spec:
  selector:
    matchLabels:
      app: cassandra
  serviceName: cassandra
  replicas: 3
  template:
    metadata:
      labels:
        app: cassandra
    spec:
      containers:
      - name: cassandra
        image: cassandra:3.11.10
        env:
        - name: CASSANDRA_SEEDS
          value: "cassandra-0.cassandra.default.svc.cluster.local,cassandra-1.cassandra.default.svc.cluster.local,cassandra-2.cassandra.default.svc.cluster.local"
        - name: CASSANDRA_CLUSTER_NAME
          value: "my-cassandra-cluster"
        - name: CASSANDRA_DC
          value: "dc1"
        - name: CASSANDRA_RACK
          value: "rack1"
        ports:
        - containerPort: 9042
          name: cql
        volumeMounts:
        - name: data
          mountPath: /var/lib/cassandra/data
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 10Gi
```
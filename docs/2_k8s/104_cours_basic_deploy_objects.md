---
title: Cours - Objets Fondamentaux pour déployer une application
draft: false
---

### Les namespaces

Tous les objets Kubernetes sont rangés dans différents espaces de travail isolés appelés `namespaces`.

Cette isolation permet 3 choses :

- ne voir que ce qui concerne une tâche particulière (ne réfléchir que sur une seule chose lorsqu'on opère sur un cluster)
- créer des limites de ressources (CPU, RAM, etc.) pour le namespace
- définir des rôles et permissions sur le namespace qui s'appliquent à toutes les ressources à l'intérieur.

Lorsqu'on lit ou créé des objets sans préciser le namespace, ces objets sont liés au namespace `default`.

Pour utiliser un namespace autre que `default` avec `kubectl` il faut :

- le préciser avec l'option `-n` : `kubectl get pods -n kube-system`
- créer une nouvelle configuration dans la kubeconfig pour changer le namespace par defaut.

Kubernetes gère lui-même ses composants internes sous forme de pods et services.

- Si vous ne trouvez pas un objet et que votre cluster n'est pas trop rempli, essayez de lancer la commande kubectl avec l'option `-A` ou `--all-namespaces`

### Les Pods

Un Pod est l’unité de base d’une application Kubernetes que vous déployez : un Pod est un `groupe atomique de conteneurs`, ce qui veut dire qu'il est garanti que ces conteneurs atterrirons sur le même noeud et seront toujours lancé ensembles et connectés.

Un Pod comprend en plus des conteneurs, des `ressources de stockage`, `une IP réseau unique`, et des options qui contrôlent comment le ou les conteneurs doivent s’exécuter (ex: `restart policy`). Cette collection de conteneurs tournent ainsicdans le même environnement d'exécution mais les processus sont isolés.

Plus précisément ces conteneurs étroitement liés et qui partagent :

- des volumes communs
- la même interface réseau : la même IP, les même noms de domaine internes
- les conteneurs peuvent se parler en IPC
- ont un nom différent et des logs différents
- ont des sondes (liveness/readiness probes) et des limites de ram et cpu différentes pour chaque conteneur

Chaque Pod est destiné à exécuter une instance unique d’un workload donné. Si vous désirez mettre à l’échelle votre workload, vous devez multiplier le nombre de Pods avec un déploiement.

Pour plus de détail sur la philosophie des pods, vous pouvez consulter [ce bon article](https://www.mirantis.com/blog/multi-container-pods-and-container-communication-in-kubernetes/).

Kubernetes fournit un ensemble de commande pour débugger des conteneurs :

- `kubectl logs <pod-name> -c <conteneur_name>` (le nom du conteneur est inutile si un seul)
- `kubectl exec -it <pod-name> -c <conteneur_name> -- bash`
- `kubectl attach -it <pod-name>`

Enfin, pour debugger la sortie réseau d'un programme on peut rapidement forwarder un port depuis un pods vers l'extérieur du cluster :

- `kubectl port-forward <pod-name> <port_interne>:<port_externe>`
- C'est une commande de debug seulement : pour exposer correctement des processus k8s, il faut créer un service, par exemple avec `NodePort`.

Pour copier un fichier dans un pod on peut utiliser: `kubectl cp <pod-name>:</path/to/remote/file> </path/to/local/file>`

Pour monitorer rapidement les ressources consommées par un ensemble de processus il existe les commande `kubectl top nodes` et `kubectl top pods`

##### Un manifeste de Pod

`rancher-demo-pod.yaml`

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: rancher-demo-pod
  labels:
    app: rancher-demo
spec:
  containers:
    - image: monachus/rancher-demo:latest
      name: rancher-demo-container
      ports:
        - containerPort: 8080
          name: http
          protocol: TCP
    - image: redis
      name: redis-container
      ports:
        - containerPort: 6379
          name: http
          protocol: TCP
```

## Rappel sur quelques concepts

### Haute disponibilité

- Faire en sorte qu'un service ait un "uptime" élevé.

On veut que le service soit tout le temps accessible même lorsque certaines ressources manquent :

- elles tombent en panne
- elles sont sorties du service pour mise à jour, maintenance ou modification

Pour cela on doit avoir des ressources multiples...

- Plusieurs serveurs
- Plusieurs versions des données
- Plusieurs accès réseau

Il faut que les ressources disponibles prennent automatiquement le relais des ressources indisponibles.
Pour cela on utilise en particulier:

- des "load balancers" : aiguillages réseau intelligents
- des "healthchecks" : une vérification de la santé des applications

Nous allons voir que Kubernetes intègre automatiquement les principes de load balancing et de healthcheck dans l'orchestration de conteneurs

### Répartition de charge (load balancing)

- Un load balancer : une sorte d'**"aiguillage" de trafic réseau**, typiquement HTTP(S) ou TCP.
- Un aiguillage **intelligent** qui se renseigne sur plusieurs critères avant de choisir la direction.

Cas d'usage :

- Éviter la surcharge : les requêtes sont réparties sur différents backends pour éviter de les saturer.

L'objectif est de permettre la haute disponibilité : on veut que notre service soit toujours disponible, même en période de panne/maintenance.

- Donc on va dupliquer chaque partie de notre service et mettre les différentes instances derrière un load balancer.

- Le load balancer va vérifier pour chaque backend s'il est disponible (**healthcheck**) avant de rediriger le trafic.
- Répartition géographique : en fonction de la provenance des requêtes on va rediriger vers un datacenter adapté (+ proche).

### Healthchecks

Fournir à l'application une façon d'indiquer qu'elle est disponible, c'est-à-dire :

- qu'elle est démarrée (_liveness_)
- qu'elle peut répondre aux requêtes (_readiness_).

### Application microservices

- Une application composée de nombreux petits services communiquant via le réseau. Le calcul pour répondre à une requête est décomposé en différente parties distribuées entre les services. Par exemple:
- un service est responsable de la gestion des **clients** et un autre de la gestion des **commandes**.
- Ce mode de développement implique souvent des architectures complexes pour être mis en oeuvre et kubernetes est pensé pour faciliter leur gestion à grande échelle.

- Imaginez devoir relancer manuellement des services vitaux pour une application en hébergeant des centaines d'instances : c'est en particulier à ce moment que kubernetes devient indispensable.
##### 2 exemples d'application microservices:

- https://github.com/microservices-patterns/ftgo-application -> fonctionne avec le très bon livre `Microservices pattern` visible sur le readme.
- https://github.com/GoogleCloudPlatform/microservices-demo -> Exemple d'application microservice de référence de Google pour Kubernetes.

## L'architecture découplée des services Kubernetes

![](/img/kubernetes/deploy-decoupled-pattern.png)

Comme nous l'avons vu dans le TP1, déployer une application dans kubernetes demande plusieurs étapes. En réalité en plus des **pods** l'ensemble de la gestion d'un service applicatif se décompose dans Kubernetes en 3 à 4 objets articulés entre eux:

- **replicatset**
- **deployment**
- **service**
- **(ingress)**

### Les Deployments (deploy)

Les déploiements sont les objets effectivement créés manuellement lorsqu'on déploie une application. Ce sont des objets de plus haut niveau que les **pods** et **replicaset** et les pilote pour gérer un déploiement applicatif.

![](/img/kubernetes/wiki-ciscolinux-co-uk-russiandolls.png)
*Les poupées russes Kubernetes : un Deployment contient un ReplicaSet, qui contient des Pods, qui contiennent des conteneurs*

Si c'est nécessaire d'avoir ces trois types de ressources c'est parce que Kubernetes respecte un principe de découplage des responsabilités.

La responsabilité d'un déploiement est de gérer la coexistence et le **tracking de versions** multiples d'une application et d'effectuer des montées de version automatiques en haute disponibilité en suivant une **RolloutStrategy** (CF. TP optionnel).

Ainsi lors des changements de version, un seul **deployment** gère automatiquement deux **replicasets** contenant chacun **une version** de l'application : le découplage est nécessaire.

Un *deployment* implique la création d'un ensemble de Pods désignés par une étiquette `label` et regroupé dans un **Replicaset**.

Exemple :

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 3
  strategy:
    type: Recreate
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: nginx
          image: nginx:1.7.9
          ports:
            - containerPort: 80
```

- Pour les afficher : `kubectl get deployments`

- La commande `kubectl run` sert à créer un *deployment* à partir d'un modèle. Il vaut mieux utilisez `apply -f`.

### Les ReplicaSets (rs)

Dans notre modèle, les **ReplicaSet** servent à gérer et sont responsables pour:

- la réplication (avoir le bon nombre d'instances et le scaling)
- la santé et le redémarrage automatique des pods de l'application (Self-Healing)

- `kubectl get rs` pour afficher la liste des replicas.

En général on ne les manipule pas directement (c'est déconseillé) même s'il est possible de les modifier et de les créer avec un fichier de ressource. Pour créer des groupes de conteneurs on utilise soit un **Deployment** soit d'autres formes de workloads (**DaemonSet**, **StatefulSet**, **Job**) adaptés à d'autres cas.

### Les Services

Dans Kubernetes, un **service** est un objet qui :
- Désigne un ensemble de pods (grâce à des labels) généralement géré par un déploiement.
- Fournit un endpoint réseau pour les requêtes à destination de ces pods.
- Configure une politique permettant d’y accéder depuis l'intérieur ou l'extérieur du cluster.
- Configure un nom de domaine pointant sur le groupe de pods en backend.

<!-- Un service k8s est en particulier adapté pour implémenter une architecture micro-service. -->

L’ensemble des pods ciblés par un service est déterminé par un `selector`.

Par exemple, considérons un backend de traitement d’image (*stateless*, c'est-à-dire ici sans base de données) qui s’exécute avec 3 replicas. Ces replicas sont interchangeables et les frontends ne se soucient pas du backend qu’ils utilisent. Bien que les pods réels qui composent l’ensemble `backend` puissent changer, les clients frontends ne devraient pas avoir besoin de le savoir, pas plus qu’ils ne doivent suivre eux-mêmes l'état de l’ensemble des backends.

L’abstraction du service permet ce découplage : les clients frontend s'addressent à une seule IP avec un seul port dès qu'ils ont besoin d'avoir recours à un backend. Les backends vont recevoir la requête du frontend aléatoirement.

<!-- Paragraphe aussi présent en haut du cours network -->
Les Services sont de trois types principaux :

- `ClusterIP`: expose le service **sur une IP interne** au cluster.

- `NodePort`: expose le service depuis l'IP de **chacun des noeuds du cluster** en ouvrant un port directement sur le nœud, entre 30000 et 32767. Cela permet d'accéder aux pods internes répliqués. Comme l'IP est stable on peut faire pointer un DNS ou Loadbalancer classique dessus.

![](/img/kubernetes/nodeport.png?width=400px)
*Crédits à [Ahmet Alp Balkan](https://medium.com/@ahmetb) pour les schémas*

- `LoadBalancer`: expose le service en externe à l’aide d'un Loadbalancer de fournisseur de cloud. Les services NodePort et ClusterIP, vers lesquels le Loadbalancer est dirigé sont automatiquement créés.


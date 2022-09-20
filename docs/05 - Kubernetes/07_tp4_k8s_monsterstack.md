---
title: "07 - TP 4 - Déployer une application multiconteneurs"
draft: false
weight: 2050
---

Récupérez le projet de base en clonant la correction du TP2: `git clone -b tp_monsterstack_base https://github.com/Uptime-Formation/corrections_tp.git tp3`

Ce TP va consister à créer des objets Kubernetes pour déployer une application microservices (plutôt simple) : `monsterstack`.
Elle est composée :

- d'un frontend en Flask (Python),
- d'un service de backend qui génère des images (un avatar de monstre correspondant à une chaîne de caractères)
- et d'un datastore `redis` servant de cache pour les images de l'application

Nous allons également utiliser le builder kubernetes `skaffold` pour déployer l'application en mode développement : l'image du frontend `frontend` sera construite à partir du code source présent dans le dossier `app` et automatiquement déployée dans le cluster (`minikube` ou `k3s`).

# Etudions le code et testons avec `docker-compose`

- Le frontend est une application web python (flask) qui propose un petit formulaire et lance une requete sur le backend pour chercher une image et l'afficher.
- Il est construit à partir du `Dockerfile` présent dans le dossier `TP3`.
- Le fichier `docker-compose.yml` est utile pour faire tourner les trois services de l'application dans docker rapidement (plus simple que kubernetes)

Pour lancer l'application il suffit d'exécuter: `docker-compose up`

Passons maintenant à Kubernetes.

## Déploiements pour le backend d'image (`imagebackend`) et le datastore `redis`

Maintenant nous allons également créer un déploiement pour `imagebackend`:

- Ouvrez `imagebackend.yaml` dans le dossier `k8s-deploy` et collez-y le code suivant :

`imagebackend.yaml` :

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: imagebackend
  labels:
    app: monsterstack
spec:
  selector:
    matchLabels:
      app: monsterstack
      partie: imagebackend
  strategy:
    type: Recreate
  replicas: 5
  template:
    metadata:
      labels:
        app: monsterstack
        partie: imagebackend
    spec:
      containers:
        - image: amouat/dnmonster:1.0
          name: imagebackend
          ports:
            - containerPort: 8080
              name: imagebackend
```

- Ensuite, configurons le deuxième deployment `redis.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: redis
  labels:
    app: monsterstack
spec:
  selector:
    matchLabels:
      app: monsterstack
      partie: redis
  strategy:
    type: Recreate
  replicas: 1
  template:
    metadata:
      labels:
        app: monsterstack
        partie: redis
    spec:
      containers:
        - image: redis:latest
          name: redis
          ports:
            - containerPort: 6379
              name: redis
```

- Appliquez ces ressources avec `kubectl` et vérifiez dans `Lens` que les 5 + 1 réplicats sont bien lancés.

## Installer et configurer skaffold

Par rapport au workflow de développement docker, nous avons ici une difficultée : construire l'image avec `docker build` ou `docker-compose` ajoute bien l'image à notre installation docker en local mais cette image n'est pas automatiquement accessible depuis notre cluster (k3s ou minikube).

=> Si on essaye de déployer le frontend en créant un déploiement nous auront donc une erreur `ErrImagePull` et le pod ne se lancera pas.

Pour remédier à ce problème dans les situations de développement simple on peut utiliser deux méthodes classiques:

- utiliser `minikube` et son intégration avec Docker tel qu'expliqué ici: https://minikube.sigs.k8s.io/docs/handbook/pushing/#1-pushing-directly-to-the-in-cluster-docker-daemon-docker-env. Une fois la commande `eval $(minikube docker-env)` lancée les commande type `docker build` contruiront l'image directement dans le cluster.

- Accéder à ou héberger un service de registry d'images docker un pour pouvoir pousser nos builds d'images dedans et ensuite les télécharger dans le cluster. <!-- TODO (Voir le cours **Problématiques pratiques de production** pour une discussion sur les différentes options de registries) -->

Cette seconde solution est générique et correspond au processus général de déploiement dans kubernetes. Le problème en situation de développement est que ce processus de build et push docker à chaque modification est très/trop lent et fatiguant en pratique. Heureusement le mécanisme de layers des images Docker ne nous oblige à uploader que les layers modifiés de notre image à chaque build mais cela ne règle pas le fond du problème du processus manuel répétif qui viens gréver le développement.

La solution puissante et générique choisie dans ce TP pour avoir un workflow développement confortable et compatible avec `minikube`, `k3s` ou tout autre distribution kubernetes est `skaffold` combiné à un registry d'images.

- Vérifiez que vous n'êtes pas dans l'environnement minikube docker-env avec `env | grep DOCKER` qui doit ne rien renvoyer.
- Installez `skaffold` en suivant les indications ici: `https://skaffold.dev/docs/install/`
- Créez ou modifiez un fichier `skaffold.yaml` avec le contenu :

```yaml
apiVersion: skaffold/v1
kind: Config
build:
  artifacts:
  - image: registry.kluster.ptych.net/frontend # change with your registry and log to it with docker login
deploy:
  kubectl:
    manifests:
      - k8s-deploy-dev/*.yaml
```

- Identifiez-vous sur le registry avec `docker login registry.kluster.ptych.net` et en utilisant le login du formateur.

- Lancez le build, push, et le déploiement du imagebackend et du redis avec `skaffold dev --tail=false`

## Déploiement du `frontend`

Ajoutez au fichier `frontend.yml` du dossier `k8s-deploy` le code suivant:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
  labels:
    app: monsterstack
spec:
  selector:
    matchLabels:
      app: monsterstack
      partie: frontend
  strategy:
    type: Recreate
  replicas: 3
  template:
    metadata:
      labels:
        app: monsterstack
        partie: frontend
    spec:
      containers:
        - name: frontend
          image: registry.kluster.ptych.net/frontend
          ports:
            - containerPort: 5000
      imagePullSecrets:
        - name: registry-credential
```

- Pour pouvoir tirer l'image depuis le cluster il faut ajouter le login sous forme d'un secret dans Kubernetes : `kubectl create secret docker-registry registry-credential --docker-server=registry.kluster.ptych.net --docker-username=elie --docker-password=<thepasspword>`

- Relancez `skaffold dev --tail=false` si nécessaire.

- Testez le fonctionnement du frontend avec la commande `kubectl port-forward ...`
#### Santé du service avec les `Probes`

- Ajoutons des healthchecks au conteneur dans le pod avec la syntaxe suivante (le mot-clé `livenessProbe` doit être à la hauteur du `i` de `image:`) :

```yaml
livenessProbe:
  tcpSocket: # si le socket est ouvert c'est que l'application est démarrée
    port: 5000
  initialDelaySeconds: 5 # wait before firt probe
  timeoutSeconds: 1 # timeout for the request
  periodSeconds: 10 # probe every 10 sec
  failureThreshold: 3 # fail maximum 3 times
readinessProbe:
  httpGet:
    path: /healthz # si l'application répond positivement sur sa route /healthz c'est qu'elle est prête pour le traffic
    port: 5000
    httpHeaders:
      - name: Accept
        value: application/json
  initialDelaySeconds: 5
  timeoutSeconds: 1
  periodSeconds: 10
  failureThreshold: 3
```

La **livenessProbe** est un test qui s'assure que l'application est bien en train de tourner. S'il n'est pas rempli le pod est automatiquement redémarré en attendant que le test fonctionne.

Ainsi, k8s sera capable de savoir si notre conteneur applicatif fonctionne bien, quand le redémarrer. C'est une bonne pratique pour que le `replicaset` Kubernetes sache quand redémarrer un pod et garantir que notre application se répare elle même (self-healing).

Cependant une application peut être en train de tourner mais indisponible pour cause de surcharge ou de mise à jour par exemple. Dans ce cas on voudrait que le pod ne soit pas détruit mais que le traffic évite l'instance indisponible pour être renvoyé vers un autre backend `ready`.

La **readinessProbe** est un test qui s'assure que l'application est prête à répondre aux requêtes en train de tourner. S'il n'est pas rempli le pod est marqué comme non prêt à recevoir des requêtes et le `service` évitera de lui en envoyer.

- Pendant que `skaffold dev --tail=false` tourne, on peut tester mettre volontairement port 3000 pour la livenessProbe et constater que k8s redémarre les conteneurs frontend un certain nombre de fois avant d'abandonner.

- On peut le constater avec `kubectl describe deployment frontend` dans la section évènement ou avec `Lens` en bas du panneau latéral droite d'une ressource.


#### Configuration d'une application avec des variables d'environnement simples

- Notre application frontend peut être configurée en mode DEV ou PROD. Pour cela elle attend une variable d'environnement `CONTEXT` pour lui indiquer si elle doit se lancer en mode `PROD` ou en mode `DEV`. Ici nous mettons l'environnement `DEV` en ajoutant (aligné avec la livenessProbe):

```yaml
env:
  - name: CONTEXT
    value: DEV
```
- Généralement la valeur d'une variable est fournie au pod à l'aide d'une ressource de type `ConfigMap` ou `Secret` ce que nous verrons par la suite.

- Configurez de même les variables `IMAGEBACKEND_DOMAIN` et `REDIS_DOMAIN` comme dans le docker-compose.

#### Ajouter des indications de ressource nécessaires pour garantir la qualité de service

- Ajoutons aussi des contraintes sur l'usage du CPU et de la RAM, en ajoutant à la même hauteur que `env:` :

```yaml
resources:
  requests:
    cpu: "100m" # 10% de proc
    memory: "50Mi"
  limits:
    cpu: "300m" # 30% de proc
    memory: "200Mi"
```

Nos pods auront alors **la garantie** de disposer d'un dixième de CPU (100/1000) et de 50 mégaoctets de RAM. Ce type d'indications permet de remplir au maximum les ressources de notre cluster tout en garantissant qu'aucune application ne prend toute les ressources à cause d'un fuite mémoire etc.

Documentation : https://kubernetes.io/docs/tasks/configure-pod-container/assign-memory-resource/


#### Exposer notre stack avec des services

Les services K8s sont des endpoints réseaux qui balancent le trafic automatiquement vers un ensemble de pods désignés par certains labels. Ils sont un peu la pierre angulaire des applications microservices qui sont composées de plusieurs sous parties elles même répliquées.

Pour créer un objet `Service`, utilisons le code suivant, à compléter :

```yaml
apiVersion: v1
kind: Service
metadata:
  name: <nom_service>
  labels:
    app: monsterstack
spec:
  ports:
    - port: <port>
  selector:
    app: <app_selector>
    partie: <tier_selector>
  type: <type>
---
```

Ajoutez le code précédent au début de chaque fichier déploiement. Complétez pour chaque partie de notre application :

<!-- - le nom du service et le nom du tier par le nom de notre programme (`frontend` et `imagebackend`) -->

- le nom du service et le nom de la `partie` par le nom de notre programme (`frontend`, `imagebackend` et `redis`)
- le port par le port du service
<!-- - pourquoi pas selector = celui du deployment? -->
- les selectors `app` et `partie` par ceux du pod correspondant.

Le type sera : `ClusterIP` pour `imagebackend` et `redis`, car ce sont des services qui n'ont à être accédés qu'en interne, et `LoadBalancer` pour `frontend`.

- Appliquez à nouveau avec `skaffold run` ou `skaffold dev --tail=false`.
- Listez les services avec `kubectl get services`.
- Visitez votre application dans le navigateur avec `minikube service frontend`.
- Supprimez éventuellement l'application avec `skaffold delete`.

### Ajoutons un ingress (~ reverse proxy) pour exposer notre application en http


- Pour **Minikube** : Installons le contrôleur Ingress Nginx avec `minikube addons enable ingress`.

- Pour **k3s** : Installer l'ingress nginx avec la commande: `kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.1.0/deploy/static/provider/cloud/deploy.yaml` Puis vérifiez l'installation avec `kubectl get svc -n ingress-nginx ingress-nginx-controller` : le service `ingress-nginx-controller` devrait avoir une IP externe.

- Pour les autres types de cluster (**cloud** ou **manuel**), lire la documentation sur les prérequis pour les objets Ingress et installez l'ingress controller appelé `ingress-nginx` : <https://kubernetes.io/docs/concepts/services-networking/ingress/#prerequisites>.


- Si vous êtes dans k3s, avant de continuer, vérifiez l'installation du contrôleur Ingress Nginx avec `kubectl get svc -n ingress-nginx ingress-nginx-controller` : le service `ingress-nginx-controller` devrait avoir une IP externe.

Il s'agit d'une implémentation de reverse proxy dynamique (car ciblant et s'adaptant directement aux objets services k8s) basée sur nginx configurée pour s'interfacer avec un cluster k8s.

- Repassez le service `frontend` en mode `ClusterIP`. Le service n'est plus accessible sur un port. Nous allons utiliser l'ingress à la place pour afficher la page.

- Ajoutez également l'objet `Ingress` suivant dans le fichier `monsterstack-ingress.yaml` :

```yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: monsterstack
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
    kubernetes.io/ingress.class: nginx
spec:
  rules:
    - host: monsterstack.local # à changer si envie/besoin
    
      http:
        paths:
          - path: /
            backend:
              serviceName: frontend
              servicePort: 5000
```

- Ajoutez ce fichier avec `skaffold run` ou `dev`. Il y a une erreur l'API (ie la syntaxe) de kubernetes a changé depuis l'écriture du TP et il faudrait réécrire ce fichier ingress pour intégrer de petites modifications de syntaxe.

- Pour corriger ce warning remplacez l'`apiVersion` par `networking.k8s.io/v1`. La syntaxe de la `spec` a légèrement changée depuis la v1beta1, modifiez comme suit:

```yaml
spec:
  rules:
    - host: monsterstack.local # à changer si envie/besoin
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: frontend
                port:
                  number: 5000
```

<!-- TODO changer la correction pour intégrer la bonne syntaxe et renommer l'ancienne en old-->

- Récupérez l'ip de minikube avec `minikube ip`, (ou alors allez observer l'objet `Ingress` dans `Lens` dans la section `Networking`. Sur cette ligne, récupérez l'ip de minikube en `192.x.x.x.`).

- Ajoutez la ligne `<ip-minikube> monsterstack.local` au fichier `/etc/hosts` avec `sudo nano /etc/hosts` puis CRTL+S et CTRL+X pour sauver et quitter.

- Visitez la page `http://monsterstack.local` pour constater que notre Ingress (reverse proxy) est bien fonctionnel.
<!-- Pour le moment l'image de monstre ne s'affiche pas car la sous route de récup d'image /monster de notre application ne colle pas avec l'ingress que nous avons défini. TODO trouver la syntaxe d'ingress pour la faire marcher -->

### Solution

Le dépôt Git de la correction de ce TP est accessible ici : `git clone -b tp_monsterstack_final https://github.com/Uptime-Formation/corrections_tp.git`

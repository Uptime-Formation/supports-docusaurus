---
title: "TP - Déployer une application multiconteneurs"
draft: false
# sidebar_position: 10
---

--- 
## Objectifs pédagogiques 
- Installer une application un peu complexe 
- Utiliser un système de build avec Kubernetes

---

## Contraintes du TP 

- Accompagnement moyen
- Durée attendue : de 60 à 120 minutes 
---
## Une application d'exemple en 3 parties

Récupérez le projet de base en clonant la correction du TP2: 

```shell

$ git clone -b tp_monsterstack_base https://github.com/Uptime-Formation/corrections_tp.git tp4-2

```

**Ce TP va consister à créer des objets Kubernetes pour déployer une application microservices (plutôt simple) : `monsterstack`.**

Elle est composée :

- d'un frontend en Flask (Python),
- d'un service de backend qui génère des images (un avatar de monstre correspondant à une chaîne de caractères)
- et d'un datastore `redis` servant de cache pour les images de l'application

## Etudions le code et testons avec `docker-compose`

**Le frontend est une application web python (flask) qui propose un petit formulaire et lance une requete sur le backend pour chercher une image et l'afficher.**

Il est construit à partir du `Dockerfile` présent dans le dossier `TP3`.

Le fichier `docker-compose.yml` est utile pour faire tourner les trois services de l'application dans docker rapidement (plus simple que kubernetes)

**Pour lancer l'application il suffit d'exécuter:** 
```shell

$ docker-compose up

```

Passons maintenant à Kubernetes.

---


## Déploiements pour le backend d'image (`imagebackend`) et le datastore `redis`

En vous inspirant du TP précédent créez des `deployments` pour `imagebackend` et `redis` sachant que:
- l'image docker pour `imagebackend` est `amouat/dnmonster:1.0` qui fonctionne sur le port 8080.
- l'image officielle redis est une image connue et bien documentée du docker hud (hub.docker.com). Lancez ici simplement l'image avec une configuration minimale comme dans le docker-compose.yml. Nous discuterons plus tard de comment déployer ce type d'application stateful de façon plus fiable et robuste.
- Combien de réplicats mettre pour l'imagebackend et le redis ?


<details><summary>Correction</summary>

- Complétez `imagebackend.yaml` dans le dossier `k8s-deploy` :

`imagebackend.yaml` :

```yaml
# file: imagebackend.yaml

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

# EOF
```

---


Ensuite, configurons le deuxième deployment `redis.yaml`:

```yaml
# file: redis.yaml

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

# EOF
```

---


- Appliquez ces ressources avec `kubectl` et vérifiez dans `Lens` que les 5 + 1 réplicats sont bien lancés.

</details>

## Déploiement du `frontend` manuellement

(cf TP développer dans Kubernetes pour de meilleures méthodes de déploiement)

- Créez un compte (gratuit et plutôt pratique) sur le Docker Hub si vous n'en avez pas encore.
- Buildez l'image `frontend` avec la ligne de commande `docker build -t frontend .` dans le dossier de projet. `docker image list` pour voir le résultat

Pour accéder à l'image dans le cluster nous allons la poussez sur le registry Docker Hub (une solution basique parmis plein d'autres) pour cela:

- Lancez la commande `docker login docker.io` et utilisez votre compte précédemment créé (ou simplement `docker login` car docker se loggue automatiquement à sa plateforme par défaut).
- Tagguez l'image `frontend` avec `docker tag ...` avec un nouveau tag précisant le serveur et l'utilisateur par exemple `docker tag frontend docker.io/myuser/frontend:1.0`
- Créez un déploiement pour le frontend en réutilisant ce tag dans la section image.
- déployez avec `kubectl apply` pour tester.

<details><summary>Correction: </summary>

Ajoutez au fichier `frontend.yml` du dossier `k8s-deploy` le code suivant:

```yaml
# file: frontend.yaml

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
          image: docker.io/<votreuserdockerhhubacompleter>/frontend:1.0
          ports:
            - containerPort: 5000

# EOF
```

- Appliquez ce fichier avec `kubectl` et vérifiez que le déploiement frontend est bien créé.

</details>


## Gérer la communication réseau de notre application avec des `Services`

Les services K8s sont des endpoints réseaux qui envoient le trafic automatiquement vers un ensemble de pods désignés par certains labels. Ils sont un peu la pierre angulaire des applications microservices qui sont composées de plusieurs sous parties elles même répliquées.

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

- le nom du service et le nom de la `partie` par le nom de notre programme (`frontend`, `imagebackend` et `redis`)
- le port par le port du service
<!-- - pourquoi pas selector = celui du deployment? -->
- les selectors `app` et `partie` par ceux du groupe de pods correspondant.

Le type sera : `ClusterIP` pour `imagebackend` et `redis`, car ce sont des services qui n'ont à être accédés qu'en interne, et `LoadBalancer` pour `frontend`.

- Appliquez à nouveau.
- Listez les services avec `kubectl get services`.
- Visitez votre application dans le navigateur avec `minikube service frontend`.

## Exposer notre application à l'extérieur avec un `Ingress` (~ reverse proxy)

- Pour **Minikube** : Installons le contrôleur Ingress Nginx avec `minikube addons enable ingress`.

- Pour **k3s** : Installer l'ingress nginx avec la commande: `kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.1.0/deploy/static/provider/cloud/deploy.yaml` Puis vérifiez l'installation avec `kubectl get svc -n ingress-nginx ingress-nginx-controller` : le service `ingress-nginx-controller` devrait avoir une IP externe.

- Pour les autres types de cluster (**cloud** ou **manuel**), lire la documentation sur les prérequis pour les objets Ingress et installez l'ingress controller appelé `ingress-nginx` : <https://kubernetes.io/docs/concepts/services-networking/ingress/#prerequisites>.

- Si vous êtes dans k3s, avant de continuer, vérifiez l'installation du contrôleur Ingress Nginx avec `kubectl get svc -n ingress-nginx ingress-nginx-controller` : le service `ingress-nginx-controller` devrait avoir une IP externe.


### Utilisation de l'ingress

Un contrôleur Ingress (**Ingress controller**) est une implémentation de reverse proxy dynamique (car ciblant et s'adaptant directement aux objets services k8s) configurée pour s'interfacer avec un cluster k8s.

Une **ressource Ingress** est le fichier de configuration pour paramétrer le reverse proxy nativement dans Kubernetes.

- Repassez le service `frontend` en mode `ClusterIP`. Le service n'est plus accessible sur un port. Nous allons utiliser l'ingress à la place pour afficher la page.

- Ajoutez également l'objet `Ingress` suivant dans le fichier `monsterstack-ingress.yaml` :

```yaml
apiVersion: networking.k8s.io/v1
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
            pathType: Prefix
            backend:
              service:
                name: frontend
                port:
                  number: 5000
```

- Récupérez l'ip de votre cluster (minikube avec `minikube ip`, pour k3 en allant observer l'objet `Ingress` dans `Lens` dans la section `Networking`. Sur cette ligne, récupérez l'ip).

- Ajoutez la ligne `<ip-cluster> monsterstack.local` au fichier `/etc/hosts` avec `sudo nano /etc/hosts` puis CRTL+S et CTRL+X pour sauver et quitter.

- Visitez la page `http://monsterstack.local` pour constater que notre Ingress (reverse proxy) est bien fonctionnel.

<!-- Pour le moment l'image de monstre ne s'affiche pas car la sous route de récup d'image /monster de notre application ne colle pas avec l'ingress que nous avons défini. TODO trouver la syntaxe d'ingress pour la faire marcher -->

## Paramétrer notre déploiement

### Configuration de l'application avec des variables d'environnement simples

- Notre application frontend peut être configurée en mode DEV ou PROD. Pour cela elle attend une variable d'environnement `CONTEXT` pour lui indiquer si elle doit se lancer en mode `PROD` ou en mode `DEV`. Ici nous mettons l'environnement `DEV` en ajoutant (aligné à la hauteur du i de image):

```yaml
env:
  - name: CONTEXT
    value: DEV
```
- Généralement la valeur d'une variable est fournie au pod à l'aide d'une ressource de type `ConfigMap` ou `Secret` ce que nous verrons par la suite.

- Configurez de même les variables `IMAGEBACKEND_DOMAIN` et `REDIS_DOMAIN` comme dans le docker-compose et trouvez comment modifier les hostnames associés aux services.

<details><summary>Correction: </summary>

Pour modifier le hostname on peut soit changer le nom du service soit utiliser le parametre `ClusterIP` du service pour y associer un nom de domaine (cela peut impacter les autres applications qui tentent de communiquer avec le service).

Voir la correction github à la fin de la page

</details>

### Quelques autres paramétrages...

<details><summary>Facultatif: Santé du service avec les Probes</summary>

### Santé du service avec les `Probes`

- Ajoutons des healthchecks au conteneur dans le pod avec la syntaxe suivante (le mot-clé `livenessProbe` doit être à la hauteur du `i` de `image:`) :

```yaml
...
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

Ainsi, Kubernetes sera capable de savoir si notre conteneur applicatif fonctionne bien, quand le redémarrer. C'est une bonne pratique pour que le `replicaset` Kubernetes sache quand redémarrer un pod et garantir que notre application se répare elle même (self-healing).

Cependant une application peut être en train de tourner mais indisponible pour cause de surcharge ou de mise à jour par exemple. Dans ce cas on voudrait que le pod ne soit pas détruit mais que le traffic évite l'instance indisponible pour être renvoyé vers un autre backend `ready`.

La **readinessProbe** est un test qui s'assure que l'application est prête à répondre aux requêtes en train de tourner. S'il n'est pas rempli le pod est marqué comme non prêt à recevoir des requêtes et le `service` évitera de lui en envoyer.

- on peut tester mettre volontairement port 3000 pour la livenessProbe et constater que k8s redémarre les conteneurs frontend un certain nombre de fois avant d'abandonner. On peut le constater avec `kubectl describe deployment frontend` dans la section évènement ou avec `Lens` en bas du panneau latéral droite d'une ressource.

</details>

<details><summary>Facultatif: Ajouter des indications de ressources</summary>

### Ajouter des indications de ressources nécessaires pour garantir la qualité de service

- Ajoutons aussi des contraintes sur l'usage du CPU et de la RAM, en ajoutant à la même hauteur que `env:` :

```yaml
    ...
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

</details>

## Correction du TP

Le dépôt Git de la correction de ce TP est accessible ici : `git clone -b tp_monsterstack_final https://github.com/Uptime-Formation/corrections_tp.git`

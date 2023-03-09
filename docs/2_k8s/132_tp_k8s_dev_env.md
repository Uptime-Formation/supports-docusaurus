---
title: "TP - Développer directement dans un cluster Kubernetes"
draft: false
# sidebar_position: 10
---

## Quel workflow de développement ?

### Envoyer les images dans le cluster...

Au moment de déployer la partie frontend de l'application, nous rencontrons un problème pratique : l'image à déployer est construite à partir d'un Dockerfile, elle est ensuite disponible dans le stock de nos images docker en local. Mais notre cluster (minikube ou autre) n'a pas accès par défaut à ces images : résultat nous pouvons bien construire et lancer l'image du frontend avec `docker build` et `docker run -p 5000:5000 frontend` mais nous ne pouvons pas utiliser cette image dans un fichier `deployment` avec `image: frontend` car le cluster ne saura pas ou la trouver => `ErrImagePull`

Nous devons donc trouver comment envoyer l'image dans le cluster et idéalement de façon efficace.

- Une première méthode utilisée dans le TP précédent est de pousser l'image sur un registry par exemple DockerHub. Ensuite si nous faisons référence dans le déploiement à `<votre_hub_login>/frontend` ou `<addresse_registry>/frontend` le cluster devrait pouvoir télécharger l'image. Cette méthode est cependant trop lente pour le développement car il faudrait lancer plusieurs commandes à chaque modification du code ou des fichiers k8s.

Imaginez que vous développiez une application microservice avec un dépot de code contenant une quinzaine de conteneurs différents à builder et déployer séparément. Imaginez que vous vouliez pouvoir éditer directement l'application, la déployer dans le cluster et pouvoir itérer rapidement sur le code logiciel et sur le code kubernetes. Il nous faut accélérer grandement la vitesse et le confort de déploiement.

- Une méthode déjà plus rapide est d'utiliser `minikube` et son intégration avec Docker tel qu'expliqué ici: https://minikube.sigs.k8s.io/docs/handbook/pushing/#1-pushing-directly-to-the-in-cluster-docker-daemon-docker-env. Une fois la commande `eval $(minikube docker-env)` lancée les commande type `docker build` contruiront l'image directement dans le cluster. On peut même construire directement l'ensemble des images d'une stack avec `docker-compose build`. Inconvénients : toujours assez lent, manuel et spécifique à minikube/docker ou a chaque distribution k8s de dev.

- Une solution puissante et générique pour avoir un workflow développement confortable et compatible avec `minikube` mais aussi tout autre distribution kubernetes est `skaffold`! Combiné ici à un registry d'images, `skaffold` surveille automatiquement nos modification de développement et reconstruira/redéploiera toutes images à chaque fois en quelques secondes.

## Méthode Minikube (facultatif)

- Lancez la commande `eval $(minikube docker-env)` qui vas indiquer à la cli docker d'utiliser le daemon présent à l'intérieur du cluster minikube, notamment pour construire l'image.

- Lancez un build docker `docker build -t frontend .`. La construction va être effectué directement dans le cluster.

- Vérifiez que l'image `frontend` est bien présente dans le cluster avec `docker image list`

### Déploiement du `frontend` via minikube

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
          image: frontend
          imagePullPolicy: Never
          ports:
            - containerPort: 5000
```

- Appliquez ce fichier avec `kubectl` et vérifiez que le déploiement frontend est bien créé.

## Méthode Skaffold

- Vérifiez que vous n'êtes pas dans l'environnement minikube docker-env avec `env | grep DOCKER` qui doit ne rien renvoyer.
- Installez `skaffold` en suivant les indications ici: `https://skaffold.dev/docs/install/`
- Créez ou modifiez un fichier `skaffold.yaml` avec le contenu :

```yaml
apiVersion: skaffold/v1
kind: Config
build:
  artifacts:
  - image: docker.io/<votre_login>/frontend # change with your registry and log to it with docker login
deploy:
  kubectl:
    manifests:
      - k8s-deploy-dev/*.yaml
```

- Identifiez-vous sur le registry avec `docker login <registry>`.


- Changez dans le fichier `frontend.yml` du dossier `k8s-deploy` le paramètre image comme suit:

```yaml
...
    spec:
      containers:
        - name: frontend
          image: docker.io/<votre_login>/frontend
          ports:
            - containerPort: 5000
      # imagePullSecrets:
      #   - name: registry-credential
```

- Lancez le build, push, et le déploiement du imagebackend et du redis avec `skaffold run` et `skaffold delete` pour nettoyer.

- Le mode développement de skaffold est lié à la commande `skaffold dev` qui en plus de tout builder et déployer s'assure de surveiller (watch) toutes les modifications apportées aux fichiers de code logiciel / Dockerfile et code Kubernetes, etc...

Enfin une solution efficace pour développer

#### Registry privé avec login simple

- Dans le cas d'un registry privé, pour pouvoir tirer l'image il faut:

  - ajouter le login sous forme d'un secret dans Kubernetes. Par exemple : `kubectl create secret docker-registry registry-credential --docker-server=registry.kluster.ptych.net --docker-username=elie --docker-password=<thepasspword>`

  - ajouter ensuite à la spec du pod une section :

```yaml
      imagePullSecrets:
        - name: registry-credential
```

...cela permettra que Kubernetes connaissent le login pour se connecter au registry et télécharger l'image.

## Skaffold avec Helm ou jsonnet etc.

`skaffold` est un petit binaire couteau suisse et peut s'intégrer à la majorité des contextes de dev et déploiement kubernetes:

- compatible avec la plupart des méthodes de déploiement d'app Kustomize, Jsonnet, ArgoCD, ...
- incontournable pour le développement Helm
- utilisable dans des pipelines CI/CD

Pour l'usage avec Helm, voir le TP Helm.

## Correction du TP

Le dépôt Git de la correction de ce TP est accessible ici : `git clone -b tp_monsterstack_final https://github.com/Uptime-Formation/corrections_tp.git`

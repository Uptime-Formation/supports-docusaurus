---
title: "Docker 2 - Construire une application simple - correction"
draft: true
---

## I – Packager une application web flask avec Docker

- Récupérez d’abord une application Flask exemple en la clonant sur le Bureau :

```
git clone https://github.com/miguelgrinberg/microblog/
```

- Ouvrez le dossier microblog cloné avec VSCode (Open Folder)

- Observez l'historique git du dépôt avec `git graph` dans VSCode.

- Nous allons activer une version simple de l’application grace à git : `git checkout v0.2`
- Pour tester l'application d’abord en mode simple (sans conteneur) nous avons besoin des outils python. Vérifions si ils sont installées :
  `sudo apt install python3-virtualenv virtualenv`

- Créons l’environnement virtuel : `virtualenv -p python3 venv`

- Activons l’environnement : `source venv/bin/activate`

- Installons la librairie flask et exportons une variable d’environnement pour déclarer l’application.
  a) `pip install flask`
  b) `export FLASK_APP=microblog.py`

- Maintenant nous pouvons tester l’application en local avec la commande : `flask run`

- Visitez l’application dans le navigateur à l’adresse indiquée.
- Observons le code dans VSCode. Qu’est ce qu’un fichier de template  ? Où se trouve les fichiers de templates dans ce projet.

```
dans app/templates
```

- Changez le prénom Miguel par le votre dans l’application. Testez à chaque modification en rechargeant la page.

## II – Passons à Docker

Déployer une application flask manuellement est relativement pénible. Nous allons donc construire une image de conteneur pour empaqueter l’application et la manipuler plus facilement. Assurez vous que docker est installé.

- Pour conteneuriser l'application, ajoutez un fichier nommé `Dockerfile` dans le dossier du projet

- Ajoutez en haut du fichier : `FROM ubuntu:latest` Cette commande indique que notre conteneur de base est le conteneur officiel ubuntu.
- Nous pouvons déjà contruire un conteneur à partir de ce modèle ubuntu vide :
  `docker build -t microblog .`

- Une fois la construction terminée lancez le conteneur.

```
docker run microblog
```

- Le conteneur s’arrête immédiatement. En effet il ne contient aucune commande bloquante et nous n'avons préciser aucune commande au lancement. Pour pouvoir observer le conteneur convenablement il fautdrait faire tourner quelque chose à l’intérieur. Ajoutez à la fin du fichier la ligne :
  `CMD ["/bin/sleep", "1000"]`
  Cette ligne indique au conteneur d’attendre pendant 1000 secondes comme au TP précédent.

- Reconstruisez le conteneur et relancez le

```
docker build -t microblog .
```

- Affichez la liste des conteneurs en train de fonctionner

```
docker ps
```

- Nous allons maintenant rentrer dans le conteneur en ligne de commande pour observer. Utilisez la commande : `docker exec -it <id_du_conteneur> /bin/bash`

- Vous êtes maintenant dans le conteneur avec une invite de commande. Utilisez quelques commandes shell pour le visiter rapidement.

- Il s’agit d’un linux standard, mais il n’est pas conçu pour être utilisé comme un système complet mais pour isoler une application. Il faut maintenant ajouter notre application flask à l’intérieur. Dans le Dockerfile supprimez la ligne CMD, puis ajoutez :

  - `RUN apt-get update -y`
  - `RUN apt-get install -y python-pip python-dev build-essential`

- Reconstruisez votre conteneur. Si tout se passe bien poursuivez.

- Il s’agit maintenant de copier le code de l’application à l’intérieur du conteneur. Pour cela ajoutez les lignes :
  `COPY . /app`
  `WORKDIR /app`
  Ces deux lignes indiquent de copier tout le contenu du dossier courant dans un dossier /app à l’intérieur du conteneur. Puis le dossier courant est déplacé à `/app`.

- Pour installer les dépendances python et configurer la variable d'environnement Flask ajoutez:

  - `RUN pip install flask`
  - `ENV FLASK_APP microblog.py`

- Enfin pour démarrer l’application nous auront besoin d’un script de boot. Créez un fichier `boot.sh` avec à l’intérieur :

```
#!/bin/sh
flask run -h 0.0.0.0
```

- Ensuite ajoutons la section de démarrage à la fin du Dockerfile :

```
RUN chmod +x boot.sh
ENTRYPOINT ["./boot.sh"]
```

- Reconstruisez le conteneur et lancez le en ouvrant le port `5000` avec la commande : `docker run -d -p 5000:5000 microblog`

- Naviguez dans le navigateur à l’adresse `localhost:5000` pour admirer le prototype microblog.

- Lancez un deuxième container cette fois avec : `docker run -d -p 5001:5000 microblog`

- Une deuxième instance de l’app est maintenant en fonctionnement et accessible à l’adresse localhost:5001

## La version plus complexe

- Committez les modifications de votre dépot.

```
git add -A
git commit -m Dockerfile_simple
```

- basculez au niveau de la version plus complexe : `git checkout v0.18`
- activez le venv: `source venv/bin/activate`
- installez les libraries python (listées dans requirements.txt) dans l'environnement virtuel: `pip install -r requirements.txt`
- Suivez le [tutoriel de michael Grindberg](https://blog.miguelgrinberg.com/post/the-flask-mega-tutorial-part-xix-deployment-on-docker-containers) pour packager cette version plus complexe avec un mysql.
- La partie finale sur elasticsearch est facultative pour ce TP

- `Dockerfile correction` :

```Dockerfile
FROM python:3.7-buster

RUN useradd microblog

WORKDIR /home/microblog

COPY requirements.txt requirements.txt
RUN python -m venv venv
RUN venv/bin/pip install -r requirements.txt
RUN venv/bin/pip install gunicorn pymysql

COPY app app
COPY migrations migrations
COPY microblog.py config.py boot.sh ./
RUN chmod a+x boot.sh

ENV FLASK_APP microblog.py

RUN chown -R microblog:microblog ./
USER microblog

EXPOSE 5000
CMD ["/bin/bash", "./boot.sh"]
```

- `boot.sh`

```bash
#!/bin/sh
source venv/bin/activate
flask db upgrade
flask translate compile
exec gunicorn -b :5000 --access-logfile - --error-logfile - microblog:app
```

- Poussez bien l'image microblog sur le Docker Hub comme indiqué dans le tutoriel. Créez un compte le cas échéant.

```bash
docker login
docker tag microblog:latest <your-docker-registry-account>/microblog:latest
docker push <your-docker-registry-account>/microblog:lates
```

- Affichez la liste des images présentes dans votre Docker Engine.

```
docker image ls
```

- Inspectez la dernière image que vous venez de créez (`docker image --help` pour trouver la commande)

```
docker image inspect <num_image>
```

- Observez l'historique de construction de l'image avec `docker image history <image>`

## Observons et optimisons l'image

- Changez le contenu du fichier `requirements.txt` (ajoutez une ligne commentée pour que docker dectecte un changement) puis relancez le build. Observez la construction. Que remarque-t-on ?

```
La construction reprends depuis la dernière étape modifiée (l'ajoute de requirements.txt). Sinon la construction utilise le cache.
```

- Changez ensuite le contenu d'un des fichier python de l'application et relancez le build.

- Observez comme le build recommence à partir de l'instruction modifiée. Les layers précédents sont mis en cache par le docker engine

- Pour optimiser, rassemblez les commandes `RUN` liées à pip en une seule commande avec `&&` et sur plusieurs lignes avec `\`.
- Faites de même pour les `RUN` avec `chown/chmod`

- Retestez votre image.

- Pour ajouter les fichiers de l'application en une seule commande nous allons utiliser `ADD . .` et utiliser un fichier `.dockerignore` (à créer à la racine) pour lister les fichier à ignorer lors de la copie.

`.dockerignore`

```
logs
venv
.gitignore
app.db
babel.cfg
Dockerfile
LICENSE
Procfile
README.md
tests.py
Vagrantfile
```

- Finalement, avons nous besoin d'un **virtualenv** à l'intérieur d'un **conteneur docker** ? La boîté isole déjà les dépendances d'une seule application.
- => modifier le Dockerfile pour installer les dépendances directement dans l'OS du conteneur (sur une seule ligne).

- Ajoutez au début du `Dockerfile` une commande `LABEL maintainer=<votre_nom>`

- Ajoutez une commande `LABEL version=<votre_version>`

- Le shell par défaut de Docker est `SHELL ["/bin/sh", "-c"]`. Cependant ce shell a certains comportement inhabituels et la commande de construction **n'échoue pas forcément** si une commande s'est mal passée. Dans une optique d'intégration continue, pour rendre la modification ultérieure de l'image plus sure ajoutez au début (en dessous des `LABEL`) `SHELL ["/bin/bash", "-eux", "-o", "pipefail", "-c"]`.

- Cependant le shell bash est non standard sur docker. Pour ne pas perturber les utilisateurs de l'image qui voudrait lancer des commande il peut être intéressant de rebasculer sur `sh` à la fin de la construction. Ajoutez à l'avant dernière ligne: `SHELL ["/bin/sh", "-c"]`

- `Dockerfile optimisé correction`

```Dockerfile
FROM python:3.7-buster

LABEL version="1.0"

# shell plus restrictif pour ne pas avoir d'erreurs silencieuse
SHELL ["/bin/bash", "-eux", "-o", "pipefail", "-c"]

# Ne pas lancer les app en root dans docker
RUN useradd microblog
WORKDIR /home/microblog

#Ajouter tout le contexte sauf le contenu de .dockerignore
ADD . .

# Installer les déps python, pas besoin de venv car docker
RUN pip install -r requirements.txt && \
    pip install gunicorn pymysql
RUN chmod a+x boot.sh && \
    chown -R microblog:microblog ./

# Déclarer la config de l'app
ENV FLASK_APP microblog.py
EXPOSE 5000

# Changer d'user pour lancer l'app
USER microblog

# Remettre le shell standard pour ne pas surprendre les utilisateur de l'image
SHELL ["/bin/sh", "-c"]
CMD ["/bin/bash", "./boot.sh"]
```

- Visitons **en root** le dossier `/var/lib/docker/` en particulier `image/overlay2/layerdb/sha256/`:
  - On y trouve une sorte base de données de tous les layers d'images avec leurs ancêtres.
  - Il s'agit une arborescence.

### Protip

- Pour inspecter et explorer confortablement la hiérarchie des images vous pouvez installer `https://github.com/wagoodman/dive`

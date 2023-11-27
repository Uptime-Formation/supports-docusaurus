---
title: "Cours Dockerfile : choisir et modifier une image de base"
---

<!-- ## Objectifs pédagogiques

  - Savoir trouver et choisir les systèmes de base
  - Savoir utiliser les commandes FROM ... AS ... -->

![](../assets/images/ops-images-dockerfile.svg)

## Image de base

### Instruction `FROM`

C'est l'instruction fondamentale des Dockerfiles. 

Elle fournit l'image de base à partir de laquelle est construite l'image qu'on va construire.

**On peut utiliser toute image Docker comme base.**

Le Dockerhub fournit une liste des images de base "officielles" :

> https://hub.docker.com/search?q=&type=image&image_filter=official


**Il y a généralement 2 chemins que l'on peut suivre.**

1. Soit on veut déployer une application maison, et dans ce cas on peut utiliser une image de base généraliste qu'on va customiser.
  * Debian-based (debian, ubuntu, ...)
  * RedHat-based (ubi, etc, ...)
  * Alpine

2. Soit on veut déployer une solution standard, et dans ce cas on utilise une image dédiés:
  * langage (python, nodejs, ...)
  * serveur web (Nginx, Traefik, ...)
  * DBMS (Postgres, MySQL, ...)
  * NoSQL (redis, mongoDB, ...) 
  * services (prometheus, registry, ...)
  * autres (busybox, hello-world, ...)


### Bonne pratique: optimiser la création d'images

Les images Docker ont souvent une taille de plusieurs centaines de **mégaoctets** voire parfois **gigaoctets**. `docker image ls` permet de voir la taille des images.

Or, on construit souvent plusieurs dizaines de versions d'une application par jour (souvent automatiquement sur les serveurs d'intégration continue).

**L'espace disque devient alors un sérieux problème.**

Le principe de Docker est justement d'avoir des images légères car on va créer beaucoup de conteneurs (un par instance d'application/service).

De plus on télécharge souvent les images depuis un registry, ce qui consomme de la bande passante.

> La principale **bonne pratique** dans la construction d'images est de **limiter leur taille (mais pas forcément au détriment de tout)**.

Alors qu'une image Docker de 1 Go en développement local est insignifiante en termes de consommation d'espace, les inconvénients deviennent apparents dans les pipelines CI/CD, où vous pourriez avoir besoin de récupérer une image spécifique plusieurs fois pour exécuter des tâches. Alors que la bande passante et l'espace disque sont bon marché, le temps ne l'est pas. Chaque minute supplémentaire ajoutée au temps de CI s'accumule pour devenir conséquente.

Par exemple, chaque minute ou deux de temps de construction supplémentaire qui peut être optimisée pourrait s'ajouter au fil du temps pour représenter des heures de temps perdues chaque année

#### Comment limiter la taille d'une image ?

Choisir une image Linux de base **légère**:

Par exemple `python3` est fourni en version `python:alpine` (99 Mo), `python:3-slim` (179 Mo) et `python:latest` (918 Mo).

Pour ce besoin de trois images ? Souvent on a besoin de plein de choses dans l'images pour effectuer le build Docker :  par exemple de librairies spécifiques et de la chaine de build C/C++ (gcc,g++ etc)

## Un autre usecase de FROM : Créer des conteneurs personnalisés

Il n'est pas obligatoire de partir d'une image Linux vierge pour construire un conteneur. On peut utiliser la directive `FROM` avec n'importe quelle image : cela peut permettre de personnaliser un logiciel.

De nombreuses applications peuvent être configurées en étendant une image officielle
_Exemple : une image Wordpress déjà adaptée à des besoins spécifiques._

L'intérêt ensuite est que l'image est disponible préconfigurée pour construire ou mettre à jour une infrastructure, ou lancer plusieurs instances (plusieurs containers) à partir de cette image.

C'est aussi grâce à cette fonctionnalité que Docker peut être considéré comme un outil d'_infrastructure as code_.

<!-- On peut également prendre une sorte de "capture" du conteneur (de son système de fichiers, pas des processus en train de tourner) sous forme d'image avec `docker commit <conteneur> <repo/image_name>:<tag/version>` et `docker push`. -->


<!-- ## Objectifs pédagogiques
  - Savoir ajouter des fichiers au système
  - Savoir ajouter des packages, des utilisateurs, etc.
  - Savoir utiliser les commandes ADD, COPY, USER, RUN, WORKDIR  -->


### Instruction `WORKDIR`

```dockerfile
WORKDIR /path/to/workdir
```
**L'instruction WORKDIR définit le répertoire de travail pour toutes les instructions RUN, CMD, ENTRYPOINT, COPY et ADD qui le suivent dans le Dockerfile.**

Si le WORKDIR n'existe pas, il sera créé même s'il n'est utilisé dans aucune instruction Dockerfile ultérieure.

L'instruction WORKDIR peut être utilisée plusieurs fois dans un Dockerfile. Si un chemin relatif est fourni, il sera relatif au chemin de l'instruction WORKDIR précédente. Par exemple:

<!-- --- -->

### Dockerfile in progress 1/5

```Dockerfile
# notre image de base
FROM ubuntu

WORKDIR /srv
```

### Instruction `RUN`


```dockerfile
RUN <command> (shell form, the command is run in a shell, which by default is /bin/sh -c on Linux or cmd /S /C on Windows)
RUN ["executable", "param1", "param2"] (exec form)
```
**Exécute toutes les commandes dans un nouveau calque au-dessus de l'image actuelle et valide les résultats.**
 
L'image validée résultante sera utilisée pour l'étape suivante dans le Dockerfile.

<!-- --- -->

### Dockerfile in progress 2/5

```Dockerfile
# our base image
FROM ubuntu

WORKDIR /srv

RUN apt update && apt install -y python3  
```
<!-- --- -->

### Instruction `COPY`

```dockerfile
COPY [--chown=<user>:<group>] <src>... <dest>
COPY [--chown=<user>:<group>] ["<src>",... "<dest>"]
```

**Copie les nouveaux fichiers ou répertoires depuis src et les ajoute au système de fichiers du conteneur au chemin dest.**

<!-- --- -->
### Dockerfile in progress 3/5

```Dockerfile
# our base image
FROM ubuntu

WORKDIR /srv

RUN apt update && apt install -y python3  

# Cette commande copie index.html depuis le contexte de build dans /srv dans le conteneur
# index.html doit exister dans votre dossier de projet
COPY index.html /srv
```
**Après avoir ajouté ces instructions, lors du build, que remarque-t-on ?**

La construction reprend depuis la dernière étape modifiée. Sinon, la construction utilise les layers précédents, qui avaient été mis en cache par le Docker Engine.

<!-- --- -->

### Instruction `ADD`

```dockerfile
ADD [--chown=<user>:<group>] [--checksum=<checksum>] <src>... <dest>
```
**Copie les nouveaux fichiers, répertoires ou URL de fichiers distants depuis src et les ajoute au système de fichiers de l'image au chemin dest.**

Généralement utilisé pour ajouter le code du logiciel en cours de développement et sa configuration au conteneur.

<!-- --- -->

### Dockerfile in progress 4/5

```Dockerfile
# our base image
FROM ubuntu

WORKDIR /srv

RUN apt update && apt install -y python3  

COPY index.html /srv

ADD https://www.gnu.org/licenses/gpl-3.0.txt /srv/licence.txt
```
<!-- --- -->

### Instruction `USER`

```dockerfile
USER <user>[:<group>]
USER <UID>[:<GID>]
```
**L'instruction USER définit le nom d'utilisateur (ou UID) et éventuellement le groupe d'utilisateurs (ou GID) à utiliser comme utilisateur et groupe par défaut pour le reste de l'étape en cours.**

L'utilisateur spécifié est utilisé pour les instructions RUN et, lors de l'exécution, exécute les commandes ENTRYPOINT et CMD appropriées.

<!-- --- -->
### Dockerfile in progress 5/5

```Dockerfile
# our base image
FROM ubuntu

WORKDIR /srv

RUN apt update && apt install -y python3  

# Cette commande copie index.html depuis le contexte de build dans /srv dans le conteneur
# index.html doit exister dans votre dossier de projet
COPY index.html /srv

ADD https://www.gnu.org/licenses/gpl-3.0.txt /srv/licence.txt

# creation de l'utilisateur car USER ne le cree pas pour nous
RUN useradd -d /srv -ms /bin/bash app

# changement d'utilisateur pour la suite des instructions Dockerfile (en particulier la CMD)
USER app

# Ajoutons une commande pour servir notre page index.html avec python httpserver
CMD ["python3", "-m", "http.server", "8000"]
```



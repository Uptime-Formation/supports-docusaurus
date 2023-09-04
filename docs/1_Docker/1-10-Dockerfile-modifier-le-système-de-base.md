---
title: "1.10 Dockerfile : modifier le système de base"
pre: "<b>1.10 </b>"
weight: 11
---
## Objectifs pédagogiques
  - Savoir ajouter des fichiers au système
  - Savoir ajouter des packages, des utilisateurs, etc.
  - Savoir utiliser les commandes ADD, COPY, USER, RUN, WORKDIR 


![](../assets/images/ops-images-dockerfile.svg)

# Un dockerfile de test

Éxécuter les commandes suivantes.
```shell
$ mkdir ~/test_dockerfile && cd ~/test_dockerfile 
$ echo "<h1>Hello</h1>" > ~/test_dockerfile/index.html
$ vim ~/test_dockerfile/Dockerfile
```
Utilisons un Dockerfile minimal.

```dockerfile
# our base image
FROM ubuntu

# run the application
CMD ["sh", "-c", "echo Hello World"]
```

---

## Instruction `WORKDIR`

```dockerfile
WORKDIR /path/to/workdir
```
**L'instruction WORKDIR définit le répertoire de travail pour toutes les instructions RUN, CMD, ENTRYPOINT, COPY et ADD qui le suivent dans le Dockerfile.**

Si le WORKDIR n'existe pas, il sera créé même s'il n'est utilisé dans aucune instruction Dockerfile ultérieure.

L'instruction WORKDIR peut être utilisée plusieurs fois dans un Dockerfile. Si un chemin relatif est fourni, il sera relatif au chemin de l'instruction WORKDIR précédente. Par exemple:

---

## Dockerfile in progress 1/5

```Dockerfile
# notre image de base
FROM ubuntu

WORKDIR /srv

# La commande par défaut lancée dans le conteneur
CMD ["sh", "-c", "ls /srv"]
```

---


## Instruction `RUN`


```dockerfile
RUN <command> (shell form, the command is run in a shell, which by default is /bin/sh -c on Linux or cmd /S /C on Windows)
RUN ["executable", "param1", "param2"] (exec form)
```
**Exécute toutes les commandes dans un nouveau calque au-dessus de l'image actuelle et valide les résultats.**
 
L'image validée résultante sera utilisée pour l'étape suivante dans le Dockerfile.

---
## Dockerfile in progress 2/5

```Dockerfile
# our base image
FROM ubuntu

WORKDIR /srv

RUN apt update && apt install -y python3  

# La commande par défaut lancée dans le conteneur
CMD ["sh", "-c", "ls /srv"]
```
---
## Instruction `COPY`

```dockerfile
COPY [--chown=<user>:<group>] <src>... <dest>
COPY [--chown=<user>:<group>] ["<src>",... "<dest>"]
```

**Copie les nouveaux fichiers ou répertoires depuis src et les ajoute au système de fichiers du conteneur au chemin dest.**

---
## Dockerfile in progress 3/5

```Dockerfile
# our base image
FROM ubuntu

WORKDIR /srv

RUN apt update && apt install -y python3  

# Cette commande copie index.html depuis le contexte de build dans /srv dans le conteneur
# index.html doit exister dans votre dossier de projet
COPY index.html /srv

# La commande par défaut lancée dans le conteneur
CMD ["sh", "-c", "ls /srv"]
```
**Après avoir ajouté ces instructions, lors du build, que remarque-t-on ?**

La construction reprend depuis la dernière étape modifiée. Sinon, la construction utilise les layers précédents, qui avaient été mis en cache par le Docker Engine.

---
## Instruction `ADD`

```dockerfile
ADD [--chown=<user>:<group>] [--checksum=<checksum>] <src>... <dest>
```
**Copie les nouveaux fichiers, répertoires ou URL de fichiers distants depuis src et les ajoute au système de fichiers de l'image au chemin dest.**

Généralement utilisé pour ajouter le code du logiciel en cours de développement et sa configuration au conteneur.

---
## Dockerfile in progress 4/5

```Dockerfile
# our base image
FROM ubuntu

WORKDIR /srv

RUN apt update && apt install -y python3  

COPY index.html /srv

ADD https://www.gnu.org/licenses/gpl-3.0.txt /srv/licence.txt

# La commande par défaut lancée dans le conteneur
CMD ["sh", "-c", "ls /srv"]
```
---

## Instruction `USER`

```dockerfile
USER <user>[:<group>]
USER <UID>[:<GID>]
```
**L'instruction USER définit le nom d'utilisateur (ou UID) et éventuellement le groupe d'utilisateurs (ou GID) à utiliser comme utilisateur et groupe par défaut pour le reste de l'étape en cours.**

L'utilisateur spécifié est utilisé pour les instructions RUN et, lors de l'exécution, exécute les commandes ENTRYPOINT et CMD appropriées.

---
## Dockerfile in progress 5/5

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

# Mettons à jour la commande pour servir notre page index.html avec python httpserver
CMD ["python3", "-m", "http.server", "8000"]
```

---

# Dockerfile pour une application web flask


- Récupérez d’abord une application Flask exemple en la clonant :

```shell
git clone https://github.com/uptime-formation/microblog/
```

Déployer une application Flask manuellement à chaque fois est relativement pénible. Pour que les dépendances de deux projets Python ne se perturbent pas, il faut normalement utiliser un environnement virtuel `virtualenv` pour séparer ces deux apps.

Avec Docker, les projets sont déjà isolés dans des conteneurs. Nous allons donc construire une image de conteneur pour empaqueter l’application et la manipuler plus facilement. Assurez-vous que Docker est installé.


- Dans le dossier du projet ajoutez un fichier nommé `Dockerfile` et sauvegardez-le

- Normalement, VSCode vous propose d'ajouter l'extension Docker. Il va nous faciliter la vie, installez-le. Une nouvelle icône apparaît dans la barre latérale de gauche, vous pouvez y voir les images téléchargées et les conteneurs existants. L'extension ajoute aussi des informations utiles aux instructions Dockerfile quand vous survolez un mot-clé avec la souris.

- Ajoutez en haut du fichier : `FROM python:3.9` Cette commande indique que notre image de base est la version 3.9 de Python. Quel OS est utilisé ? Vérifier en examinant l'image ou via le Docker Hub.

- Nous pouvons déjà contruire un conteneur à partir de ce modèle Ubuntu vide :
  `docker build -t microblog .`

- Une fois la construction terminée lancez le conteneur.
- Le conteneur s’arrête immédiatement. En effet il ne contient aucune commande bloquante et nous n'avons précisé aucune commande au lancement.

:::tip Remarque

On pourrait ici être tenté d'installer python et pip (installeur de dépendance python) comme suit:

```Dockerfile
RUN apt-get update -y
RUN apt-get install -y python3-pip
``` 
Cette étape, qui aurait pu être nécessaire dans un autre contexte : en partant d'un linux vide comme `ubuntu` est ici inutile car l'image officielle python contient déjà ces éléments.
:::



- Reconstruisez votre image. Si tout se passe bien, poursuivez.

- Pour installer les dépendances python et configurer la variable d'environnement Flask ajoutez:

```Dockerfile
COPY ./requirements.txt /requirements.txt
RUN pip3 install -r requirements.txt
```

- Reconstruisez votre image. Si tout se passe bien, poursuivez.

- Ensuite, copions le code de l’application à l’intérieur du conteneur. Pour cela ajoutez les lignes :

```Dockerfile
WORKDIR /microblog
COPY ./ /microblog
```

### Ne pas faire tourner l'app en root
- Avec l'aide du [manuel de référence sur les Dockerfiles](https://docs.docker.com/engine/reference/builder/), faire en sorte que l'app `microblog` soit exécutée par un utilisateur appelé `microblog`.

```Dockerfile
# Ajoute un user et groupe appelés microblog
RUN  useradd -ms /bin/bash -d /microblog microblog
RUN chown -R microblog:microblog ./
USER microblog
```


Construire l'application avec `docker build`, la lancer et vérifier avec `docker exec`, `whoami` et `id` l'utilisateur avec lequel tourne le conteneur.

- `docker build -t microblog .`
- `docker run --rm -it microblog bash`

Une fois dans le conteneur lancez:

- `whoami` et `id`
- Avec `ps aux`, le serveur est-il lancé ? 
- Avec `docker run --rm -it microblog ` que se passe-t-il ?

## Le dockerfile final

```dockerfile
FROM python:3.9
RUN apt-get update -y
RUN apt-get install -y python3-pip
COPY ./requirements.txt /requirements.txt
RUN pip3 install -r requirements.txt
WORKDIR /microblog
COPY ./ /microblog
# Ajoute un user et groupe appelés microblog
RUN  useradd -ms /bin/bash -d /microblog microblog 
RUN chown -R microblog:microblog ./
USER microblog
```

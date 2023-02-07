---
title: TP 3bis - Volumes
weight: 1032
sidebar_position: 8
---

<!--
#TODO
# change network name to moby-network and add a schematics for clarity
# Add explanation on redis functionning (in RAM db => create a dump.rdb file only used when restarted) : https://redis.io/topics/persistence
# Redis need to restart to update from file stored in volume.
-->

## Portainer

<!-- - Pour visualiser aisément notre environnement docker au fur et à mesure de nos TPs nous allons charger une interface web d'administration docker appelée `portainer` et qui s'installe elle-même avec Docker. -->

Si vous aviez déjà créé le conteneur Portainer, vous pouvez le relancer en faisant `docker start portainer`, sinon créez-le comme suit :

```bash
docker volume create portainer_data
docker run --detach --name portainer \
    -p 9000:9000 \
    -v portainer_data:/data \
    -v /var/run/docker.sock:/var/run/docker.sock \
    portainer/portainer-ce
```

<!-- - Remarque sur la commande précédente : pour que Portainer puisse fonctionner et contrôler Docker lui-même depuis l'intérieur du conteneur il est nécessaire de lui donner accès au socket de l'API Docker de l'hôte grâce au paramètre `--mount` ci-dessus. -->

<!-- - Visitez ensuite la page [http://localhost:9000](http://localhost:9000) pour accéder à l'interface.
- Créez votre user admin avec le formulaire.
- Explorez l'interface de Portainer.
- Créez un conteneur -->

# Partie 2 : Volumes Docker

## Introduction aux volumes

- Pour comprendre ce qu'est un volume, lançons un conteneur en mode interactif et associons-y le dossier `/tmp/data` de l'hôte au dossier `/data` sur le conteneur :

```bash
docker run -it -v /tmp/data:/data ubuntu /bin/bash
```

- Dans le conteneur, navigons dans ce dossier et créons-y un fichier :

```bash
cd /data/
touch testfile
```

- Sortons ensuite de ce conteneur avec la commande `exit`

```bash
exit
```

- Après être sorti·e du conteneur, listons le contenu du dossier **sur l'hôte** avec la commande suivante ou avec le navigateur de fichiers d'Ubuntu :

```bash
ls /tmp/data/
```

Le fichier `testfile` a été crée par le conteneur au dossier que l'on avait connecté grâce à `-v /tmp/data:/data`

## L'app `moby-counter`, Redis et les volumes

Pour ne pas interférer avec la deuxième partie du TP :

- Stoppez tous les conteneurs redis et moby-counter avec `docker stop` ou avec Portainer.
- Supprimez les conteneurs arrêtés avec `docker container prune`
- Lancez `docker volume prune` pour faire le ménage de volume éventuellement créés dans les TPs précédent
<!-- - Lancez `docker volume ls` pour vérifier qu'aucun volume n'est créé (sauf `portainer_data` si vous utilisez encore Portainer) sinon supprimez-les avec `docker volume rm --force <id_volume>` -->
- Lancez aussi `docker network prune` pour nettoyer les réseaux inutilisés

Passons à l'exploration des volumes:

- Recréez le réseau `moby-network` et les conteneurs `redis` et `moby-counter` à l'intérieur :

```bash
docker network create moby-network
docker run -d --name redis --network moby-network redis
docker run -d --name moby-counter --network moby-network -p 8000:80 russmckendrick/moby-counter
```

- Visitez votre application dans le navigateur. **Faites un motif reconnaissable en cliquant.**

<!-- - Recréez le conteneur `redis` dans le réseau `moby-network` :
```bash
docker run -d --name redis --network moby-network redis
```

- Rechargez la page. Que s'est-il passé ? -->

### Récupérer un volume d'un conteneur supprimé

- supprimez le conteneur `redis` : `docker stop redis` puis `docker rm redis`

- Visitez votre application dans le navigateur. Elle est maintenant déconnectée de son backend.

- Avons-nous vraiment perdu les données de notre conteneur précédent ? Non !
  Le Dockerfile pour l'image officielle Redis ressemble à ça :

```Dockerfile
FROM alpine:3.5

RUN addgroup -S redis && adduser -S -G redis redis
RUN apk add --no-cache 'su-exec>=0.2'
ENV REDIS_VERSION 3.0.7
ENV REDIS_DOWNLOAD_URL http://download.redis.io/releases/redis-3.0.7.tar.gz
ENV REDIS_DOWNLOAD_SHA e56b4b7e033ae8dbf311f9191cf6fdf3ae974d1c
RUN set -x \
 && apk add --no-cache --virtual .build-deps \
 gcc \
 linux-headers \
 make \
 musl-dev \
 tar \
 && wget -O redis.tar.gz "$REDIS_DOWNLOAD_URL" \
    && echo "$REDIS_DOWNLOAD_SHA \*redis.tar.gz" | sha1sum -c - \
 && mkdir -p /usr/src/redis \
 && tar -xzf redis.tar.gz -C /usr/src/redis --strip-components=1 \
 && rm redis.tar.gz \
 && make -C /usr/src/redis \
 && make -C /usr/src/redis install \
 && rm -r /usr/src/redis \
 && apk del .build-deps

RUN mkdir /data && chown redis:redis /data
VOLUME /data
WORKDIR /data
COPY docker-entrypoint.sh /usr/local/bin/
RUN ln -s usr/local/bin/docker-entrypoint.sh /entrypoint.sh # backwards compat
ENTRYPOINT ["docker-entrypoint.sh"]
EXPOSE 6379
CMD [ "redis-server" ]
```

Notez que, vers la fin du fichier, il y a une instruction `VOLUME` ; cela signifie que lorque notre conteneur a été lancé, un volume "caché" a effectivement été créé par Docker.

Beaucoup de conteneurs Docker sont des applications _stateful_, c'est-à-dire qui stockent des données. Automatiquement ces conteneurs créent des volument anonymes en arrière plan qu'il faut ensuite supprimer manuellement (avec rm ou prune).

- Inspectez la liste des volumes (par exemple avec Portainer) pour retrouver l'identifiant du volume caché. Normalement il devrait y avoir un volume `portainer_data` (si vous utilisez Portainer) et un volume anonyme avec un hash.

- Créez un nouveau conteneur redis en le rattachant au volume redis "caché" que vous avez retrouvé (en copiant l'id du volume anonyme) :
  `docker container run -d --name redis -v <volume_id>:/data --network moby-network redis:alpine`

- Visitez la page de l'application. Normalement un motif de logos _moby_ d'une précédente session devrait s'afficher (après un délai pouvant aller jusqu'à plusieurs minutes)

- Affichez le contenu du volume avec la commande : `docker exec redis ls -lha /data`

### Bind mounting

Finalement, nous allons recréer un conteneur avec un volume qui n'est pas anonyme.

En effet, la bonne façon de créer des volumes consiste à les créer manuellement (volumes nommés) : `docker volume create redis_data`.

- Supprimez l'ancien conteneur `redis` puis créez un nouveau conteneur attaché à ce volume nommé : `docker container run -d --name redis -v redis_data:/data --network moby-network redis:alpine`

Lorsqu'un répertoire hôte spécifique est utilisé dans un volume (la syntaxe `-v HOST_DIR:CONTAINER_DIR`), elle est souvent appelée **bind mounting**.
C'est quelque peu trompeur, car tous les volumes sont techniquement "bind mounted". La différence, c'est que le point de montage est explicite plutôt que caché dans un répertoire géré par Docker.

- Lancez `docker volume inspect redis_data`.

<!-- ### Deux conteneurs Redis sur un seul volume

- Créez un réseau `moby-network2` et ajoutez un deuxième conteneur `redis2` qui va partager les même données que le premier :
  - situé à l'intérieur du nouveau réseau (`moby-network2`) comme à la partie précédent.
  - utilisant l'option `--network-alias redis` pour pouvoir être joignable par `moby-counter2` (que nous n'avons pas encore créé).
  - partageant le volume de données du premier (cf. cours)
      - monté en read-only (`:ro` après le paramètre de la question précédente)

<details><summary>Réponse</summary>
`docker run -v redis_data:/data -d --name redis2 --network moby-network2 --network-alias redis redis:alpine`
</details>

Le read-only est nécessaire pour que les deux Redis n'écrivent pas de façon contradictoire dans la base de valeurs.

- Ajoutez une deuxième instance de l'application dans le deuxième réseau connectée à ce nouveau Redis.

- Visitez la deuxième application : vous devriez voir également le motif de moby apparaître. -->

### Supprimer les volumes et réseaux

- Pour nettoyer tout ce travail, arrêtez d'abord les différents conteneurs `redis` et `moby-counter`.

- Lancez la fonction `prune` pour les conteneurs d'abord, puis pour les réseaux, et enfin pour les volumes.

Comme les réseaux et volumes n'étaient plus attachés à des conteneurs en fonctionnement, ils ont été supprimés.

**_Généralement, il faut faire beaucoup plus attention au prune de volumes (données à perdre) qu'au `prune` de conteneurs (rien à perdre car immutable et en général dans le registry)._**

### Facultatif : utiliser `VOLUME` avec `microblog`

- Rendez-vous dans votre répertoire racine en tapant `cd`.
- Après être entré·e dans le repo `microblog` grâce à `cd microblog`, récupérez une version déjà dockerisée de l'app en chargeant le contenu de la branche Git `tp2-dockerfile` en faisant `git checkout tp2-dockerfile -- Dockerfile`.

- Si vous n'aviez pas encore le repo `microblog` :

```bash
git clone https://github.com/uptime-formation/microblog/
cd microblog
git checkout tp2-dockerfile
```

- Lire le `Dockerfile` de l'application `microblog`.

Un volume Docker apparaît comme un dossier à l'intérieur du conteneur.
Nous allons faire apparaître le volume Docker comme un dossier à l'emplacement `/data` sur le conteneur.

- Pour que l'app Python soit au courant de l'emplacement de la base de données, ajoutez à votre `Dockerfile` une variable d'environnement `DATABASE_URL` ainsi (cette variable est lue par le programme Python) :

```Dockerfile
ENV DATABASE_URL=sqlite:////data/app.db
```

- Ajouter au `Dockerfile` une instruction `VOLUME` pour stocker la base de données SQLite de l'application.

<details><summary>Réponse</summary>

Dans le conteneur, le chemin de la base de données est :
`/data/app.db`

</details>

<details><summary>Réponse</summary>

Voici le `Dockerfile` complet :

```Dockerfile
FROM python:3-alpine

COPY ./requirements.txt /requirements.txt
RUN pip3 install -r requirements.txt
ENV FLASK_APP microblog.py

COPY ./ /microblog
WORKDIR /microblog

ENV CONTEXT PROD

EXPOSE 5000

ENV DATABASE_URL=sqlite:////data/app.db
VOLUME ["/data"]

CMD ["./boot.sh"]
```

</details>

- Créez un volume nommé appelé `microblog_db`, et lancez un conteneur l'utilisant, créez un compte et écrivez un message.
- Vérifier que le volume nommé est bien utilisé en branchant un deuxième conteneur `microblog` utilisant le même volume nommé.

---

<!--
La ligne de code Python qui nous permet de déterminer comment l'app utilise le volume du Dockerfile est la suivante :

`config.py` :

```python
SQLALCHEMY_DATABASE_URI = os.environ.get('DATABASE_URL') or \
 'sqlite:///' + os.path.join(basedir, 'data/app.db')

``` -->

<!-- , la variable d'environnement `DATABASE_URL`, qui indique à l'app où est la base de données, doit donc indiquer un fichier présent dans le dossier monté. -->

<!-- Marquer solution -->

<!-- ### Facultatif : `microblog` avec MySQL

Lire le `Dockerfile` de l'application `microblog` à l'adresse `https://github.com/uptime-formation/microblog` (branche `docker`) du TP précédent pour le lancer dans le même réseau qu'un conteneur `mysql` lancé avec les bonnes options de configuration.


<details><summary>Réponse</summary>

La ligne du `Dockerfile` qui nous intéresse est la suivante :

```Dockerfile
ENV DATABASE_URL=mysql+mysqlconnector://microblog:${MYSQL_PASSWORD}@db/microblog
```

Il faut donc remplacer la variable `DATABASE_URL` au lancement.

</details>

<details><summary>Réponse</summary>

Il va falloir configurer des options de démarrage pour le conteneur `mysql`, à lire sur le [Docker Hub](https://hub.docker.com/).

</details> -->

### _Facultatif :_ Packagez votre propre app

Vous possédez tous les ingrédients pour packager l'app de votre choix désormais ! Récupérez une image de base, basez-vous sur un Dockerfile existant s'il vous inspire, et lancez-vous !

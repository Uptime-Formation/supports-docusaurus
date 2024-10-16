---
title: "TP: Déployer avec docker compose créer et lancer ses applications"
---

<!-- 
## Objectifs pédagogiques
  - Savoir lancer une application multi-conteneur avec docker compose
  - Savoir créer une application multi-conteneur
-->


## Mise en pratique : écrire un fichier compose pas à pas 

### `frontend` : une application Flask qui se connecte à `redis`

Démarrez un nouveau projet dans VSCode (créez un dossier appelé `tp_compose` et chargez-le avec la fonction _Add folder to workspace_)

Dans un sous-dossier `app`, ajoutez une petite application python en créant ce fichier `app.py` :

```python
from flask import Flask, Response, request, abort
import requests
import hashlib
import redis
import os
import logging

LOGLEVEL = os.environ.get('LOGLEVEL', 'INFO').upper()
logging.basicConfig(level=LOGLEVEL)

app = Flask(__name__)
cache = redis.StrictRedis(host='redis', port=6379, db=0)
salt = "UNIQUE_SALT"
default_name = 'toi'

@app.route('/', methods=['GET', 'POST'])
def mainpage():

    name = default_name
    if request.method == 'POST':
        name = request.form['name']

    salted_name = salt + name
    name_hash = hashlib.sha256(salted_name.encode()).hexdigest()
    header = '<html><head><title>Identidock frontend</title></head><body>'
    body = '''<form method="POST">
                Salut <input type="text" name="name" value="{0}"> !
                <input type="submit" value="submit">
                </form>
                <p>Tu ressembles à ça :
                <img src="/monster/{1}"/>
            '''.format(name, name_hash)
    footer = '</body></html>'
    return header + body + footer


@app.route('/monster/<name>')
def get_identicon(name):
    found_in_cache = False

    try:
        image = cache.get(name)
        redis_unreachable = False
        if image is not None:
            found_in_cache = True
            logging.info("Image trouvée dans le cache")
    except:
        redis_unreachable = True
        logging.warning("Cache redis injoignable")

    if not found_in_cache:
        logging.info("Image non trouvée dans le cache")
        try:
            r = requests.get('http://imagebackend:8080/monster/' + name + '?size=80')
            image = r.content
            logging.info("Image générée grâce au service dnmonster")

            if not redis_unreachable:
                cache.set(name, image)
                logging.info("Image enregistrée dans le cache redis")
        except:
            logging.critical("Le service dnmonster est injoignable !")
            abort(503)

    return Response(image, mimetype='image/png')

if __name__ == '__main__':
  app.run(debug=True, host='0.0.0.0', port=5000)
```

`uWSGI` est un serveur python de production très adapté pour servir notre serveur intégré Flask, nous allons l'utiliser.

### Le Dockerfile

Dockerisons maintenant cette nouvelle application avec le Dockerfile suivant :

```Dockerfile
FROM python:3.12

RUN groupadd -r uwsgi && useradd -r -g uwsgi uwsgi
RUN pip install Flask uWSGI requests redis
WORKDIR /app
COPY app/app.py /app

EXPOSE 5000 9191
USER uwsgi
CMD ["uwsgi", "--http", "0.0.0.0:5000", "--wsgi-file", "/app/app.py", \
"--callable", "app", "--stats", "0.0.0.0:9191"]
```

Observons le code du Dockerfile ensemble s'il n'est pas clair pour vous. 

Construire l'application, pour l'instant avec `docker build ...`, la lancer.


### Le fichier Docker Compose

A la racine de notre projet (à côté du Dockerfile), créez un fichier de déclaration de notre application appelé `docker-compose.yml` avec à l'intérieur :

```yml
version: "3.8"
services:
  frontend:
    build: .
    ports:
      - "5000:5000"
```

**Plusieurs remarques**

  - La première ligne après `services` déclare le conteneur de notre application
  - Les lignes suivantes permettent de décrire comment lancer notre conteneur
  - `build: .` indique que l'image d'origine de notre conteneur est le résultat de la construction d'une image à partir du répertoire courant (équivaut à `docker build -t frontend .`)
  - La ligne suivante décrit le mapping de ports entre l'extérieur du conteneur et l'intérieur.

**Lancez le service (pour le moment mono-conteneur) avec `docker compose up`**

Notez que cette commande sous-entend `docker compose build`.

Visitez la page web de l'app.

### Ajoutons maintenant un deuxième conteneur

Nous allons tirer parti d'une image "dnmonster" déjà existante sur docker hub. Elle permet de récupérer une "identicon". 

Ajoutez à la suite du fichier Compose **_(attention aux indentations !)_** :

```yml
imagebackend:
  image: amouat/dnmonster:1.0
```

Le `docker-compose.yml` doit pour l'instant ressembler à ça :

```yml
services:
  frontend:
    build: .
    ports:
      - "5000:5000"

  imagebackend:
    image: amouat/dnmonster:1.0
```

### Mettre nos conteneurs dans un réseau dédié

Enfin, nous déclarons aussi un réseau appelé `identinet` pour y mettre les deux conteneurs de notre application.

Il faut d'abord déclarer le réseau à la fin du fichier.

```yaml
networks:
  identinet:
    driver: bridge
```

Sans spécifier le driver réseau, `bridge` celui utilisé par défaut, donc la 3e ligne est facultative ici.

Il faut ensuite aussi mettre nos deux services `frontend` et `imagebackend` sur le même réseau en ajoutant **deux fois** le bout de code suivant pour chaque service/conteneur :

```yaml
networks:
  - identinet
```

### Un conteneur de cache pour nos données

Ajoutons également un conteneur `redis`.

Cette "base de données" sert à mettre en cache les images et à ne pas les recalculer à chaque fois.

```yml
redis:
  image: redis
  networks:
    - identinet
```

### Résultat final

`docker-compose.yml` final :

```yaml
services:
  frontend:
    build: .
    ports:
      - "5000:5000"
      - "9191:9191" # port pour les stats
    networks:
      - identinet

  imagebackend:
    image: amouat/dnmonster:1.0
    networks:
      - identinet

  redis:
    image: redis
    networks:
      - identinet

networks:
  identinet:
    driver: bridge
```


**Lancez l'application et vérifiez que le cache fonctionne en cherchant les messages dans les logs de l'application.**

N'hésitez pas à passer du temps à explorer les options et commandes de `docker-compose`, ainsi que [la documentation officielle du langage des Compose files](https://docs.docker.com/compose/compose-file/). 

<!-- 
###  Le Docker Compose de `microblog`

Créons un fichier Docker Compose pour faire fonctionner l'application Microblog avec redis sous forme de docker-compose.

Quelles étapes faut-il ?

Avancé : Comment pourrait-on faire pour avoir du "Hot Reload", c'est à dire voir les modifications du code immédiates ? 

Indice : chercher "flask hot reload" et penser aux volumes

Avancé : Trouver comment configurer une base de données Postgres pour une app Flask (c'est une option de SQLAlchemy). -->



## Faire varier la configuration en fonction de l'environnement

Finalement le serveur de développement flask est bien pratique pour debugger en situation de développement, mais il n'est pas adapté à la production.

Nous pourrions créer deux images pour les deux situations mais ce serait aller contre l'imperatif DevOps de rapprochement du dév et de la production.


**Créons un script bash `boot.sh` pour adapter le lancement de l'application au contexte.**

```shell
#!/bin/bash
set -e
if [ "$CONTEXT" = 'DEV' ]; then
    echo "Running Development Server"
    exec python3 "/app/app.py"
else
    echo "Running Production Server"
    exec uwsgi --http 0.0.0.0:5000 --wsgi-file /app/app.py --callable app --stats 0.0.0.0:9191
fi
```

Ajoutez au Dockerfile une deuxième instruction `COPY` en dessous de la précédente pour mettre le script dans le conteneur.

Ajoutez un `RUN chmod a+x /boot.sh` pour le rendre executable.

Modifiez l'instruction `CMD` pour lancer le script de boot plutôt que `uwsgi` directement.

Modifiez l'instruction `EXPOSE` pour déclarer le port 5000 en plus.

Ajoutez au dessus une instruction `ENV CONTEXT PROD` pour définir la variable d'environnement `ENV` à la valeur `PROD` par défaut.

Testez votre conteneur en mode DEV avec `docker run --env CONTEXT=DEV -p 5000:5000 identidock`, visitez localhost:5000

Et en mode `PROD` ? 

Conclusions:

- On peut faire des images multicontextes qui s'adaptent au contexte.
- Les variables d'environnement sont souvent utilisée pour configurer les conteneurs au moment de leur lancement. (plus dynamique qu'un fichier de configuration)


```Dockerfile
FROM python:3.12

RUN groupadd -r uwsgi && useradd -r -g uwsgi uwsgi
RUN pip install Flask uWSGI requests redis

WORKDIR /app
COPY app /app
COPY boot.sh /
RUN chmod a+x /boot.sh

ENV CONTEXT PROD
EXPOSE 9191 5000

USER uwsgi
CMD ["/boot.sh"]
```

## Code `hot reload`

Une façon pratique de développer avec Docker Compose consiste à monter le code de l'application directement dans le conteneur via un bind mount

- ajoutez une section `volumes` à `frontend` avec `./app:/app:ro`

Modifiez le code dans app.py par exemple avec un simple commentaire. Si vous êtes en contexte DEV le serveur flask devrait recharger le code automatiquement (disponible dans la plupart des langages et frameworks)


### Un `docker-compose.prod.yml` pour `frontend`

Créez un deuxième fichier Compose `docker-compose.prod.yml` (à compléter) pour lancer l'application `identicon` en configuration de production. 

On veut ajouter les fonctionnalités suivantes :
- configurer les variables d'environnement via un fichier d'environnement
  - voir [la documentation](https://docs.docker.com/compose/environment-variables/env-file/)
  - LOGLEVEL
  - CONTEXT
  - Tester [d'autres variables Flask](https://flask.palletsprojects.com/en/2.2.x/config/)

- Un volume pour la base redis

- un service redis-commander pour afficher le contenu de la base redis
  - disponible sur le port 8081
  - le connecter via des variables d'environnement

<details><summary>Correction étendue de prod avec traefik reverse proxy https</summary>

**À compléter au niveau du nom de domaine**


```yaml
services:
  reverse-proxy:
    image: "traefik:v2.3"
    container_name: "traefik"
    ports:
      - "443:443"
      - "8080:8080"
    networks:
      - identinet
      - redis
    volumes:
      - "./letsencrypt:/letsencrypt"
      - "/var/run/docker.sock:/var/run/docker.sock:ro"
    command:
      #- "--log.level=DEBUG" # pour debugger avec docker logs si la connexion ou le letsencrypt marche pas
      - "--api.insecure=true"
      - "--providers.docker=true"
      - "--providers.docker.exposedbydefault=false"
      - "--entrypoints.websecure.address=:443"
      - "--certificatesresolvers.myresolver.acme.tlschallenge=true"
      #- "--certificatesresolvers.myresolver.acme.caserver=https://acme-staging-v02.api.letsencrypt.org/directory" # pour tester en staging
      - "--certificatesresolvers.myresolver.acme.email=testfakemail777@free.fr"
      - "--certificatesresolvers.myresolver.acme.storage=/letsencrypt/acme.json"

  frontend:
    build: .
    # ports: # plus nécessaire car traefik
    #   - "5000:5000"
    networks:
      - identinet
    env_file:
      - .env
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.frontend.rule=Host(`monster.<votrenom>.formation.dopl.uk`)"
      - "traefik.http.routers.frontend.entrypoints=websecure"
      - "traefik.http.routers.frontend.tls.certresolver=myresolver"
      - "traefik.http.services.frontend.loadbalancer.server.port=5000"

  imagebackend:
    image: amouat/dnmonster:1.0
    networks:
      - identinet

  redis:
    image: redis
    hostname: redis
    networks:
      - identinet
      - redis
    volumes:
      - redis_data:/data

  rediscommander:
    image: rediscommander/redis-commander
    environment:
    - REDIS_HOSTS=local:redis:6379
    # ports:
    # - "8081:8081"
    networks:
      - redis
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.rediscommander.rule=Host(`rediscommander.<votrenom>.formation.dopl.uk`)"
      - "traefik.http.routers.rediscommander.entrypoints=websecure"
      - "traefik.http.routers.rediscommander.tls.certresolver=myresolver"
      - "traefik.http.services.rediscommander.loadbalancer.server.port=8081"

networks:
  identinet:
    driver: bridge
  redis:
    driver: bridge

volumes:
  redis_data:
```

</details>


## Exercice facultatif 1 : un pad HedgeDoc (ou autre logiciel de votre choix).

On se propose ici d'essayer de déployer plusieurs services pré-configurés comme Wordpress, Nextcloud, Sentry ou votre logiciel préféré.

Récupérez (et adaptez si besoin) à partir d'Internet un fichier `docker-compose.yml` permettant de lancer un pad HedgeDoc ou autre avec sa base de données. 

Je vous conseille de toujours chercher **dans la documentation officielle** ou le repository officiel (souvent sur Github) en premier.

Vérifiez que le service est bien accessible sur le port donné.

Si besoin, lisez les logs en quête de bug et adaptez les variables d'environnement.

## Exercice facultatif 2 : Wordpress et/ou Nextcloud

Assemblez à partir d'Internet un fichier `docker-compose.yml` permettant de lancer un Wordpress et un Nextcloud **déjà pré-configurés** (pour l'accès à la base de données notamment). 

Ajoutez-y un pad CodiMD / HackMD (toujours grâce à du code trouvé sur Internet).



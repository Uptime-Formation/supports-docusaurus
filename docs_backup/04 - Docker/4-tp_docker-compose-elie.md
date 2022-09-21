---
title: "TP 4 - Multiconteneurs avec compose"
draft: true
---

## Démarrons une nouvelle application Flask

- Démarrez un nouveau projet dans VSCode (créez un dossier et chargez le avec la fonction `add folder to workspace`)
- Dans un sous dossier `app`, ajoutez une petite application python `identidock.py`:

```python
from flask import Flask, Response, request
import requests
import hashlib
import redis

app = Flask(__name__)
cache = redis.StrictRedis(host='redis', port=6379, db=0)
salt = "UNIQUE_SALT"
default_name = 'Joe Bloggs'

@app.route('/', methods=['GET', 'POST'])
def mainpage():
    name = default_name
    if request.method == 'POST':
        name = request.form['name']
    salted_name = salt + name
    name_hash = hashlib.sha256(salted_name.encode()).hexdigest()
    header = '<html><head><title>Identidock</title></head><body>'
    body = '''<form method="POST">
                Hello <input type="text" name="name" value="{0}">
                <input type="submit" value="submit">
                </form>
                <p>You look like a:
                <img src="/monster/{1}"/>
            '''.format(name, name_hash)
    footer = '</body></html>'
    return header + body + footer


@app.route('/monster/<name>')
def get_identicon(name):
    image = cache.get(name)
    if image is None:
        print ("Cache miss", flush=True)
        r = requests.get('http://dnmonster:8080/monster/' + name + '?size=80')
        image = r.content
    cache.set(name, image)

    return Response(image, mimetype='image/png')

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')

```

- Nous allons dockeriser cette application python de façon classique

  - utilisons l'image docker de base python 3.7 du docker hub : cherchez sur [hub.docker.com](hub.docker.com)
  - les dépendances python sont `Flask uWSGI requests redis` à installer avec `pip`. Pas besoin de `virtualenv pour isoler car on a déjà un conteneur : installer les dépendance à la racine du conteneur.

- Nous allons utiliser `uWSGI` qui est un serveur python de production très adapté pour servir des applications flask (mieux que le serveur intégré flask).

- Dans le Dockerfile, créez l'instruction pour ajouter un utilisateur et groupe dédié à uWSGI avec `groupadd -r uwsgi && useradd -r -g uwsgi uwsgi`.

- Exposez le port `9090` et `9191` qui seront les deux ports de norte mini backend. L'instruction expose est indicative elle n'ouvre pas effectivement les ports.

- Juste avant de lancer l'application, changez d'utilisateur vers `uwsgi` avec l'instruction `USER`.

- A la fin , plutôt que d'utiliser `flask run` pour lancer l'application nous allons appeler `uwsgi` avec CMD :

```Dockerfile
CMD ["uwsgi", "--http", "0.0.0.0:9090", "--wsgi-file", "/app/identidock.py", "--callable", "app", "--stats", "0.0.0.0:9191"]
```

{{% expand "Correction `Dockerfile`  :" %}}

```Dockerfile
FROM python:3.7
RUN groupadd -r uwsgi && useradd -r -g uwsgi uwsgi
RUN pip install Flask uWSGI requests redis
WORKDIR /app
COPY app/identidock.py /app
EXPOSE 9090 9191
USER uwsgi
CMD ["uwsgi", "--http", "0.0.0.0:9090", "--wsgi-file", "/app/identidock.py", \
"--callable", "app", "--stats", "0.0.0.0:9191"]
```

{{% /expand %}}

- Construire l'application, la lancer et vérifier avec `docker exec`, `whoami` et `id` l'utilisateur avec lequel tourne le conteneur.

{{% expand "Réponse  :" %}}

- `docker build -t identidock .`
- `docker run --detach --name identidock -p 9090:9090 identidock`
- `docker exec -it identidock /bin/bash`

Une fois dans le conteneur lancez:

- `whoami` et `id`
- vérifiez aussi avec `ps aux` que le serveur est bien lancé.

{{% /expand %}}

- Validez la version actuelle du code avec `git init && git add -A && git commit -m tp_compose_init`

## Pousser notre conteneur sur un registry (le docker hub)

- Créez un compte sur `hub.docker.com`.
- Lancez `docker login` pour vous identifier en CLI.
- Donnons un nom tag public avec votre login docker hub à notre image pour pouvoir la pousser sur le registry `docker tag identidock <votre_hub_login>/identidock:0.1`
- Puis poussons l'image sur le hub docker avec : `docker push <votre_hub_login>/identidock:0.1`

## Faire varier la configuration en fonction de l'environnement

Finalement le serveur de développement flask est bien pratique pour debugger en situation de développement bien que pas adapté à la production.
Nous pourrions créer deux images pour les deux situations mais ce serait aller contre l'imperatif DevOps de rapprochement du dév et de la production.

- Créons un script bash `boot.sh` pour adapter le lancement de l'application au contexte:

```bash
#!/bin/bash
set -e
if [ "$CONTEXT" = 'DEV' ]; then
    echo "Running Development Server"
    exec python3 "/app/identidock.py"
else
    echo "Running Production Server"
    exec uwsgi --http 0.0.0.0:9090 --wsgi-file /app/identidock.py --callable app --stats 0.0.0.0:9191
fi
```

- Ajoutez au Dockerfile une deuxième instruction `COPY` en dessous de la précédente pour mettre le script dans le conteneur.
- Ajoutez un `RUN chmod a+x /boot.sh` pour le rendre executable.
- Modifiez l'instruction `CMD` pour lancer le script de boot plutôt que `uwsgi` directement.
- Modifiez l'instruction expose pour déclarer le port 5000 en plus.
- Ajoutez au dessus une instruction `ENV ENV PROD` pour définir la variable d'environnement `ENV` à la valeur `PROD` par défaut.

- Testez votre conteneur en mode DEV avec `docker run --env CONTEXT=DEV -p 5000:5000 identidock`, visitez localhost:5000
- Et en mode `PROD` avec `docker run --env CONTEXT=PROD -p 9090:9090 identidock`. Visitez localhost:9090.

{{% expand "Correction `Dockerfile`:" %}}

```Dockerfile
FROM python:3.7
RUN groupadd -r uwsgi && useradd -r -g uwsgi uwsgi
RUN pip install Flask uWSGI requests redis
WORKDIR /app
COPY app /app
COPY boot.sh /
RUN chmod a+x /boot.sh
ENV CONTEXT PROD
EXPOSE 9090 9191 5000
USER uwsgi
CMD ["/boot.sh"]
```

{{% /expand %}}

Conclusions:

- On peut faire des images multicontextes qui s'adaptent au contexte.
- Les variables d'environnement sont souvent utilisée pour configurer les conteneurs au moment de leur lancement. (plus dynamique qu'un fichier de configuration)

## Articuler deux images avec Docker compose

- A la racine de notre projet (à côté du Dockerfile), créez un fichier déclaration de notre application `docker-compose.yml` avec à l'intérieur:

```yaml
version: "3"
services:
  identidock:
    build: .
    ports:
      - "5000:5000"
    environment:
      - CONTEXT=DEV
    volumes:
      - ./app:/app
```

- Plusieurs remarques:

  - la première ligne déclare le conteneur de notre application
  - les lignes suivante permette de décrire comment lancer notre conteneur
  - `build: .` d'abord l'image d'origine de notre conteneur est le résultat de la construction du répertoire courant
  - la ligne suivante décrit le mapping de ports.
  - on définit ensuite la valeur de l'environnement de lancement du conteneur
  - on définit un volume (le dossier `app` dans le conteneur sera le contenu de notre dossier de code) de cette façon si on modifie le code pas besoin de rebuilder l'application !!!

- Lancez le service (pour le moment mono conteneur) avec `docker-compose up`.
- Visitez la page web.
- Essayez de modifier l'application et de recharger la page web. Voilà comment, grâce à un volume on peut développer sans reconstruire l'image à chaque fois ! (grace au volume /app)

- Ajoutons maintenant un deuxième conteneur. Nous allons tirer parti d'une image déjà créée qui permet de récupérer une "identicon" et l'afficher dans l'application `identidock`. Ajoutez à la suite du compose file (attention aux identation !!):

```yaml
    networks:
      - identinet

  dnmonster:
    image: amouat/dnmonster:1.0
    networks:
      - identinet
```

- Cette fois plutôt de construire l'image, nous indiquons de simplement de la récupérer sur le docker hub avec le mot clé `image: `.
- Mais surtout nous déclarons un réseau `identidock` pour mettre les deux conteneurs de notre application.
- Il faut déclarer ce réseau à la fin du fichier:

```yaml
networks:
  identinet:
    driver: bridge
```

- Ajoutons également un conteneur redis:

```yaml
redis:
  image: redis
  networks:
    - identinet
```

- Correction: `docker-compose.yml`:

```yaml
version: "3"
services:
  identidock:
    build: .
    ports:
      - "5000:5000"
    environment:
      ENV: DEV
    volumes:
      - ./app:/app
    networks:
      - identinet

  dnmonster:
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

- Lancez l'application et vérifiez que le cache fonctionne en chercheant les `cache miss` dans les logs de l'application.

- Créez un deuxième fichier compose `docker-compose.prod.yml` (à compléter) pour lancer l'application en configuration de production:

```yaml
version: "3"
services:
  identidock:
    image: <votre_hub_login>/identidock:0.1
    ports:
      - "9090:9090"
      - "9191:9191"
    environment:
      - CONTEXT=PROD
    networks:
      - identinet

  dnmonster:
    image: amouat/dnmonster:1.0
    networks:
      - identinet

  redis:
    image: redis
    networks:
      - identinet
    volumes:
      - identiredis_volume:/data

  redis-commander:
    image: rediscommander/redis-commander:latest
    environment:
      - REDIS_HOSTS=local:redis:6379
    ports:
      - "8081:8081"
    networks:
      - identinet

networks:
  identinet:
    driver: bridge

volumes:
  identiredis_volume:
    driver: local
```

- Commentons ce code:

  - plus de volume `/app` pour identidock car nous sommes en prod
  - on ouvre le port de l'app 9090 mais aussi le port de stat du serveur uWSGI 9191
  - CONTEXT = PROD pour lancer l'application avec le serveur uWSGI
  - On a mis un volume nommé à redis pour conserver les données sur le long terme
  - on a ajouté un GUI web redis accessible sur localhost:8081 pour voir le conteneur de la DB redis.
  - le tout dans le même réseau

- Le dépot de correction [https://github.com/e-lie/tp4_docker_compose_correction_202001.git](https://github.com/e-lie/tp4_docker_compose_correction_202001.git)

- N'hésitez pas à passer du temps à explorer les options et commande de `docker-compose`. Ainsi que [la documentation du langage (DSL) des compose-file](https://docs.docker.com/compose/compose-file/).

---
title: 'Docker 4 - Créer une application multiconteneur - Correction'
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

- En vous inspirant du TP précédent (version simple), dockerisez cette application (les dépendances sont
  `Flask uWSGI requests redis`)

- `uWSGI` est un serveur python de production très adapté pour servir des applications flask. Notre serveur intégré flask.
 nous allons l'utiliser.

- Au début du Dockerfile, créez l'instruction pour ajouter un utilisateur et groupe dédié avec `groupadd -r uwsgi && useradd -r -g uwsgi uwsgi`

- Exposez le port `9090` et `9191` plutôt que `5000`.

- Juste avant de lancer l'application, changez d'utilisateur avec l'instruction `USER`.

- A la fin , plutôt que d'utiliser `flask run` pour lancer l'application nous allons appeler uwsgi :

```Dockerfile
CMD ["uwsgi", "--http", "0.0.0.0:9090", "--wsgi-file", "/app/identidock.py", "--callable", "app", "--stats", "0.0.0.0:9191"]
```

- Correction `Dockerfile`:
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


- Construire l'application, la lancer et vérifier avec `docker exec`,  `whoami` et `id` l'utilisateur avec lequel tourne le conteneur.



## Faire varier la configuration en fonction de l'environnement

Finalement le serveur de développement flask est bien pratique pour debugger en situation de développement bien que pas adapté à la production.
Nous pourrions créer deux images pour les deux situations mais ce serait aller contre l'imperatif DevOps de rapprochement du dév et de la production.

- Créons un script bash `boot.sh` pour adapter le lancement de l'application au contexte:

```bash
#!/bin/bash
set -e
if [ "$ENV" = 'DEV' ]; then
    echo "Running Development Server"
    exec python3 "/app/identidock.py"
else
    echo "Running Production Server"
    exec uwsgi --http 0.0.0.0:9090 --wsgi-file /app/identidock.py --callable app --stats 0.0.0.0:9191
fi
```

- Ajoutez une instruction `CMD` pour lancer le script de boot.

- Correction `Dockerfile`:
```Dockerfile
FROM python:3.7
RUN groupadd -r uwsgi && useradd -r -g uwsgi uwsgi
RUN pip install Flask uWSGI requests redis
WORKDIR /app
COPY app /app
COPY boot.sh /
RUN chmod a+x /boot.sh
ENV ENV PROD
EXPOSE 9090 9191 5000
USER uwsgi
CMD ["/boot.sh"]
```


## Articuler deux images avec Docker compose

- Observons le code de l'application ensemble s'il n'est pas clair pur vous.

- A la racine de notre projet (à côté du Dockerfile), créez un fichier déclaration de notre application `docker-compose.yml` avec à l'intérieur:
  
```yml
version: '3'
services:
  identidock:
    build: .
    ports:
      - "5000:5000"
    environment:
      ENV: DEV
    volumes:
      - ./app:/app
```

- Plusieurs remarques:
  - la première ligne déclare le conteneur de notre application
  - les lignes suivante permette de décrire comment lancer notre conteneur
  - `build: .` d'abord l'image d'origine de notre conteneur est le résultat de la construction du répertoire courant
  - la ligne suivante décrit le mapping de ports.
  - on définit ensuite la valeur de l'environnement de lancement du conteneur
  - on définit un volume (le dossier `app` dans le conteneur sera le contenu de notre dossier de code)

- Lancez le service (pour le moment mono conteneur) avec `docker-compose up`
- Visitez la page web.
- Essayez de modifier l'application et de recharger la page web. Voilà comment, grâce à un volume on peut développer sans reconstruire l'image à chaque fois !

- Ajoutons maintenant un deuxième conteneur. Nous allons tirer parti d'une image déjà créée qui permet de récupérer une "identicon". Ajoutez à la suite du compose file (attention aux identation !!):

```yml
    links:
      - dnmonster

  dnmonster:
    image: amouat/dnmonster:1.0
```

Cette fois plutôt de construire l'image, nous indiquons de simplement de la récupérer sur le docker hub. Nous ajoutons également un lien qui indique à docker de configurer le réseau convenablement.

- Ajoutons également un conteneur redis:

```yml
    redis:
      image: redis:3.0
```

- Et un deuxième lien `- redis`


- Correction: `docker-compose.yml`
```yml
version: '3'
services:
  identidock:
    build: .
    ports:
      - "5000:5000"
    environment:
      ENV: DEV
    volumes:
      - ./app:/app
    links:
      - dnmonster
      - redis

  dnmonster:
    image: amouat/dnmonster:1.0

  redis:
    image: redis:3.0
```

- Lancez l'application et vérifiez que le cache fonctionne en chercheant les `cache miss` dans les logs de l'application.

- Créez un deuxième fichier compose `docker-compose.prod.yml` pour lancer l'application en configuration de production.
```yml
version: '3'
services:
  identidock:
    build: .
    ports:
      - "9090:9090"
      - "9191:9191"
    environment:
      ENV: PROD
    volumes:
      - ./app:/app
    links:
      - dnmonster
      - redis

  dnmonster:
    image: amouat/dnmonster:1.0

  redis:
    image: redis:3.0
```

- N'hésitez pas à passer du temps à explorer les options et commande de `docker-compose`. Ainsi que [la documentation du langage (DSL) des compose-file](https://docs.docker.com/compose/compose-file/).
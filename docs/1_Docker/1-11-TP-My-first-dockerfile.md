---
title: "1/1 TP Dockerfile MyFirstApp"
pre: "<b>1.11 TP</b>"
weight: 11
---

### Objectif

**On va créer une image pour une micro webapp en Python.**

Pour cela on va utiliser l'image Python basée sur Debian pour servir notre application Flask, en suivant les bonnes pratiques de sécurité et de qualité de code.

Les fichiers nécessaires sont en fin de page.

### Étapes 

- **Action** : Préparer un répertoire local pour le projet Docker.  
  **Observation** : Le répertoire contient les fichiers `main.py`, `index.html` et `requirements.txt`.


- **Action** : Créer un fichier `Dockerfile` en utilisant l'image `python:3.11-slim-bullseye` comme base.  
  **Observation** : Le fichier `Dockerfile` est présent dans le répertoire et contient les instructions de base.


- **Action** : Ajouter des instructions dans le `Dockerfile` pour copier les fichiers de dépendances et installer les modules Python requis.  
  **Observation** : Le `Dockerfile` inclut les commandes pour copier `requirements.txt` et installer les dépendances.


- **Action** : Ajouter des bonnes pratiques de sécurité et de qualité de code dans le `Dockerfile` (utilisateur non-root, utilisation d'ARG et de labels, configuration du `HEALTHCHECK`).  
  **Observation** : Le `Dockerfile` contient des instructions optimisées pour la sécurité et la qualité.


- **Action** : Construire l'image Docker personnalisée.  
  **Observation** : L'image est construite avec succès sans erreurs de build.


- **Action** : Vérifier que l'image Docker créée est présente dans la liste des images locales sur l'hôte.  
  **Observation** : L'image apparaît dans la liste des images locales via `docker images`.


- **Action** : Tagger l'image Docker avec un nom et une version appropriés.  
  **Observation** : L'image est correctement taggée et identifiable.


- **Action** : Tester l'image en lançant un conteneur et en exécutant l'application Flask.  
  **Observation** : L'application Flask s'exécute correctement dans le conteneur.


- **Action** : Vérifier le fonctionnement de l'application et le respect des bonnes pratiques (taille de l'image, sécurité, performance).  
  **Observation** : Le conteneur fonctionne conformément aux attentes, et les bonnes pratiques sont respectées.


### Structure des fichiers du projet Python 

Voici l'arborescence simplifiée avec les fichiers essentiels :

```
MyFirstApp/
│
├── Dockerfile
├── main.py
├── templates/
│   └── index.html
└── requirements.txt
```

---

**`main.py`**
```python
from flask import Flask, render_template, jsonify
import os
import redis

app = Flask(__name__)

# Configuration de Redis via les variables d'environnement
REDIS_HOST = os.getenv('REDIS_HOST', None)
REDIS_PORT = os.getenv('REDIS_PORT', 6379)

# Récupération du port d'application depuis les variables d'environnement
APP_PORT = int(os.getenv('APP_PORT', 3000))

# Connexion à Redis si disponible
redis_client = None
counter_value = 0  # Valeur par défaut si Redis n'est pas disponible
if REDIS_HOST:
    try:
        redis_client = redis.StrictRedis(host=REDIS_HOST, port=REDIS_PORT, decode_responses=True)
        redis_client.ping()

        # Initialiser le compteur à 0 si Redis est connecté et n'existe pas encore
        if not redis_client.exists('counter'):
            redis_client.set('counter', 0)
        else:
            # Lire la valeur actuelle du compteur depuis Redis
            counter_value = redis_client.get('counter')
    except redis.exceptions.ConnectionError:
        redis_client = None

@app.route('/')
def index():
    # Définir la variable pour savoir si Redis est disponible
    redis_available = redis_client is not None
    return render_template('index.html', redis_available=redis_available, counter=counter_value)

@app.route('/increment', methods=['POST'])
def increment_counter():
    if redis_client:
        # Incrémenter le compteur dans Redis
        new_count = redis_client.incr('counter')
        return jsonify({'status': 'success', 'new_count': new_count})
    return jsonify({'status': 'error', 'message': 'Redis not available'})

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=APP_PORT)


```

---


**`templates/index.html`**
```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MyFirstApp</title>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
</head>
<body>
    <h1>Welcome to MyFirstApp</h1>
    
    {% if redis_available %}
        <p>Redis is connected! Here are some options:</p>
        <button id="increment-btn">Increment Counter</button>
        <p>Counter: <span id="counter-value">{{ counter }}</span></p>
    {% else %}
        <p>Redis is not available. Please check your configuration.</p>
    {% endif %}

    <script>
    $(document).ready(function() {
        $('#increment-btn').on('click', function() {
            $.ajax({
                url: '/increment',
                type: 'POST',
                success: function(response) {
                    if (response.status === 'success') {
                        $('#counter-value').text(response.new_count);
                    } else {
                        alert(response.message);
                    }
                },
                error: function() {
                    alert('Error occurred while contacting the server.');
                }
            });
        });
    });
    </script>
</body>
</html>

```

---

**`requirements.txt`**

```makefile
Flask==2.3.2
redis==4.6.0
```

---


**`Dockerfile`**


```Dockerfile
FROM python:3.11-slim-bullseye

ARG APP_VERSION=1.0

LABEL maintainer="support@mytechcompany.io" \
      version="${APP_VERSION}" \
      description="Docker image for MyFirstApp - a Flask application with optional Redis support"

WORKDIR /app

RUN apt update && apt install curl && apt clean

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

RUN useradd -ms /bin/bash flaskuser && chown -R flaskuser /app

USER flaskuser

COPY . .

ENV APP_PORT=3000

EXPOSE ${APP_PORT}

ENTRYPOINT ["python"]
CMD ["main.py"]

HEALTHCHECK --interval=30s --timeout=10s --retries=3 CMD curl -f http://localhost:${APP_PORT} || exit 1
```

### Avancé 

- Que se passe-t-il si vous relancez le build de l'image ? 
- Essayez de modifier le code HTML et de reconstruire l'image en changeant de version.
- Comment lancer sur un autre port ? Peut-on lancer plusieurs fois la même image ? Sur le même port ? 
- Pourquoi ça ne marche pas t-il si on essaie de se connecter à la machine via un `docker exec ... bash` ? Comment faire ?


### Solution 

<details><summary>Afficher</summary>

- Créer le répertoire local : `mkdir MyFirstApp && cd MyFirstApp`  
- Créer le fichier `Dockerfile` avec l'éditeur de texte.  
- Ajouter les instructions au `Dockerfile` : voir le contenu fourni précédemment.  
- Construire l'image Docker : `docker build .`  
- Vérifier la liste des images : `docker images`  
- Tagger l'image : `docker tag [image_uuid] myfirstapp:1.0`  
- Lancer le conteneur : `docker run -p 3000:3000 myfirstapp:1.0`  
- Vérifier l'application : `curl http://localhost:3000`  

</details>
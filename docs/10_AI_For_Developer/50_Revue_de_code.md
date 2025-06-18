---
title: 5 - Revue de code
---

## Quickstart

Dans un dossier contenant du code généré durant la formation, afficher le contenu d'un commit git.

Entrez le prompt suivant 

```text 
<diff>...<diff>
<fichier final>...</fichier final>

Fournis un message de commit prenant en compte le diff et le fichier final.

```

<details><summary>Example</summary>

```text
<diff>
diff --git a/service.py b/service.py
index c64cf6d..d777e75 100644
--- a/service.py
+++ b/service.py
@@ -20,6 +20,13 @@ if COLOR_FROM_ENV:
 else:
     COLOR = "#887766"
 
+# Get port from Environment variable
+PORT_FROM_ENV = os.environ.get('PORT')
+if PORT_FROM_ENV:
+    PORT = PORT_FROM_ENV
+else:
+    PORT = "3000"
+
 db_init(db)
 
 
@@ -67,6 +74,6 @@ if __name__ == "__main__":
     # Run Flask Application
     app.run(
         host="0.0.0.0",
-        port=3000,
+        port=PORT,
         use_debugger=True
     )
</diff>
<fichier final>
from flask import Flask
from flask import render_template
import os
import socket
from src.funcs import *
from pathlib import Path
from git import Repo
app = Flask(__name__)

db = Path('./SQLite_Python.db').absolute()

repo = Repo(Path("."))
branch = repo.active_branch.name
commit = repo.active_branch.commit.hexsha

# Get color from Environment variable
COLOR_FROM_ENV = os.environ.get('COLOR')
if COLOR_FROM_ENV:
    COLOR = COLOR_FROM_ENV
else:
    COLOR = "#887766"

# Get port from Environment variable
PORT_FROM_ENV = os.environ.get('PORT')
if PORT_FROM_ENV:
    PORT = PORT_FROM_ENV
else:
    PORT = "3000"

db_init(db)


@app.route("/clicks")
def clicks():
    return {
        "counter": get_clicks(db)
    }


@app.route("/ip")
def ip():
    return {
        "ip_list": if_get_info()
    }


@app.route("/sys")
def sys():
    return {
        "sys_list": sys_get_info()
    }


@app.route("/new")
def new():
    increment_clicks(db)
    return {
        "counter": get_clicks(db)
    }


@app.route("/")
def index():
    return render_template('index.html',
                           name=socket.gethostname(),
                           clicks=clicks,
                           color=COLOR,
                           branch=branch,
                           commit=commit
                           )


if __name__ == "__main__":
    # Run Flask Application
    app.run(
        host="0.0.0.0",
        port=PORT,
        use_debugger=True
    )

</fichier final>

Fournis un message de commit prenant en compte le diff et le fichier final.

```

</details>

---

## L'IA pour les workflows en équipe 

**Dernier pattern : utiliser l'IA pour automatiser des actions liées à la gestion événementiel du code**

- pre-commit : vérifier la conformité avant d'envoyer
- commit : préparer une pull request de qualité
- post-receive : analyser une pull request 

---

**L'idée générale est d'associer à ces événements des déclenchements d'action soit via des hooks Git, soit via des pipelines d'Intégration Continue.** 

L'idée n'est pas neuve : il y a longtemps que des équipes passent un linter et/ou un compilateur sur leur code avant de push le code (ex: Puppet).

---

### Solutions du Marché

**Les solutions open-source manquent aujourd'hui dans le domaine.**


   Solution | Description | Avantages | Lien |
 |----------|-------------|-----------|---|
 | **DeepCode** | Plateforme d'analyse de code basée sur l'IA | Détection des vulnérabilités, suggestions d'amélioration |[DeepCode](https://www.deepcode.ai/)
 | **CodeClimate** | Outil d'analyse de code et de revue | Intégration avec divers IDE, rapports détaillés | [CodeClimate](https://codeclimate.com/)
 | **SonarQube** | Plateforme de qualité de code | Analyse statique, détection des bugs et des vulnérabilités |[SonarQube](https://www.sonarqube.org/)
 | **Amazon CodeGuru** | Service de revue de code basé sur le machine learning | Intégration avec AWS, recommandations pour l'optimisation du code |[Amazon CodeGuru](https://aws.amazon.com/codeguru/)

---

**Il est très simple d'intégrer des solutions dans ses pipelines via le Github Marketplace.**

Sur Gitlab, d'autres outils sont disponibles comme CodeAnt or Codacy.

---


## Fonctions 

**L'IA au service des workflows permet d'automatiser certaines tâches afin de garantir une qualité soutenue au quotidien.**

---

### Garantir la qualité du code 

**Via l'analyse statique du Code, il est possible de s'assurer que le code reste :**

- compatible avec les standards de code du projet / de l'équipe ; 
- consistant en termes de perfomance.

--- 

**Les solutions comme SonarQube ou DeepCode savent remonter des défauts éventuels, qualifier les problèmes et assister dans leurs corrections.**

Par exemple SonarQube présente le concept de Quality Gate, qui permet de définir des critères de qualité pour chaque projet (ex: 80% de couverture des tests unitaires)

---

### Garantir la sécurité du code 

**L'autre aspect intéressant est la recherche de vulnérabilités dans le code.**

Des solutions comme DeepCode ou CodeGuru savent identifier les patterns problématiques comme les injections SQL ou les failles d'authentification, parmi tant d'autres.

---

**Comme d'habitude avec la sécurité tout dépend du modèle de menaces.**

Si votre code remplit des fonctions critiques et qu'il est exposé à des utilisateurs, ce type de solution peut vous éviter bien des problèmes.

---






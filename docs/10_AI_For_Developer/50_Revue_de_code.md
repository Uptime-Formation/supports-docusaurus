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

## L'IA pour les workflows en équipe et la qualité de code 



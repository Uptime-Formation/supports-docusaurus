---
title: TP - les volumes Docker
---

## Observer l'installation de Portainer


Si vous aviez déjà créé le conteneur Portainer, vous pouvez le relancer en faisant `docker start portainer`, sinon créez-le comme suit :

```shell
docker volume create portainer_data
docker run --detach --name portainer \
    -p 9000:9000 \
    -v portainer_data:/data \
    -v /var/run/docker.sock:/var/run/docker.sock \
    portainer/portainer-ce
```



- Visitez ensuite la page [http://localhost:9000](http://localhost:9000) pour accéder à l'interface.
- Créez votre user admin avec le formulaire.
- Explorez l'interface de Portainer.

- Supprimez le conteneur portainer et recréez le. Les données persistent-t-elles ?

- Supprimez le conteneur et recréez le sans le `-v portainer_data:/data`. Que remarque-t-on ?
- Supprimez le conteneur et recréez le sans le `-v /var/run/docker.sock:/var/run/docker.sock`. Que remarque-t-on ?


Remarque : pour que Portainer puisse fonctionner et contrôler Docker lui-même depuis l'intérieur du conteneur il est nécessaire de lui donner accès au socket de l'API Docker de l'hôte grâce au bind mount ci-dessus.

### Facultatif : utiliser `VOLUME` avec `microblog`


- Clonons le repo `microblog` ailleurs :

```shell
git clone https://github.com/uptime-formation/microblog/ --branch tp2-dockerfile microblog-volume
```

- Ouvrons ça avec VSCode : `codium microblog-volume`

- Lire le `Dockerfile` de l'application `microblog`.

Un volume Docker apparaît comme un dossier à l'intérieur du conteneur.
Nous allons faire apparaître le volume Docker comme un dossier à l'emplacement `/data` sur le conteneur.

- Pour que l'app Python soit au courant de l'emplacement de la base de données, ajoutez à votre `Dockerfile` une variable d'environnement `DATABASE_URL` ainsi (cette variable est lue par le programme Python) :

```Dockerfile
ENV DATABASE_URL=sqlite:////data/app.db
```

Cela indique que l'on va demander à Python d'utiliser SQLite pour stocker la base de données comme un unique fichier au format `.db` (SQLite) dans un dossier accessible par le conteneur. On a en fait indiqué à l'app Python que chemin de la base de données est :
`/data/app.db`

- Ajouter au `Dockerfile` une instruction `VOLUME` pour stocker la base de données SQLite de l'application.

Voici le `Dockerfile` complet :

```Dockerfile
FROM python:3.9-alpine

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

- Créez un volume nommé appelé `microblog_db`, et lancez un conteneur l'utilisant, créez un compte et écrivez un message.
- Vérifier que le volume nommé est bien utilisé en branchant un deuxième conteneur `microblog` utilisant le même volume nommé.

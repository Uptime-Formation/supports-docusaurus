---
title: "1.11 Dockerfile TP : conteneuriser une application flask"
pre: "<b>1.11 TP</b>"
weight: 11
---

## TP - Dockerfile pour une application web flask

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


## TP Finir le Dockerfile précédent (il manquait la CMD)


- Ajoutons la section de démarrage à la fin du Dockerfile, on va utuliser un script appelé `boot.sh` déjà présent dans le projet qu'on a cloné:

```Dockerfile
CMD ["./boot.sh"]
```

- Reconstruisez l'image et lancez un conteneur basé sur l'image en ouvrant le port `5000` avec la commande : `docker run -p 5000:5000 microblog`

- Naviguez dans le navigateur à l’adresse `localhost:5000` pour admirer le prototype microblog.

- Lancez un deuxième container cette fois avec : `docker run -d -p 5001:5000 microblog`

- Une deuxième instance de l’app est maintenant en fonctionnement et accessible à l’adresse `localhost:5001`

## Correction: le dockerfile final

<details><summary>correction:</summary>
<p>

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

</p>
</details>

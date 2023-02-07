---
title: Conteneurs Docker Créer Lister et Détruire
pre: "<b>1.06 </b>"
weight: 7
---
## Objectifs pédagogiques
  - Savoir utiliser les commandes stop, kill, delete, stats, prune 


## Manipuler un conteneur

- **Commandes utiles :** <https://devhints.io/docker>
- **Documentation `docker run` :** <https://docs.docker.com/engine/reference/run/>

Mentalité :
![](../assets/images/changingThings.jpg)
Il faut aussi prendre l'habitude de bien lire ce que la console indique après avoir passé vos commandes.

Avec l'aide du support et de `--help`, et en notant sur une feuille ou dans un fichier texte les commandes utilisées :

- Lancez simplement un conteneur Debian. Que se passe-t-il ?

{{% expand "Résultat :" %}}

```bash
docker run debian
# Il ne se passe rien car comme debian ne contient pas de processus qui continue de tourner le conteneur s'arrête
```

{{% /expand %}}

- Lancez un conteneur Debian (`docker run` puis les arguments nécessaires, cf. l'aide `--help`)n avec l'option "mode détaché" et la commande passée au conteneur `echo "Je suis le conteneur basé sur Debian"`. Rien n'apparaît. En effet en mode détaché la sortie standard n'est pas connectée au terminal.

- Lancez `docker logs` avec le nom ou l'id du conteneur. Vous devriez voir le résultat de la commande `echo` précédente.

{{% expand "Résultat :" %}}

```bash
docker logs <5b91aa9952fa> # n'oubliez pas que l'autocomplétion est activée, il suffit d'appuyer sur TAB !
=> Debian container
```

{{% /expand %}}


## Commandes Docker

- Le démarrage d'un conteneur est lié à une **commande**.

- Si le conteneur n'a pas de commande, il s'arrête dès qu'il a fini de démarrer

```bash
docker run debian # s'arrête tout de suite
```

- Pour utiliser une commande on peut simplement l'ajouter à la fin de la commande run.

```bash
docker run debian echo 'attendre 10s' && sleep 10 # s'arrête après 10s
```

---

### Stopper et redémarrer un conteneur

`docker run` créé un nouveau conteneur à chaque fois.

```bash
docker stop <nom_ou_id_conteneur> # ne détruit pas le conteneur
docker start <nom_ou_id_conteneur> # le conteneur a déjà été créé
docker start --attach <nom_ou_id_conteneur> # lance le conteneur et s'attache à la sortie standard
```


**NB:** On peut désigner un conteneur soit par le nom qu'on lui a donné, soit par le nom généré automatiquement, soit par son empreinte (toutes ces informations sont indiquées dans un `docker ps` ou `docker ps -a`). L'autocomplétion fonctionne avec les deux noms.

- Trouvez comment vous débarrasser d'un conteneur récalcitrant (si nécessaire, relancez un conteneur avec la commande `sleep 3600` en mode détaché).

{{% expand "Solution :" %}}

```
docker kill <conteneur>
```

{{% /expand %}}

- Tentez de lancer deux conteneurs avec le nom `debian_container`

{{% expand "Solution :" %}}

```
docker run -d --name debian_container debian sleep 500
docker run -d --name debian_container debian sleep 500
```

{{% /expand %}}

Le nom d'un conteneur doit être unique (à ne pas confondre avec le nom de l'image qui est le modèle utilisé à partir duquel est créé le conteneur).

- Créez un conteneur avec le nom `debian2`

```bash
docker run debian -d --name debian2 sleep 500
```

- Lancez un conteneur debian en mode interactif (options `-i -t`) avec la commande `/bin/bash` et le nom `debian_interactif`.
- Explorer l'intérieur du conteneur : il ressemble à un OS Linux Debian normal.

---

## Chercher sur Docker Hub

- Visitez [hub.docker.com](https://hub.docker.com)
- Cherchez l'image de Nginx (un serveur web), et téléchargez la dernière version (`pull`).

```bash
docker pull nginx
```

- Lancez un conteneur Nginx. Notez que lorsque l'image est déjà téléchargée le lancement d'un conteneur est quasi instantané.

```bash
docker run --name "test_nginx" nginx
```

Ce conteneur n'est pas très utile, car on a oublié de configurer un port exposé sur `localhost`.

- Trouvez un moyen d'accéder quand même au Nginx à partir de l'hôte Docker (indice : quelle adresse IP le conteneur possède-t-il ?).

{{% expand "Solution :" %}}

- Dans un nouveau terminal lancez `docker inspect test_nginx` (c'est le nom de votre conteneur Nginx). Cette commande fournit plein d'informations utiles mais difficiles à lire.

- Lancez la commande à nouveau avec `| grep IPAddress` à la fin. Vous récupérez alors l'adresse du conteneur dans le réseau virtuel Docker.

{{% /expand %}}

- Arrêtez le(s) conteneur(s) `nginx` créé(s).
- Relancez un nouveau conteneur `nginx` avec cette fois-ci le port correctement configuré dès le début pour pouvoir visiter votre Nginx en local.

```bash
docker run -p 8080:80 --name "test2_nginx" nginx # la syntaxe est : port_hote:port_container
```

- En visitant l'adresse et le port associé au conteneur Nginx, on doit voir apparaître des logs Nginx dans son terminal car on a lancé le conteneur en mode _attach_.
- Supprimez ce conteneur. NB : On doit arrêter un conteneur avant de le supprimer, sauf si on utilise l'option "-f".

---

On peut lancer des logiciels plus ambitieux, comme par exemple Funkwhale, une sorte d'iTunes en web qui fait aussi réseau social :

```bash
docker run --name funky_conteneur -p 80:80 funkwhale/all-in-one:1.0.1
```

Vous pouvez visiter ensuite ce conteneur Funkwhale sur le port 80 (après quelques secondes à suivre le lancement de l'application dans les logs) ! Mais il n'y aura hélas pas de musique dedans :(

_Attention à ne jamais lancer deux containers connectés au même port sur l'hôte, sinon cela échouera !_

- Supprimons ce conteneur :

```bash
docker rm -f funky_conteneur
```

### _Facultatif :_ Wordpress, MYSQL et les variables d'environnement

- Lancez un conteneur Wordpress joignable sur le port `8080` à partir de l'image officielle de Wordpress du Docker Hub
- Visitez ce Wordpress dans le navigateur

Nous pouvons accéder au Wordpress, mais il n'a pas encore de base MySQL configurée. Ce serait un peu dommage de configurer cette base de données à la main. Nous allons configurer cela à partir de variables d'environnement et d'un deuxième conteneur créé à partir de l'image `mysql`.

Depuis Ubuntu:

- Il va falloir mettre ces deux conteneurs dans le même réseau (nous verrons plus tarde ce que cela implique), créons ce réseau :

```bash
docker network create wordpress
```

- Cherchez le conteneur `mysql` version 5.7 sur le Docker Hub.

- Utilisons des variables d'environnement pour préciser le mot de passe root, le nom de la base de données et le nom d'utilisateur de la base de données (trouver la documentation sur le Docker Hub).

- Il va aussi falloir définir un nom pour ce conteneur

{{% expand "Résultat :" %}}

```bash
docker run --name mysqlpourwordpress -d -e MYSQL_ROOT_PASSWORD=motdepasseroot -e MYSQL_DATABASE=wordpress -e MYSQL_USER=wordpress -e MYSQL_PASSWORD=monwordpress --network wordpress mysql:5.7
```

{{% /expand %}}

- inspectez le conteneur MySQL avec `docker inspect`

- Faites de même avec la documentation sur le Docker Hub pour préconfigurer l'app Wordpress.
- En plus des variables d'environnement, il va falloir le mettre dans le même réseau, et exposer un port

{{% expand "Solution :" %}}

```bash
docker run --name wordpressavecmysql -d -e WORDPRESS_DB_HOST="mysqlpourwordpress:3306" -e WORDPRESS_DB_PASSWORD=monwordpress -e WORDPRESS_DB_USER=wordpress --network wordpress -p 80:80 wordpress
```

{{% /expand %}}

- regardez les logs du conteneur Wordpress avec `docker logs`

- visitez votre app Wordpress et terminez la configuration de l'application : si les deux conteneurs sont bien configurés, on ne devrait pas avoir à configurer la connexion à la base de données
- avec `docker exec`, visitez votre conteneur Wordpress. Pouvez-vous localiser le fichier `wp-config.php` ? Une fois localisé, utilisez `docker cp` pour le copier sur l'hôte.
<-- - (facultatif) Détruisez votre conteneur Wordpress, puis recréez-en un et poussez-y votre configuration Wordpress avec `docker cp`. Nous verrons ensuite une meilleure méthode pour fournir un fichier de configuration à un conteneur. -->

## Faire du ménage

Il est temps de faire un petit `docker stats` pour découvrir l'utilisation du CPU et de la RAM de vos conteneurs !

- Lancez la commande `docker ps -aq -f status=exited`. Que fait-elle ?

- Combinez cette commande avec `docker rm` pour supprimer tous les conteneurs arrêtés (indice : en Bash, une commande entre les parenthèses de "`$()`" est exécutée avant et utilisée comme chaîne de caractère dans la commande principale)

{{% expand "Solution :" %}}

```bash
docker rm $(docker ps -aq -f status=exited)
```

{{% /expand %}}

- S'il y a encore des conteneurs qui tournent (`docker ps`), supprimez un des conteneurs restants en utilisant l'autocomplétion et l'option adéquate

- Listez les images
- Supprimez une image
- Que fait la commande `docker image prune -a` ?

## Décortiquer un conteneur

- En utilisant la commande `docker export votre_conteneur -o conteneur.tar`, puis `tar -C conteneur_decompresse -xvf conteneur.tar` pour décompresser un conteneur Docker, explorez (avec l'explorateur de fichiers par exemple) jusqu'à trouver l'exécutable principal contenu dans le conteneur.



# Introspection de conteneur

- La commande `docker exec` permet d'exécuter une commande à l'intérieur du conteneur **s'il est lancé**.

- Une utilisation typique est d'introspecter un conteneur en lançant `bash` (ou `sh`).

```
docker exec -it <conteneur> /bin/bash
```

---

---
title: TP - Déployer une app PHP MYSQL et le déboguage
---

Dans cette partie, on se propose de déployer Nextcloud une application basée sur PHP /
Mysql, ce qui est un exemple classique d'application "dynamique" (c.f.
architecture LAMP).

Une telle installation implique typiquement les étapes suivantes :
- téléchargement de l'application et extraction dans le bon dossier
- installation de dépendances
- création de la base de donnée
- configuration du serveur web
- configuration de l'application
- test et finalisation de l'installation

Les instructions suivantes ne viennent pas de `/dev/urandom` : elles ont été
récupérées depuis le site officiel de Nextcloud (et aussi du script
d'installation de l'app YunoHost !).

- 8.1 - Télécharger l'archive de la dernière version de Nextcloud (c.f. lien
fourni sur Dismorphia). Décompresser l'archive à l'aide de `tar` et mettre son
contenu dans `/var/www/nextcloud`.

- 8.2 - Installer les dépendances de Nextcloud (c.f. liste fournie sur
Dismorphia). Vérifier qu'il y a bien un service `php7.4-fpm` et `mysql` (ou
`mariadb`) qui tourne désormais sur le serveur - à la fois via `systemctl` et
`ps`.

- 8.3 - Créez un utilisateur `nextcloud` et une base de donnée portant le même
nom. Pour ceci, il faut ouvrir une console mysql et utiliser les incantations
correspondantes (éventuellement, remplacez `password` par un vrai mot de passe)
(aussi : n'oubliez pas les `;` !)

```bash
$ mysql -u root
MariaDB [(none)]> CREATE USER 'nextcloud'@'localhost' 
                  IDENTIFIED BY 'password';
MariaDB [(none)]> CREATE DATABASE IF NOT EXISTS nextcloud;
MariaDB [(none)]> GRANT ALL PRIVILEGES ON nextcloud.*
                  TO 'nextcloud'@'localhost'
                  IDENTIFIED BY 'password';
MariaDB [(none)]> FLUSH privileges;
MariaDB [(none)]> quit
```

- 8.4 - Configurons maintenant Nextcloud pour utiliser la base de donnée qui
  vient d'être créée. Pour cela, rendez-vous dans `/var/www/nextcloud`.
  Assurez-vous qu'il existe un fichier `occ` dans ce dossier. Lancez ensuite
  la commande suivante (êtes-vous capable de comprendre le rôle de ses
  différents morceaux ?). Il vous faudra peut-être remplacer `password` par le
  mot de passe précédemment choisi.

```bash
$ php occ maintenance:install \
     --database      "mysql"     --database-name "nextcloud" \
     --database-user "nextcloud" --database-pass "password" \
     --admin-user    "admin"     --admin-pass    "password"
```

- 8.5 - Il nous faut aussi définir le domaine derrière lequel Nextcloud est hébergé :
éditez le fichier `config/config.php` de Nextcloud, et rajoutez votre nom de
domaine dans les "trusted domains". Ajoutez également le paramètre
`overwriteprotocol` avec la valeur `http`. (Pour ces deux manipulations, il
vous faudra essayer de deviner la syntaxe à partir du contenu déjà présent dans
le fichier ;))

- 8.6 - Configurons maintenant Nginx pour servir l'application Nextcloud. Pour
  cela, récupérer et étudiez le modèle de configuration (fourni sur Dismorphia).
  Il vous faudra ajouter ce modèle à votre configuration nginx, et remplacer 
  `__WEB_PATH__` et `__UNIX_FOLDER__` par des valeurs appropriée. (Ne remplacez
  pas toutes les occurrences à la main, utilisez un outil approprié !).
  Notez l'existence d'une ligne mentionnant `/var/run/php/php7.4-fpm.sock`. À
  votre avis, à quoi sert ce fichier et cette ligne ?

- 8.7 - Testez que la configuration nginx semble valide avec `nginx -t`,
  rechargez la configuration nginx et tentez d'accéder à votre application via
  un navigateur web. Si elle ne fonctionne pas correctement (c'est probable !),
  investiguez les logs d'erreur de nginx. Comparez les messages aux permissions
  de `/var/www/nextcloud`, et à l'utilisateur avec lequel tournent les processus
  `php-fpm`. Comment faut-il modifier les permissions pour que l'application 
  fonctionne correctement ?
  
- 8.8 - Une fois le problème résolu, tester que l'application fonctionne
  correctement et découvrir Nextcloud (téléversez des fichiers, créez des
  dossier, etc...). (Il est même possible d'installer une application Nextcloud
  sur votre smartphone pour synchroniser les fichiers !)
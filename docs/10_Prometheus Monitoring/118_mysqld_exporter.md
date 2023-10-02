---
title: TP - Mysqld exporter
draft: false
# sidebar_position: 6
---

<!-- - `docker run -it --net=host --rm mysql mysql -h 127.0.0.1 -P 3306 -uroot -pmy-secret-pw` -->

Lancer un conteneur mysql et se connecter au client à l'interieur:

- `docker run -d --net=host --rm -e MYSQL_ROOT_PASSWORD=unsecure --name mysql mysql`

- `docker exec -it mysql mysql -h 127.0.0.1 -P 3306 -uroot -punsecure`

Puis dans le prompt mysql:

- `mysql> CREATE USER 'prometheus'@'127.0.0.1' IDENTIFIED BY 'my-secret-prom-pw' WITH MAX_USER_CONNECTIONS 3;`

- `mysql> GRANT PROCESS, REPLICATION CLIENT, SELECT ON *.* TO 'prometheus'@'127.0.0.1';`

- créez le fichier `~/my.cnf` avec à l'intérieur:

```ini
[client]
user = prometheus
password = my-secret-prom-pw
host = 127.0.0.1
```

- Téléchargez l'exporter mysql sur la page de téléchargement prometheus puis lancez le.

- visitez la route de métrique pour vérifier le bon fonctionnement de l'exporteur

- Ajoutez un scraping de cet exporteur.
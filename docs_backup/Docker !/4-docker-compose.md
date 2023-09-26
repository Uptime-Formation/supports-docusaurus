---
title: 3.05 Déployer avec docker compose le fichier docker compose.yml
pre: "<b>3.05 </b>"
weight: 33
---

## Objectifs pédagogiques
  - Comprendre le format de fichier YAML
  - Savoir identifier les directives principales du fichier docker-compose.yml

# Docker Compose

**Nous avons pu constater que lancer plusieurs conteneurs liés avec leur mapping réseau et les volumes liés implique des commandes assez lourdes. Cela devient ingérable si l'on a beaucoup d'applications microservice avec des réseaux et des volumes spécifiques.**

Pour faciliter tout cela et dans l'optique d'**Infrastructure as Code**, Docker introduit un outil nommé **docker-compose** qui permet de décrire de applications multiconteneurs grâce à des fichiers **YAML**.

Pour bien comprendre qu'il s'agit au départ uniquement de convertir des options de commande Docker en YAML, un site vous permet de convertir une commande `docker run` en fichier Docker Compose : https://www.composerize.com/

Le code est sur https://github.com/docker/compose, docker-compose est un *fat binary* en go qui pèse seulement ~30 Mo.

---
## Le "langage" de Docker Compose

Documentation 
* [la documentation du langage (DSL) des compose-files](https://docs.docker.com/compose/compose-file/compose-file-v3/)
* `man docker-compose`
**N'hésitez pas à passer du temps à explorer les options et commandes de `docker-compose`.**

il est aussi possible d'utiliser des variables d'environnement dans Docker Compose : se référer au [mode d'emploi](https://docs.docker.com/compose/compose-file/#variable-substitution) pour les subtilités de fonctionnement


---

## Syntaxe

- Alignement ! (**2 espaces** !!)
- ALIGNEMENT !! (comme en python)
- **ALIGNEMENT !!!** (le défaut du YAML, pas de correcteur syntaxique automatique, c'est bête mais vous y perdrez forcément quelques heures !

- des listes (tirets)
- des paires **clé: valeur**
- Un peu comme du JSON, avec cette grosse différence que le JSON se fiche de l'alignement et met des accolades et des points-virgules
 
- **les extensions Docker et YAML dans VSCode vous aident à repérer des erreurs**
- Les erreurs courantes quotes, et deux-points :
```yaml
titre: Un exemple: on va avoir des soucis
titre: "Un exemple: on va avoir des soucis"
```

---

## Exemples de fichier Docker Compose

### Sans build : un wordpress sur le port 80

```yaml
services:
  wordpress:
    depends_on:
      - mysqlpourwordpress
    environment:
      - "WORDPRESS_DB_HOST=mysqlpourwordpress:3306"
      - WORDPRESS_DB_PASSWORD=monwordpress
      - WORDPRESS_DB_USER=wordpress
    networks:
    - wordpress
    ports:
      - "80:80"
    image: wordpress
    volumes:
      - wordpress_config:/var/www/html/

  mysqlpourwordpress:
    image: "mysql:5.7"
    environment:
      - MYSQL_ROOT_PASSWORD=motdepasseroot
      - MYSQL_DATABASE=wordpress
      - MYSQL_USER=wordpress
      - MYSQL_PASSWORD=monwordpress
    networks:
    - wordpress
    volumes:
      - wordpress_data:/var/lib/mysql/

networks:
  wordpress:

volumes:
  wordpress_config:
  wordpress_data:

```

### Avec build : un ruby on rails sur le port 80
Un deuxième exemple :


```yml
services:
  postgres:
    image: postgres:10
    environment:
      POSTGRES_USER: rails_user
      POSTGRES_PASSWORD: rails_password
      POSTGRES_DB: rails_db
    networks:
      - back_end
  redis:
    image: redis:3.2-alpine
    networks:
      - back_end
  rails:
    build: .
    depends_on:
      - postgres
      - redis
    environment:
      DATABASE_URL: "postgres://rails_user:rails_password@postgres:5432/rails_db"
      REDIS_HOST: "redis:6379"
    networks:
      - front_end
      - back_end
    volumes:
      - .:/app

  nginx:
    image: nginx:latest
    networks:
      - front_end
    ports:
      - 80:80
    volumes:
      - ./nginx.conf:/etc/nginx/conf.d/default.conf:ro

networks:
  front_end:
  back_end:
```


---

## Le workflow de Docker Compose

Les commandes suivantes sont couramment utilisées lorsque vous travaillez avec Compose. La plupart se passent d'explications et ont des équivalents Docker directs, mais il vaut la peine d'en être conscient·e :

- `build` reconstruit toutes les images créées à partir de Dockerfiles. La commande up ne construira pas une image à moins qu'elle n'existe pas, donc utilisez cette commande à chaque fois que vous avez besoin de mettre à jour une image (quand vous avez édité un Dockerfile). On peut aussi faire `docker-compose up --build`

- `up` démarre tous les conteneurs définis dans le fichier compose et agrège la sortie des logs. Normalement, vous voudrez utiliser l'argument `-d` pour exécuter Compose en arrière-plan.

- `run` fait tourner un conteneur pour exécuter une commande unique. Cela aura aussi pour effet de faire tourner tout conteneur décrit dans `depends_on`, à moins que l'argument `--no-deps` ne soit donné.

- `stop` arrête les conteneurs sans les enlever.

- `ps` fournit des informations sur le statut des conteneurs gérés par Compose.

- `logs` affiche les logs. De façon générale la sortie des logs est colorée et agrégée pour les conteneurs gérés par Compose.

- `down` détruit tous les conteneurs définis dans le fichier Compose, ainsi que les réseaux 

- `rm` enlève les contenants à l'arrêt. N'oubliez pas d'utiliser l'argument `-v` pour supprimer tous les volumes gérés par Docker.


<<<<<<<< HEAD:docs/bonus_docker/3-05-Déployer-avec-docker-compose-le-fichier-docker-compose.yml.md
---
========
## Usage non synchrone de docker-compose

On peut également exécuter des tâches une par une dans les conteneurs du docker-compose sans démarrer tous les conteneurs simultanéement. Comme par exemple pour une migration de base de donnée. Exemple : https://docs.funkwhale.audio/installation/docker.html#start-funkwhale-service

>>>>>>>> 20230106.kubernetes.supports.dopl.uk:docs/bonus_docker/4-docker-compose.md

## Visualisation des applications microservice complexes

Certaines applications microservice peuvent avoir potentiellement des dizaines de petits conteneurs spécialisés. 

**Le service devient alors difficile à lire dans le compose file.**

Il est possible de visualiser l'architecture d'un fichier Docker Compose en utilisant docker-compose-viz:

* https://github.com/pmsipilot/docker-compose-viz
* `sudo apt-get install graphviz`
* `docker run --rm -it --name dcv -v $(pwd):/input pmsipilot/docker-compose-viz render -m image docker-compose.yml`


Cet outil peut être utilisé dans un cadre d'intégration continue pour produire automatiquement la documentation pour une image en fonction du code.
---
title: Construire des images
weight: 1
---

# Conseils pour Optimiser les Builds Docker (Buildkit)

## Gardez Votre Image Docker Légère

L'une des choses les plus importantes à intégrer lorsque vous travaillez avec Docker est de maintenir la taille de votre image petite. Les images Docker peuvent rapidement atteindre plusieurs gigaoctets en taille. Alors qu'une image Docker de 1 Go en développement local est insignifiante en termes de consommation d'espace, les inconvénients deviennent apparents dans les pipelines CI/CD, où vous pourriez avoir besoin de récupérer une image spécifique plusieurs fois pour exécuter des tâches. Alors que la bande passante et l'espace disque sont bon marché, le temps ne l'est pas. Chaque minute supplémentaire ajoutée au temps de CI s'accumule pour devenir conséquente.

Par exemple, chaque minute ou deux de temps de construction supplémentaire qui peut être optimisée pourrait s'ajouter au fil du temps pour représenter des heures de temps perdues chaque année. Si votre pipeline CI s'exécute 50 fois par jour, cela équivaut à 90 000 à 180 000 secondes perdues par mois.

Cela signifie qu'une équipe de développement pourrait attendre pendant 60s x 50 (50 minutes) par jour pour obtenir des retours de la CI qui pourraient être évités.

Nombre de Builds Par Jour Temps de Construction Supplémentaire Temps Perdu Par An
50 60s (60s X 50) X 5 jours X 52 semaines = ~216h/an

Cependant, les économies de temps réelles ne proviennent pas vraiment d'une CI/CD plus rapide, mais plutôt d'une boucle de rétroaction plus rapide pour tous les développeurs. Les builds lents et donc les temps d'attente longs sont l'ennemi du maintien de la concentration.

Comment maintenez-vous la taille de votre image petite ?

- N'installez que les dépendances nécessaires à votre application et rien de plus.
- Utilisez une image de base légère. Ne choisissez pas Ubuntu comme image de base lorsque vous pouvez utiliser Alpine Linux, par exemple, qui est plus petite.
- Chaque layer que vous ajoutez augmente la taille de votre image. Essayez d'utiliser le moins de layers possible.
- N'installez pas de dépendances seulement pour les supprimer ensuite.
- Si vous devez installer des fichiers, utilisez les plus petits quand c'est possible.

# Lisibilité : organisez les Instructions Multi-lignes

Les lignes non triées sont difficiles à lire. Utiliser des commandes multilignes vous aidera à repérer rapidement les duplications d'arguments ou les dépendances inutiles qui pourraient être évitées si elles existent.

Deux exemples :

```Dockerfile

RUN apt-get update && apt-get install -y libsqlite4-dev aufs-tools automake build-essential curl dpkg-sig libcap-dev libsqlite3-dev mercurial reprepro cowsay ruby1.9.1 s3cmd=1.1.*

```

```Dockerfile

RUN apt-get update && apt-get install -y \
   aufs-tools \
   automake \
   build-essential
   curl \
   dpkg-sig \
   libcap-dev \
   libsqlite3-dev \
   mercurial \
   reprepro \
   cowsay \
   ruby1.9.1 \
   s3cmd=1.1.* \
   libsqlite4-dev
```

Les deux instructions Docker incluent des dépendances inutiles : cowsay. 

# Identifiez les Layers Mémorisables et Combinez-les

Le layer est l'un des attributs les plus intéressants et utiles de l'image Docker. Les images Docker sont construites en layers. Chaque layer correspond aux instructions du Dockerfile et représente un changement du système de fichiers de l'image entre l'état précédent avant l'exécution et l'état après l'exécution d'une commande. Docker met en cache les layers pour accélérer les temps de construction. Si rien n'a changé dans un layer (les instructions ou les fichiers), Docker réutilisera simplement les layers précédemment construites dans le cache au lieu de les reconstruire.

Cependant, avoir de multiples layers inutiles ajoute de la surcharge. Parce que les layers Docker sont des systèmes de fichiers, de nombreuses layers inutiles ont des implications en termes de performances. Étant donné que chaque commande RUN crée une nouvelle layer, il est plus efficace de créer un seul cache avec une seule commande RUN qui applique toutes les dépendances plutôt que de les diviser en plusieurs layers. Le temps gagné en identifiant les layers mémorisables et en les exploitant s'accumulera pour représenter une quantité de temps significative à long terme.

## Spécifiez Toujours une Étiquette (Tag)

Les exemples ci-dessous montrent comment vous pourriez potentiellement commencer un Dockerfile :

```Dockerfile
FROM node

FROM node:12.1
```

Il est recommandé de commencer un Dockerfile avec la deuxième option car elle fixe l'image de base à une version spécifique. Le premier exemple choisira automatiquement la dernière version. Le problème avec l'utilisation de dépendances non fixées est que la cohérence n'est pas garantie. Il peut y avoir un changement de rupture, etc. Nous épinglons principalement les versions pour la certitude et la visibilité. Lorsque vous avez une version épinglée de l'image de base, vous savez exactement quelle version est utilisée à tout moment.

Spécifier des étiquettes s'applique également à la construction d'images. Vous ne devriez jamais compter sur l'étiquette "latest" créée automatiquement et toujours être explicite à ce sujet.

## Créez une Image de Base Commune

Supposons que vous travailliez avec plusieurs microservices ayant beaucoup en commun. Peut-être qu'ils ont tous la même image de base et partagent certaines dépendances. Il est préférable de créer une image de base avec les composants partagés sur laquelle toutes les autres images peuvent être basées. Cela vous permettra d'appliquer des modifications communes en un seul endroit. De plus, vous bénéficierez également de la mise en cache des layers Docker. Étant donné que les services multiples partagent la même layer, Docker chargera la layer commune depuis le cache, ce qui vous fera gagner du temps de construction. Vous pouvez construire une fois et réutiliser la layer.

```Dockerfile

# Dockerfile pour le service A
FROM my-common-base-image:2.3.1 as base

```

Dans les autres services, vous pouvez utiliser l'image de base commune.

```Dockerfile
# Dockerfile pour le service B
FROM my-common-base-image:2.3.1 as base

WORKDIR /app
....
```

## Analysez Votre Image pour la sécurité

Les applications empaquetées dans des conteneurs ne sont pas immunisées contre les vulnérabilités de sécurité. Votre application sera rarement composée uniquement du code que vous avez écrit vous-même. Elle aura des dépendances et des bibliothèques écrites par d'autres personnes. Plus vous avez de dépendances, plus la surface d'attaque est large. Vous ne saurez peut-être jamais à quel point votre image Docker est vulnérable à moins de les scanner. Docker utilise le moteur Snyk pour fournir des services de balayage des vulnérabilités que vous pouvez utiliser avec la commande "docker scan" comme suit :

bash

docker scan NOM_IMAGE

Il n'y a pas de moyen plus simple d'imposer l'utilisation d'images Docker et de dépendances sécurisées que de les intégrer à votre pipeline CI/CD si vous travaillez au sein d'une grande équipe. L'utilisation de "docker scan" vous aidera à créer une application plus sécurisée.

## Utilisez l'Ordre des layers d'image à Votre Avantage

Les images Docker sont composées de layers empilées les unes sur les autres. Il y a une leçon importante à apprendre ici pour pouvoir exploiter le découpage des images à votre avantage. Une fois qu'une layer change, toutes les layers aval seront reconstruites. Le truc pour en tirer parti est de veiller à ce que les layers qui ne changent pas souvent restent en haut, et que celles qui changent fréquemment soient poussées en aval.

Considérez le Dockerfile ci-dessous. Nous pouvons l'optimiser en utilisant le découpage des images à notre avantage.

```Dockerfile

FROM node:14.14.0-alpine3.12 as base

WORKDIR /app

COPY . . # copier le code source, qui change souvent.

RUN npm install # vos dépendances ne changent pas très souvent
```

Les dépendances de l'application ne changent pas aussi souvent que le code source. Le code sur lequel vous travaillez activement changera plusieurs fois à mesure que vous ajouterez des fonctionnalités. Pour éviter que la layer des dépendances ne soit reconstruite à chaque changement de code, vous pouvez réorganiser les instructions du Dockerfile. Les dépendances devraient être construites en tant que layer distincte, poussées en haut, et construites avant de copier le code source qui change fréquemment, comme suit :

```Dockerfile

FROM node:14.14.0-alpine3.12 as base

WORKDIR /app

COPY package*.json ./
RUN npm install # installer les dépendances, qui changent rarement avant de copier votre code source

COPY ... # copier votre code source, qui change le plus, dans la layer supérieure
```

## Les Builds multistage


## N'oubliez Pas les Instructions LABEL et EXPOSE

Docker comprend également un ensemble d'instructions comme EXPOSE et LABEL qui faciliteront votre vie et celle des personnes travaillant avec vos images. Si votre conteneur expose un port, soyez explicite à ce sujet et précisez ce qu'il expose. Enfin, utilisez des étiquettes (labels) pour rendre vos images plus descriptives.

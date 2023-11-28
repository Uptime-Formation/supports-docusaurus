---
title: "Configurer une application conteneurisée"
---

<!-- ## Objectifs pédagogiques
  - Comprendre les variables d'environnement d'un process
  - Savoir utiliser la directive ENV dans un Dockerfile
  - Savoir passer des variables d'environnement à un conteneur -->

<!-- --- -->

## Les variables d'environnement 

> Analogie : Une commande de restauration à livrer.   
> La fiche du client affiche des informations qui lui sont spécifiques.  
> Par exemple son adresse, pas d'anchois dans les pizzas, intolérance au Gluten.
> Pour une même commande, le résultat sera différent car le contexte est différent.

Les variables d'environnement UNIX sont des variables dont les valeurs sont définies en dehors du code d'une application.

Les variables d'environnement sont constituées de paires de noms et de valeurs, et vous pouvez en créer autant que vous le souhaitez pour qu'elles soient disponibles à titre de référence à un moment donné.

<!-- --- -->

**Tout process a généralement des variables d'environnement.** 

```shell
env
sudo cat /proc/self/environ | tr "\0" "\n"
```

**Avancé** : En remplaçant `self` par un `pid` vous pouvez voir les variables d'environnement de tout process.

<!-- --- -->

Les variables d'environnement sont des variables "shell", elles ont toujours la forme

```shell
VAR=<value>
```

On les crée avec la commande shell `export` et la commande `env` sert à les afficher et les gérer.


```shell
env -i sh -c "env"
env -i sh -c "export VAR=VALUE; printenv"
```

<!-- --- -->

**Les variables d'environnement sont une façon recommandée de configurer vos applications Docker.**

Elles permettent une configuration "au _runtime_".

## Instruction `ENV`

```shell
ENV <key>=<value> <key2>=<value2>
ENV <key> <value>
```

<!-- --- -->

**On peut utiliser des variables d'environnement dans les Dockerfiles. La syntaxe est `${...}`.*

Exemple :
```Dockerfile
FROM busybox
ENV DEST=/opt
WORKDIR ${DEST}   # WORKDIR /opt
ADD . $DEST       # ADD . /opt
COPY \$DEST /srv # COPY $DEST /srv
```

C'est un bon moyen de définir une seule fois une information redondante dans le Dockerfile (ex: un tag).

Se référer au [mode d'emploi](https://docs.docker.com/engine/reference/builder/#environment-replacement) pour la logique plus précise de fonctionnement des variables.

<!-- --- -->

## En ligne de commande 

**On peut également définir les variables d'environnement en ligne de commande.**

```shell
docker run --env VAR=VALUE ubuntu env
```

<!-- --- -->

# Impact sur le code 

**Une fois admis qu'il faut utiliser des variables d'environnement pour configurer un service, il faut l'intégrer aux applications.**

Absolument tous les langages de programmation offrent des moyens très simples de lire ces variables.

En PHP, vous pouvez accéder aux variables d'environnement à l'aide de la fonction getenv().
```php
  $maVar = getenv('MA_VAR');
```

En Python, vous pouvez accéder aux variables d'environnement à l'aide du module os.
```python
import os
maVar = os.environ.get('MA_VAR')
```

En Java, vous pouvez accéder aux variables d'environnement à l'aide de la classe System.

```java
String myVar = System.getenv("MY_VAR");
```
Dans Node.js, vous pouvez accéder aux variables d'environnement à l'aide de l'objet process.env.
```javascript 
const myVar = process.env.MY_VAR;
```

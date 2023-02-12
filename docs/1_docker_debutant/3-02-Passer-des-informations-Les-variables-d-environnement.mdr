---
title: Passer des informations Les variables d'environnement
pre: "<b>3.02 </b>"
weight: 30
---

## Objectifs pédagogiques
  - Comprendre les variables d'environnement d'un process
  - Savoir utiliser la directive ENV dans un Dockerfile
  - Savoir passer des variables d'environnement à un conteneur

---

## Instruction `ENV`

- Une façon recommandée de configurer vos applications Docker est d'utiliser les variables d'environnement UNIX, ce qui permet une configuration "au _runtime_".

---

## Les variables
On peut utiliser des variables d'environnement dans les Dockerfiles. La syntaxe est `${...}`.
Exemple :
```Dockerfile
FROM busybox
ENV FOO=/bar
WORKDIR ${FOO}   # WORKDIR /bar
ADD . $FOO       # ADD . /bar
COPY \$FOO /quux # COPY $FOO /quux
```

Se référer au [mode d'emploi](https://docs.docker.com/engine/reference/builder/#environment-replacement) pour la logique plus précise de fonctionnement des variables.


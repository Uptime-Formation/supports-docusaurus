---
title: "TP : Pour commencer, un Dockerfile minimal"
---

<!-- ## Objectifs pédagogiques
  - Reconnaître les différentes étapes d'un Dockerfile
  - Savoir utiliser la commande build -->
  
Pour continuer sur notre analogie de la cuisine, le Dockerfile est une recette. 
C'est une suite d'instructions qui permet d'obtenir un plat cuisiné. 
On va travailler sur une recette très simple de Dockerfile, un **Hello World.**

## La composition d'un Dockerfile minimal

- Le **Dockerfile** est un fichier procédural qui permet de décrire l'installation d'un logiciel (la configuration d'un container) en enchaînant des instructions Dockerfile (en MAJUSCULE).

- Exemple:

```Dockerfile
FROM alpine:3.18

RUN echo "echo Hello World" > /boot.sh

# run the application
CMD ["/bin/sh", "boot.sh"]
```

**On va immédiatement contruire une image avec ce Dockerfile.**

1. Créer un nouveau dossier dans son IDE
2. Créer dans ce dossier un fichier nommé Dockerfile
3. Y copier le contenu du fichier
4. Lancer dans le dossier la commande

```
docker build -t minimal . 
```

5. Lancer l'image docker nommée "minimal"

```
docker run minimal
hello World
```

## Arrêtons nous pour bien compdrendre cette base

Pour afficher "Hello World", il nous a fallu au moins 2 instructions 

1. le système de base dans lequel on veut lancer le process
2. un fichier de script shell ajouté qui afficher hello world
2. la commande du process qu'on veut lancer ici le script `boot.sh`

La commande `build` est l'opération qui "prépare le plat", et le met dans un format "consommable".  

La commande pour est :

```shell
docker build [-t <tag:version>] [-f <chemin_du_dockerfile>] <contexte_de_construction>
```

Lors de la construction, Docker télécharge l'image de base. On constate plusieurs téléchargements en parallèle.

Il lance ensuite la séquence des instructions du Dockerfile.

Observez l'historique de construction de l'image avec `docker image history <image>`

**Il lance ensuite la série d'instructions du Dockerfile et indique un *hash* pour chaque étape.**
 
C'est le *hash* correspondant à un *layer* de l'image


---
title: "Dockerfile : un langage spécifique"
pre: "<b>1.08 </b>"
weight: 9
---
## Objectifs pédagogiques
  - Reconnaître les différentes étapes d'un Dockerfile
  - Savoir utiliser la commande build
  
## Analogie 

Pour continuer sur notre analogie de la cuisine, le Dockerfile est une recette. 

C'est une suite d'instructions qui permet d'obtenir un plat cuisiné. 

## La composition d'un Dockerfile minimal

- Le **Dockerfile** est un fichier procédural qui permet de décrire l'installation d'un logiciel (la configuration d'un container) en enchaînant des instructions Dockerfile (en MAJUSCULE).

- Exemple:

```Dockerfile
# our base image
FROM alpine:3.5

# run the application
CMD ["sh", "-c", "echo Hello World"]
```

**On va immédiatement contruire une image avec ce Dockerfile.**

1. Créer un nouveau dossier dans son IDE
2. Créer dans ce dossier un fichier nommé Dockerfile
3. Y copier le contenu du fichier
4. Lancer dans le dossier la commande
```
# docker build  . -t minimal 
```
5. Lancer l'image docker nommée "minimal"
```
# docker run minimal
hello World
```

## Faisons une pause 

**Ceci est une suite d'opérations importantes**

### 2 instructions suffisent

Pour afficher "Hello World", il nous faut au moins ces 2 informations 

1. le système de base dans lequel on veut lancer le process
2. la commande du process qu'on veut lancer ici `sh -c "echo Hello World"`

Q: Que se passerait-il si on ne donnait pas la 2e commande ?

## Documentation

- Il existe de nombreuses instructions dans la documentation officielle : [https://docs.docker.com/engine/reference/builder/](https://docs.docker.com/engine/reference/builder/)

**Les autres instructions qu'on peut ajouter vont permettre d'aller plus loin qu'un simple Hello World.**

### build = Dockerfile -> Image

La commande duild est l'opération qui "prépare le plat", et le met dans un format "consommable".  

La commande pour est :

```bash
docker build [-t <tag:version>] [-f <chemin_du_dockerfile>] <contexte_de_construction>
```

Lors de la construction, Docker télécharge l'image de base. On constate plusieurs téléchargements en parallèle.

Il lance ensuite la séquence des instructions du Dockerfile.

Observez l'historique de construction de l'image avec `docker image history <image>`

**Il lance ensuite la série d'instructions du Dockerfile et indique un *hash* pour chaque étape.**
 
C'est le *hash* correspondant à un *layer* de l'image

---

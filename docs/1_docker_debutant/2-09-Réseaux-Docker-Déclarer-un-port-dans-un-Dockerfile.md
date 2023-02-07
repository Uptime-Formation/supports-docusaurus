---
title: Réseaux Docker Déclarer un port dans un Dockerfile
pre: "<b>2.09 </b>"
weight: 22
---
## Objectifs pédagogiques
  - Comprendre le mode de fonctionnement des ports dans Linux
  - Savoir utiliser la commande EXPOSE


### Exposer le port

- Ajoutons l'instruction `EXPOSE 5000` pour indiquer à Docker que cette app est censée être accédée via son port `5000`.
- NB : Publier le port grâce à l'option `-p port_de_l-hote:port_du_container` reste nécessaire, l'instruction `EXPOSE` n'est là qu'à titre de documentation de l'image.


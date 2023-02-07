---
title: Plan de la Formation
pre: "<b>1.01 </b>"
weight: 2
---

## Objectifs pédagogiques 
  - Présenter tous les objectifs pédagogiques
  - Évaluer les parties les plus difficiles

## Les grandes orientations pédagogiques
- Exposer les évolutions du monde des conteneurs et du déploiement automatisé
- Exposer l'état du secteur des conteneurs et les alternatives (docker is dead?)
- Associer au maximum la pratique aux contenus théoriques avec des objectifs simples et clairs
- Fournir des postes individuels virtualisés


## 3 jours de formation


* Jour 1: **Pourquoi Docker**
* Jour 2: **Docker en pratique**
* Jour 3: **Déployer avec Docker**

<--
# Day 1: Pourquoi Docker
0.    Introduction/ Questions / niveaux des participants
  - Répondre aux questions préalables (éventuelles réticences comprises)
  - Anticiper les problèmes de niveaux différents au sein du groupe / faire des paires
0.    Plan de la formation
  - Présenter tous les objectifs pédagogiques
  - Évaluer les parties les plus difficiles
0.    Docker : premiers pas avec Docker Desktop
  - Connaître les outils permettant d'interagir avec docker
  - Lancer son premier conteneur
0.    Point système : qu'est-ce qu'un process ?
  - Connaître le rôle et les attributs d'un process Linux
  - Identifier les process docker dans la liste des process du système
0.    Docker : premiers pas avec la ligne de commande
  - Connaître les outils permettant d'interagir avec docker
  - Lancer un conteneur avec des passages d'arguments
0.    Pourquoi Docker : les pratiques de déploiement
  - Connaître l'histoire des pratiques devops
  - Comprendre les pratiques d'IAC et d'automatisation
0.    CRUD les conteneurs docker
  - Utiliser les commandes run, ps, delete
0.    Pourquoi Docker : Les Dockerfiles
  - Savoir comparer un Dockerfile à d'autres solutions d'IAC (Ansible, puppet)
  - Analyser les avantages et inconvénients de cette solution
0.    Dockerfiles Un langage spécifique
  - Comprendre l'intérêt d'une "recette" de déploiement
  - Reconnaître les différentes étapes d'un Dockerfile
  - Savoir utiliser la commande build
0.    Dockerfiles Les systèmes de base
  - Savoir trouver et choisir les systèmes de base
  - Savoir utiliser les commandes BASE ... AS ...
0.    Dockerfiles Les commandes UNIX de configuration et d'ajout de fichiers
  - Savoir ajouter des fichiers au système
  - Savoir ajouter des packages, des utilisateurs, etc.
  - Savoir utiliser les commandes RUN, ADD, COPY, WORKSPACE
0.    Dockerfiles Les commandes de démarrage
  - Savoir lancer un process dans un container Docker
  - Savoir utiliser les commandes CMD, ENTRYPOINT
0.    Dockerfiles Les build multistage
  - Savoir compiler un binaire dans un builder
  - Savoir utiliser les commandes COPY ... FROM ...
  - Savoir créer une image
  
0. 0_intro.md
1_cours_manipulation-de-conteneurs.md
1_tp_manipulation-de-conteneurs.md

2-cours_les-dockerfiles.md
2-multistage-build-Dockerfile
2-tp_les-dockerfiles.md


# Day 2: Docker en pratique

0.    Docker en pratique Les strates du système de fichier
  - Connaître l'histoire qui mène à ce système de couche
  - Comprendre les avantages et inconvénients de ce système
0.    Les images Docker Analyse d'une récupération
  - Identifier les strates qui composent une image docker
  - Comprendre comment les étapes du Dockerfile commandent les couches
0.    Les images Docker Créer Lister Détruire
  - Savoir utiliser les commandes image de base (pull, ls, history, inspect, tag, prune)
  - Savoir identifier les images
  - Connaître les bonnes pratiques (Dockerfile, nettoyage, etc.)
0.    Les images Docker Les registries
  - Comprendre le fonctionnement des registries
  - Savoir installer un registry local
  - Savoir utiliser la commande push
0.    Docker en pratique Pourquoi les conteneurs
  - Connaître l'histoire des conteneurs
  - Comprendre les raisons du développement des conteneurs
  - Identifier les problèmes réseau et persistance associés
0.    Volumes Docker Déclarer des volumes dans un Dockerfile
  - Savoir utiliser la commande VOLUME
  - Comprendre la persistance de données
0.    Volumes Docker Monter des fichiers en ligne de commande
  - Comprendre le montage dans les systèmes de fichier Linux
  - Savoir monter un volume dans un conteneur Docker
0.    Volumes Docker Créer Lister Détruire
  - Savoir utiliser les commandes volume (create, ls, rm, prune)
  - Savoir monter des volumes de persistance locaux et distants

3-tp_volumes.md
0.    Réseaux Docker Déclarer un port dans un Dockerfile
  - Comprendre le mode de fonctionnement des ports dans Linux
  - Savoir utiliser la commande EXPOSE
0.    Réseaux Docker Interactions avec le système parent
  - Comprendre le mode de fonctionnement des bridge Linux et le NAT
  - Savoir inspecter la couche réseau d'un conteneur Docker
0.    Réseaux Docker Créer Lister Détruire
  - Savoir utiliser les commandes volume (create, ls, rm, connect, prune)
  - Savoir lancer un conteneur Docker en le connectant à un réseau
  - Savoir faire communiquer deux conteurs Docker
0.    Les réseaux
3_volumes-et-reseaux.md
tp3-elie-réseau-volumes.md
3_volumes-et-reseaux.md
3-tp_reseaux.md
tp3-elie-réseau-volumes.md

# Day 3: Déployer avec Docker
0.    Déployer avec Docker L'évolution de l'écosystème des conteneurs
  - comprendre les composants nécessaires pour un système de conteneurs
  - connaître les alternatives à Docker
0.    Passer des informations Les variables d'environnement
  - Comprendre les variables d'environnement d'un process
  - Savoir utiliser la directive ENV dans un Dockerfile
  - Savoir passer des variables d'environnement à un conteneur
0.    Passer des informations Les secrets Docker
  - Comprendre les dangers d'exposer les secrets
  - Comprendre les secrets Docker
  - Savoir utiliser les secrets Docker
0.    Déployer avec Docker L'évolution de l'écosystème des orchestrateurs
  - Comprendre les enjeux qui mènent à de l'orchestration de conteneurs
  - Connaître les différentes solutions actuelles
0.    Déployer avec docker compose le fichier docker-compose.yml
  - Comprendre le format de fichier YAML
  - Savoir identifier les directives principales du fichier docker-compose.yml
0.    Déployer avec docker compose  créer et lancer ses applications
  - Savoir lancer une application multi-conteneur avec docker compose
  - Savoir créer une application multi-conteneur
4-docker-compose.md
4-tp_docker-compose.md
0.    Déployer avec docker Utiliser un reverse proxy
  - Connaître le fonctionnement d'un reverse proxy
  - Savoir utiliser Traefik pour docker

0.    Les orchestrateurs : aperçu de K8S
0.    Déployer avec Docker Les grandes lignes sécurité
  - Connaître les méthodes de conteneurisation
  - Connaître les bonnes pratiques
  0_intro-les-containers.md
0.    Déployer avec Docker Observabilité des conteneurs
-->
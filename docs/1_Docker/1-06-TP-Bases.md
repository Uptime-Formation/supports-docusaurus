---
title: "1/2 TP Fondamentaux Docker"
pre: "<b>1.07 </b>"
weight: 8
---

### Objectif 

**On va installer un serveur web dans une instance Docker.**

On va donc télécharger une image Debian de base, explorer son contenu, démarrer et arrêter le conteneur, le lancer en mode daemon, installer un serveur web, et observer son fonctionnement.

### Étapes 

- **Action** : Télécharger l'image Docker Python/Debian de base `python:3.11-slim-bullseye`  
  **Observation** : L'image apparaît dans la liste des images locales via la commande `docker images`.


- **Action** : Lancer un conteneur en mode interactif basé sur l'image.  
  **Observation** : Le conteneur est actif, et les commandes peuvent être exécutées dans son terminal.


- **Action** : Arrêter puis redémarrer le conteneur.  
  **Observation** : Le conteneur est arrêté (`docker ps` ne le montre plus), puis redémarré (`docker ps` le montre à nouveau).


- **Action** : Lancer le conteneur en mode daemon (en arrière-plan).  
  **Observation** : Le conteneur tourne en arrière-plan (`docker ps` montre le conteneur en cours d'exécution).


- **Action** : Utiliser la commande `ps` sur la machine hôte pour vérifier le processus Docker.  
  **Observation** : Voir le processus Docker correspondant à l'instance en cours d'exécution.


- **Action** : Installer un serveur web (comme Nginx) dans le conteneur.  
  **Observation** : Le serveur web s'installe correctement et démarre sans erreurs.


- **Action** : Démarrer le serveur Nginx dans le conteneur.  
  **Observation** : Le serveur web fonctionne, et les logs de Nginx confirment qu'il est opérationnel.


**Avancé :**  

- Explorer les autres images Python et Debian sur le Docker Hub. Quelles sont les différences?   
- Utiliser `docker exec` pour accéder au conteneur en arrière-plan et vérifier le statut du serveur web.  
- Comment accéder à la page d'accueil du serveur web ? Depuis l'instance Docker ? Depuis la machine hôte ?
- Comment modifier la page d'accueil du serveur web ? Comment le faire rapidement ? Quel sera le problème ?  
- Configurer le conteneur pour redémarrer automatiquement en cas de panne (`--restart` policy).  
- Explorer les différents logs du serveur web et du conteneur pour comprendre les interactions.



### Solution 

<details><summary>Afficher</summary>

- Télécharger l'image : `docker pull python:3.11-slim-bullseye`  
- Lancer un conteneur interactif : `docker run -it python:3.11-slim-bullseye bash`  
- Arrêter le conteneur : `docker stop <container_id>`  
- Redémarrer le conteneur : `docker start <container_id>`  
- Lancer le conteneur en mode daemon : `docker run -d docker run -it python:3.11-slim-bullseye bash`  
- Vérifier le processus Docker sur la machine hôte : `ps aux | grep docker`  
- Accéder au conteneur en cours d'exécution : `docker exec -it <container_id> bash`  
- Installer Nginx dans le conteneur : `apt-get update && apt-get install -y nginx`  
- Démarrer Nginx dans le conteneur : `service nginx start`

</details>
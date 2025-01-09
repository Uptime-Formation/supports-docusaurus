---
title: "TP Fondamentaux Docker"
weight: 8
---

### Objectif 

**On va installer un serveur web dans une instance Docker.**

On va donc télécharger une image Debian de base, explorer son contenu, démarrer et arrêter le conteneur, le lancer en mode daemon, installer un serveur web, et observer son fonctionnement.

### Étapes 

- **Action** : Télécharger l'image Docker de base `ubuntu:24-04`  
  **Observation** : L'image apparaît dans la liste des images locales via la commande `docker images`.

- **Action** : Lancer un nouveau conteneur nommé `mycontainer` en mode daemon (en arrière-plan) avec une commande d'instance Docker  `tail -f /dev/null`.  
  **Observation** : Le conteneur tourne en arrière-plan (`docker ps` montre le conteneur en cours d'exécution).

- **Action** : Arrêter le conteneur, puis le redémarrer.  
  **Observation** : Le conteneur est arrêté (`docker ps` ne le montre plus), puis redémarré (`docker ps` le montre à nouveau).

- **Action** : Utiliser la commande `ps` sur la machine hôte pour vérifier le processus Docker.  
  **Observation** : Voir le processus Docker correspondant à l'instance en cours d'exécution.
- 
- **Action** : Accéder au conteneur en cours d'exécution.  
  **Observation** : Utillisez la commande `docker exec -it ...`

- **Action** : Installer les packages `nginx` et `curl` dans le conteneur avec `apt update && apt install nginx curl`.  
  **Observation** : Le serveur web s'installe correctement.

- **Action** : Démarrer le serveur Nginx dans le conteneur avec `service nginx start`.  
  **Observation** : Le serveur web fonctionne, et les logs de Nginx confirment qu'il est opérationnel.

- **Action** : Faire un appel http au serveur nginx depuis l'intérieur du conteneur avec `curl http://localhost`.  
  **Observation** : La page web par défaut de nginx apparaît.


- **Action** : Vérifier que les logs de nginx situés dans le dossier `/var/log/nginx` du conteneur sont bien remplis.  
  **Observation** : le fichier `access.log` contient une entrée relative à curl.


**Avancé :**  

- Que donne `docker logs mycontainer` ? Pourquoi ? 
- Utiliser `docker exec` pour accéder au conteneur en arrière-plan et vérifier le statut du serveur web.  
- Comment accéder à la page d'accueil du serveur web depuis la machine hôte ?
- Comment modifier la page d'accueil du serveur web ? Comment le faire rapidement ? Quel sera le problème ?  
- Configurer le conteneur pour redémarrer automatiquement en cas de panne (`--restart` policy).  



### Solution 

<details><summary>Afficher</summary>

- Télécharger l'image : `docker pull ubuntu:24.04`  
- Lancer le conteneur en mode daemon : `docker run --name mycontainer -d ubuntu:24.04 tail -f /dev/null`  
- Arrêter le conteneur : `docker stop mycontainer`  
- Redémarrer le conteneur : `docker start mycontainer`  
- Vérifier le processus Docker sur la machine hôte : `ps aux | grep docker`  
- Accéder au conteneur en cours d'exécution : `docker exec -it mycontainer bash`  
- Installer les packages dans le conteneur : `apt-get update && apt-get install -y nginx curl procps`
- Démarrer Nginx dans le conteneur : `service nginx start`
- Utiliser curl pour faire un appel HTTP depuis le conteneur : `curl http://localhost`
- Observer les logs dans le conteneur : `cat /var/log/nginx/access.log` 

</details>
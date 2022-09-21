---
title: "TP6 - Orchestration avec Swarm"
draft: true
---

## Orchestration avec Docker Swarm

- Cloner l'application exemple ici : [https://gitlab.com/e-lie/getstarted_docker.git](https://gitlab.com/e-lie/getstarted_docker.git)

- Créez une clé ssh et mettez la signature publique ici (avec votre nom): [pad](https://quotidien.framapad.org/p/ssh-pubkey-sharing-442)

- Récupérez un token digitalocean pour créer des machines dans le Cloud.

- Suivez le [guide Docker de découverte de Swarm à partir de la partie 3](https://docs.docker.com/get-started/part3/) sauf pour la partie de création des machines ou vous utiliserez:

```bash
 docker-machine create  --driver digitalocean \
      --digitalocean-ssh-key-fingerprint <SSHKey_id> \
      --digitalocean-access-token <token_api> \
      <nom machine>
```

- Le reste peut être poursuivi de façon presque identique (attention l'user ssh est root).
- Une fois le tutoriel terminé ajoutez un noeud worker supplémentaire.
- Scalez la stack en modifiant les replicats.
- Trouvez comment promouvoir(promote) un worker en manager
- Puis déchoir(demote) le manager pour le sortir du cluster (drain) : `docker node update --availability drain <node-name>`

- Comment faire en production pour gérer la configuration de base des machines finement ? Déployer et provisionner les machines avec terraform et ansible par exemple puis utiliser le driver generic pour les ajouter à docker-machine.
- Comment ne pas exposer les ports de tous nos hôtes à tous l'internet ?

## Installons portainer

Portainer est une interface web de base pour gérer un cluster docker.

```bash
docker service create \
      --name portainer \
      --publish 9000:9000 \
      --constraint 'node.role == manager' \
      --mount type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
      portainer/portainer-ce \
      -H unix:///var/run/docker.sock
```

- Listez les services
- Inspectez le service portainer avec l'option --pretty
- Ouvrez la page avec `firefox http://$(docker-machine ip <machine_manager>):9000`

# Installer un loadbalancer HAProxy

- [https://github.com/docker/dockercloud-haproxy/tree/master](https://github.com/docker/dockercloud-haproxy/tree/master)

## Déployons du nginx et des journaux distribués avec la stack ELK

On se propose ici d'essayer de déployer plusieurs conteneurs nginx.

- A partir de cette [stack d'exemple](https://discuss.elastic.co/t/nginx-filebeat-elk-docker-swarm-help/130512) trouvez comment installer `filebeat` pour récupérer les logs de nginx et les envoyer à un elasticsearch. (décrire sur papier comment faire avant).
- Ajoutez un elasticsearch et un kibana pour explorer nos logs.

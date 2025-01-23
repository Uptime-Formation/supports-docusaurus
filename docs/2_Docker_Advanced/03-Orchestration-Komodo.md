---
title:  "Orchestrateurs - Komodo" 
weight: 6
---

# Komodo

## Déploiement du cluster

### Déploiement du serveur 

Installer le serveur  Komodo

```shell

wget -P komodo https://raw.githubusercontent.com/mbecker20/komodo/main/compose/postgres.compose.yaml
wget -P komodo https://raw.githubusercontent.com/mbecker20/komodo/main/compose/compose.env
docker compose -p komodo -f komodo/postgres.compose.yaml --env-file komodo/compose.env up -d

```

Explorer l'interface sur 

http://<ip.du.ser.veur>:9120

### Ajout de noeuds Komodo client 

**Créer un docker compose sur le client**

```yaml

# File: compose-komodo-client.yml
services:
  periphery:
    image: ghcr.io/mbecker20/periphery:latest
    # image: ghcr.io/mbecker20/periphery:latest-aarch64 # use for arm support
    labels:
      komodo.skip: # Prevent Komodo from stopping with StopAllContainers
    logging:
      driver: local
    ports:
      - 8120:8120
    volumes:
      ## Mount external docker socket
      - /var/run/docker.sock:/var/run/docker.sock
      ## Allow Periphery to see processes outside of container
      - /proc:/proc
      ## use self signed certs in docker volume, 
      ## or mount your own signed certs.
      - ssl-certs:/etc/komodo/ssl
      ## manage repos in a docker volume, 
      ## or change it to an accessible host directory.
      - repos:/etc/komodo/repos
      ## manage stack files in a docker volume, 
      ## or change it to an accessible host directory.
      - stacks:/etc/komodo/stacks
      ## Optionally mount a path to store compose files
      # - /path/to/compose:/host/compose
    environment:
      ## Full list: `https://github.com/mbecker20/komodo/blob/main/config/periphery.config.toml`
      ## Configure the same passkey given to Komodo Core (KOMODO_PASSKEY)
      PERIPHERY_PASSKEYS: a_random_passkey # Alt: PERIPHERY_PASSKEYS_FILE
      ## Adding IP here will ensure calling IP is in the list. (optional)
      PERIPHERY_SSL_ENABLED: false
      ## If the disk size is overreporting, can use one of these to 
      ## whitelist / blacklist the disks to filter them, whichever is easier.
      ## Accepts comma separated list of paths.
      ## Usually whitelisting /etc/hostname gives correct size.
      PERIPHERY_INCLUDE_DISK_MOUNTS: /etc/hostname
      # PERIPHERY_EXCLUDE_DISK_MOUNTS: /snap,/etc/repos

volumes:
  ssl-certs:
  repos:
  stacks:
```

**Lancer docker compose sur le client**

```shell

docker compose -f compose-komodo-client.yml up -d 
docker compose -f compose-komodo-client.yml logs 

```

**Ajouter le client dans l'interface du serveur**

http://<ip.du.ser.veur>:9120/servers

Créer un nouveau serveur avec l'url du client komodo

http://<ip.du.cli.ent>:9120


## Lancement de recettes compose 

**Aller dans l'onglet stack de l'interface**

- Créer un nouveau stack
- Donner le nom `wordpress`
- Selectionner le serveur cible
- Choisir le mode "UI defined"
- Coller la recette suivante 

```yaml

version: '3.3'
services:
  wordpress:
    depends_on:
      - mysqlpourwordpress
    environment:
      - "WORDPRESS_DB_HOST=mysqlpourwordpress:3306"
      - WORDPRESS_DB_PASSWORD=monwordpress
      - WORDPRESS_DB_USER=wordpress
    networks:
    - wordpress
    ports:
      - "80:80"
    image: wordpress
    volumes:
      - wordpress_config:/var/www/html/

  mysqlpourwordpress:
    image: "mysql:5.7"
    environment:
      - MYSQL_ROOT_PASSWORD=motdepasseroot
      - MYSQL_DATABASE=wordpress
      - MYSQL_USER=wordpress
      - MYSQL_PASSWORD=monwordpress
    networks:
    - wordpress
    volumes:
      - wordpress_data:/var/lib/mysql/

networks:
  wordpress:

volumes:
  wordpress_config:
  wordpress_data:
  ```
---
title: "TP5 - Docker Swarm et cloud"
draft: true
---

## Docker, Ansible, Terraform : combiner et comparer différents outils d'Infrastructure as Code (IaC)

L'objectif de ce TP est double:

- Installer et expérimenter avec Docker Swarm pour découvrir l'orchestration de conteneurs
- Combiner trois solutions d'infrastructure as code, **Docker**, **Ansible** et **Terraform** pour voir en quoi elles sont **différentes** et **complémentaires**.

## Orchestrons une application dockerisée avec les services et stacks docker

### Tester et pousser l'application

Nous allons repartir de la correction du TP4 sur Docker compose et l'intégrer à un déploiement d'IaC.

- Récupérer le projet de base [https://github.com/e-lie/cursus_janvier2020_docker_tp5_base](https://github.com/e-lie/cursus_janvier2020_docker_tp5_base)

Notre application (quasiment identique à celle du TP4) se trouve dans le dossier flaskapp_src:

- Observer le contenu de ce dossier
- Testez l'application avec : `docker-compose up --build`.
- Visitez `localhost: 5000`.
- Construisez l'image `monster_icon` à pousser sur le Docker Hub avec la commande **à compléter** suivante: `docker build -t <votre_hub_login>/monster_icon:0.1 .`
- Poussez votre image avec `docker login && docker push <votre_hub_login>/monster_icon:0.1` .

### Tester docker swarm en local sur un noeud

Depuis 2017, l'orchestrateur Docker Swarm a été intégré directement à la runtime docker. On parle de `swarm mode` de docker. Ce swarm mode peut être activé facilement sur une simple machine de développement.

Depuis fin 2019, Docker Desktop inclue aussi une distribution de dev de Kubernetes.

- Pour activer le Swarm Mode lancez: `docker swarm init`

En mode swarm, docker ne gère plus les conteneurs un par un mais sour forme de services répliqués. `docker service create` ressemble beaucoup à `docker run` mais on peut préciser le nombre d'instances identiques à lancer, le placement sur le cluster etc. Lançons par exemple notre application monster_icon à l'aide d'un service avec 3 réplicats:

- `docker service create --name monster_icon -p 9090:9090 --replicas 3 tecpi/monster_icon:0.1`
- Visitez `localhost:9090`.
- Lancez `docker service ls` puis `docker service ps monster_icon` vous liste les conteneurs liés à ce service.
- `docker service logs monster_icon` affiche les logs aggrégés des trois conteneurs.
- visitez votre portainer pour observer le service `monster_icon`
- `docker service rm monster_icon` supprime tous les conteneurs.

De la même façon qu'on utilise docker compose pour décrire un déploiement de développement multiconteneur, Docker Swarm propose le concept de **stack** qui consiste en la description en YAML d'un ensemble de services répliqués et déployés d'un certaine façon. En simplifié un fichier de stack docker est simplement un docker-compose file, en version 3 avec une section `deploy` pour chaque service du type:

```yml
version: "3"
services:
  monster_icon:
    image: tecpi/monster_icon:0.1
    ports:
      - "9090:9090"
      - "9191:9191"
    environment:
      - CONTEXT=PROD
    networks:
      - monster_network
    deploy:
      replicas: 3
      resources:
        limits:
          cpus: "0.1"
          memory: 50M
      restart_policy:
        condition: on-failure
```

- Observez le dossier `swarm_stacks` dans VSCode et ouvrez le fichier `monster_icon_stack.yml`. Il s'agit d'une copie du docker compose de prod du TP4 légèrement modifié pour intégrer des instruction de déploiement (section `deploy`).

- Déplacez vous dans le dossier `swarm_stacks` et Déployez cette stack avec `docker stack deploy -c monster_icon_stack monsterstack`
- Observez la création des services de la stack avec `docker service ls` et `docker service ps <nom_service>`
- Testez aussi `docker stack services monsterstack`.
- Observez votre stack dans portainer.

- Visitez `localhost:9090` et `localhost:8081`.

- Supprimez la stack avec `docker stack rm monsterstack`.
- Nettoyez avec `docker container prune -f && docker network prune -f && docker volume prune`.

Nous allons maintenant créer un cluster swarm de plusieurs noeuds. La méthode simple pour tester cela est d'utiliser `docker-machine` pour créer des machines virtuelles dans virtualbox ou un provider de cloud. Mais la configuration avec `docker-machine` est limitée et ne respecte pas le principe d'infrastructure as code (création en ligne de commande).

Nous allons donc configurer un cluster avec des outils plus robustes: Terraform et Ansible !

Voici un schéma pour récapituler le projet:

```txt
           +--------+
  DOCKER   |        |                          +------------------------------------+ +---------------------------------+
           | +----+ |                       ^  |                                    | |                                 |
           |        |                 SaaS  |  |   SERVICE 1 - 2 REPLICAS           | |    SERVICE 2 - 2 REPLICAS       |
           | +----+ +--------+              |  |                                    | |                                 |
           |        |        |              |  |                                    | |                                 |
           | +----+ |        |              |  |                                    | |                                 |
           |        |        +-------------->  +------------------+-+---------------+ +---------------+-+---------------+
           +--------+                       |  |                  | |               | |               | |               |
                                            |  | CONTENEUR        | | CONTENEUR     | | CONTENEUR     | | CONTENEUR     |
           +--------+                       |  |                  | |               | |               | |               |
 ANSIBLE   |        |                       |  |                  | |               | |               | |               |
           | +----+ |                       |  +------------------+ +---------------+ +---------------+ +---------------+
           |        |                       v  +------------------------------------------------------------------------+
           | +----+ +--------+                 |                                                                        |
           |        |        |              ^  | DOCKER ENGINE SWARM MODE                                               |
           | +----+ |        |        PaaS  |  |                                                                        |
           |        |        |              |  +------------------------------------------------------------------------+
           +--------+        |              |  +---------------------+   +---------------------+   +--------------------+
                             +-------------->  |                     |   |                     |   |                    |
           +--------+                       |  | SWARM MASTER        |   | SWARM NODE 1        |   | SWARM NODE 2       |
TERRAFORM  |        |                       |  |                     |   |                     |   |                    |
           | +----+ |                       v  |                     |   |                     |   |                    |
           |        |                          |                     |   |                     |   |                    |
           | +----+ +--------+              ^  +---------------------+   +---------------------+   +--------------------+
           |        |        |        IaaS  |  | VPS 1               |   | VPS2                |   | VPS 2              |
           | +----+ |        |              |  +---------------------+   +---------------------+   +--------------------+
           |        |        |              |
           +--------+        +-------------->  +------------------------------------------------------------------------+
                                            |  |                                                                        |
                                            |  | DIGITAL OCEAN                                                          |
                                            |  |                                                                        |
                                            v  +------------------------------------------------------------------------+
```

### Prérequis : Digitalocean token et clé SSH

- Pour louer les machines dans le cloud pour ce TP vous aurez besoin d'un compte digitalocean : celui du formateur ici mais vous pouvez facilement utiliser le votre. Il faut récupérer les éléments suivant pour utiliser le compte de cloud du formateur:
  - un token d'API digitalocean fourni pour la formation. Cela permet de commander des machines auprès de ce provider.
  - une clé SSH (pré ajoutée au compte de cloud et automatiquement provisionnée dans les VPS):
    - Une clé "fingerprint" de clé ssh
    - La paire de clé ssh (un fichier clé privée du type `id_xxx` et clé publique `id_xxx.pub`) sont directement dans le dépôt du TP.

<!-- - Récupérez sur git la paire clé ssh adaptée: [https://github.com/e-lie/id_ssh_shared.git](https://github.com/e-lie/id_ssh_shared.git). Utilisez "clone or download" > "Download as ZIP". Puis décompressez l'archive.
- mettez la paire de clé `id_ssh_shared` et `id_ssh_shared.pub` dans le dossier `~/.ssh/`. La passphrase de cette clé est `trucmuch42`.
- Rétablissez les droits `600` sur la clé privée : `chmod 600 ~/.ssh/id_ssh_shared`.
- faites `ssh-add ~/.ssh/id_ssh_shared` pour vérifier que vous pouvez déverrouiller deux clés (l'ancienne avec votre passphrase et la nouvelle paire que vous venez d'ajouter) -->

<!-- - Si vous utilisez votre propre compte, vous aurez besoin d'un token personnel. Pour en crée allez dans API > Personal access tokens et créez un nouveau token. Copiez bien ce token et collez le dans un fichier par exemple `~/Bureau/compte_digitalocean.txt`. (important détruisez ce token à la fin du TP par sécurité).

- Copiez votre clé ssh (à créer sur nécessaire): `cat ~/.ssh/id_ed25519.pub`
- Aller sur digital ocean dans la section `account` en haut à droite puis `security` et ajoutez un nouvelle clé ssh. Notez sa fingerprint dans le fichier précédent. -->

## Installer terraform et le provider ansible

Terraform est un outils pour décrire une infrastructure de machines virtuelles et ressources IaaS (infrastructure as a service) et les créer (commander). Il s'intègre en particulier avec AWS, DigitalOcean mais peut également créer des machines dans un cluster VMWare en interne (on premise) pour créer par exemple un cloud mixte.

Terraform n'est pas disponible sous forme de dépôt ubuntu/debian. Pour l'installer il faut le télécharger et le copier manuellement:

```bash
cd /tmp
wget https://releases.hashicorp.com/terraform/0.12.19/terraform_0.12.19_linux_amd64.zip
sudo unzip ./terraform_0.12.19_linux_amd64.zip -d /usr/local/bin/
```

- Testez l'installation avec `terraform --version`

Pour pouvoir se connecter à nos VPS, ansible doit connaître les adresses IP et le mode de connexion ssh de chaque VPS. Il a donc besoin d'un inventaire.

Jusqu'ici nous avons créé un inventaire statique c'est à dire un fichier qui contenait la liste des machines. Nous allons maintenant utiliser un inventaire dynamique c'est à dire un programme qui permet de récupérer dynamiquement la liste des machines et leurs adresses en contactant une API.

- Le meilleur inventaire dynamique pour terraform est [https://github.com/nbering/terraform-inventory/](https://github.com/nbering/terraform-inventory/).

Cependant cet inventaire dépend d'un provider spécifique à installer manuellement pour cela lancez les commandes suivantes:

```
wget https://github.com/nbering/terraform-provider-ansible/releases/download/v1.0.3/terraform-provider-ansible-linux_amd64.zip
mkdir -p ~/.terraform.d/plugins
unzip ./terraform-provider-ansible-linux_amd64.zip -d ~/.terraform.d/plugins/
```

## Terraform digital ocean

- Les fichiers qui décrivent les VPS et ressources à créer avec terraform sont `terraform/digitalocean_vps.tf` et `terraform/ansible_hosts.tf`. Nous allons commentez ensemble ce fichier:

!! La documentation pour utiliser terraform avec digitalocean se trouve ici [https://www.terraform.io/docs/providers/do/index.html](https://www.terraform.io/docs/providers/do/index.html)

Pour terraform puisse s'identifier auprès de digitalocean nous devons renseigner le token et la fingerprint de clé ssh. Pour cela:

- copiez le fichier `terraform.tfvars.dist` et renommez le en enlevant le `.dist`
- collez le token récupéré précédemment dans le fichier de variables `terraform.tfvars`

```
token: 0de8a7ae2f643a86c1a5975e820c37587d1e1199e70d127793de1d023bdeffdf
```

- ajoutez également la fingerprint de clé ssh à ce fichier.

```
fingerprint: 05:f7:18:15:4a:77:3c:4c:86:70:85:aa:cb:18:b7:68
```

Avant de pouvoir continuer nous devons compléter les groupes dans `terraform/ansible_hosts`.

Mais pour cela nous devons connaître les groupes utililisés pour le rôle ansible d'installation de docker swarm.

## Chercher le rôle Docker Swarm Ansible

- Visitez le dépôt officiel de role ansible nommé **Galaxy** [https://galaxy.ansible.com/](https://galaxy.ansible.com/)

- Cherchez le role docker swarm de `thomasjpfan`.
- Ajoutez ce role au fichier `requirement.yml` de `ansible/roles`.
- Pour installer facilement des roles utilisez depuis le dossier ansible la commande: `ansible-galaxy install -r roles/requirements.yml -p roles`

### Compléter les groupes ansible dans le terraform ansible provider

- Avant d'exécuter ce role il faut compléter les groupes pour désigner correctement les workers et les managers dans `terraform/ansible_hosts.tf` :
- En lisant le du role sur galaxy on constate qu'il utiliser le role `docker_swarm_manager` pour désigner les noeuds manager et `docker_swarm_worker` pour désigner les worker.
- Nous avons aussi besoin d'un groupe pour désigner l'ensemble des noeuds swarm. Comme vous pouvez le constater dans `ansible/playbooks/swarm_nodes_setup.yml` nous vous proposons `swarm_nodes` comme groupe global swarm.
- A partir de ces informations complétez `ansible_hosts` avec `groups = ["swarm_nodes","docker_swarm_manager"]` et `groups = ["swarm_nodes", "docker_swarm_worker"]`.

### Lancer le provisionning des VPS

- Maintenant que ces deux fichiers sont complétés (quoi créer et comment s'identifier auprès du provider) nous pouvons lancer la création de nos VPS:

  - `terraform init` permet à terraform de télécharger les "driver" nécessaire pour s'interfacer avec notre provider. Cette commande crée un dossier .terraform
  - `terraform plan` est facultative et permet de calculer et récapituler les créations modifications de ressources à partir de la description de `main.tf`
  - `terraform apply` permet de déclencher la création des ressources.

- La création prend environ 1 minute.

Maintenant que nous avons des machines dans le cloud nous devons fournir leurs IP à Ansible pour pouvoir les configurer. Pour cela nous allons utiliser un inventaire dynamique.

## Terraform dynamic inventory

- Le meilleur inventaire dynamique pour terraform est [https://github.com/nbering/terraform-provider-ansible/](https://github.com/nbering/terraform-inventory/).

Une bonne intégration entre Ansible et Terraform permet de décrire précisément les liens entre resource terraform et hote ansible ainsi que les groupes de machines ansible. Pour cela notre provider ansible propose de dupliquer les ressources terraform dans pour créer explicitement les hotes ansible à partir des données dynamiques de terraform.

- Ouvrons à nouveau le fichier `ansible_hosts.tf` pour étudier le mapping entre les ressources digitalocean et leur duplicat ansible : la variable `ansible_host` de terraform est initialisée en récupérant la valeur générée par les ressources `digital_ocean_droplets` de `digitalocean_vps.tf`.

- Pour vérifier le fonctionnement de notre inventaire dynamique, allez à la racine du projet et lancez:

```
source .env
cd ../ansible
./terraform-inventory.
```

- La seconde appelle l'inventaire dynamique et vous renvoie un résultat en json décrivant les groupes, variables et adresses IP des machines crées avec terraform.

- Complétez le `ansible.cfg` avec le chemin de l'inventaire dynamique: `./terraform-inventory.py`

- Nous pouvons maintenant tester la connexion avec ansible directement: `ansible all -m ping`.

## Installation de Docker Swarm

- Lancez le playbook `ansible/site_setup.yml` pour installer swarm sur les trois VPS digital ocean.

## Déployer notre stack Monster Icon

- Récupérez l'ip du swarm manager avec `ansible-inventory --host docker_swarm_manager`
- Connectez vous en ssh au manager.
- Listez les noeuds swarm avec `docker node ls`
- récupérez la stack portainer du projet avec `wget https://raw.githubusercontent.com/e-lie/cursus_janvier2020_docker_tp5_base/cursusjanvier2020-docker-tp5/swarm_stacks/portainer_stack.yml`.
- déployez la stack avec `docker stack deploy -c portainer_stack.yml portainerstack`.
- Visitez `<ip>:9000` -> portainer est disponible depuis n'importe quel noeud également alors que nous l'avons installé sur le manager.

Nous allons maintenant déployer la stack monster avec un playbook ansible

- Ouvrez le fichier `ansible/playbook/deploy_monsterstack.yml`

  - Explorez la doc du module ansible `docker_stack`.
  - Lancez ce playbook.

- récupérez l'ip de n'importe lequel des noeuds avec `ansible-inventory --list`
- Visitez la page `<ip>:9090` -> notre app rechargez la page plusieurs fois.
  - l'adresse qui sert la page est différente à chaque fois !
  - pourquoi ?

![](/img/docker/ingress-routing-mesh.png)

- Visitez `<ip>:8081` -> regardez les valeur binaire des images et le compteur se mettre à jour

## Redimensionner notre cluster dynamiquement !!!

- Modifiez `main.tf` pour passer le nombre de worker à 3.
- Appliquer la configuration avec `terraform apply` dans le dossier `terraform`.
- Constatez que les noeuds ont bien été créé en les pinguant avec `ansible swarm_nodes -m ping`
- Relancez le playbook `site_setup.yml`.
- Modifiez la stack `swarm_stacks/monster_icon_stack.yml` : scalez le service `dnmonster` pour le passer à 12 replicat.
- Allez dans `portainer` et appliquez la stack en chargeant le fichier stack dans l'interface.
- Allez dans le menu `swarm > Go to cluster visualizer` pour voir le résultat.

## La puissance de l'automatisation

- Essayez de détruire et recréer tout le cluster avec :
  - `./cluster.sh destroy_infra`
  - `./cluster.sh setup_full`

Si tout va bien votre cluster devrait être complètement réinstallé avec une commande

## Correction

Vous trouverez la correction de ce TP dans le dépôt [https://github.com/e-lie/cursus_janvier2020_docker_tp5_correction.git](https://github.com/e-lie/cursus_janvier2020_docker_tp5_correction.git).

## NE PAS OUBLIER DE DETRUIRE LES VPS

Pour ne pas payer des serveurs inutiles il faut absolument penser à détruire les droplets avec `terraform destroy` ou `./cluster destroy_infra`. Puis vérifions dans Digital Ocean qu'il n'y a plus de droplets.

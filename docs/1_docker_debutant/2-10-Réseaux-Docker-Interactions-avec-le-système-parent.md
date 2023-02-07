---
title: Réseaux Docker Interactions avec le système parent
pre: "<b>2.10 </b>"
weight: 23
---
## Objectifs pédagogiques
  - Comprendre le mode de fonctionnement des bridge Linux et le NAT
  - Savoir inspecter la couche réseau d'un conteneur Docker

## Réseau

### Gestion des ports réseaux (_port mapping_)

<-- Schéma -->

- L'instruction `EXPOSE` dans le Dockerfile informe Docker que le conteneur écoute sur les ports réseau au lancement. L'instruction `EXPOSE` **ne publie pas les ports**. C'est une sorte de **documentation entre la personne qui construit les images et la personne qui lance le conteneur à propos des ports que l'on souhaite publier**.

- Par défaut les conteneurs n'ouvrent donc pas de port même s'ils sont déclarés avec `EXPOSE` dans le Dockerfile.

- Pour publier un port au lancement d'un conteneur, c'est l'option `-p <port_host>:<port_guest>` de `docker run`.

- Instruction `port:` d'un compose file.

---

### Bridge et overlay

<-- Schéma réseau classique bridge -->

- Un réseau bridge est une façon de créer un pont entre deux carte réseaux pour construire un réseau à partir de deux.

- Par défaut les réseaux docker fonctionne en bridge (le réseau de chaque conteneur est bridgé à un réseau virtuel docker)

- par défaut les adresses sont en 172.0.0.0/8, typiquement chaque hôte définit le bloc d'IP 172.17.0.0/16 configuré avec DHCP.

<-- Schéma réseau overlay -->

- Un réseau overlay est un réseau virtuel privé déployé par dessus un réseau existant (typiquement public). Pour par exemple faire un cloud multi-datacenters.

---

#### Le réseau Docker est très automatique

<-- Schéma DNS et DHCP -->

- Serveur DNS et DHCP intégré dans le "user-defined network" (c'est une solution IPAM)

- Donne un nom de domaine automatique à chaque conteneur.

- Mais ne pas avoir peur d'aller voir comment on perçoit le réseau de l'intérieur. Nécessaire pour bien contrôler le réseau.

- `ingress` : un loadbalancer automatiquement connecté aux nœuds d'un Swarm. Voir la [doc sur les réseaux overlay](https://docs.docker.com/network/overlay/).
<-- schéma ingress -->

### Lier des conteneurs

- Aujourd'hui il faut utiliser un réseau dédié créé par l'utilisateur ("user-defined bridge network")

  - avec l'option `--network` de `docker run`
  - avec l'instruction `networks:` dans un docker composer

- On peut aussi créer un lien entre des conteneurs
  - avec l'option `--link` de `docker run`
  - avec l'instruction `link:` dans un docker composer
  - MAIS cette fonctionnalité est **obsolète** et déconseillée

### Plugins réseaux

Il existe :

- les réseaux par défaut de Docker
- plusieurs autres solutions spécifiques de réseau disponibles pour des questions de performance et de sécurité
  - Ex. : **Weave Net** pour un cluster Docker Swarm
    - fournit une autoconfiguration très simple
    - de la sécurité
    - un DNS qui permet de simuler de la découverte de service
    - Du multicast UDP
    <-- Donner un autre exemple -->

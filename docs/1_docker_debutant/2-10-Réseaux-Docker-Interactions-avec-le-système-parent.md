---
title: 2.10 Réseaux Docker Interactions avec le système parent
pre: "<b>2.10 </b>"
weight: 23
---
## Objectifs pédagogiques
  - Comprendre le mode de fonctionnement des bridge Linux et le NAT
  - Savoir inspecter la couche réseau d'un conteneur Docker

---

# Le réseau Docker est très automatique

* DNS et DHCP intégré dans le "user-defined network" 
* Fournit des adresses automatiquement
* Fournit un nom de domaine automatique à chaque conteneur
* Fournit par défaut une isolation des containers
---

## Les réseaux de type bridge

**Un réseau bridge est une façon de créer un pont entre deux carte réseaux pour construire un réseau à partir de deux.**

Par défaut les réseaux docker fonctionne en bridge (le réseau de chaque conteneur est bridgé à un réseau virtuel docker)

Par défaut les adresses sont en 172.16.0.0/12, typiquement chaque hôte définit le bloc d'IP 172.17.0.0/16 configuré avec DHCP.

---
## Les autres types de réseaux

### Overlay

Un réseau overlay est un réseau virtuel privé déployé par dessus un réseau existant (typiquement public). Pour par exemple faire un cloud multi-datacenters.

---
### Plugins réseaux

Il existe :

- les réseaux par défaut de Docker
- plusieurs autres solutions spécifiques de réseau disponibles pour des questions de performance et de sécurité
  - Ex. : **Weave Net** pour un cluster Docker Swarm
    - fournit une autoconfiguration très simple
    - de la sécurité
    - un DNS qui permet de simuler de la découverte de service
    - Du multicast UDP



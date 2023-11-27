---
title: "Cours: Réseaux Docker Interactions avec le système parent"
---

<!-- ## Objectifs pédagogiques
  - Comprendre le mode de fonctionnement des bridge Linux et le NAT
  - Savoir inspecter la couche réseau d'un conteneur Docker -->


# Le réseau Docker est très automatique

Par défaut :

* DNS et DHCP intégré dans le "user-defined network" 
* Fournit des adresses automatiquement
* Fournit un nom de domaine automatique à chaque conteneur
* Fournit par défaut une isolation des containers

Il est néanmoins modulaire, et permet de choisir entre plusieurs options.


## Par défaut : les réseaux de type bridge

**Un réseau bridge est une façon de créer un pont entre deux carte réseaux pour construire un réseau à partir de deux.**

> Analogie: une multiprise de courant.  
> Au départ il n'y a qu'une seule prise disponible.  
> Avec la multiprise, cette prise unique est utilisée par d'autres appareils connectés au même appareil.

Par défaut les réseaux docker fonctionne en bridge (le réseau de chaque conteneur est bridgé à un réseau virtuel docker)

Par défaut les adresses sont en 172.16.0.0/12, typiquement chaque hôte définit le bloc d'IP 172.17.0.0/16 configuré avec DHCP.

## Les autres types de réseaux

### Overlay

Un réseau overlay est un réseau virtuel privé déployé par dessus un réseau existant (typiquement public). Pour par exemple faire un cloud multi-datacenters.

**Cette fonctionnalité est utilisée par la solution de Docker pour interconnecter plusieurs serveurs, Docker Swarm** 

La solution Swarm est en perte de vitesse, on ne va pas s'apesantir sur cette option.


### Host
Pour les conteneurs autonomes, supprime l'isolation réseau entre le conteneur et l'hôte Docker, et utilise directement la mise en réseau de l'hôte. 

### ipvlan
Les réseaux IPvlan offrent aux utilisateurs un contrôle total sur l'adressage IPv4 et IPv6. 

Le pilote VLAN s'appuie sur cela en donnant aux opérateurs un contrôle complet du balisage VLAN de couche 2 et même du routage IPvlan L3 pour les utilisateurs intéressés par l'intégration du réseau sous-jacent. 

### macvlan 
Les réseaux Macvlan vous permettent d'attribuer une adresse MAC à un conteneur, le faisant apparaître comme un périphérique physique sur votre réseau. 

Le démon Docker achemine le trafic vers les conteneurs par leurs adresses MAC. 

L'utilisation du pilote macvlan est parfois le meilleur choix lorsqu'il s'agit d'applications héritées qui s'attendent à être directement connectées au réseau physique, plutôt que d'être acheminées via la pile réseau de l'hôte Docker. 

### none
Désactive tous les réseaux. Généralement utilisé en conjonction avec un pilote réseau personnalisé. none n'est pas disponible pour les services Swarm. 

### Plugins réseaux

En dehors des réseaux par défaut de Docker, il existe plusieurs autres solutions spécifiques de réseau disponibles pour des questions de performance et de sécurité.

  - Ex. : **Weave Net** pour un cluster Docker Swarm
    - fournit une autoconfiguration très simple
    - de la sécurité
    - un DNS qui permet de simuler de la découverte de service
    - Du multicast UDP



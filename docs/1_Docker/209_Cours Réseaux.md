---
title: Cours - Réseaux Docker
---

<!-- ## Objectifs pédagogiques
  - Comprendre le mode de fonctionnement des ports dans Linux
  - Savoir utiliser la commande EXPOSE
  - Savoir exposer effectivement le port d'un conteneur
  - Comprendre le mode de fonctionnement des bridge Linux et le NAT
  - Savoir inspecter la couche réseau d'un conteneur Docker
-->

## Un petit rappel sur les ports (et le réseau)

**Les ports des protocules TCP et UDP dans Linux ont quelques propriétés particulière.**

Seul l'utilisateur root a le droit d'ouvrir des ports inférieurs à 1024, indiquant que le service est autorisé par un administrateur système.

Pour rappel, c'est avec le triplet `(PROTOLE,ADDRESSE DESTINATION,PORT DESTINATION)` qu'on peut échanger avec un service sur le réseau.

ex: `(UDP,8.8.8.8,53)` pour faire du DNS sur les serveurs DNS de Google 

## Exposer le port dans un Dockerfile avec PORT

```dockerfile
EXPOSE <port> [<port>/<protocol>...]
```
**L'instruction EXPOSE informe Docker que le conteneur écoute sur les ports réseau spécifiés lors de l'exécution.**

Vous pouvez spécifier si le port écoute sur TCP ou UDP, et la valeur par défaut est TCP si le protocole n'est pas spécifié.

**L'instruction EXPOSE ne publie pas réellement le port.** 

Elle fonctionne comme un type de documentation entre la personne qui construit l'image et la personne qui exécute le conteneur, sur les ports destinés à être publiés. 


## Exporter effectivement le(s) port(s) d'un conteneur

**Pour publier réellement le port lors de l'exécution du conteneur, utilisez l'indicateur -p lors de l'exécution du docker pour publier et mapper un ou plusieurs ports, ou l'indicateur -P pour publier tous les ports exposés et les mapper aux ports de niveau supérieur.**

On publie le port grâce à la syntaxe `-p [ip_interface:]port_de_l_hote:port_du_container`.

```shell
docker run --rm -d --name "test_nginx" -p 8000:80 nginx # ouvre le port par défaut sur 0.0.0.0 toutes les interfaces
# ou bien plus securisé
docker run --rm -d --name "test_nginx" -p 127.0.0.1:8000: 80 nginx
curl http://localhost:8000
docker logs test_nginx
```

En visitant l'adresse et le port associé au conteneur Nginx, on doit voir apparaître des logs Nginx.

On peut lancer des logiciels plus ambitieux, comme par exemple Funkwhale, une sorte d'iTunes en web qui fait aussi réseau social :

```shell
docker run --name funky_conteneur -p 80:80 funkwhale/all-in-one:1.2.9
```

Vous pouvez visiter ensuite ce conteneur Funkwhale sur le port 80 (après quelques secondes à suivre le lancement de l'application dans les logs) ! Mais il n'y aura hélas pas de musique dedans :(

**Attention à ne jamais lancer deux containers connectés au même port sur l'hôte, sinon cela échouera !**
`

## Le réseau Docker est très automatique

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

## Le réseau Docker en profondeur (conteneurs plus généralement)

- https://medium.com/techlog/diving-into-linux-networking-and-docker-bridge-veth-and-iptables-a05eb27b1e72


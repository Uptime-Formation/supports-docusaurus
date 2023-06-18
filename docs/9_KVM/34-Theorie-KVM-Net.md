# Théorie: Réseau

## Objectifs Pédagogiques 

- Connaître les contraintes opérationnelles de KVM en production

Documentation : 
* https://www.linux-kvm.org/page/Networking

---

## Problématique réseau et production pour KVM 

**Si on considère les méthodes basiques pour fournir du réseau à des machines virtuelles, il existe plusieurs possibilités.**

Dans une architecture cloud, c'est le fournisseur de cloud qui fournit les réseaux privées, LAN, addresses privées et publiques, load balancers, etc.

Dans le cadre d'une infrastructure privée, on peut néanmoins résoudre un certain nombre de cas avec des solutions simples.

---

### Bridge

**Un bridge (ou pont) est un équipement matériel qui permet d’interconnecter deux réseaux physiques.**

Le pont travaille au niveau 2 du modèle OSI (un routeur travaille au niveau 3). 

Le transfert des paquets est effectué suivant l’adresse Ethernet (adresse MAC) et non avec l’adresse IP. 

Un pont peut être vu comme une sorte de switch virtuel.

```shell

iface br0 inet dhcp
    bridge_ports    eth0
    bridge_stp      off
    bridge_maxwait  0
    bridge_fd       0
    
```
---

**La conséquence directe de la configuration en bridge est que les IP des VM et de l’hôte sont dans le même sous-réseau.**

Le mode bridge est très souvent utilisé afin que les VM soient vues par les clients comme des serveurs physiques.
s0

---
### Bridge Réseau privé

**Ce mode permet de complètement isoler de l’hôte un réseau de VM. Il n’y a donc plus aucune communication entre les VM et le réseau local.**

Ce mode de fonctionnement est très intéressant pour simuler un réseau local entre plusieurs VM. Il se rapproche du schéma du NAT sauf que les VM ne peuvent pas communiquer avec l’extérieur.

--- 

**Cas d'utilisation:**

Vous souhaitez mettre en place un réseau privé entre 2 ou plusieurs machines virtuelles. Ce réseau ne sera pas visible des autres machines virtuelles ni du réseau réel.

```shell


$ ip tuntap add tun0 mode tap 
$ ip link set tun0 up
$ ip link set tun0 master {BRIDGE}
# connection des VMs sur l'interface tun


```

--- 

### NAT / Routeur 

**Le principe du NAT (Network Address Translation) est de faire correspondre le plus souvent des adresses internes non routables (192.168…) vers une ou des adresses routables.**

Son mode de fonctionnement est quasiment identique à celui du routage, sauf que les IP des VM ne sont pas accessibles de l’extérieur.

---

**Le NAT est très utilisé pour partager une connexion Internet pour laquelle il n’existe qu’une adresse IP publique.**

Le NAT permet de faire un réseau isolé pouvant communiquer avec l’extérieur (principe de passerelle). C’est ce type de configuration réseau qui est en place dans les box ADSL grand public des fournisseurs d’accès Internet.

Par défaut, QEMU lance une VM en mode NAT.

```shell

$ qemu-system-x86_64 -hda /path/to/hda.img
# équivaut à 
$ qemu-system-x86_64 -hda /path/to/hda.img -netdev user,id=user.0 -device e1000,netdev=user.0


```

--- 

**Un routeur est un équipement électronique dont le rôle est d’acheminer les paquets réseau.**

Pour atteindre une machine sur le réseau, il est souvent nécessaire de passer par plusieurs routeurs.

```shell
$ traceroute www.free.fr 
traceroute to www.free.fr (212.27.48.10), 30 hops max, 60 byte  
packets   
 1  192.168.3.1 (192.168.3.1)  0.816 ms  1.200 ms  1.595 ms   
 2  80.10.115.225 (80.10.115.225)  30.228 ms  30.892 ms  32.347 ms 
 3  10.123.204.14 (10.123.204.14)  33.299 ms  34.778 ms  35.614 ms 
 4  ae43-0.nridf202.Paris.francetelecom.net (193.252.98.150)  
37.450 ms  38.418 ms  40.676 ms   
 5  ae43-0.nosta102.Paris.francetelecom.net (193.251.126.57)  
 40.929 ms  42.068 ms  43.037 ms   
 6  193.253.13.66 (193.253.13.66)  45.248 ms  28.495 ms  29.159 ms 
 7  th2-crs16-1-be1001.intf.routers.proxad.net (212.27.57.213)  
31.735 ms  33.086 ms  33.773 ms   
 8  p11-crs16-1-be1001.intf.routers.proxad.net (78.254.249.5)  
41.462 ms  38.974 ms  37.038 ms   
 9  p11-9k-1-be1000.intf.routers.proxad.net (78.254.249.130)  
38.538 ms  39.441 ms  41.625 ms   
10  bzn-9k-2-sys-be2001.intf.routers.proxad.net (194.149.161.246)  
42.445 ms  43.855 ms  44.836 ms   
11  www.free.fr (212.27.48.10)  45.868 ms  47.256 ms  48.487 ms 
 ```

---

**Le principal atout du mode routeur pour les VM est que celles-ci, bien qu’étant dans un réseau différent de l’hôte, restent accessibles de l’extérieur.**

Le schéma est quasi identique au mode NAT sauf au niveau de la configuration.

```shell
iptables -t nat -A PREROUTING -p tcp -m tcp --dport 9${f} -j DNAT --to-destination 10.10.10.$f:9090

```
--- 

### Solutions Software Defined Network : VDE et Open vSwitch 

**VDE (Virtual Distributed Ethernet) fournit un support polyvalent pour créer des réseaux virtuels compatibles Ethernet.**

La bibliothèque vdeplug, comme une prise Ethernet, peut être utilisée pour connecter des machines virtuelles, des espaces de noms, des processus IoTh (Internet of Threads) ou des commandes d'utilitaires VDE à des réseaux virtuels.

Cette bibliothèque utilise des plug-ins pour prendre en charge plusieurs implémentations VDE et s'ouvrir aux nouveaux développements des réseaux virtuels.

--- 

**VDE est historiquement supporté par QEMU, mais son intégration désormais est plutôt déconseillée par QEMU.**

> Le backend réseau VDE utilise l'infrastructure Virtual Distributed Ethernet pour mettre en réseau les invités. À moins que vous ne sachiez spécifiquement que vous souhaitez utiliser VDE, ce n'est probablement pas le bon backend à utiliser.

---

**Open VSwitch, parfois abrégé sous forme d'OVS, est une implémentation open source d'un commutateur multicouche virtuel distribué.**

L'objectif principal de l'Open VSwitch est de fournir une pile de commutation pour les environnements de virtualisation matérielle, tout en prenant en charge plusieurs protocoles et normes utilisés dans les réseaux informatiques.

--- 

**Open VSwitch est conçu pour prendre en charge la distribution transparente sur plusieurs serveurs physiques en permettant la création de commutateurs inter-serveur d'une manière qui résume l'architecture de serveur sous-jacente, similaire à VMware VSWitch ou Cisco NEXUS 1000V.**

Open VSwitch est utilisé

- Xen / XenServer  / Xen Cloud (par défaut) 
- Linux KVM
- Proxmox VE
- VirtualBox
- Hyper-V 
- OpenStack et autres plateforms cloud 

---

**La mise en œuvre du noyau Linux d'Open VSwitch a été fusionnée dans la ligne principale du noyau dans la version 3.3**

Des packages Linux officiels sont disponibles pour Debian, Fedora, OpenSuse et Ubuntu.



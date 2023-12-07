---
title: Cours - Quelques notions de réseau
---

### en 60 slides !

### Objectifs

- Comprendre et savoir se représenter les différentes couches
- Savoir faire quelques des tests "de base"
- ... et les commandes associées

![](/img/linux/admin/formationreseau.jpg)

### Notions essentielles à acquérir

- Comprendre ce qu'est une IP
- Comprendre ce qu'est un port
- Comprendre ce qu'est un client et un serveur (au sens logiciel) 
- Comprendre ce qu'est un nom de domaine
- Comprendre ce qu'il se passe sous le capot lorsque vous visitez une url web

### Autres cours en ligne plutôt bien faits

- https://cisco.goffinet.org/ccna/fondamentaux/modeles-tcp-ip-osi/
- https://www.fingerinthenet.com/le-modele-tcp-ip/

### Teh interntez

![](/img/linux/admin/serieoftube.jpg)


### Modele OSI

- Un empilement de couches
- Est là pour structurer la complexité du réseau
- Similaire au système : créer des abstractions
    - pour ne pas avoir à se soucier de ce qui se passe dans les couches "basses"
    - pour l'interopérabilité
- Chaque parti sur Internet implémente ces couches


![](/img/linux/admin/modele_OSI.png)


![](/img/linux/admin/osi2.jpeg)


### Modele OSI "simplifié": le modèle TCP/IP

- Application
- Transport (TCP)
- Internet (IP)
- Accès réseau (Ethernet, cables, ondes, ...)


### Encapsulation des données

![](/img/linux/admin/encapsulation.png)


![](/img/linux/admin/recap_network.png)


### Exemple de réseau

![](/img/linux/admin/network_1.png)


### Couche 1 : cable RJ45 / paires torsadées

![](/img/linux/admin/rj45.jpg)
![](/img/linux/admin/twisted_pair.jpg)

- Différentes catégories de cable : CAT 5, 6, 7, (8)


### Couche 1 : WiFi

![](/img/linux/admin/antenne_wifi.jpg)

- 2.4 GHz vs. 5 GHz
    - 2.4 GHz : meilleure portée, mais moins rapide, peu de canaux
    - 5 GHz : moins bonne portée, mais plus rapide, plus de canaux 


### Couche 1 : 4G/5G

![](/img/linux/admin/4g5g.png)


### Couche 1 : fibre optique

![](/img/linux/admin/fibreoptique.jpg)
![](/img/linux/admin/fibreoptique2.png)


### Couche 1 : liaisons intercontinentales

![](/img/linux/admin/cableocean.jpg)



### Couche 2 : Ethernet

- Protocole pour transmettre l'information sur le médium physique
- Adresse MAC, par ex. `4c:96:0b:7d:d3:1a`
- Les ordinateurs disposent de cartes d'interface ethernet (filaire, wifi)
- (Ethernet s'applique **aussi** au WiFi)

![](/img/linux/admin/ethernet_card.png)
![](/img/linux/admin/trame_ethernet.png)


- Les `switch` permettent de connecter plusieurs machines pour créer segment
- Un `switch` est "conscient" de la notion d'adresse ethernet

![](/img/linux/admin/switch.jpeg)

- Un `bridge` permet de "fusionner" plusieurs LAN ensemble

![](/img/linux/admin/bridge.jpeg)
![](/img/linux/admin/bridge.png)

Qu'est-ce qu'un VLAN ?

Un réseau local virtuel, est un réseau informatique logique indépendant. De nombreux VLAN peuvent coexister sur un même commutateur réseau ou « switch ». 


### Couche 2 : les interfaces dans Linux

- Les interfaces sont configurées grâce aux fichiers `/etc/network/interfaces` et `/etc/network/interfaces.d/*`


- `ip a` permet d'obtenir des informations sur les interfaces
    - Historiquement, les noms étaient "simple" : `eth0`, `eth1`, `wlan0`, ...
    - Aujourd'hui les noms sont un peu plus complexes / arbitraires
    - Il existe toujours une interface `lo` (loopback, la boucle locale - 127.0.0.1)
    - Il peut y'avoir d'autres interfaces ou bridges "virtuelles" (contexte de conteneur, etc..)



```bash
$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP>
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: enp0s25: <NO-CARRIER,BROADCAST,MULTICAST,UP>
    link/ether 33:0e:d8:3f:65:7e
3: wlp3s0: <BROADCAST,MULTICAST,UP,LOWER_UP>
    link/ether 68:a6:2d:9f:ad:07
```


### Couche 3 : IP

- IP pour *Internet Protocol*
- IP fait parler **des machines** !
    - .. et permet de relier plusieurs réseaux, qui potentiellement ont des fonctionnements différents
- Protocole de routage des paquets
    - "Best-effort", non fiable !
- Les routeurs, les facteurs d'internet
    - par ex. votre box internet
    - Routeur != Switch, un routeur "comprends" les adresses et protocole IP
    - Capable de discuter entre eux pour optimiser l'acheminement (BGP)


- Internet, c'est avant-tout une INTERconnexion d'opérateurs réseaux (NET)
- Ex: le réseau de l'opérateur Proxad

![](/img/linux/admin/proxad.png)


- Les opérateurs (AS) s'interconnectent (peering) dans des IXP
- Croissance "organique" du réseau

![](/img/linux/admin/interconnect_network.png)



### Couche 3 : IP : système d'adressage (IPv4) 

- addresses codées sur 32 bits (4 nombres entre 0 et 255)
- par exemple `92.93.127.10`
- "seulement" 4.3 milliards d'adresses ! (pénurie)


### Couche 3 : IP : IPv4 frame / paquet

![](/img/linux/admin/IPv4_frame.png)



- Distribution des addresses IP gérées par des ONG (IANA, RIR, LIR, ISP, ...)

![](/img/linux/admin/RIP_LIR_etc.png)


![](/img/linux/admin/RIP_LIR_etc2.png)


- Notion de plage d'IP, réseau, masques de sous-réseau, notation CIDR
    - une adresse IP est composée d'une partie "réseau" (préfixe) et d'une partie "hote"
    - par exemple `192.65.196.0/23` est un bloc de 512 IP attribué au CERN
    - `/23` signifie que les 23 premiers bits constituent la partie réseau
    - Il reste donc 32-23=9 bits pour la partie hote, soit 2^9 = 512 IP
    - Les masques "typiques" sont `/8`, `/16`, `/24` et `/32`


- Certains blocs d'IP sont réservés à certains usages
    - Loopback (interne à la machine)
        - `127.0.0.0/8` (c.f. typiquement `127.0.0.1`)
    - Réseau locaux (private network)
        - `192.168.0.0/16`
        - `10.0.0.0/8`
        - `172.16.0.0/12` 
    - Autres : c.f. https://en.wikipedia.org/wiki/Reserved_IP_addresses


### Couche 3 : Et l'IPv6 ?

- Addresses codées sur 128 bits (soit 2^94 fois plus d'adresses que IPv4 -> 10^38 addresses)
   - Par exemple, `2a04:7260:9088:6c00:0044:0000:0000:0001`
   - En IPv6, on peut simplifier les `0` et juste écrire: `2a04:7260:9088:6c00:44::1`
   - L'équivalent de `127.0.0.1` est `::1`
   - L'équivalent de `192.168.0.0/16` est `fc00::/10`
   - Les masques vont jusqu'à `/128`
- Beaucoup plus commun d'avoir directement un IP "globale" pour chaque machine, "directement" exposée sur le "vrai" internet
    - ... voir même un préfixe, comme par exemple un `/56`
   

- Certains commandes ont un équivalent "v6" (par ex. `ping6`) et/ou une option `-6` (par ex. `ping -6`)
    - pour les URLs, le `:` conflicte avec la notation des ports, il faut alors écrire l'IP entre crochet
    - par ex: `https://[2001:db8:85a3:8d3:1319:8a2e:370:7348]:443/`


- Existe depuis 1998 (sigh)
- Incompatible avec IPv4
    - période de transition "dual-stack"
    - problème d'oeuf et la poule / pas d'offre = pas de demande, etc

### Couche 3 : commandes essentielles

`ip a` affiche les interfaces (et IPv4 et v6 associées)

```bash
$ ip a
enp3s0: <BROADCAST,MULTICAST,UP,LOWER_UP>
 link/ether 40:8d:5c:f3:3e:35
 inet 91.225.41.29/32 scope global enp3s0
 inet6 2a04:7202:8008:60c0::1/56 scope global
```

Voir aussi : `ifconfig` (deprecated) et `ipconfig` (sous windows!)

### Couche 3 : commandes essentielles

`ping` teste la connexion entre deux machines

```bash
$ ping 91.198.174.192
PING 91.198.174.192 (91.198.174.192) 56(84) bytes of data.
64 bytes from 91.198.174.192: icmp_seq=1 ttl=58 time=51.5 ms
64 bytes from 91.198.174.192: icmp_seq=2 ttl=58 time=65.3 ms
^C
--- 91.198.174.192 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 3ms
rtt min/avg/max/mdev = 51.475/58.394/65.313/6.919 ms
```

Note: `ping` utilise le protocole `ICMP` qui a lieu au niveau de la couche 3 (ou 4 ?)

`whois` pour obtenir des infos sur le(s) proprio(s) d'une ip

```
$ whois 91.198.174.192
[...]
organisation:   ORG-WFI2-RIPE
org-name:       Wikimedia Foundation, Inc
[...]
mnt-by:         RIPE-NCC-HM-MNT
mnt-by:         WIKIMEDIA-MNT
```

`traceroute` permet d'étudier la route prise par les paquets

```bash
$ traceroute 91.198.174.192
 1  _gateway (192.168.0.1)  4.212 ms  6.449 ms  6.482 ms
 2  * 10.13.25.1 (10.13.25.1)  248.615 ms *
 3  211-282-253-24.rev.numericable.fr (211.282.253.24)  251.263 ms  251.332 ms  251.408 ms
 4  172.19.132.146 (172.19.132.146)  251.493 ms ip-65.net-80-236-3.static.numericable.fr (80.236.3.65)  251.569 ms  251.619 ms
 5  prs-b7-link.telia.net (62.115.55.45)  251.692 ms  251.769 ms  251.979 ms
 6  prs-bb4-link.telia.net (62.115.120.30)  252.026 ms prs-bb3-link.telia.net (62.115.121.96)  17.989 ms prs-bb4-link.telia.net (213.155.134.228)  1069.536 ms
 7  adm-bb4-link.telia.net (213.155.136.167)  1070.116 ms  1242.772 ms adm-bb3-link.telia.net (213.155.136.20)  1242.839 ms
 8  adm-b3-link.telia.net (62.115.122.179)  1243.006 ms adm-b3-link.telia.net (62.115.122.191)  1242.879 ms  1243.082 ms
[...]
```



### Couche 4 : TCP

- TCP pour Transmission Control Protocol (1/2)
- TCP est un protocole parmis d'autres qui ont lieu sur la couche 4
    - typiquement, il y a aussi UDP ...
- TCP fait communiquer **des programmes**
    - il y a une mise en place explicite d'un tuyau de communication
- Découpage des messages en petits paquets pour IP
- Fiabilité avec des accusés de réception / renvois



### Couche 4 : Notion de port

- TCP fourni un "tuyau de communication" entre deux programmes
- Notion de 'port' : un nombre entre 1 et 65536 (2^16)
    - Analogie avec les différents "departement" à l'intérieur d'une entreprise
    - plusieurs programmes sur une même machine peuvent vouloir communiquer avec un même programme sur une machine distante, donc l'addresse IP ne suffit pas pour spécifier l'expéditeur / destinataire
- Une connexion entre deux programme est caractérisé par **deux** couples (IP:port) 
- Par exemple : votre navigateur web (port 56723) qui discute qui discute avec le serveur web (port 80)
    - côté A : 183.92.18.6:56723 (un navigateur web)
    - côté B : 91.198.174.192:80 (un serveur web)



### Couche 4 : commandes essentielles

`lsof -i` pour lister les connexions active

```bash
$ lsof -i
ssh        3231 alex IPv4 shadow.local:34658->142.114.82.73.rev.sfr.net:ssh (ESTABLISHED)
thunderbi  3475 alex IPv4 shadow.local:59424->tic.mailoo.org:imap (ESTABLISHED)
thunderbi  3475 alex IPv4 shadow.local:57312->tic.mailoo.org:imap (ESTABLISHED)
waterfox  12193 alex IPv4 shadow.local:54606->cybre.space:https (ESTABLISHED)
waterfox  12193 alex IPv4 shadow.local:32580->cybre.space:https (ESTABLISHED)
```

ACHTUNG : ne pas abuser de cela..

```bash
$ nc -zv 44.112.42.13 22
Connection to 44.112.42.13 22 port [tcp/ssh] succeeded!
```

`tcpdump` pour regarder l'activité sur le réseau

`wireshark`, similaire à tcpdump, mais beaucoup plus puissant, et en interface graphique

### Couche 5+ : Modèle client/serveur

Un **serveur** (au sens logiciel) est un programme. Comme un serveur dans un bar (!) :
- il **écoute** et attends qu'on lui demande un **service** en suivant **un protocole**
- par exemple : fournir la page d'acceuil d'un site
- le serveur écoute sur *un port*  : par exemple : 80

Le **client** est celui qui demande le service selon **le protocole**
- il toque à la bonne porte
- explique sa demande
- le serveur lui réponds (on espère)


### Couche 5+ : `netstat`

`netstat -tulpn` permet de lister les programmes qui écoutent et attendent

```bash
 > netstat -tulpn | grep LISTEN | grep "80\|25"
tcp     0.0.0.0:80  LISTEN   28634/nginx: master
tcp     0.0.0.0:25  LISTEN   1331/master # <- postfix, un serveur mail
tcp6    :::80       LISTEN   28634/nginx: master
tcp6    :::25       LISTEN   1331/master # <- postfix, un serveur mail
```

### Couche 5+ : notion de protocole

- Un protocole = une façon de discuter entre programmes
- Conçus pour une finalité particulière
- Ont généralement un port "par défaut" / conventionnel (c.f. `/etc/services`)
   - 80/http : le web (des "vitrines" pour montrer et naviguer dans du contenu)
   - 443/https : le web (mais en chiffré)
   - 25/smtp : le mail (pour relayer les courriers électroniques)
   - 993/imap : le mail (synchroniser des boites de receptions)
   - 587/smtps : le mail (soumettre un courrier à envoyer)
   - 22/ssh : lancer des commandes à distance
   - 53/dns : transformer des noms en ip
   - 5222/xmpp : messagerie instantannée
   - 6667/irc : salons de chat


### Couche 5+ : HTTP

- On ouvre un socket TCP avec le serveur distant
- On envoie `GET /` et on reçoit 200 + la page d'acceuil
- On envoie `GET /chaton.jpg` et on reçoit 200 + une image (si elle existe)
- On envoie `GET /meaningoflife.txt` et on reçoit 404 (si la page n'existe pas)
- On peut ajouter des Headers aux requetes et réponses (c.f. debugger firefox)
- Il existe d'autres requetes : POST, PUT, DELETE, ...

### Couche 5+ : Le web

- Le web, ce n'est par Internet
- Le web est construit grace au language HTML, généralement transporté par HTTP
- "Web" désigne la "toile" créée par les liens hypertextes, une fonctionnalité introduite par HTML 

- Dans le modèle OSI:
    - 7 Application: votre onglet dans le navigateur, une application web
    - 6 Présentation: HTML, CSS, JS, PNG, ...
    - 5 Session: HTTP / HTTPs
    - 4 TCP
    - 3 IP
    - 2 (liaison)
    - 1 (physique)

### DNS : Domain name server

- Retenir cinquante numéros de telephone (ou coordonées GPS) par coeur, c'est pas facile
- On invente l'annuaire et les adresses postales
- `wikipedia.org -> 91.198.174.192`
- On peut acheter des noms chez des *registrars* (OVH, Gandi, ...)
- Composant critique d'Internet (en terme fonctionnel)
- Fonctionne en UDP et (et pas en TCP)


- Il existe des résolveurs DNS à qui on peut demander de résoudre un nom via le protocole DNS (port 53)
- Par exemple :
    - 8.8.8.8, le resolveur de Google
    - 9.9.9.9, un nouveau service qui "respecte la vie privée"
    - 89.234.141.66, le resolveur de ARN
    - 208.67.222.222, OpenDNS
- **Choix critique pour la vie privée !!**
- Generalement, vous utilisez (malgré vous) le resolveur de votre FAI, ou bien celui de Google


- Sous Linux, le resolveur DNS se configure via un fichier `/etc/resolv.conf`

```bash
$ cat /etc/resolv.conf
nameserver 89.234.141.66
```


`ping` fonctionne aussi avec noms de domaine

`host` permet sinon de connaître l'ip associée

```bash
$ host wikipedia.org
wikipedia.org has address 91.198.174.192
wikipedia.org has IPv6 address 2620:0:862:ed1a::1
wikipedia.org mail is handled by 50 mx2001.wikimedia.org.
wikipedia.org mail is handled by 10 mx1001.wikimedia.org.
```

- On peut outrepasser / forcer la résolution DNS de certains domaine avec le fichier `/etc/hosts`

```bash
 > cat /etc/hosts
127.0.0.1	localhost
127.0.1.1	shadow
::1	localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters

127.0.0.1 google.com
127.0.0.1 google.fr
127.0.0.1 www.google.com
127.0.0.1 www.google.fr
127.0.0.1 facebook.com
127.0.0.1 facebook.fr
```

![](/img/linux/admin/recap_network.png)

![](/img/linux/admin/recap_network2.png)

![](/img/linux/admin/recap_network3.png)

### Réseau local, DHCP, NAT (1/6)

- En pratique, on est peu souvent "directement" connecté à internet
    - MachinBox
    - Routeur de l'entreprise
- Pas assez d'IPv4 pour tout le monde
    - nécessité de sous-réseaux "domestique" / des réseau "local"
    - basé sur les NAT (network address translation)
- Quand je me connecte au réseau:
    - mon appareil demande au routeur une IP, suivant le protocole DHCP <small>(dynamic host configuration protocol)</small>
    - le routeur a un range d'IP qu'il peut attribuer, typiquement quelque chose comme `192.168.0.0/24`
    - DHCP permet aussi de configurer certains paramètres, comme le résolveur DNS à utiliser


![](/img/linux/admin/nat1.png)

![](/img/linux/admin/nat2.png)


- Le routeur agit comme "gateway" (la "passerelle" vers les internets)
    - (c.f. `ip route`, et la route par défaut)
- Depuis l'extérieur du réseau local, il n'est pas possible de parler "simplement" à une machine
- Example : Je ne peux apriori pas parler à la machine 192.168.0.12 de mon réseau local chez moi depuis le centre de formation...
- Egalement : Difficulté de connaître sa vraie IP "globale" ! Il faut forcément demander à une autre machine ... c.f whatsmyip.com

La situation se complexifie avec Virtualbox :
- Typiquement Virtualbox créé un NAT à l'intérieur de votre machine
- Les différentes VM ont alors des adresses en 10.0.x.y


![](/img/linux/admin/subnat.png)

![](/img/linux/admin/vpn.png)

### Et les VPNs, késaco ?

- Virtual Private Network
- Il s'agit de faire "comme si" on était connecté depuis un autre endroit

Plusieurs utilités possibles:
- accéder à des services accessibles seulement au sein d'un réseau privé (par ex. entreprise)
- forcer une communication à être chiffrée
- "anonymiser" ses requêtes (partager une IP commune avec pleins de gens)
- contourner des géo-restrictions
- ...

### Autres notions : proxys, firewall


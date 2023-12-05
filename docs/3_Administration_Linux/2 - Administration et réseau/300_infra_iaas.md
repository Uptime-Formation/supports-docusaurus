---
title: Cours - Introduction à l'ingénierie d'infrastructure
---

## Problématiques qui émergent lorsque l'infrastructure ou le nombre d'user grandi

- Haute disponibilité
- Redondance, sauvegarde
- Quel bottleneck (goulot d'étranglement)
    - Storage I/O ? (interactions avec le stockage)
    - Requests I/O ? (gestion des demandes)
    - Computing power ? (gestion des calculs)


## Storage engineering

- Lorsque le besoin grandit : nécessité de séparer la partie OS/application de la partie stockage
- Exemples de technique:
    - NAS
    - SAN
    - RAID
    - Tiering
    - ...


## Storage engineering : NAS

- NAS (network attached storage)
- Un (unique?) périphérique branché au réseau dont la fonction est de s'occuper de la partie stockage des données
- Le NAS s'occupe de la partie système de fichier
- Plusieurs OSs peuvent se connecter sur ce stockage et interagir avec
- Ex. : un espace de partage de documents dans une entreprise


## Storage engineering : NAS

![](/img/linux/admin/synology.png)


## Storage engineering : SAN

- SAN (storage area network)
- Un réseau de périphériques de stockage
- ... connectés sur les machines pour faire "comme si" les disques étaient branchés directement sur la machine
- Accès au niveau "block" : c'est à la machine de gérer l'aspect système de fichier
- Performance + redondance


## Storage engineering : SAN

![](/img/linux/admin/san.png)


## Storage engineering : SAN

![](/img/linux/admin/san.jpg)



## Storage engineering : RAID

- RAID (Redudant Array of Inexpensive Disks)
- Un ensemble d'architecture de stockage pour gérer la redondance, disponibilité, performance, ou capacité
- Géré au niveau software ou hardware
- On parle de "grappe" de disque

![](/img/linux/admin/raid.jpg)


## Storage engineering : RAID

- RAID 0 (striping) :
    - les morceaux d'un fichier sont répartis entre les disques
    - pas d'augmentation de redondance, mais augmentation de la performance
        - (lecture/écriture sur plusieurs disques en parallèle)

![](/img/linux/admin/striping.png)


## Storage engineering : RAID

- RAID 1 (mirror) : 
    - copie des données sur chaque disques (bottleneck = slowest drive)
    - lecture sur n'importe lequel des disques
    - ajouter un disque augmente la redondance mais pas la capacité

![](/img/linux/admin/raid1.png)


## Storage engineering : RAID

- RAID 10 (1+0) : stripping + mirroring
    - nécessite au moins 4 disques
    - performance + redondance
    - jusqu'à 50% de perte de disque (tant qu'un disque + son miroir n'est pas perdu)

![](/img/linux/admin/raid10.png)


## Storage engineering : RAID

- RAID 5 :
    - nécessite au moins 3 disques
    - information répartie entre les disques
    - tradeoff capacité/redondance : une seule perte de disque tolérée 

![](/img/linux/admin/raid5.png)


## Storage engineering : RAID

- RAID 6 :
    - nécessite au moins 4 disques
    - information répartie entre les disques
    - tradeoff capacité/redondance : jusqu'à deux pertes de disque tolérée 


![](/img/linux/admin/raid6.png)


## Storage engineering : tiering

- Optimiser la disponibilité des données et leur coût de stockage, en fonction de la demande

![](/img/linux/admin/tiering2.png)


![](/img/linux/admin/tiering.png)


## Traffic engineering

- Lorsque le nombre d'user grandit : besoin d'optimiser le traitement des requêtes
- Exemple de quelques techniques:
    - caching, zipping
    - load balancing
    - DNS round robin
    - CDN


## Traffic engineering : caching, compression

- Caching
    - par ex. côté client: le navigateur garde en mémoire certaine image pour ne pas les re-demander à chaque requête

- Compression (e.g. avec gzip)
    - compression des données statiques textuels (`.html`, `.js`, `.css`, ...)
    - gain en débit
    - (attention, implications de sécu non triviale, c.f. [BREACH](https://en.wikipedia.org/wiki/BREACH))


## Traffic engineering : load balancing

- Peut avoir lieu au niveau software, ou bien niveau hardware (équipement dédié)
- Le daemon principal réparti le traitement des requêtes entre des workers
- Beaucoups de serveurs logiciels intègrent cette fonctionnalité (`nginx`, `apache`, ..)

![](/img/linux/admin/loadbalancing.jpg)


## Traffic engineering : DNS round robin

- Il s'agit d'une autre technique de load balancing
- Associer plusieurs IP (`A` record) à un nom de domaine
- Lors de la résolution du nom de domaine, un enregistrement est choisi aléatoirement (round robin)


## Traffic engineering : CDN

- CDN (Content Delivery Network)
- Sorte d'opérateur "haut-niveau" (couche 5+) qui proposent comme service une haute dispo pour certains fichiers web (e.g. `.js`) ou contenus multimédias (e.g. video)
- Répartition de serveurs géographiquement dans des "points de présence" (PoP)
- Réponse du DNS en fonction de la proximité géographique
- Interfaçage privilégié avec les opérateurs réseaux directement dans les datacenter / IXP
- Typiquement appliqué au web mais pas seulement (par ex. mirroir des dépots debian)


## Traffic engineering : CDN


![](/img/linux/admin/cdn.png)


## Anything As A Service

- Un des fondement du cloud : l'abstraction de l'infrastructure, de la plateforme et des applications

![](/img/linux/admin/aas.jpg)

## Anything As A Service

- Sur les plateformes d'IaaS, on peut non seulement louer des machines, mais aussi des services comme : stockage additionels, load balancer,firewall, ...

![](/img/linux/admin/pizza-as-a-service.jpeg)

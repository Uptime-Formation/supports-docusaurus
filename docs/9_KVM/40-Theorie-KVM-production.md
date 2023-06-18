# Theorie : KVM en production

## Objectifs pédagogiques

**Théoriques**

- Connaître les contraintes opérationnelles de KVM en production

--- 

## Le stockage



Un serveur est composé de quatre éléments principaux :

le processeur ;

la mémoire vive (RAM) ;

le réseau ;

le disque dur.

Cette partie s’intéresse aux disques durs et présente les différents modes de stockage des VM.

## Stockage par fichiers

C’est la méthode la plus courante et aussi la plus simple à configurer. Le disque dur de la VM est en fait un simple fichier disque. La taille de ce fichier définit la dimension du disque dur de la VM. Il est possible d’utiliser deux types de fichiers :

fichier plein ou complet ;

fichier à trou (sparse file) ou encore alloué dynamiquement.

Sous Linux, la création de ces fichiers est simple via la commande dd.

La commande suivante crée un fichier plein ou complet sous /home nommé disk1.img d’une taille de 10 Go. La clause bs=512K permet de définir une taille de blocs en conformité avec la norme Unix des disques durs.


dd if=/dev/zero of=/home/disk1.img bs=512K count=20000
 
La commande suivante crée un fichier à trou ou alloué dynamiquement sous /home nommé disk2.img d’une taille initiale nulle pouvant aller jusqu’à 10 Go.


dd if=/dev/zero of=/home/disk2.img bs=512K count=0 seek=20000
 
La différence entre les deux commandes fait que dans le cas du fichier plein, le fichier est complètement créé avec sa taille définitive, ceci prend donc un peu de temps. Dans le second cas, le fichier est vu par l’OS comme faisant 10 Go mais sa taille réelle est beaucoup plus faible. Ici, la création est rapide, quasi instantanée, quelle que soit la taille demandée. En fonction du besoin en place disque, le fichier s’étendra jusqu’à son maximum, soit 10 Go. Le paramètre -s de la commande ls permet de visualiser la différence entre ce que voit l’OS et la taille réelle.


ls -shl /home/disk*.img  
  
9,8G -rw-r--r-- 1 erik erik 9,8G août  23 10:06 disk1.img  
$ 0 -rw-r--r-- 1 erik erik 9,8G août  23 10:09 disk2.img
 
Les fichiers pleins sont plus performants. En effet, il n’est pas nécessaire en cas de besoin de capacité plus importante du disque d’allouer cet espace. Ceci implique donc moins d’entrées/sorties. Par contre, en cas de déplacement de la VM, il faut transférer l’intégralité du fichier et ce quel que soit son taux de remplissage.

Le fichier à trou, au contraire, est créé très rapidement. En fonction du volume disque, le fichier va "grossir". Il y aura donc un surcoût d’I/O pour gérer cette extension. Par contre, en cas de déplacement de la VM, seule la taille réellement utilisée sera transférée.

En production, il est conseillé d’utiliser plutôt des fichiers complets. Dans certains cas, notamment pour la mise en place d’un système de fichiers clusterisés ou de disques partagés, c’est obligatoire.

## Stockage LVM

Cette fonctionnalité est bien connue des administrateurs Linux. LVM permet la modification d’un système de fichiers de manière dynamique, à chaud et sans perte. Appliqué au stockage des VM, il permet l’agrandissement du disque dur de manière souple. LVM est assez consommateur de CPU. De plus, l’arrivée prochaine de BRTFS (prononcer "ButterFS") comme futur système de fichiers standard sous Linux permettra les mêmes fonctions que LVM.

## Stockage partagé

Lors de la mise en place d’une plate-forme de production de virtualisation, c’est la solution la plus intéressante. Dans ce type de configuration, les disques des VM sont accessibles par tous les hôtes de virtualisation. Grâce à ce principe, la migration à chaud des VM d’un hôte vers un autre est très facile.

Mettre en place un stockage partagé peut être simple. Le protocole NFS (Network File System) utilisé sous Unix depuis sa création est une solution. Aujourd’hui, NFS est supplanté par iSCSI (se prononce "aie-squese-zi"). La présentation de la mise en place de iSCSI sera vue dans le chapitre Stockage partagé.

Si l’entreprise dispose de moyens financiers importants, il est également possible d’utiliser un SAN (Storage Area Network). Ce type d’architecture utilise le protocole Fiber-Channel. iSCSI permet d’obtenir un SAN à moindre coût. Attention toutefois, la performance n’est pas du tout la même.


**Chaque solution présente des caractéristiques, des avantages et des considérations spécifiques en matière de stockage, offrant différentes options pour répondre aux besoins des utilisateurs.**

## SAN (Storage Area Network)

**Le SAN est un réseau dédié au stockage qui utilise des composants spécialisés (HBA).**

Le protocole Fiber Channel est le plus couramment utilisé dans les SAN, mais il est coûteux et nécessite une configuration complexe.

Une alternative plus simple et économique consiste à utiliser un serveur Linux avec une capacité de stockage et le protocole iSCSI, qui encapsule des informations SCSI dans des paquets IP.

Cette solution sera mise en œuvre dans l'étude présentée dans le livre.


## NAS (Network Attached Storage) 

**Le NAS est un serveur de fichiers accessible via une adresse IP.**

Il permet un accès au stockage sous forme d'un espace disque.

Le protocole NFS, historiquement utilisé, a été remplacé par SMB ou CIFS, notamment grâce à Samba.

De nombreux fabricants proposent des boîtiers NAS compacts avec une interface d'administration conviviale.

Il est également possible de créer un NAS à partir d'un PC avec des disques et un système d'exploitation Linux.

BSD propose également une solution intéressante appelée FreeNAS.

## DAS (Direct Attached Storage) 

**Le DAS est une méthode classique où les disques durs sont directement connectés au serveur via un contrôleur.**

Différents types de contrôleurs existent, allant des moins performants (et moins chers) aux plus performants (et plus coûteux), tels que IDE ou ATA, SATA, SCSI et SAS.

Les vitesses de rotation et les capacités des disques varient selon l'interface utilisée.

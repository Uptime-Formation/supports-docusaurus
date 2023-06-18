# Evaluation 2

## Théorie 

### Virtualisation / Systèmes de fichiers 

Les systèmes de fichiers suivants permettent d'opérer des clusters de disques QEMU/KVM 

- iSCSI
- ext4 
- CephFS
- GlusterFS

### Virtualisation / réseaux  

Quelles sont les avantages d'une solution d'interfaces réseaux virtuelles / Software Define Networking dans une infrastructure de virtualisation ?

### Virtualisation / services  

Quelles sont les problématiques d'adressage / mise à disposition des services déployés dans une infrastructure virtualisées ?

### Virtualisation / MCO

Quels sont les avantages d'une virtualisation des machines supportant des charges utiles en terme de maintenance ? 

## Pratique 

### IHM console : lister 

Quelle commande permet de lister les instances KVM lancées dans libvirt, y compris celles qui sont stoppées ?

### IHM console : sauver 

Quelle commande permet de faire un snapshot du disque de la VM `guest1` ?

### IHM console : migrer

Quelle commande permet de migrer à chaud (online) une VM vers le host `kvm1"

## Statégie 

### Virtualisation / Conteneurs

Pourquoi est-il est courant de faire tourner des systèmes de conteneurisation dans des Machines Virtuelles ?

### Virtualisation / Plateformes

Quels sont les avantages et les inconvénients des plateformes qui forment des clusters de virtualisation, comme Proxmox ?
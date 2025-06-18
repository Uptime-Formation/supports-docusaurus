# Evaluation 1

**Questions à choix multiples!**

## Théorie 

### Virtualisation : principe 

La virtualisation peut se faire à la portée

- [ ] d'un utilisateur du système
- [ ] d'un système complet
- [ ] d'un processus
- [ ] d'un flux réseau 
 

### Virtualisation : QEMU

QEMU permet de virtualiser

- [ ]  une carte son
- [ ]  un processeur ARM
- [ ]  un port série 
- [ ]  une carte vidéo

### Virtualisation : KVM 

KVM est un hyperviseur

- [ ]  vrai
- [ ]  faux

### Virtualisation : Réseau

Pour accéder à Internet depuis une VM KVM il faut nécessairement qu'elle ait

- [ ]  une interface 
- [ ]  une adresse IP
- [ ]  une adresse de routage

## Pratique 


### IHM Web : installation

Pour installer un OS sur une VM de manière traditionnelle, il faut

- [ ]  un accès à la sortie graphique de la VM
- [ ]  un switch virtuel 
- [ ]  une image ISO de l'OS monté dans le CD virtuel
- [ ]  au moins 4 processeurs viruels

### IHM Web : dépendances 

Pour installer des machines KVM dans une IHM web Cockpit il faut

- [ ]  des droits d'administration
- [ ]  QEMU et KVM installés
- [ ]  accès à une image ISO sur le serveur 
- [ ]  un réseau et un pool de stockage sur le host

### IHM Web : images 

Sur une machine Debian avec une IHM web on peut lancer des VM 

- [ ]  Debian
- [ ]  Ubuntu
- [ ]  Alpine 
- [ ]  Windows

### Images simples 

Quelle est la commande pour créer une machine centos6 avec un disque de 50 Go et le mot de passe root "Jrz2kT5KErlBstU" ?

## Statégie 


### Licences 

Les hyperviseurs avec des licences libres

- [ ] ne peuvent lancer que des OS linux
- [ ] exigent un support payant
- [ ] sont maintenus par des bénévoles 
- [ ] permettent des audits sécurité de leur code  

### Virtualisation / Conteneurs 

Par rapport à la virtualisation 

- [ ]  les conteneurs ont un noyaux individuel renforcé
- [ ]  les conteneurs sont une technique plus ancienne 
- [ ]  les conteneurs utilisent aussi KVM
- [ ]  les conteneurs Docker sont des IAC simples 

### Virtualisation / IHM

Les IHM Cockpit, Proxmox, Openstack pour QEMU/KVM 

- [ ]  utilisent des méthodes identiques  
- [ ]  fournissent les mêmes backends de stockage
- [ ]  fournissent toutes des API cloud 
- [ ]  fournissent toutes des capacités de migration 

# Formation KVM

![](/img/kvm/kvm-logo.png)

## Objectifs pédagogiques

Théoriques

- Connaître les spécificités de la virtualisation KVM
- Connaître les IHM permettant de piloter KVM
- Connaître les contraintes opérationnelles de KVM en production

Pratiques

- Installer KVM et ses IHM
- Créer des images système pour KVM
- Opérer des instances KVM via ses IHM
  - Démarrer un nouvel OS invité (VM)
  - Configurer le réseau dans KVM (NAT, libvirt, bridge, etc.)
  - Maîtriser le stockage (pool, volume, chiffrement, virtfs)

Stratégiques

- Savoir choisir KVM comme outil d'architecture en fonction de critères rationnels.

---

## Angle d'approche / problématiques

* Quelles sont les grandes problématiques de KVM en production ?
  * Déploiement 
  * Réseau
  * Stockage
  * Sauvegarde
  * Monitoring
* Comment s'inscrit KVM dans le paysage des conteneurs ?
  * Déploiement : des capacités d'IAC différentes
  * Production : des rôles différents

---

## Démo / Déroulé 

- Choisir un identifiant pour la machine virtuelle
- Choisir une image 
- Choisir les paramètres de virtualisation  
- Démarrer l'instance KVM  
- Installer le système à partir de l'image de base  
- S'y connecter 
- Configurer un service sur l'instance
- Valider que le service fonctionne


### Jour 1

- Théorie : virtualisation 
- Théorie : les IHM
- Pratique : IHM web 

### Jour 2

- Contraintes opérationnelles réseau et stockage 
- Déploiement : créer des images  
- Pratique : IHM console 
- Pratique : périphériques virtuels réseau et stockage 

---


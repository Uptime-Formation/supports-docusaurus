
# 1.17 TP : créer ses images avec Packer 

## Objectifs pédagogiques

**Théoriques**

- Connaître les spécificités de la virtualisation KVM

**Pratiques**

- Installer KVM et ses IHM
- Créer des images système pour KVM
- Opérer des instances KVM via ses IHM
  - Démarrer un nouvel OS invité (VM)

---

![](../../static/img/kvm/kvm-logo-packer.png)

**Packer est une solution Hashicorp d'IAC images.**

> https://www.packer.io/

Packer est un outil open source permettant de créer des images machine identiques pour plusieurs plates-formes à partir d'une configuration source unique.

**Packer est léger, fonctionne sur tous les principaux systèmes d'exploitation et est très performant, créant des images machine pour plusieurs plates-formes en parallèle.**

Packer ne remplace pas la gestion de configuration comme Ansible.

En fait, lors de la création d'images, Packer est capable d'utiliser des outils comme Ansible pour installer des logiciels sur l'image.

--- 

**L'intérêt de Packer est de normaliser la création d'images pour une chaîne CI/CD.**

Packer distingue deux types fondamentaux de patterns pour générer des images : 
- les _builders_ sont les plateformes qui vont accueillir le build comme AWS, VMWare ou QEMU
- les _provisioners_ sont les composants d'IAC de configuration comme les scripts shell ou Ansible 


---

## TP : Installer une application sur une image générée via Packer

**Cloner le projet https://github.com/Uptime-Formation/packer-examples**

Observez le langage utilisé pour définir l'image souhaitée : le connaissez-vous ?

Créez une image qui vous permette de déployer une application de votre choix.

Attention : le temps d'attente pour l'installation peut être long car on part d'une ISO brute qu'il faut réinstaller depuis la base.

---

:::tip avancé 

Comment utiliser Ansible comme provisioner ?

:::

---


## Objectifs pédagogiques

**Théoriques**

- Connaître les spécificités de la virtualisation KVM

**Pratiques**

- Installer KVM et ses IHM
- Créer des images système pour KVM
- Opérer des instances KVM via ses IHM
  - Démarrer un nouvel OS invité (VM)

---
---
title: 'QCM Ansible Correction'
draft: true
sidebar_class_name: hidden
---


**Question 1**

Pour configurer une machine Ansible agit...

1. ... grâce à un agent depuis l'intérieur des machines à configurer.
2. **V**... de l'extérieur depuis le poste du DevOps ou un serveur d'administration.
3. ... depuis l'extérieur grâce à un orchestrateur comme docker swarm.

**Question 2**

Comment est organisé un role ?

1. Une archive tar.gz avec à l'intérieur des fichiers tasks.yml, defaults.yml et des fichiers de templates à copier sur les serveurs.
1. Un dossier de fichiers .yml avec une structure interne variable selon les choix du développeur du role.
1. **V** Un dossier avec des sous dossiers tasks, files, etc contenant des fichiers main.yml ou fichiers à copier sur les serveurs.

**Question 3**

Pour utiliser un role tier déjà installé il faut d'abord

1. Lancer `ansible install` qui se chargera de l'appliquer automatiquement sur les noeuds.
1. Lancer `ansible clone` puis utiliser r10k pour activer le role.
1. **V** Lire son readme sur github pour savoir quelles variables utiliser pour le paramétrer.

**Question 4**

Ansible Galaxy désigne :

1. **V** Le dépôt officiel de rôles ansible et la commande pour les installer.
1. La communauté red hat orientée DevOps qui fournit des conseils sur `OpenShift`.
1. Le programme spatial de Red Hat pour concurrencer Elon Musk.

**Question 5**

Quel module Ansible sert à installer des paquets sous ubuntu ?

1. `package`
1. **V** `apt`
1. `debian_pkg`
1. `yum`
1. `apt_get`

**Question 6**

Les variables ansible sont stockée sous la forme ?

1. `d'une base de donnée noSQL`
1. `d'un dictionnaire séparé pour chaque playbook`
1. `d'un fichier binaire récupéré depuis une API`
1. **V** `d'un gros dictionnaire global`

**Question 7**

Qu'est ce qu'une commande adhoc ?

1. Un module Ansible qui permet d'utiliser des commandes bash dans les playbooks.
2. **V** Une façon d'appeler directement un module ansible à des fins d'orchestration du parc de machine.
3. Une commande qui appelle un role pour configurer automatiquement une machine.

**Question 8**

Quelle est la nouvelle syntaxe pour les boucles dans Ansible ?

1. `for: {{ une_liste }}` à la fin d'une tache.
1. `for_item_in: {{ une_liste }}` à la fin d'une tache.
1. `with_items: {{ une_liste }}` à la fin d'une tache.
1. **V** `loop: {{ une_liste }}` à la fin d'une tache.

**Question 9**

Au sein d'un play, la section `roles:` s'exécute...

1. Toujours après la section `tasks:`
1. Toujours avant la section `tasks:` c'est d'ailleurs pour cela qu'il existe une section `pre_tasks:`
1. En fonction de l'ordre des taches dans le playbook
2. En fonction de la configuration dans `ansible.cfg`

**Question 10**

Quelle est la nouvelle syntaxe pour les boucles dans Ansible

1. `for: {{ une_liste }}` à la fin d'une tache.
1. `for_item_in: {{ une_liste }}` à la fin d'une tache.
1. `with_items: {{ une_liste }}` à la fin d'une tache.
1. **V** `loop: {{ une_liste }}` à la fin d'une tache.
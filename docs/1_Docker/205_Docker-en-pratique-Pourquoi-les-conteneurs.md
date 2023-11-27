---
title: 2.05 Docker en pratique Pourquoi les conteneurs
pre: "<b>2.05 </b>"
weight: 18
---
## Objectifs pédagogiques
  - Connaître l'histoire des conteneurs
  - Comprendre les raisons du développement des conteneurs
  - Identifier les problèmes réseau et persistance associés

---

# Une (petite) histoire des conteneurs 

* 1979 : Chroot
* 2000 : BSD Jail
* 2001 : Vserver 
* 2002 : Linux Namespaces 
* 2006 : Process Containers (cgroups)
* 2008 : LXC 
* 2013 : Docker 
* 2014 : rkt
* 2016 : runc, containerd, cri-o
* 2018 : Kubernetes

---

# Les facteurs de lecture

* [E] Des évolutions techniques...
* [P] impactant la persistance des données...
* [R] et la distribution du service sur le réseau.

---

# Les étapes


## 1979 : Chroot

* [E] Une évolution technique "pure" liée à l'espace disque

> Analogie : Une maison, qui dispose de sa cuisine, salle de bain, etc.  
> Dans les combles, on aménage un appartement avec sa propre cuisine, salle de bain, etc.    
> C'est une maison dans la maison.  
> Quand on cherche une casserole ou une brosse à dents, on cherche ailleurs, localement.

La commande `chroot` permet de changer la racine d'un process.

C'est une forme primaire de Sandboxing.

Elle sert à l'époque pour construire des honeypots, mais son usage va se répandre.

Il permet notamment de tester une application sans risque d'effets secondaires sur le reste du système.

---


## 2000 : BSD Jail

* [E] Chroot + isolation, mais seulement BSD

Les Jails sont une amélioration des chroots pour le Sandboxing.

Les Jails BSD isolent les process, les utilisateurs et le réseau. 

Cette technique assez simple d'emploi a été utile notamment pour de petits hébergeurs afin de mutualiser des serveurs avec une meilleure garantie de sécurité.

Elle reste néanmoins assez méconnue des entreprises car le système BSD est une niche de spécialistes.

Les données des utilisateurs sont stockées sur le disque du serveur, qui héberge directement les services.

La persistance des données utilisateurs n'est pas impactée et les services ne bougent pas sur le réseau. 


---

## 2001 : Vserver 

* [E] Un sandboxing "maison" dans Linux

Vserver s'inspire des Jails BSD pour apporter du Sandboxing de process au noyau Linux. 

Mais le fait que la technique requiert des patchs spécifiques du noyau Linux limite le succès de cette approche.

---

## 2002 : Linux Namespaces 

* [E] Un sandboxing standard dans Linux

> Analogie : Une société multinationale.   
> Le salarié n°1 de la filiale française pense qu'il est le n°1.  
> Mais pour les RH centraux, il est le n°1251. Et le n°2 français est le n° 1265.  
> Et c'est la même chose pour les différentes filiales.  
> Le numéro local est différent du central.

Le noyau Linux intègre cette nouveauté : la capacité de cloisonner les processus.

Ce cloisonnement se fait par "domaine par domaine" : les montages, les PIDs, le réseau, etc.

C'est le début formel des conteneurs Linux car les namespaces sont encore utilisés aujourd'hui, notamment par Docker.

On voit ici que l'évolution de la technique requiert un temps relativement long pour être intégré dans le noyau Linux et ainsi disponible dans tous les systèmes.

---

## 2006 : Process Containers (cgroups) 

* [E] Ajout de capacités de comptabilité et de limitation 

> Analogie: Dans une maison, les enfants ont une seule console de jeu portable.  
> Chacun a droit à seulement une heure de console par jour.  
> Un système les identiie et va les bloquer quand ils ont dépassé leur temps individuel.  
> Un décompte de temps est pratiqué et une mesure de blocage intervient.  
> De plus les parents peuvent avoir un contrôle du temps consommé.

Google apporte une nouvelle dimension au Sandboxing de process dans le noyau Linux.

Cette technique permet au noyau Linux de contraindre la consomemation de process regroupés (les container groups).

CPU, mémoire, disque, réseau, I/O : les aspects fondamentaux de ce qu'un process peut consommer sont mesurés et limitables. 

Dès 2008, les cgroups intègrent le noyau Linux, alors que Google les utilise en interne.

---

## 2008 : LXC 

* [E] Outil simplifiant l'accès aux techniques existantes
* [P][R] Certains opérateurs commencent à distribuer les services dans des conteneurs à durée de vie courte

Les **L**inu**X** **C**ontainers utilisent les cgroups et les namespaces désormais disponibles.

C'est la première solution grand-public de conteneurisation.

L'utilisation de LXC revient le plus souvent à lancer des systèmes complets, avec des gains de simplicité et de performances.

Le fait de passer "à l'échelle" permet de découvrir de nombreuses failles de sécurité auxquelles les développeurs n'avaient pas pensé. 

Ces failles sont corrigées au fur et à mesure mais donnent une réputation de faible sécurité aux conteneurs.

La sécurité s'améliorant, de nombreux hébergeurs vont utiliser LXC pour mettre à disposition de leurs clients des conteneurs.

Certains hébergeurs les fournissent sous forme de serveurs privés, avec une couche réseau et un stockage stables. 

D'autres comme Heroku vont avoir une approche Cloud, avec des conteneurs qui apparaissent et disparaissent selon les déploiements et les besoins.

Cette approche place alors les questions de réseau (service mesh) et de persistance des données au coeur de ses considérations.

---


## 2013 : Docker 

* [E] Outil facilitant la création d'images et préconisant les instances "jetables" 
* [P][R] Le réseau dynamique et les volumes externes font partie de la solution.

Docker s'est basé sur les LXC, et donc les progrès précédents, avec une approche différente. 

La solution s'est tournée vers les développeurs, en leur permettant de construire des images personnalisées pour leurs applications.

Au contraire de LXC, elle recommande l'exécution de process uniques et pas de systèmes complets (init as PID 1).

Elle fournit un écosystème applicatif permettant de construire ces images, les télécharger, et les exécuter.

Auparavant, ce travail était réservé à des administrateurs système experts. 

La méconnaissance des contraintes de sécurité de production et la faiblesse du fichier de système initial donnent une mauvaise réputation au produit chez les adminsys.

Au fur et à mesure des progrès en terme de stabilité et de bonnes pratiques, la solution prend son envol.

---


## 2014 : rkt

* [E] Une "copie" de Docker
* [P][R] avec les mêmes problématiques persistance et réseau

C'est la première alternative à Docker, produite par CoreOS.

Elle utilise ses propres formats d'application et d'images par rapport à Docker.

L'idée d'une standardisation des formats se fait jour afin de pouvoir rendre interopérable les conteneurs légers.

L'usage de rkt restant limité, la solution a péréclité.

---

## 2016 : runc, containerd, cri-o

* [E] La standardisation de l'écosystème Docker dans Linux

Les progrès d'une initiative commune nommée OCI (Open Container Initiative) donnent naissance à des projets de "Docker sans Docker".

Docker participe directement à cet effort au sein d'un projet de la Linux Foundation et les intègre à son propre système. 

Désormais le runtime de haut niveau (containerd) et celui de bas niveau (runc) sont utilisables par tous.

Les usages vont aller en grandissant car le modèle open source va améliorer et croître sur ces bases.

Docker tend à devenir une brique interchangeable dans des systèmes plus complexes.

---

## 2018 : Kubernetes 

* [E] Un orchestrateur de conteneur pour les exécuter en production 
* [P][R] Persistance et Réseau font partie de la définition du service et sont orchestrés comme les conteneurs

Dès 2015 des orchestrateurs comme Mesos (Apache), Swarm (Docker) émergent.

Leur ambition est de fournir des systèmes complets permettant d'exécuter des conteneurs légers dans des contraintes de production.

La solution Kubernetes développée au sein cu CNCF (Cloud Native Computing Foundation), un projet de la Linux Foundation tend à s'imposer comme l'orchestrateur staandard.

À l'origine, c'est un projet développé chez Google, en s'inspirant de ses propres outils internes. 

Complexe, K8S permet de gérer tous les détails complexes d'une exécution dans des contraintes de sécurité. 

Le réseau et la persistance des données deviennent des objets de premier niveau, avec une approche modulaire.
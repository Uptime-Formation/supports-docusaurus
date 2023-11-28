---
title: Déployer avec Docker L'évolution de l'écosystème des conteneurs
weight: 28
---

## Objectifs pédagogiques
  - comprendre les composants nécessaires pour un système de conteneurs
  - connaître les alternatives à Docker

# *Docker is dead?* Un petit temps pour l'anatomie

Docker a été normalisé par la Linux Foundation.

**C'est un moyen pour faire évoluer la technologie alors que l'entreprise Docker n'a pas trouvé de voie commerciale viable.**

On peut ainsi considérer que Docker est une techno fondatrice, qui n'avait pas forcément vocation à devenir un produit payant.

Désormais Docker tend à devenir un modèle de système qui est amélioré et implementé par différents opérateurs.  

## Comment ça marche Docker?

![](https://www.docker.com/wp-content/uploads/974cd631-b57e-470e-a944-78530aaa1a23-1.jpg)

On voit qu'il y a plusieurs couches distinctes
* ILM / interfaces utilisateurs (docker, docker-compose) et autres, pour gérer le cycle de vie des conteneurs 
* Container Engine: Les gestionnaires de fonctionnalités (volumes, réseaux, etc.)
* Container Runtimes : Les runtimes d'exécution (containerd, runc)
* OS et Infrastructure : Les parties matérielles 

La partie Container Runtimes a été normalisée comme on l'a vu. 

À quoi sert-elle plus précisément ?
 
## containerd : le runtime haut

https://www.docker.com/blog/what-is-containerd-runtime/

Le rôle de containerd est de fournir des éléments de haut niveau nécessaire à l'exécution des conteneurs. 

* Prise en charge de la gestion des images, push et pull 
* Fourniture d'une API de cycle de vie de conteneur pour créer, exécuter et gérer des conteneurs et leurs tâches 
* Fourniture d'une API entière dédiée à la gestion des snapshots 
 
**En somme une plate-forme de conteneurs sans avoir à gérer les détails sous-jacents du système d'exploitation.** 

Sous la forme d'une API versionnée et stable qui aura des corrections de bogues et des correctifs de sécurité rétroportés. 

## runc : le runtime bas

https://www.docker.com/blog/runc/

* Un format de configuration formellement spécifié, standardisé par l'Open Container Initiative sous les auspices de la Linux Foundation.
* Prise en charge des espaces de noms (namespaces) Linux
* Prise en charge des fonctionnalités de sécurité disponibles sous Linux : groupes de contrôle (cgroups), suppression de capacités (capabilities), Selinux, Apparmor, seccomp, pivot_root, suppression d'uid/gid, etc.
* Prise en charge multi architectures y compris Arm, Sparc, et d'autres 
<!-- * Profils de performances portables. -->

**En somme un standard robuste et évolutif, depuis 2015.**


# Container engines 

**Une fois des standards définis pour les opérations de base, il existe différents moteurs de conteneurs qui font l'interface avec l'utilisateur.**

Ces moteurs vont du plus simple au plus complexe, selon le besoin des utilisateurs.

* "Daemonless" : Podman, sans démon comme le docker-engine, qui vient avec sa propre suite logicielle (Buildah, Skopeo) qui gère le build et le transfert d'images
* Gestion simple avec un daemon : Docker
* Mini-orchestrateurs : 
  * k3s, une version simplifiée de Kubernetes
  * microk8s
  * kind (k8s dans docker)
* Orchestrateurs 
  * Kubernetes, qui nécessite plusieurs serveurs 
  * Mesos
  * rke2
* Super orchestrateurs 
  * Open Shift (RedHat) qui fournit une surcouche à Kubernetes

**Le rôle de ces moteurs est de prendre en charge les entrées utilisateurs et de fournir un service final de gestion des conteneurs**

On dispose ainsi d'une boîte à outils permettant de choisir des solutions adaptées aux besoins.

# CRI, Docker et Kubernetes

**Depuis Kubernetes 1.24 (mai 2022), Kubernetes ne supporte plus Docker en tant que Container Runtime.**

Désormais K8S utilise uniquement des Container Runtime compatible Container Runtime Initiative, comme containerd.

Pour comprendre ce cas d'usage "canonique", voyons comment Docker et Kubernetes interagissaient.

![](https://miguelminoldo.files.wordpress.com/2022/08/image-1.png)

En dehors de containerd, `cri-o` est l'alternative développée au sein du projet Kubernetes.

De la même manière l'idée est de normaliser le fonctionnement pour éviter les situations de monopole et d'enfermement.

# Open Container Initiative (OCI)

De nombreuses solutions ont émergé de cette organisation.

https://www.docker.com/blog/demystifying-open-container-initiative-oci-specifications/

Les images OCI sont une spécification bien faite avec un manifeste standardisé et évolutif => Docker a fait converger le format des images Docker avec cette spécification.

Des solutions simples :
* runc
* crun
* runhcs (windows OCI compliant)

Grace au format d'image : des solutions qui ajoutent de la sécurité en allant "vers les Machines Virtuelles"
* [firecracker-containerd](https://github.com/firecracker-microvm/firecracker-containerd) qui fournit des VMs légères 
* [gvisor](https://github.com/google/gvisor) qui fournit un kernel léger



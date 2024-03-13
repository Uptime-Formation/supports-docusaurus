---
title:  Objectifs de Kubernetes
weight: 32
--- 

## Objectifs de Kubernetes



**Pourquoi ai-je besoin de Kubernetes et que peut-il faire?**

Kubernetes a un certain nombre de fonctionnalités.

* Une plate-forme d'orchestration résiliente
* Une plate-forme cloud sans vendor lock-in
* Une plate-forme de conteneur
* Une plate-forme de microservice
* Une plate-forme de déploiement
* Une plate-forme mutualisable en single-tenant
* Une plate-forme customisable 

---

 ## Une plate-forme d'orchestration résiliente

**Kubernetes utilise des arbres de dépendances pour créer les ressources dans l'ordre.** 

De plus Kubernetes part du principe qu'une infrastructure est régulièrement "cassée" et utilise ces dépendances pour recréer / redémarrer des parties de l'infrastructure qui auraient disparues ou seraient manquantes.

---

 ## Une plate-forme cloud sans vendor lock-in

**Kubernetes est une solution qu'on peut déployer sur cloud privé et cloud public.** 

C'est une solution généralisable qui peut fonctionner quasiment de la même manière sur des hébergements différents.

---

 ## Une plate-forme de conteneur

**Les conteneurs à base d'image Docker sont le composant applicatif dans Kubernetes.** 

Ceci permet de bénéficier des avantages et de l'écosystème de Docker.


---

 ## Une plate-forme de microservice

**Kubernetes fournit un outillage dédié à la gestion de la mise en réseau des charges applicatives.** 

Ces outils permettent d'interconnecter les applications entre elles au sein du cluster.

---

 ## Une plate-forme de déploiement

**Kubernetes gère les déploiements multi-instances pour les charges utiles et les rotations de version.**

L'automatisation des changements de version est appliqué sur des répliques avec une logique de zero-downtime.


--- 

## Une plate-forme mutualisable en single-tenant

**Kubernetes fournit une séparation des charges utiles par namespace qui rend un cluster exploitable au sein d'une "zone applicative" ex: prod extranet.**

La logique est qu'il devient possible de mutualiser les ressources au sein du cluster en appliquant des politiques de sécurité limitant les droits (RBAC).

En revanche les déploiements kubernetes multi-tenants sont déconseillés.

--- 

## Une plate-forme customisable 

**Kubernetes met à disposition un framework extensible pour ajouter des objets de bas niveau qui seront disponibles pour tout le cluster.**

Ainsi il est possible de personnaliser la solution en fonction des besoins spécifiques d'une organisation : stockage de secrets, authentification, voire besoins métiers spécifiques.
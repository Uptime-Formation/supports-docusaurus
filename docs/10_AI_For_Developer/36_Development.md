--- 
title: 4 - Bien développer
---

## Les limites du code généré par IA

### Premier niveau 

- Est-ce que le code fonctionne ? 
- Est-ce que le code est bon ?
- Est-ce que les dépendances (ex: JS) sont sécurisées ? 

### Deuxième niveau 

- Est-ce que je dois faire du copier / coller à chaque fois ? 
- Qu'est-ce qui se passe quand je veux faire évoluer le code ?
- Comment je vais déployer ça ?

---

## Quelques pistes pour mieux coder avec l'IA 


```text

Adopter l'architecture hexagonale pour séparer le cœur métier des dépendances externes (bases de données, API, UI), en utilisant des ports et des adaptateurs.
Implémenter l'injection de dépendances pour gérer les dépendances de manière dynamique et découpler les composants.
Appliquer le Domain-Driven Design (DDD) pour modéliser les règles métier complexes et structurer l'architecture autour des entités et des domaines.
Utiliser le pattern de service (Service Layer) pour regrouper la logique métier et isoler les couches de présentation et de persistance.
Respecter le principe de responsabilité unique (Single Responsibility Principle) pour maintenir la modularité et la maintenabilité du code.
Appliquer le principe Open/Closed (ouverture aux extensions, fermeture aux modifications) pour permettre l'ajout de nouvelles fonctionnalités sans altérer l'existence.
Concevoir des interfaces claires et testables, en favorisant l'abstraction pour faciliter le mocking et les tests unitaires.
Utiliser le pattern Strategy pour encapsuler des algorithmes interchangeables et éviter la duplication de code logique.
Intégrer des pratiques de versioning (comme Git) et de gestion des branches pour collaborer efficacement sur l'architecture et le code.

```

### Découpler pour éviter les adhérences et les blocages

#### Penser modulaire

**Les fonctions de conversion de données en tableau doivent être dans un module / une classe à part.**

----

####  Architecture hexagonale / écrire des interfaces 

**La conception en ports / adapters permet de découpler les composants et facilite les tests unitaires.**

Par exemple, du JSON pourrait être utilisé en plus du format Excel. 

Si le code est écrit pour une seule implémentation, il sera difficile de changer de format sans refactorer massivement.

---

#### Gérer les dépendances comme des priorités

**La sélection des dépendances et des frameworks est un enjeu essentiel : il faut certainement canaliser les choix du LLM pour minimiser la dette technique.**  


---

#### Urbaniser les flux

**Définir les formats d'échange standard pour formaliser les entrées / sorties du code.**  

Les formats de données en transit ont vocation à être décrits précisément pour permettre à différents logiciels de les consommer.



---

### Utiliser les méthodes de la Livraison Continue (Continuous Delivery)

**Des décennies de progrès dans l'ingénierie logicielle ont permis de faire émerger certaines méthodes comme le Continuous Delivery.**

---

#### Faire le plus dur d'abord (MVP)

**Un MVP n'est pas juste un produit qui fonctionne mais un produit qui remplit les fonctionnalités les plus complexes à mettre en place.**

Le reste est une question de tuyauterie, d'extensions, de branchements, de polissages, certes importants mais qui n'apporte pas autant de valeur. 

---


#### Toute livraison est librable au client (Feature Flags)

**En livraison Continue, chaque build est censé être exploitable en production, même s'il est porteur de fonctionnalités désactivées.**

C'est pour cela que les fonctionnalités sont souvent désactivées par défaut et activées par des flags de configuration.

---

#### Tester automatiquement dans les pipelines de livraison (CI)

**Afin de garantir que chaque build est vraiment exploitable, l'intégration continue valorise l'automatisation des tests, du build et de la livraison de packages.** 

---

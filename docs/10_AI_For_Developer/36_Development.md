--- 
title: 4 - Bien développer
---

## Les limites du code généré par IA

**Niveau 1 : On a vu du mal à canaliser la sortie des modèles.**

A ce premier niveau on a des soucis sur la cohérence et la qualité du code produit.

- Est-ce que le code fonctionne ? 
- Est-ce que le code est bon ?
- Est-ce que les dépendances (ex: JS) sont sécurisées ?

---

**Le risque est de stagner à ce niveau : on se limite à un usage superficiel des modèles.**

- autocomplétion
- production de helpers
- production de tests à la main

---

**Niveau 2 : Une fois que certaines bonnes bases acquises, de nouveaux problèmes surgissent.**

On commence à se poser des questions d'augmentation de productivité.

- Eviter le copier / coller  
- Généraliser les bonnes pratiques / personas
- Standardiser les formats 


---

**Le risque est de se limiter à des POC et des projets satellites.**

- Complexité à gérer une codebase legacy
- Complexité à ajouter des features

---



**Niveau 3 : Les bonnes pratiques sont maîtrisées vous pouvez passer à un mode agentique.** 

Avec les outils agentiques de type Void ou Claude Code, vous allez pouvoir faire travailler le modèle de manière autonome. 

Avec de bons personas et de bons fichiers de contraintes, vous pourrez cadrer vos agents.

Exemple : https://github.com/jelmer/xandikos/blob/fe2792669566c13754232eefafffa3db2cb52323/CLAUDE.md?plain=1


---

## Quelques pistes pour mieux coder avec l'IA 


### Découpler pour éviter les adhérences et les blocages

**Penser modulaire**

Les fonctions de conversion de données en tableau doivent être dans un module / une classe à part.

Utiliser des patterns comme l'architecture hexagonale / l'écritur d'interfaces  permet de découpler les composants et facilite les tests unitaires.


```text
## Extrait de best_practices.md

Adopter l'architecture hexagonale pour séparer le cœur métier des dépendances externes (bases de données, API, UI), en utilisant des ports et des adaptateurs.
Implémenter l'injection de dépendances pour gérer les dépendances de manière dynamique et découpler les composants.
Appliquer le Domain-Driven Design (DDD) pour modéliser les règles métier complexes et structurer l'architecture autour des entités et des domaines.
Utiliser le pattern de service (Service Layer) pour regrouper la logique métier et isoler les couches de présentation et de persistance.
Respecter le principe de responsabilité unique (Single Responsibility Principle) pour maintenir la modularité et la maintenabilité du code.
Appliquer le principe Open/Closed (ouverture aux extensions, fermeture aux modifications) pour permettre l'ajout de nouvelles fonctionnalités sans altérer l'existence.
Concevoir des interfaces claires et testables, en favorisant l'abstraction pour faciliter le mocking et les tests unitaires.
Utiliser le pattern Strategy pour encapsuler des algorithmes interchangeables et éviter la duplication de code logique.

```

---

#### Gérer les dépendances comme des priorités

**La sélection des dépendances et des frameworks est un enjeu essentiel : il faut certainement canaliser les choix du LLM pour minimiser la dette technique.**  

```text
## Extrait de dependances.md

Les librairies utilisées par le projet ne sont pas négotiables, il faut utiliser exclusivement celles-ci.

Liste des dépendances du projet :
- templating: jinja2 uniquement
- bases de données: sqlalchemy
- redis: redis-py
...

```

---

#### Urbaniser les flux

**Définir les formats d'échange standard pour formaliser les entrées / sorties du code.**  

Les formats de données en transit ont vocation à être décrits précisément pour permettre à différents logiciels de les consommer.

Ex: pour les API, respectez le standard OpenAPI. Pour les fichiers, document les formats de l'entreprise (ex: XML et autres). 

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

Avec un bon flow de développement de tests vous pourrez garantir la stabilité du code que vous livrez. 

---


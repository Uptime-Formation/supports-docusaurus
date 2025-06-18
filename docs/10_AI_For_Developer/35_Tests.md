---
title: 4 - Bien tester
---
## Quickstart

Utilisez l'outil de votre choix pour exécuter le prompt suivant.

Choisissez un fichier à tester. Ex [AlternC](https://github.com/AlternC/AlternC/blob/main/bureau/class/m_quota.php)

```text

<recommandations>
Les tests unitaires sont essentiels pour garantir la qualité, la maintenabilité et la stabilité d'un code.
Chaque test unitaire doit valider une seule fonctionnalité ou un seul cas de figure.
Un test unitaire ne doit pas vérifier à la fois la logique d'une fonction et son interaction avec une base de données.
Les tests unitaires doivent être indépendants les uns des autres.
Utiliser des mocks ou des stubs pour isoler les dépendances (ex. API externe, bases de données).
Ne pas partager des états entre les tests (ex. variables globales, données de test).
Les tests unitaires doivent être reproductibles et ne pas dépendre de l'ordre d'exécution.
Suivre le principe AAA (Arrange, Act, Assert) pour structurer les tests.
Les tests unitaires doivent valider les scénarios attendus (ex. une fonction qui renvoie un résultat prévu).
Tester les cas limites de la plage de valeurs (ex. 0, -1, 1000, etc.).
Vérifier que les erreurs sont levées correctement (ex. division par zéro, paramètres invalides).
Tester les comportements des dépendances (ex. appel d'une API, lecture d'un fichier).
Les développeurs négligent souvent de tester les cas d'erreur non gérés (ex. entrées invalides, fichiers corrompus).
Ajouter des tests pour chaque cas d'erreur possible.
Les tests unitaires ne mesurent pas la performance (ex. temps d'exécution).
Les tests unitaires ne vérifient pas les aspects de sécurité (ex. injection SQL, attaques XSS).
Réutiliser des tests via des méthodes ou des fonctions de test partagées.
</recommandation>
<fichier>

... inclure le code ...

<fichier>
<task>

Produis un fichier de test unitaire pour le code fourni en prenant en compte les recommandations.

<task>

```

--- 


## Automatiser la création de ses tests unitaires (Code to Test)

Basique avec du templating / few shots 

Les modèles AI Gen spécialisés code ont appris à faire ça. 

Il faut fournir des documents contextuels pour encadrer la tâche. 

--- 

## Test Driven Development (Test to Code) 

Workflow intéressant car débouche sur l'autonomie 

on fournit les besoins et les données en entrée / sortie 

on demande à produire les tests 

on demande à produire le code 

On veut faire d'abord les tests qui précisent les fonctionnalités de la librairie, puis développer le code sur la base des tests. 

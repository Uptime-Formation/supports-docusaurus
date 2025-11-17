---
title: TP 3 - Développement piloté par les tests (TDD)
---

**Ajouter une nouvelle fonctionnalité en écrivant les tests AVANT le code.**

**Durée : 30 minutes**

### Contexte

Votre responsable commercial est satisfait du script d'analyse, mais il aimerait connaître la valeur moyenne des paniers pour mieux comprendre le comportement d'achat des clients.

Au lieu d'écrire directement le code puis les tests (comme au TP2), vous allez découvrir le TDD (Test-Driven Development) : écrire les tests EN PREMIER, puis le code qui les fait passer au vert.

Cette approche inverse garantit que le code est testable dès sa conception et que chaque ligne de code a un test qui la justifie.

### Contraintes pédagogiques

Continuez avec le langage utilisé aux TP1 et TP2 (Python ou Node.js).

---

## Focus IA

**Ce que vous allez apprendre dans ce TP :**

- ✅ **TDD avec l'IA** : Générer les tests AVANT le code
- ✅ **Cycle rouge-vert-refactor** : Comprendre et appliquer le cycle TDD
- ✅ **Instructions TDD** : Créer un document pour guider l'IA sur l'approche TDD

---

## Objectif

À la fin de ce TP, vous devez avoir :

- ✅ Un fichier `docs/tdd.instructions.md` guidant l'IA sur l'approche TDD
- ✅ Une nouvelle fonction `get_average_basket_value()` ajoutée au code
- ✅ Des tests écrits AVANT le code (phase RED visible)
- ✅ Tous les tests passent au vert (phase GREEN démontrée)
- ✅ Un commit propre avec type `feat`

---

## Fichiers fournis

- **[`../sources/sales.csv`](../sources/sales.csv)** : Même fichier que TP1 et TP2
- **[`../TP3/docs/tdd.instructions.txt`](docs/tdd.instructions.txt)** : Guide complet sur l'approche TDD

---

## Contraintes techniques

- **TDD strict** : Les tests DOIVENT être écrits avant le code
- **Phase RED visible** : Les tests doivent échouer avant l'implémentation
- **Calcul attendu** : Valeur moyenne du panier = Total des ventes / Nombre de commandes uniques
- **Résultat attendu** : Total des ventes / Nombre de commandes uniques

---

## Étape 1 - Comprendre le TDD

**Objectif** : Saisir la différence entre TDD et approche classique.

- **Action** : Réfléchissez à votre démarche au TP2
  **Observation** : Vous avez d'abord refactoré le code, PUIS ajouté les tests

- **Action** : Avec le TDD, l'ordre est inversé : TESTS → CODE → REFACTOR
  **Observation** : Les tests définissent le comportement attendu AVANT que le code existe

**Pourquoi TDD ?**

- Les tests guident le design du code (pas de refactoring post-hoc pour la testabilité)
- On écrit uniquement le code nécessaire (pas de fonctionnalités non testées)
- Les tests documentent le comportement attendu
- Le code est testable par construction

**Le cycle TDD :**

1. **RED** : Écrire un test qui échoue (la fonction n'existe pas)
2. **GREEN** : Écrire le code minimal pour faire passer le test
3. **REFACTOR** : Améliorer le code sans casser les tests

---

## Étape 2 - Générer votre fichier d'instructions TDD

**Objectif** : Créer un fichier d'instructions adapté à votre besoin pour guider l'IA.

- **Action** : Utilisez ce meta-prompt pour générer votre fichier d'instructions TDD :

```
Je veux créer un fichier d'instructions pour guider une IA à faire du TDD.

Le fichier doit expliquer à l'IA :
1. Le cycle TDD (RED → GREEN → REFACTOR)
2. Les règles pour écrire de bons tests (structure, assertions, isolation)
3. Comment répondre quand on lui demande d'ajouter une fonction :
   - Générer les tests D'ABORD
   - Ne PAS générer le code tout de suite
   - Attendre validation que les tests échouent
   - PUIS générer le code minimal

Format : Markdown simple, concis (50 lignes max).
Langage : [Python/Node.js] avec framework [pytest/Jest].

Génère le contenu du fichier docs/tdd.instructions.md.
```

  **Observation** : L'IA génère un fichier d'instructions adapté à votre langage et framework

- **Action** : Sauvegardez le contenu dans `docs/tdd.instructions.md`
  **Observation** : Le fichier est créé dans votre dossier `docs/`

- **Action** : Lisez le contenu pour vérifier qu'il correspond à vos besoins
  **Observation** : Le fichier explique clairement le cycle TDD et les attentes pour l'IA

<details><summary>Indice - Fichier de référence</summary>

Si vous préférez partir d'un fichier existant plutôt que de le générer :

```bash
cp ../TP3/docs/tdd.instructions.txt docs/tdd.instructions.md
cat docs/tdd.instructions.md
```

Le fichier fourni contient :
- Cycle TDD (RED → GREEN → REFACTOR)
- Règles pour les tests (structure, assertions, isolation, lisibilité)
- Instructions pour l'IA (générer tests d'abord, puis code minimal)

Vous pouvez l'adapter selon vos besoins.

</details>

---

## Étape 3 - Définir le comportement attendu

**Objectif** : Spécifier clairement ce que la nouvelle fonction doit faire.

- **Action** : Analysez le besoin : "calculer la valeur moyenne du panier"
  **Observation** : Il faut diviser le total des ventes par le nombre de commandes uniques

- **Action** : Définissez la signature de la fonction
  **Observation** :
  - Nom : `get_average_basket_value(data)`
  - Entrée : Liste de dictionnaires (lignes CSV)
  - Sortie : Float (moyenne en euros)

- **Action** : Calculez le résultat attendu avec `sales.csv`
  **Observation** :
  - Total des ventes : [à calculer]
  - Nombre de commandes uniques : [à compter]
  - Moyenne attendue : [résultat du calcul]

<details><summary>Indice</summary>

**Commandes uniques dans sales.csv** :
Le fichier contient plusieurs commandes (order_id uniques) avec plusieurs produits par commande.

Nombre total : À déterminer en analysant les données

</details>

---

## Étape 4 - Générer les tests EN PREMIER (Phase RED)

**Objectif** : Écrire les tests avant que le code existe.

- **Action** : Demandez à l'IA de générer les tests avec ce prompt :

```
Lis le fichier docs/tdd.instructions.md.

Je veux ajouter une fonction get_average_basket_value(data) qui calcule
la valeur moyenne du panier (total des ventes / nombre de commandes uniques).

Génère UNIQUEMENT les tests unitaires pour cette fonction :
- Test avec les données de sales.csv (résultat attendu : moyenne calculée)
- Test avec données vides (retour : 0.0 ou erreur explicite)
- Test avec une seule commande (vérifier calcul correct)

N'écris PAS encore le code de la fonction, seulement les tests.
Framework : [pytest / Jest] selon le langage.
Fichier : tests/test_average_basket.py (ou .test.js)
```

  **Observation** : L'IA génère uniquement les tests, pas le code

- **Action** : Sauvegardez les tests dans `tests/test_average_basket.py` (ou `.test.js`)
  **Observation** : Structure : `TP-IA/tests/test_average_basket.py`

<details><summary>Indice</summary>

**Pourquoi les tests en premier ?**

Les tests définissent le contrat de la fonction :
- Qu'est-ce qu'elle prend en entrée ?
- Qu'est-ce qu'elle retourne ?
- Comment gère-t-elle les cas limites ?

En écrivant les tests d'abord, on force la réflexion sur le comportement attendu AVANT de penser à l'implémentation.

</details>

---

## Étape 5 - Lancer les tests (ils DOIVENT échouer - Phase RED)

**Objectif** : Vérifier que les tests échouent car la fonction n'existe pas encore.

- **Action** : Lancez les tests

```bash
# Python
pytest tests/test_average_basket.py

# Node.js
npm test -- tests/average_basket.test.js
```

  **Observation attendue** : Les tests ÉCHOUENT avec une erreur du type :
```
NameError: name 'get_average_basket_value' is not defined
```
ou
```
ReferenceError: get_average_basket_value is not defined
```

**C'est NORMAL et ATTENDU. Vous êtes en phase RED.**

<details><summary>Indice - Si les tests passent</summary>

**Problème** : Les tests ne devraient PAS passer puisque la fonction n'existe pas.

**Causes possibles** :
- L'IA a généré le code en même temps que les tests (ce n'est plus du TDD)
- Les tests ne testent pas réellement la fonction
- Un import est incorrect

**Solution** : Vérifiez que les tests importent bien `get_average_basket_value` et l'appellent.

</details>

---

## Étape 6 - Générer le code pour passer au vert (Phase GREEN)

**Objectif** : Implémenter la fonction pour faire passer les tests.

- **Action** : Demandez à l'IA de générer le code avec ce prompt :

```
Lis le fichier docs/tdd.instructions.md.

J'ai écrit les tests pour get_average_basket_value(data).
Les tests échouent car la fonction n'existe pas encore (phase RED).

Génère maintenant le code de la fonction get_average_basket_value(data) qui :
- Calcule le total des ventes (sum de quantity × price)
- Compte le nombre de commandes uniques (distinct order_id)
- Retourne la moyenne (total / nombre de commandes)
- Gère le cas des données vides (retourner 0.0)

Ajoute cette fonction dans app.py (ou app.js).
```

  **Observation** : L'IA génère uniquement le code de la fonction

- **Action** : Ajoutez la fonction au fichier `app.py` (ou `app.js`)
  **Observation** : Le fichier est mis à jour avec la nouvelle fonction

- **Action** : Lancez les tests à nouveau

```bash
# Python
pytest tests/

# Node.js
npm test
```

  **Observation attendue** : Tous les tests passent maintenant (vert)
```
===== 12 passed in 0.15s =====
```

**Vous êtes en phase GREEN.**

<details><summary>Indice - Si les tests échouent encore</summary>

**Vérifiez** :
- La fonction est bien exportée/importée correctement
- Le calcul du nombre de commandes uniques est correct (utiliser `set` ou `Set`)
- La division gère bien le cas des données vides (division par zéro)

**Prompt de correction** :
```
Les tests échouent encore avec cette erreur :
[COPIER-COLLER L'ERREUR]

Voici le code généré :
[COPIER-COLLER LA FONCTION]

Corrige le problème.
```

</details>

---

## Étape 7 - Vérifier l'intégration

**Objectif** : S'assurer que la nouvelle fonction fonctionne avec le reste du code.

- **Action** : Ajoutez l'affichage de la moyenne du panier dans la sortie du script
  **Observation** : Le script affiche maintenant 4 informations au lieu de 3

- **Action** : Lancez le script complet avec `sales.csv`

```bash
# Python
python app.py sales.csv

# Node.js
node app.js sales.csv
```

  **Observation attendue** : Le script affiche :
```
=== Analyse des Ventes ===
Total des ventes: [montant] €
Moyenne du panier: [moyenne] €

Top 3 Produits:
  1. [Produit A] ([X] unités)
  2. [Produit B] ([Y] unités)
  3. [Produit C] ([Z] unité)

CA par Ville:
  [Ville 1]: [montant] €
  [Ville 2]: [montant] €
  [Ville 3]: [montant] €
```

<details><summary>Indice</summary>

**Modifier la fonction d'affichage** :

Demandez à l'IA d'ajouter la moyenne du panier dans `display_results()` :

```
Modifie la fonction display_results() pour afficher également
la moyenne du panier après le total des ventes.

Format : "Moyenne du panier: XXX.XX €"
```

</details>

---

## Étape 8 - Refactorer si nécessaire (Phase REFACTOR)

**Objectif** : Améliorer le code sans casser les tests.

- **Action** : Relisez le code de `get_average_basket_value()`
  **Observation** : Le code est-il clair ? Y a-t-il de la duplication ?

- **Action** : Si le code peut être simplifié, demandez à l'IA de refactorer
  **Observation** : L'IA propose une version améliorée

- **Action** : Relancez tous les tests après refactoring

```bash
pytest tests/  # ou npm test
```

  **Observation** : Les tests passent toujours au vert (le comportement est préservé)

**Si les tests passent : le refactoring est réussi.**

<details><summary>Indice</summary>

**Exemples de refactoring** :
- Extraire le calcul du total dans une fonction réutilisée
- Simplifier la logique de comptage des commandes uniques
- Ajouter des variables intermédiaires pour la lisibilité

**Important** : Le refactoring ne change PAS le comportement, seulement la structure interne.

</details>

---

## Étape 9 - Commiter avec les conventions professionnelles

**Objectif** : Créer un commit propre pour cette nouvelle fonctionnalité.

- **Action** : Ajoutez les fichiers modifiés au staging

```bash
git add app.py tests/test_average_basket.py docs/tdd.instructions.md
```

  **Observation** : `git status` montre les fichiers en staging

- **Action** : Demandez à l'IA de générer le message de commit

```
Lis le fichier docs/git-conventions.md.

Génère un message de commit pour cette nouvelle fonctionnalité :
- Ajout de la fonction get_average_basket_value()
- Développement en TDD (tests écrits avant le code)
- Tests unitaires : 3 nouveaux tests
- Affichage de la moyenne du panier dans le script

Outil IA utilisé : [nom de l'outil].

Respecte le format Conventional Commits avec annotations IA.
Type de commit : feat
```

  **Observation** : L'IA génère le message complet

- **Action** : Créez le commit avec le message généré

```bash
git commit -m "[COLLER LE MESSAGE GÉNÉRÉ]"
```

  **Observation** : `git log` montre le commit avec le message formaté

<details><summary>Indice - Exemple de message</summary>

```
feat(analytics): add average basket value calculation

Add new metric to compute average basket value (total sales / unique orders).

Implementation details:
- get_average_basket_value(data): calculates total / unique order count
- Handles empty data (returns 0.0)
- Integrated in display output after total sales

Developed using TDD approach:
1. Tests written first (RED phase)
2. Code implemented to pass tests (GREEN phase)
3. No refactoring needed (code was clean from start)

Test coverage:
- Nominal case with sales.csv data (résultat calculé)
- Empty data handling
- Single order edge case

---
🤖 AI-Assisted Development
Tool: Claude Code v1.2 (claude-sonnet-4-5-20250929)
Agent: Guided TDD implementation
Prompt type: Test-first development with explicit RED-GREEN-REFACTOR cycle
Context files: docs/tdd.instructions.md
Human validation:
  - Functionality: ✓ Script displays average basket value (résultat attendu)
  - Tests: ✓ 3/3 new tests passing, all existing tests still green
  - Code review: ✓ TDD cycle respected (tests before code)
```

</details>

---

### Avancé

Questions pour aller plus loin :

- **Métriques supplémentaires** : Comment ajouteriez-vous d'autres métriques en TDD (médiane du panier, écart-type, etc.) ?

- **TDD sur refactoring** : Comment utiliseriez-vous les tests existants pour refactorer du code legacy en toute sécurité ?

- **Mocking** : Si la fonction appelait une API externe, comment écririez-vous les tests en TDD avec des mocks ?

- **Performance TDD** : Comment testeriez-vous les performances en TDD (ex: fonction doit traiter 10000 lignes en < 1s) ?

---

### Synthèse

**Qu'est-ce qui a bien fonctionné ?**

- Le cycle TDD (RED → GREEN → REFACTOR) était-il clair ?
- Avez-vous vu la différence entre "tests après" (TP2) et "tests avant" (TP3) ?
- Les instructions TDD ont-elles bien guidé l'IA ?

**Quels sont les problèmes rencontrés ?**

- Avez-vous été tenté d'écrire le code avant les tests ?
- Les tests ont-ils bien échoué en phase RED ?
- Le refactoring a-t-il cassé des tests ?

**Quelles compétences avez-vous développées avec l'IA ?**

- ✅ Comprendre et appliquer le cycle TDD
- ✅ Générer des tests avant le code avec l'IA
- ✅ Utiliser les tests comme spécification du comportement
- ✅ Refactorer en confiance grâce aux tests
- ✅ Créer des documents d'instruction pour guider l'approche TDD

**Prochaine étape** : Au TP4, vous transformerez ce script en API REST documentée avec Swagger !

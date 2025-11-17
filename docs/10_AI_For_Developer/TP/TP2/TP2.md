---
title: TP 2 - Rendre le code testable et ajouter des tests
---

**Refactorer le code existant pour le rendre testable, puis générer des tests automatisés.**

**Durée : 30 minutes**

### Contexte

Le script CLI du TP1 fonctionne, mais il mélange tout : lecture de fichiers, calculs métier, et affichage. Ce code est impossible à tester automatiquement car il dépend des entrées/sorties système.

Pour écrire des tests, il faut d'abord séparer la logique métier (calculs) des interactions système (I/O). C'est ce qu'on appelle une approche "librairie" ou "hexagonale" : le cœur métier devient indépendant, réutilisable, et testable.

### Contraintes pédagogiques

Continuez avec le langage utilisé au TP1 (Python ou Node.js).

---

## Focus IA

**Ce que vous allez apprendre dans ce TP :**

- ✅ **Rendre du code testable** : Refactorer pour séparer logique métier et I/O
- ✅ **Générer des tests avec l'IA** : Utiliser l'IA pour créer des tests unitaires
- ✅ **Instructions pour les tests** : Créer un document d'instruction pour guider l'IA sur la stratégie de test

---

## Objectif

À la fin de ce TP, vous devez avoir :

- ✅ Un code refactoré avec la logique métier séparée des I/O
- ✅ Des tests unitaires couvrant les calculs (total, top produits, CA par ville)
- ✅ Un fichier `docs/tests.instructions.md` guidant l'IA sur la stratégie de test
- ✅ Tous les tests passent au vert

---

## Fichiers fournis

- **[`../sources/sales.csv`](../sources/sales.csv)** : Même fichier que TP1
- **[`../sources/sales_empty.csv`](../sources/sales_empty.csv)** : Fichier vide pour tester les cas limites

---

## Contraintes techniques

- **Tests unitaires** : Utiliser le framework de test standard du langage (pytest pour Python, Jest/Mocha pour Node.js)
- **Couverture** : Tester au minimum les 3 fonctions de calcul (total ventes, top produits, CA par ville)
- **Isolation** : Les tests ne doivent PAS lire de fichiers réels (utiliser des données en mémoire)
- **Validation** : Tous les tests doivent passer (résultat vert)

---

## Étape 1 - Comprendre pourquoi le code actuel n'est pas testable

**Objectif** : Identifier le problème structurel du code du TP1.

- **Action** : Ouvrez votre script `app.py` (ou `app.js`) du TP1    
  **Observation** : Le code fait tout dans un seul flux : ouvrir le fichier → lire → calculer → afficher

- **Action** : Demandez-vous : "Comment tester le calcul du total sans lire un fichier réel ?"    
  **Observation** : C'est impossible. Le calcul est entremêlé avec la lecture du CSV.

**Problème** : Pour tester automatiquement, il faut pouvoir appeler une fonction avec des données en mémoire et vérifier le résultat. Actuellement, le code n'expose pas de fonctions réutilisables.

**Solution** : Refactorer en séparant :
- **Logique métier** : Fonctions pures qui prennent des données en entrée et retournent des résultats
- **Adaptateurs I/O** : Code qui lit les fichiers et affiche les résultats

---

## Étape 2 - Créer le fichier d'instructions pour les tests

**Objectif** : Guider l'IA sur la stratégie de test à adopter.

- **Action** : Copiez le fichier [`./docs/tests.instructions.txt`](./docs/tests.instructions.txt) dans votre dossier `TP-IA/docs/` en le renommant en `tests.instructions.md`  
  **Observation** : Ce fichier contient les directives pour l'IA concernant les tests unitaires

- **Action** : Lisez le contenu du fichier  
  **Observation** : Il décrit les bonnes pratiques : tests unitaires isolés, couverture des cas nominaux et limites, assertions claires

<details><summary>Indice</summary>

```bash
cp tests.instructions.txt docs/tests.instructions.md
cat docs/tests.instructions.md
```

Le fichier guide l'IA pour :
- Écrire des tests unitaires (pas d'intégration)
- Tester les fonctions métier indépendamment
- Couvrir les cas normaux et les cas limites
- Utiliser le framework standard du langage

</details>

---

## Étape 3 - Refactorer le code pour le rendre testable

**Objectif** : Extraire la logique métier dans des fonctions pures.

- **Action** : Demandez à l'IA de refactorer votre code avec ce prompt :

```
Lis le fichier docs/tests.instructions.md.

Refactore le code pour séparer :
1. Des fonctions métier (calculs) : calculate_total_sales(), get_top_products(), get_revenue_by_city()
2. Les adaptateurs I/O : read_csv_file(), display_results() avec des classes data testables

Les fonctions métier doivent :
- Prendre des données en paramètre (liste de dictionnaires/objets représentant les lignes CSV)
- Retourner des résultats (pas d'affichage)
- Être pures (pas d'effets de bord)

Le main() coordonne les appels en chainant input => traitements => output.

Génère le code refactoré.
```
    
  **Observation** : L'IA génère un code avec des fonctions séparées

- **Action** : Remplacez votre code existant par le code refactoré    
  **Observation** : Le fichier est mis à jour

- **Action** : Testez que le script fonctionne toujours avec `sales.csv`    
  **Observation** : Les résultats sont identiques au TP1

<details><summary>Indice</summary>

**Pourquoi cette séparation est cruciale** :

Avant : `lire_csv() → calculer_et_afficher()` (impossible à tester)

Après :
- `calculate_total_sales(data)` → testable avec `data = [{...}, {...}]`
- `get_top_products(data)` → testable avec des données fictives
- `read_csv_file()` → peut être remplacé par un mock dans les tests

Les fonctions métier deviennent réutilisables dans d'autres contextes (API, batch, etc.).

</details>

---

## Étape 4 - Générer les tests avec l'IA

**Objectif** : Créer des tests unitaires pour les fonctions métier.

- **Action** : Demandez à l'IA de générer les tests avec ce prompt :

```
Lis le fichier docs/tests.instructions.md.

Génère des tests unitaires pour les 3 fonctions métier :
- calculate_total_sales(data)
- get_top_products(data)
- get_revenue_by_city(data)

Chaque fonction doit avoir :
1. Un test avec les données du fichier sales.csv (résultats attendus : montants et quantités calculés)
2. Un test avec des données vides (vérifier le comportement)
3. Un test avec un cas limite (1 seule ligne, ou produits à égalité)

Framework : [pytest / Jest] selon le langage.
Fichier de sortie : tests/test_sales.py (ou tests/sales.test.js).
```
    
  **Observation** : L'IA génère un fichier de tests complet

- **Action** : Créez le dossier `tests/` et sauvegardez le fichier généré    
  **Observation** : Structure : `TP-IA/tests/test_sales.py`

<details><summary>Indice</summary>

**Installation des dépendances de test** :

Python :
```bash
pip install pytest
```

Node.js :
```bash
npm install --save-dev jest
# ou
npm install --save-dev mocha chai
```

</details>

---

## Étape 5 - Lancer les tests

**Objectif** : Vérifier que tous les tests passent.

- **Action** : Lancez les tests avec la commande appropriée

```bash
# Python
pytest tests/

# Node.js (Jest)
npm test

# Node.js (Mocha)
npx mocha tests/
```
    
  **Observation attendue** : Tous les tests passent (vert), affichage du type :
```
===== 9 passed in 0.12s =====
```

**Si des tests échouent** : Passez à l'Étape 6.

<details><summary>Indice - Problèmes courants</summary>

**Erreur : "module not found" / "import error"**
- Vérifiez que le fichier de tests importe correctement les fonctions depuis `app.py`
- Python : Ajoutez un `__init__.py` vide dans le dossier racine si nécessaire

**Tests en échec** :
- Regardez le message d'erreur exact : valeur attendue vs obtenue
- Vérifiez que les fonctions métier retournent exactement ce que les tests attendent
- Corrigez avec l'aide de l'IA (voir Étape 6)

</details>

---

## Étape 6 - Corriger avec l'IA (si nécessaire)

**Objectif** : Débugger les tests qui échouent.

**⚠️ Seulement si des tests échouent !**

- **Action** : Identifiez le test qui échoue et le message d'erreur    
  **Observation** : Message du type "Expected [valeur attendue], got [valeur obtenue]"

- **Action** : Retournez vers l'IA avec un prompt de correction

```
Le test test_calculate_total_sales échoue avec cette erreur :
[COPIER-COLLER L'ERREUR EXACTE]

Voici la fonction testée :
[COPIER-COLLER LA FONCTION]

Corrige le problème.
```
    
  **Observation** : L'IA propose une correction

- **Action** : Appliquez la correction et relancez les tests (Étape 5)    
  **Observation** : Les tests passent maintenant

---

## Étape 7 - Commiter avec les conventions professionnelles

**Objectif** : Créer un commit propre pour cette évolution.

- **Action** : Réutiliser notre configuration git pour avoir un commit propre.


---

### Avancé

Questions pour aller plus loin :

- **Couverture** : Comment mesurer le pourcentage de code couvert par les tests ? Demandez à l'IA d'ajouter un rapport de couverture (pytest-cov, Jest --coverage).

- **Cas limites supplémentaires** : Que se passe-t-il avec des prix négatifs ? Des quantités à zéro ? Comment ajouteriez-vous ces tests ?

- **Intégration** : Maintenant que vous avez des fonctions métier testables, comment les réutiliser dans une API REST ? (Indice : TP4)

- **CI/CD** : Comment automatiser l'exécution de ces tests à chaque commit ? (GitHub Actions, GitLab CI)

---

### Synthèse

**Qu'est-ce qui a bien fonctionné ?**

- La séparation logique métier / I/O rend-elle le code plus clair ?
- L'IA a-t-elle généré des tests pertinents du premier coup ?
- Les instructions dans `docs/tests.instructions.md` ont-elles bien guidé l'IA ?

**Quels sont les problèmes rencontrés ?**

- Avez-vous dû corriger des tests qui échouaient ? Pourquoi ?
- Le refactoring a-t-il cassé quelque chose au départ ?
- Les tests couvrent-ils tous les cas importants ?

**Quelles compétences avez-vous développées avec l'IA ?**

- ✅ Comprendre l'importance de la testabilité (séparation des responsabilités)
- ✅ Refactorer du code avec l'aide de l'IA
- ✅ Générer des tests unitaires automatiquement
- ✅ Utiliser des documents d'instruction pour guider l'IA sur la stratégie de test
- ✅ Débugger des tests en itérant avec l'IA

**Prochaine étape** : Au TP3, vous ajouterez une nouvelle fonctionnalité avec TDD (tests d'abord, code ensuite).

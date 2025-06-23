---
title: 4 - Bien tester
---
## Quickstart

Utilisez l'outil de votre choix pour exécuter le prompt suivant.

Choisissez un fichier à tester.

Un exemple PHP : [AlternC](https://github.com/AlternC/AlternC/blob/main/bureau/class/m_quota.php)

Voici le prompt à utilier

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
</recommandation>

<fichier>

... inclure le code ...

<fichier>

<task>
Produis un fichier de test unitaire pour le code fourni en prenant en compte les recommandations.
<task>

```

--- 

## Comment les LLM associent code source et tests : Mécanismes d'apprentissage

**Les LLM orientés code comme Codex, AlphaCode, ou les modèles de GitHub Copilot, apprennent à associer code et tests grâce à leur entraînement sur des datasets massifs de paires code-test.**

---

**Ces datasets leur permettent d'apprendre l'association entre des motifs / structures / patterns.**
     
     `def test_...()` → appelle `fonction_x()` avec entrées Y → vérifie sortie Z


---

**Puis le modèle utilise l'attention pour relier fonctions de tests et code**

     ```python
     # Code
     def add(a, b):
         return a + b
     
     # Test associé (dans un autre fichier)
     def test_add():
         assert add(2, 3) == 5  # Lien via le nom 'add'
     ```

---

**Enfin le modèle va généraliser pour appliquer ces motis à ne nouveaux contextes.**

Une fois qu'il a assimilé le pattern, il le généralise à travers les langages (pytest → JUnit → Jest)

---

### Les LLMs sont-ils de bons testeurs ? 

**En pratique, il est difficile d'obtenir de bons tests sans une réelle participation humaine.**

- **Couverture des tests** :  Les LLM tendent à générer des tests "évidents" mais manquent les cas limites complexes.

- **Hallucinations** :  Peuvent inventer des assertions non valides (ex: `assert is_prime(4) == True`)

- **Biais des données** :  Surreprésentation du Python (45% des datasets) vs langages comme Rust (2%).

---

**La fourniture des documents pour guider la production des tests permet de corriger partiellement ces problèles.**

On revient sur la logique qu'on a défini : écrire un persona qui inclut toutes les règles de production propres à l'équipe / entreprise.

---

## Automatiser la création de ses tests unitaires (Code to Test)

**C'est une pratique assez triviale en utilisant du templating et/ou du few shots.** 

 
---


**Pour générer des tests unitaires à partir du code existant, la recette est simple.**

- Utiliser un modèle spécialisé code
  - Codex
  - AlphaCode
- Fournir les informations de contexte adéquates :
  - code à tester
  - cadrage et bonnes pratiques des tests
- Lancer un prompt adapté
  - *templating* 
  - *few-shot learning*
  
```text

# Producing Code to Test
<contraintes>
Chaque test unitaire doit valider une seule fonctionnalité ou un seul cas de figure.
Un test unitaire ne doit pas vérifier à la fois la logique d'une fonction et son interaction avec une base de données.
Les tests unitaires doivent être indépendants les uns des autres.
</contraintes>

<code>
# Contexte pour une fonction de calcul
def add(a: int, b: int) -> int:
   """Additionne deux nombres."""
   return a + b
</code>

<example>
def multiply(x, y):
   return x * y
# Tests générés :
def test_multiply():
   assert multiply(2, 3) == 6  # Cas nominal
   assert multiply(0, 5) == 0  # Valeur limite
</example>

<task>
En tant que spécialiste des tests dans l'entreprise, tu dois génèrer un fichier de tests unitaires pour le code fourni en utilisant le framework pytest.  
Tu dois respecter les contraintes et utiliser l'exemple fourni.
Couvre ces cas :  
- Cas nominal  
- Erreurs de type  
- Valeurs limites  
- ...
<task>

   ```


**L'IA produira un bon départ, avec des tests couvrant une partie des cas critiques, fournissant ainsi un gain de temps sur les tests répétitifs.**

--- 

## Test Driven Development (Test to Code) 

**On va voir l'autre workflow, qui est intéressant car il débouche sur l'autonomie agentique.** 

Cette approche va garantir un code *testé* et *spécification-driven*.  

- on fournit les contraintes métiers et les données en entrée / sortie

- On demande à produire l'architecture du code (structure, entrées/sorties attendues)
```markdown
<persona>... tech lead ... </persona>
<contraintes> ... </contraintes>
Fonction : trier_liste(liste: List[int]) -> List[int]
Exigences :
- Tri ascendant
- Gère les listes vides
- Lève TypeError si entrée non-liste
```

- On demande à produire les tests 
```markdown

<persona>... tech lead ... </persona>
<contraintes> ... </contraintes>
<contexte>...sortie du tech lead...</contexte>  

Écris des tests pytest pour une la fonction `trier_liste` avec :  
- Test liste normale : [3, 1, 2] → [1, 2, 3]  
- Test liste vide : [] → []  
- Test erreur de type : "abc" → TypeError  
```

- On demande à produire le code 
```markdown

<persona>... tech lead ... </persona>
<contraintes> ... </contraintes>
<contexte>...sortie du tech lead...</contexte>  
<contexte>...sortie du testeur...</contexte>  

Écris une fonction Python `trier_liste` qui passe les tests.  

```
---

**Avec ce type de workflow, on va déboucher sur une boucle de validation**  

En produisant en boucle les tests et le code, l'exécution des tests va corriger les échecs de l'IA.  

---

**Cela implique d'avoir de bonnes spécifications et une bonne définition des données en entrée / sortie .**

Mais si on a fourni toutes les données nécessaires, avec le bon modèle, on se dirige vers une assurance que le code produit fonctionne et est conforme aux spécifications.

---

### Exemple 


#### Spécifications

"""
Fonction à tester : somme_listes(listes: List[List[int]]) -> Dict[str, Union[int, str]]

Cas de test :
1. [Succès] Cas nominal avec plusieurs listes
   - Input: [[1, 2], [3, 4, 5], []]
   - Output attendu: {"total": 15, "detail": "3 listes traitées"}

2. [Échec] Type incorrect dans une liste
   - Input: [[1, "a"], [3, 4]]
   - Output attendu: TypeError

3. [Échec] Paramètre non liste
   - Input: "hello"
   - Output attendu: ValueError

4. [Succès] Liste vide en entrée
   - Input: []
   - Output attendu: {"total": 0, "detail": "0 liste traitée"}
"""

### Prompt testeur 

```text

En tant que testeur Python, génère une classe de test unitaire complète (unittest.TestCase) basée sur les spécifications suivantes.  

**Exigences :**  
- Utilise `unittest`  
- Respecte scrupuleusement les cas de test fournis  
- Ne génère que le code de test, sans explications  

**Spécifications :**  
{Insérer ici le fichier de spécifications}  

**Contraintes :**  
- Pas de commentaires superflus  
- Pas d'implémentation de la fonction à tester  
- Uniquement la classe `unittest.TestCase`  


```

---

### Prompt développeur 

```
En tant que développeur Python, écris une implémentation de fonction/classe qui passe tous les tests fournis.  

**Exigences :**  
- Respecte strictement les spécifications et les cas de test  
- Gère tous les cas d'erreur mentionnés  
- Ne génère que le code final, sans explications  

**Spécifications :**  
{Insérer ici le fichier de spécifications}  

**Classe de test :**  
{Insérer ici la classe de test}  

**Contraintes :**  
- Pas de commentaires hors docstrings  
- Pas de modifications des tests  
- Uniquement le code implémentant la fonction/classe  

```
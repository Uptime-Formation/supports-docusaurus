---
title: TP 1 - Script CLI avec l'IA
---

**Créer un script d'analyse de ventes e-commerce en utilisant l'IA avec des instructions professionnelles.**

**Durée : 20 minutes**

### Contexte

Votre entreprise reçoit des fichiers CSV contenant les données de ventes e-commerce. Le responsable commercial souhaite obtenir rapidement quelques statistiques simples : le total des ventes, les produits les plus vendus, et le chiffre d'affaires par ville.

Pour le moment, il n'a besoin que d'un script simple qui lit un fichier CSV et affiche les résultats en console. Rien de compliqué, mais il faut que ce soit fait proprement.

### Contraintes pédagogiques

Vous êtes libres d'utiliser l'outil de votre choix (Python, Node.js, etc.) et l'assistant IA de votre choix (Claude Code, Cursor, ChatGPT, Copilot, etc.).

---

## Focus IA

**Ce que vous allez apprendre dans ce TP :**

- ✅ **Prompting basique efficace** : Formuler une demande claire à l'IA
- ✅ **Itération avec l'IA** : Tester, identifier les bugs, corriger avec l'aide de l'IA
- ✅ **Instructions pour l'agent** : Créer un dossier `/docs` avec des instructions pour guider l'IA
- ✅ **Conventions Git professionnelles** : Utiliser les Conventional Commits avec annotations IA

**L'objectif n'est PAS de devenir expert en parsing CSV**, mais d'apprendre à **utiliser l'IA efficacement** pour générer du code fonctionnel rapidement.

---

## Objectif

À la fin de ce TP, vous devez avoir réussi les objectifs suivants :

- ✅ Un script CLI fonctionnel qui analyse le fichier `sales.csv`
- ✅ Un dossier `/docs` contenant les instructions Git pour l'agent IA
- ✅ Des commits propres suivant les Conventional Commits avec annotations IA

---

## Fichiers fournis

- **[`../sources/sales.csv`](../sources/sales.csv)** : Fichier CSV de données e-commerce avec 8 colonnes
  - Colonnes : `order_id`, `date`, `product_id`, `product_name`, `quantity`, `price`, `customer_city`, `status`
  - Contient des lignes dupliquées (même `order_id` pour plusieurs produits)

- **[`docs/git-conventions.txt`](./docs/git-conventions.txt)** : Instructions complètes pour que l'agent IA génère des commits conformes aux standards professionnels

---

## Contraintes techniques

- **Lecture CSV** : Le script doit lire le fichier `sales.csv` fourni
- **Calculs attendus** :
  - Total des ventes : somme de `quantity × price` pour toutes les lignes
  - Top 3 produits : classement par quantité totale vendue
  - CA par ville : somme des ventes agrégées par `customer_city`
- **Format de sortie** : Affichage console en texte formaté (pas de JSON pour ce TP)
- **Pas de tests** : Pour ce TP, validation manuelle uniquement (les tests arrivent au TP2)

---

## Étape 1 - Initialiser le projet et le dossier d'instructions

**Objectif** : Créer la structure de projet avec un dossier `/docs` pour guider l'IA.

- **Action** : Créez un nouveau dossier pour votre projet (ex: `TP-IA`)  
  **Observation** : Vous avez un dossier vide prêt à accueillir votre code

- **Action** : Dans ce dossier, créez un sous-dossier `docs/`  
  **Observation** : Structure : `TP-IA/docs/`

- **Action** : Copiez le fichier [`git-conventions.txt`](./docs/git-conventions.txt) dans votre dossier `docs/` en le renommant en `git-conventions.md`
  **Observation** : Vous avez maintenant `docs/git-conventions.md` qui contient les règles de commits pour l'agent IA

- **Action** : Initialisez Git dans le dossier projet : `git init`  
  **Observation** : Git est initialisé (message "Initialized empty Git repository")

<details><summary>Indice</summary>

\`\`\`bash
# Créer la structure
mkdir TP-IA
cd TP-IA
mkdir docs

# Copier les instructions Git (renommer en .md pour l'IDE)
cp ../TP1/docs/git-conventions.txt docs/git-conventions.md 

# Initialiser Git
git init

# Créer le .gitignore adapté à votre langage
# Python
echo "__pycache__/
*.pyc
.pytest_cache/
venv/" > .gitignore

# Node.js
echo "node_modules/
*.log
.env" > .gitignore
\`\`\`

</details>

---

## Étape 2 - Récupérer le fichier CSV

**Objectif** : Préparer les données pour le développement.

- **Action** : Copiez le fichier `../sources/sales.csv` dans votre dossier projet  
  **Observation** : Vous avez `sales.csv` à la racine du projet

- **Action** : Ouvrez le fichier CSV pour voir sa structure    
  **Observation** : Le fichier contient 8 colonnes : `order_id`, `date`, `product_id`, `product_name`, `quantity`, `price`, `customer_city`, `status`

<details><summary>Indice</summary>

```bash
# Copier le fichier
cp ../sources/sales.csv .

# Voir les premières lignes
head -5 sales.csv
```

**Résultat attendu** :
```csv
order_id,date,product_id,product_name,quantity,price,customer_city,status
ORD-001,2024-01-15,P001,Laptop,1,899.99,Paris,completed
ORD-001,2024-01-15,P045,Mouse,2,25.50,Paris,completed
...
```

</details>

---

## Étape 3 - Générer le code avec l'IA (prompt simple)

**Objectif** : Utiliser l'IA pour créer le script d'analyse.

- **Action** : Ouvrez votre outil IA préféré (Claude Code, Cursor, ChatGPT, Copilot, etc.)  
  **Observation** : L'outil IA est prêt à recevoir votre prompt

- **Action** : Donnez ce prompt à l'IA en adaptant au langage de votre choix :

**Prompt à utiliser** :

```
Je veux un script [Python/Node.js] qui analyse un fichier CSV de ventes e-commerce.

Le CSV contient ces colonnes :
order_id, date, product_id, product_name, quantity, price, customer_city, status

Le script doit :
1. Lire le fichier "sales.csv" passé en argument
2. Calculer le TOTAL des ventes (somme de quantity × price pour toutes les lignes)
3. Trouver les TOP 3 produits les plus vendus (par quantité)
4. Calculer le chiffre d'affaires par ville (customer_city)
5. Afficher les résultats en console de manière formatée

Format de sortie attendu :
=== Analyse des Ventes ===
Total des ventes: XXXX.XX €

Top 3 Produits:
  1. Produit (X unités)
  ...

CA par Ville:
  Ville: XXXX.XX €
  ...

Génère le code dans un fichier app.py (ou app.js, main.rs selon le langage).
```
  
**Observation** : L'IA génère le code complet du script

<details><summary>Indice</summary>

**Conseils pour le prompt** :

1. **Soyez précis sur le langage** : "Python" ou "Node.js" ou "Rust"
2. **Donnez la structure du CSV** : Liste des colonnes
3. **Décrivez les calculs attendus** : Total, top 3, CA par ville
4. **Montrez le format de sortie** : L'IA comprendra mieux

**Si l'IA demande des précisions** :
- Pour Python : "Utilise le module csv standard, pas de pandas"
- Pour Node.js : "Utilise fs et readline, pas de librairie externe"

</details>

---

## Étape 4 - Tester le script

**Objectif** : Vérifier que le code fonctionne et produit les bons résultats.

- **Action** : Sauvegardez le code généré dans un fichier (app.py ou app.js)
  **Observation** : Le fichier est créé dans votre projet

- **Action** : Lancez le script avec le fichier CSV

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

Top 3 Produits:
  1. [Produit A] ([X] unités)
  2. [Produit B] ([Y] unités)
  3. [Produit C] ([Z] unité)

CA par Ville:
  [Ville 1]: [montant] €
  [Ville 2]: [montant] €
  [Ville 3]: [montant] €
```

**Si ce n'est pas le cas** : Passez à l'Étape 5 pour corriger.

<details><summary>Indice - Problèmes courants</summary>

**Erreur : "module not found" / "cannot find module"**
- Python : `pip install [nom-du-module]` si l'IA a utilisé des dépendances
- Node.js : `npm install [nom-du-module]`

**Résultats incorrects :**
  - **Total différent** : Vérifiez que TOUTES les lignes sont prises en compte
- **Top produits faux** : L'agrégation doit sommer les quantités par nom de produit
- **CA par ville faux** : Vérifiez que les calculs sont bien `quantity × price` agrégés par ville

**Le script plante :**
- Vérifiez que le chemin vers `sales.csv` est correct
- Regardez le message d'erreur exact (vous en aurez besoin pour l'Étape 5)

</details>

---

## Étape 5 - Corriger avec l'IA (si nécessaire)

**Objectif** : Débugger en itérant avec l'IA.

**⚠️ Seulement si le script ne fonctionne pas correctement !**

- **Action** : Identifiez le problème précis (erreur ou résultat incorrect)  
  **Observation** : Vous avez un message d'erreur OU des chiffres qui ne correspondent pas

- **Action** : Retournez vers l'IA avec un prompt de debugging

**Exemples de prompts de correction** :

**Si erreur d'exécution** :
```
Le script génère cette erreur :
[COPIER-COLLER L'ERREUR EXACTE]

Voici le code généré :
[COPIER-COLLER LE CODE]

Comment corriger cette erreur ?
```

**Si résultats incorrects** :
```
Le script affiche un résultat différent de celui attendu.
Le problème vient probablement de l'arrondi ou du type de données (int au lieu de float).

Voici la fonction de calcul :
[COPIER-COLLER LA FONCTION]

Peux-tu corriger pour obtenir le bon résultat ?
```
  
**Observation** : L'IA propose une correction

- **Action** : Appliquez la correction et relancez le script (Étape 4)  
  **Observation** : Le script fonctionne maintenant avec les bons résultats

<details><summary>Indice - Bien débugger avec l'IA</summary>

**Méthodologie efficace** :

1. **Soyez précis** : Donnez l'erreur EXACTE (pas de paraphrase)
2. **Contexte minimal** : Montrez uniquement la partie du code concernée
3. **Résultat attendu** : "Je veux [valeur attendue], j'obtiens [valeur obtenue]"
4. **Testez la correction** : Ne faites pas confiance aveuglément, relancez !

**Itération** : Il est NORMAL de faire 2-3 allers-retours avec l'IA pour arriver au résultat. C'est justement ce que vous apprenez dans ce TP.

</details>

---

## Étape 6 - Commiter avec les conventions professionnelles

**Objectif** : Créer un commit propre avec les annotations IA.

- **Action** : Ajoutez les fichiers au staging Git

```bash
git add .gitignore docs/ app.py sales.csv
# Adaptez selon votre langage (app.js, package.json, etc.)
```
  
**Observation** : `git status` montre les fichiers prêts à être commités (en vert)

- **Action** : Demandez à l'IA de générer le message de commit

**Prompt pour l'IA** :

```
Lis le fichier docs/git-conventions.md.

Génère un message de commit pour l'ajout initial de ce script d'analyse de ventes CSV.

Informations :
- Le script lit un fichier CSV de ventes e-commerce
- Il calcule le total des ventes, top 3 produits, et CA par ville
- Langage utilisé : [Python/Node.js]
- Outil IA utilisé : [nom de l'outil, ex: Claude Code, ChatGPT, etc.]

Respecte le format Conventional Commits avec annotations IA.
```
  
**Observation** : L'IA génère un message de commit complet avec annotations

- **Action** : Créez le commit avec le message généré

```bash
# Option 1 : Copier-coller directement
git commit -m "feat(cli): implement CSV sales analysis

[COLLER LE MESSAGE COMPLET GÉNÉRÉ PAR L'IA]"

# Option 2 : Via un fichier temporaire (plus pratique pour les longs messages)
# Créer commit-msg.txt avec le message
git commit -F commit-msg.txt
```
  
**Observation** : `git log` montre votre commit avec le message formaté

<details><summary>Indice - Exemple de message généré</summary>

```text
feat(cli): implement CSV sales analysis

Add command-line tool to analyze e-commerce sales data:
- Read CSV files with 8 columns (order_id, date, product, etc.)
- Calculate total sales amount (quantity × price)
- Identify top 3 products by quantity sold
- Compute revenue by customer city
- Display formatted results in console

Implementation uses Python csv.DictReader for parsing.
Currency values formatted with 2 decimal precision.

---
🤖 AI-Assisted Development
Tool: Claude Code v1.2 (claude-sonnet-4-5-20250929)
Agent: Guided implementation from prompt
Prompt type: Feature request with functional specifications
Context files: sales.csv
Human validation:
  - Functionality: ✓ Tested with sales.csv (results verified)
  - Tests: ✗ Not implemented yet (planned for TP2)
  - Code review: ✓ Logic validated manually
```

**Points importants** :
- Type `feat` (nouvelle fonctionnalité)
- Scope `cli` (interface ligne de commande)
- Corps détaillé (what + why)
- Annotations IA obligatoires (🤖 section)

</details>

---

### Avancé

Questions pour aller plus loin :

- **Performance** : Que se passe-t-il si le fichier CSV contient 1 million de lignes ? Comment l'IA pourrait-elle vous aider à optimiser le code ?

- **Gestion d'erreurs** : Actuellement, que se passe-t-il si le fichier CSV est vide ou mal formaté ? Comment demanderiez-vous à l'IA d'ajouter une gestion d'erreurs robuste ?

- **Formats multiples** : Comment prompteriez-vous l'IA pour ajouter une option `--format json` qui affiche les résultats en JSON au lieu de texte ?

- **Réutilisabilité** : Sauriez-vous expliquer à l'IA comment refactorer le code pour séparer la logique de calcul de l'affichage ? (Indice : cela sera utile pour le TP3)

---

### Synthèse

**Qu'est-ce qui a bien fonctionné ?**

- L'IA a-t-elle généré du code fonctionnel du premier coup ?
- Les instructions dans `docs/git-conventions.md` étaient-elles claires ?
- Le fichier `requirements.md` a-t-il aidé l'IA à comprendre vos besoins ?

**Quels sont les problèmes rencontrés ?**

- Avez-vous dû itérer plusieurs fois pour corriger des bugs ?
- Le format de sortie était-il correct dès la première génération ?
- Les commits ont-ils été faciles à créer avec les conventions ?

**Quelles compétences avez-vous développées avec l'IA ?**

- ✅ Formuler des prompts clairs et précis
- ✅ Itérer avec l'IA pour corriger des erreurs
- ✅ Créer des fichiers d'instructions pour guider l'agent IA
- ✅ Utiliser les Conventional Commits avec annotations IA
- ✅ Séparer spécifications (requirements.md) et code

**Prochaine étape** : Au TP2, vous ajouterez des tests automatisés pour valider ce code !

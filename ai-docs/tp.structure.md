# TP Structure Reference

This document describes the structural pattern for writing TPs (Travaux Pratiques) in this repository. It is **topic-agnostic** — the same structure applies to Docker, Kubernetes, Terraform, AI, or any other module.

Reference file: `docs/10_AI_For_Developer/TP/TP1/TP1.md`

---

## Top-level anatomy

A TP file has the following sections, in order:

```
1. Frontmatter
2. One-line bold description + duration
3. Contexte
4. Contraintes pédagogiques (optional)
5. Focus [topic] — learning outcomes
6. Objectif — success criteria (checklist)
7. Fichiers fournis (optional)
8. Contraintes techniques (optional)
9. Étapes (numbered, each with sub-steps)
10. Avancé
11. Synthèse
```

---

## Section details

### 1. Frontmatter
```yaml
---
title: TP N - Short descriptive title
---
```

### 2. One-line description + duration
Bold sentence summarizing the TP goal. Immediately followed by duration.
```markdown
**Créer un script d'analyse de ventes e-commerce en utilisant l'IA avec des instructions professionnelles.**

**Durée : 20 minutes**
```
Duration is explicit and realistic. Morning TPs are shorter than afternoon TPs.

### 3. Contexte
A short narrative paragraph (3–5 sentences) placing the student in a **realistic professional scenario**. Uses second person ("Votre entreprise..."). Grounds the technical work in a business need. Does NOT explain how to do anything yet.

### 4. Contraintes pédagogiques (optional)
Freeform constraints for the student. Used when there is meaningful choice (tool, language, approach). Keeps the TP open while focusing on the learning goal.

### 5. Focus [topic]
What the student will **learn** in this TP — not what they will do. Uses checkboxes. Each item is **bold concept** followed by a colon and a one-line explanation. Ends with a negative clarification: "L'objectif n'est PAS de..."

```markdown
## Focus IA

- ✅ **Prompting basique efficace** : Formuler une demande claire à l'IA
- ✅ **Itération avec l'IA** : Tester, identifier les bugs, corriger avec l'aide de l'IA

**L'objectif n'est PAS de devenir expert en parsing CSV**, mais d'apprendre à **utiliser l'IA efficacement**.
```

### 6. Objectif
What the student must **produce** by the end — verifiable success criteria. Uses checkboxes. Each item is a concrete deliverable, not a vague goal.

```markdown
## Objectif

À la fin de ce TP, vous devez avoir réussi les objectifs suivants :

- ✅ Un script CLI fonctionnel qui analyse le fichier `sales.csv`
- ✅ Un dossier `/docs` contenant les instructions Git pour l'agent IA
- ✅ Des commits propres suivant les Conventional Commits avec annotations IA
```

### 7. Fichiers fournis (optional)
List of provided assets with relative links and short descriptions. Used when the TP depends on external files (data, config, etc.).

### 8. Contraintes techniques (optional)
Explicit technical constraints scoping the work. Prevents over-engineering. Example: "Pas de tests : validation manuelle uniquement".

### 9. Étapes (core section)
Numbered steps (`## Étape N - Title`), each with:
- A bold **Objectif** line stating what this step achieves
- Sub-steps using the **Action / Observation** pattern:

```markdown
- **Action** : Do the thing
  **Observation** : What you should see

- **Action** : Do the next thing
  **Observation** : Expected result
```

Each step ends with a `<details><summary>Indice</summary>` block containing:
- Complete commands / code to execute
- Expected output (where applicable)
- Common errors and how to fix them
- Tips for using the tool effectively

**Key rules for steps:**
- One concept per step — don't bundle unrelated actions
- Observations are specific and verifiable, not vague ("Le script fonctionne")
- Conditional steps are explicitly marked: "⚠️ Seulement si..."
- Prompts given to students are complete and copy-pasteable
- Commands use realistic filenames, not placeholders like `myfile.txt`

### 10. Avancé
Open-ended questions for students who finish early or want to go further. Uses bullet points starting with **bold topic** + colon. Questions end with "?" and often include a hint in parentheses. Does NOT provide answers — encourages research and experimentation.

```markdown
### Avancé

- **Performance** : Que se passe-t-il si le fichier CSV contient 1 million de lignes ?
- **Gestion d'erreurs** : Comment demanderiez-vous à l'IA d'ajouter une gestion d'erreurs robuste ?
```

### 11. Synthèse
Retrospective section with three subsections:
- **Qu'est-ce qui a bien fonctionné ?** — reflection on what worked
- **Quels sont les problèmes rencontrés ?** — reflection on friction
- **Quelles compétences avez-vous développées ?** — skill checklist (✅)

Ends with a forward pointer: "**Prochaine étape** : Au TP suivant, vous..."

---

## Structural rules

- **No solution sections at top level** — solutions are always inside `<details>` blocks
- **Duration is always explicit** — stated at the top, realistic
- **Action/Observation is mandatory** in steps — never bare instructions without expected outcome
- **Hints (`Indice`) are not solutions** — they scaffold, they don't replace the work
- **`<details>` for hints, not for core content** — the main path is always visible
- **Steps are numbered sequentially** — `## Étape 1`, `## Étape 2`, etc.
- **Horizontal rules (`---`) between major sections** — improves scanability
- **Checkboxes (`- ✅`) for objectives and learning outcomes** — visual progress tracking
- **Bold for emphasis on key terms and actions** — not decorative

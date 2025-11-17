---
title: Documentation avec l'IA
draft: false
weight: 4
---

## La documentation : fondation de la maintenabilité

**Un logiciel sans documentation n'a pas de valeur.**

Code parfaitement fonctionnel mais incompréhensible = code mort dans 6 mois.

La documentation n'est pas un luxe, c'est le contrat entre :
- Vous et votre futur vous
- Votre équipe et les futurs mainteneurs
- Votre API et ses consommateurs
- Votre projet et ses contributeurs

**Un bon artisan documente son travail. Un excellent artisan automatise cette documentation.**

> **Rappel** : Dans les leçons précédentes, nous avons vu comment le TDD (Test-Driven Development) et le développement basé sur les spécifications permettent de clarifier les objectifs avant de coder. Ici, nous allons voir comment l'IA peut renforcer ces pratiques en automatisant la documentation. 

---

### Documentation : plusieurs types, plusieurs publics

La documentation n'est pas monolithique. Chaque type sert un public spécifique.

| Type | Public | Objectif |
|------|--------|----------|
| **README** | Utilisateurs, nouveaux devs | Installation, quick start, vue d'ensemble |
| **Docstrings** | Mainteneurs, IDE | Comprendre fonction/classe sans lire le code |
| **API spec** (OpenAPI) | Consommateurs API | Intégrer l'API sans devinette |
| **ADR** (Architecture Decision Records) | Équipe technique, futurs devs | Comprendre le "pourquoi" des choix |
| **Guides** (setup, contribution) | Contributeurs | Participer efficacement |
| **Changelog** | Ops, utilisateurs | Suivre évolutions, breaking changes |

**Problème :** Produire et maintenir tout cela manuellement demande trop de temps.

**Solution :** L'IA génère et maintient la documentation pendant que vous développez.

> **Réflexion** : Comment ces types de documentation s'intègrent-ils dans un workflow TDD ? Quels outils d'IA pourraient automatiser ces tâches tout en respectant les spécifications définies ?

---

### Cas 3 : Maintenir la doc à jour

**Un subagent dédié à la documentation**

Pour garantir que les changements dans le code n'impactent pas la documentation existante, un subagent spécialisé peut être utilisé. Ce subagent joue le rôle d'un expert rigoureux de la documentation produit.

#### Fonctionnement du subagent

1. **Analyse des changements locaux** :
   - Le subagent identifie les fichiers modifiés et les parties de la documentation potentiellement impactées.

2. **Vérification des documents concernés** :
   - Il utilise des outils de recherche locale pour vérifier si les documents associés sont à jour.

3. **Proposition de mise à jour** :
   - En cas d'incohérence, il génère des suggestions claires et propose un commit adapté.

#### Exemple d'instructions pour le subagent

Un fichier d'exemple détaillant les instructions pour ce subagent est disponible ici :
[Instructions pour le subagent documentation](./examples/documentation_subagent_instructions.txt)

> **Exercice** : Implémentez un subagent basé sur ces instructions. Testez-le sur un projet en modifiant des fichiers et en vérifiant les suggestions de mise à jour. Quels avantages observez-vous par rapport à une vérification manuelle ?

---

## Ce qu'il faut retenir

**Les 3 cas d'usage :**

1. **Legacy** : Générer README, docstrings, spec API en batch
2. **Nouvelles features** : Doc d'abord, code ensuite
3. **Maintenance** : Automatiser updates dans CI/CD, tester les exemples

**Le pattern qui marche :**
- Template (format voulu)
- Code (ce qu'il faut documenter)
- Task (ce que vous voulez)

**Règle d'or :** Doc périmée = pire que pas de doc. Automatisez ou abandonnez.

> **Conclusion** : L'IA est un outil puissant pour automatiser la documentation, mais elle doit être utilisée en complément des bonnes pratiques comme le TDD et le développement basé sur les spécifications. Réfléchissez toujours à la manière dont ces outils s'intègrent dans votre workflow global.

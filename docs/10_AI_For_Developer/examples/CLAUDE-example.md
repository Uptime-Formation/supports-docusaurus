# Nom du Projet

## Vue d'ensemble

[Description en 2-3 phrases du projet, son objectif, son état]

## Architecture

### Stack technique
- Backend: Node.js 20 + Express + TypeScript
- Base de données: PostgreSQL 15
- Frontend: React 18 + TailwindCSS
- Tests: Jest + Playwright

### Structure du projet
```
/src
  /api       - Routes et controllers
  /services  - Logique métier
  /models    - Modèles de données
  /utils     - Utilitaires
/tests       - Tests unitaires et E2E
/docs        - Documentation
```

## Conventions de code

### Style TypeScript
- Utiliser strict mode
- Préférer les interfaces aux types pour les objets
- Nommage: camelCase pour variables/fonctions, PascalCase pour classes
- Imports: toujours utiliser des chemins absolus via @/

### Conventions de commits
Suivre le format Conventional Commits avec annotations IA (voir documentation projet)

### Standards de sécurité
- Jamais de secrets en dur dans le code
- Toujours valider les entrées utilisateur
- Utiliser des requêtes paramétrées (protection SQL injection)
- Implémenter rate limiting sur les API publiques

## Workflows

### Développement d'une nouvelle feature
1. Créer une branche `feature/nom-feature`
2. Implémenter avec tests unitaires
3. Vérifier la couverture de tests (min 80%)
4. Code review obligatoire
5. Tests E2E passent
6. Merge vers `main`

### Débogage
- Toujours inclure la stack trace complète
- Fournir le contexte (fichiers concernés)
- Décrire le comportement attendu vs observé

## Dépendances

### Dépendances autorisées
- Préférer les packages bien maintenus (dernière maj < 6 mois)
- Vérifier les vulnérabilités (npm audit)
- Documenter pourquoi chaque dépendance est ajoutée

### Dépendances interdites
- Packages avec vulnérabilités critiques
- Packages abandonnés (pas de maj depuis > 2 ans)

## Personas

Quand tu travailles sur ce projet :
- **Architecte** : Pense modularité et scalabilité
- **Sécurité** : Vérifie chaque endpoint pour les vulnérabilités
- **Performance** : Optimise les requêtes DB et les temps de réponse
- **Testeur** : Couvre tous les cas limites

## Ressources

- Documentation API: `/docs/api.md`
- Guide de contribution: `/CONTRIBUTING.md`
- Architecture decisions: `/docs/ADR/`

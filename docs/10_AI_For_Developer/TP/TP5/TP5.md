---
title: TP 5 - Scénarios avancés
---

**Cinq scénarios avancés pour mettre en pratique TDD, Spec-Driven Development et intégration d'outils externes.**

**Durée : Variable (30-60 minutes par scénario)**

### Contexte

Vous avez maintenant une application complète d'analyse de ventes avec CLI, tests unitaires, et API REST avec frontend. Ce TP propose cinq scénarios indépendants pour aller plus loin, chacun simulant une situation professionnelle réelle.

Choisissez un ou plusieurs scénarios selon votre intérêt et votre niveau.

### Contraintes générales

**Pour tous les scénarios** :

1. **Continuité de l'application fil rouge**
   - Vous partez du code des TP précédents
   - Chaque évolution enrichit l'application existante
   - Les tests existants doivent rester verts

2. **TDD obligatoire**
   - Écrire les tests AVANT le code
   - Fournir les données de test (fixtures, mocks)
   - Cycle RED → GREEN → REFACTOR

3. **Spec-Driven Development**
   - Documenter le comportement attendu avant d'implémenter
   - Créer des fichiers d'instructions pour guider l'IA
   - Spécifications = source de vérité

---

## Scénario A - Support Excel (Ticket JIRA)

### Le ticket

```
┌─────────────────────────────────────────────────────────────┐
│  PRO-1397                                      🔵 En cours  │
├─────────────────────────────────────────────────────────────┤
│  Support des fichiers Excel (.xlsx)                         │
├─────────────────────────────────────────────────────────────┤
│  Type: Story          Priorité: High         Points: 5      │
├─────────────────────────────────────────────────────────────┤
│  Description:                                               │
│                                                             │
│  En tant qu'utilisateur,                                    │
│  Je veux pouvoir analyser des fichiers Excel (.xlsx)        │
│  En plus des fichiers CSV existants                         │
│  Afin de ne pas avoir à convertir mes exports comptables    │
│                                                             │
│  Critères d'acceptation:                                    │
│  ─────────────────────                                      │
│  ☐ Le CLI accepte les fichiers .xlsx en argument            │
│  ☐ L'API REST accepte l'upload de fichiers .xlsx            │
│  ☐ Le formulaire HTML permet de sélectionner .csv ou .xlsx  │
│  ☐ Les calculs sont identiques quel que soit le format      │
│  ☐ Message d'erreur clair si format non supporté            │
│  ☐ Tests unitaires pour le parsing Excel                    │
│  ☐ Tests d'intégration avec fichier Excel de test           │
│                                                             │
│  Notes techniques:                                          │
│  ─────────────────                                          │
│  - Le fichier Excel aura la même structure que le CSV       │
│  - Première ligne = headers (order_id, date, etc.)          │
│  - Une seule feuille (sheet) à traiter                      │
│  - Librairies suggérées: xlsx (Node.js), openpyxl (Python)  │
│                                                             │
│  Fichier de test fourni: sales.xlsx (dans sources/)         │
│                                                             │
├─────────────────────────────────────────────────────────────┤
│  Assigné à: Vous        Reporter: Marie (Product Owner)     │
│  Sprint: Sprint 12      Epic: Import/Export                 │
└─────────────────────────────────────────────────────────────┘
```

### Ce qu'on doit obtenir

- ✅ CLI : `python app.py sales.xlsx` ou `node app.js sales.xlsx` fonctionne
- ✅ API : Upload .xlsx retourne les mêmes résultats que .csv
- ✅ Frontend : Input accepte `.csv,.xlsx`
- ✅ Tests couvrant le parsing Excel
- ✅ Tous les tests existants toujours verts
- ✅ Commit avec référence PRO-1397

---

## Scénario B - Authentification OIDC GitHub

### Contexte

Votre équipe veut sécuriser l'accès à l'API d'analyse. Seuls les utilisateurs authentifiés via GitHub pourront uploader des fichiers et voir les résultats.

### Comportement attendu

1. **Page d'accueil non authentifié** : Bouton "Se connecter avec GitHub", formulaire d'upload masqué
2. **Flux OAuth** : Redirection GitHub → autorisation → callback avec token
3. **Page authentifié** : Username + avatar, formulaire visible, bouton déconnexion
4. **API sécurisée** : `POST /api/v1/analysis` retourne 401 si non authentifié

### Ce qu'on doit obtenir

- ✅ OAuth App configurée sur GitHub (callback sur `http://[IP_LAB]:3000`)
- ✅ Frontend adapté (état connecté/déconnecté)
- ✅ API protégée (401 sans token, 200 avec)
- ✅ Tests avec mocks (pas de dépendance GitHub réel)
- ✅ Flux complet fonctionnel
- ✅ Commit propre

---

## Scénario C - Intégration MCP JIRA

### Contexte

Vous souhaitez connecter votre IDE agentique (Claude Code, Cursor, etc.) à JIRA pour parcourir et implémenter des tickets directement depuis le chat.

### Objectif

Installer et configurer le serveur MCP Atlassian, puis utiliser l'IA pour parcourir les tickets JIRA disponibles et en implémenter un.

### Ressource

- **Atlassian MCP Server** : https://github.com/atlassian/atlassian-mcp-server

### Ce qu'on doit obtenir

- ✅ Serveur MCP Atlassian installé et configuré
- ✅ Authentification JIRA fonctionnelle (API token)
- ✅ Capacité à parcourir les tickets via le chat de l'IDE
- ✅ Un ticket choisi et implémenté avec TDD
- ✅ Commit avec référence du ticket

---

## Scénario D - Test de performance avec gros fichiers

### Contexte

Votre application fonctionne bien avec des fichiers de quelques lignes, mais un client souhaite analyser ses données historiques : plusieurs millions de lignes. Vous devez vérifier que l'application supporte ces volumes sans consommer trop de mémoire.

### Objectif

Tester et optimiser l'application pour qu'elle traite un fichier CSV de 1 Go avec seulement 128 Mo de RAM disponible.

### Contraintes

- Générer un fichier CSV de ~1 Go (~10 millions de lignes) avec des données synthétiques crédibles (villes françaises, prix cohérents par produit)
- Conteneuriser l'application avec Docker
- Limiter la RAM à 128 Mo : `docker run --memory=128m --memory-swap=128m`
- Refactorer jusqu'à ce que l'application traite le fichier sans crash

### Ce qu'on doit obtenir

- ✅ Script générateur de données synthétiques (~1 Go)
- ✅ Dockerfile fonctionnel
- ✅ Application fonctionne avec `--memory=128m`
- ✅ Résultats corrects vérifiés
- ✅ Tous les tests existants toujours verts
- ✅ Commit descriptif

---

## Scénario E - Créer un serveur MCP avec prompts de persona

### Contexte

Vous souhaitez enrichir votre IDE agentique avec des prompts spécialisés pour différents rôles (sécurité, architecture, documentation, tests). Pour cela, vous allez créer votre propre serveur MCP qui expose ces prompts.

### Objectif

Créer un serveur MCP personnalisé qui fournit des prompts de persona à votre IDE.

### Étude préalable : comprendre les prompts MCP

Avant de coder, faites lire à votre assistant la documentation officielle des prompts MCP :

- **Spécification MCP Prompts** : https://modelcontextprotocol.io/specification/2025-06-18/server/prompts

Interrogez-vous (et interrogez l'IA) sur la bonne manière d'utiliser un prompt MCP :
- Comment donner le contexte utile au prompt ? (fichier courant, sélection, projet entier ?)
- Quels arguments définir pour chaque persona ?
- Comment le client (IDE) passe-t-il le contexte au serveur MCP ?

Cette réflexion guidera la conception de vos prompts.

### Approche obligatoire : TDD / Documentation-first

Ce scénario doit suivre une approche rigoureuse :

1. **Documentation d'abord**
   - Rédiger les spécifications de chaque persona avant d'implémenter
   - Définir les paramètres attendus (code à analyser, contexte)
   - Documenter le format de réponse attendu

2. **Tests avant implémentation**
   - Écrire les tests unitaires pour chaque prompt
   - Définir les cas de test avec des exemples de code
   - Cycle RED → GREEN → REFACTOR

3. **Configuration de l'IDE**
   - Consultez la documentation officielle de votre IDE/outil pour apprendre comment ajouter un serveur MCP
   - Chaque outil (Claude Code, Cursor, Windsurf, etc.) a sa propre procédure de configuration

### Personas à implémenter

- **Responsable sécurité** : Analyse les vulnérabilités, OWASP, audit de code
- **Architecte logiciel** : Patterns, découplage, scalabilité, maintenabilité
- **Responsable documentation** : Clarté, exhaustivité, exemples, cohérence
- **Responsable tests** : Couverture, cas limites, TDD, qualité des assertions

### Ce qu'on doit obtenir

- ✅ Documentation des personas rédigée avant le code
- ✅ Tests unitaires écrits avant l'implémentation
- ✅ SDK MCP installé et projet initialisé
- ✅ Serveur MCP fonctionnel exposant des prompts
- ✅ 4 prompts de persona implémentés
- ✅ Serveur connecté à l'IDE agentique (suivre la doc de votre outil)
- ✅ Prompts testés et fonctionnels dans le chat
- ✅ Validation effective : invoquer chaque prompt avec du code réel

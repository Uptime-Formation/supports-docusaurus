---
title: 3 - Designer avec l'IA
---

## Utiliser l'IA pour le design de projet informatique

**L'IA Gen est un outil de design intéressant car il permet de challenger ses propres idées.**

Pour bien designer, il faut bien définir le cadre et les contraintes qu'il faut respecter.

En même temps il faut être capable de réfléchir dans plusieurs directions, les comparer, les enrichir.

---

### Les mauvais patterns

#### Commencer à réaliser avant d'avoir défini un cadre raisonnable

**Les LLMs sont très efficaces pour générer du texte. Beaucoup de texte.**

Mais il est difficile de générer du sens, d'éviter d'être noyé et de garder la cohérence et les priorités.  

---

#### Faire un MVP avant d'avoir une vue globale

**Les LLMs peuvent vous fournir très rapidement une version 1 de votre application.**

Mais cette première version risque de ne pas être adaptée aux besoins futurs.

--- 

### Les bons patterns

#### Définir le cadre fonctionnel

**Une application existe pour répondre à des besoins qu'elle vise à satisfaire.**

Il faut donc fournir un cadre minimal pour préciser dans le contexte les éléments qui guident votre propre jugement.

- Expression de besoins : quelles sont les fonctionnalités métiers attendues ?
- échanges de données : flux

---

**Ce cadre est évidemment très variable selon la nature du code à produire.**

Ajouter des interfaces dans un logiciel web MVP, créer une API REST centrale ou fabriquer une base de données de type Graph sont des sujets très différents.

Mais c'est pour spécifier cette différence qu'il est important de qualifier la nature du besoin fonctionnel.

```text

<Contexte Métier>  
La DSI souhaite disposer d'une solution de messagerie pour les clients réutilisable par plusieurs applications internes.  
- **Fonctionnalité principale** : Envoi de messages via SMS/email  
- **Exigence critique** : Abstraction complète de la logique d'envoi pour les applications émettrices 
- **Besoins secondaires** :  
  • Rapports quotidiens des échecs de livraison  
  • Traçabilité complète des messages  
  • Isolation des applications clientes  
</Contexte Métier>  
```

---

#### Définir les contraintes d'architecture et d'industrialisation
 
 
**Une application est conçue pour répondre à certaines contraintes d'exploitation.**

N'hésitez pas introduire dans votre prompt les contraintes attendues de performances, d'intégrité des données, de sécurité et de traçabilité.

```text
<Contexte Architecture>
1. **Performance** :  
   - 1000 msg/sec en pic  
   - Latence < 500ms P99  

2. **Intégrité des Données** :  
   - Garantie "exactly-once delivery"  
   - Transactions ACID pour les statuts de messages  

3. **Sécurité** :  
   - Chiffrement au repos/en transit  
   - RBAC avec JWT et secrets managés (Hashicorp Vault)  

4. **Traçabilité** :  
   - Correlation ID end-to-end  
   - Logs structurés (OpenTelemetry)  
   - Historique des changements de statut (immutable ledger)  
</Contexte Architecture>

```

---

#### Utiliser des Modèles avec réflexion selon de besoin

**Les modèles comme DeepSeek R-1 ou ChatGPT 4 sont capables d'une forme de réflexion plus poussée que leurs prédécesseurs.**

Cette réflexion les fait s'auto-analyser, considérer la réponse à données, et définir le cadre avant d'apporter la réponse.

Elle les rend plus efficace sur les sujets les plus complexes, sans que cela remette en question votre esprit critique.

Mais elles sont souvent plus coûteuses, et la partie réflexive peut être inutile.


--- 

#### Utiliser des personas pour incarner les différents cas d'utilisation 

**Les personas sont un concept venant du design qui permet de définir des profils de utilisateurs fictifs qui représentent les différents cas d'utilisation.**

Pour concevoir une application et ses interfaces, on va par exemple créer un profil pour :

- Sophie, utilisatrice finale, 45 ans
- Marie, conseiller client, 50 ans
- Azid, responsable d'exploitation, 30 ans
- etc.

--- 

**Les agents sont une forme de persona adaptés à l'IA : on définit un cadre de production pour la génération basé sur une typologiqe métier.** 

On peut ainsi aborder un programme en appliquant le cadre de pensée de l'entreprise.

> « Toute organisation qui conçoit un système, au sens large, concevra une structure qui sera la copie de la structure de communication de l’organisation. »
> — M. Conway, Loi de Conway 

> « Si vous avez quatre équipes travaillant sur un compilateur, vous aurez un compilateur à quatre étapes »
> — Eric S. Raymond

---

**Exemple : Architecte logiciel**

```text

You are an expert **Software Architect** with 15+ years of experience designing scalable enterprise systems. Your core responsibilities include:  
1. **System Design**: Create cloud-agnostic, fault-tolerant architectures (microservices, serverless, or monoliths) using diagrams (Mermaid/PlantUML).  
2. **Tech Selection**: Justify framework/tool choices (e.g., Kubernetes vs. Nomad) based on scalability, cost, and security.  
3. **Non-functional Requirements**: Address latency, compliance (GDPR/HIPAA), and disaster recovery.  
4. **Anti-pattern Prevention**: Identify risks like vendor lock-in or single-point failures.  

**Workflow**:  
- **Input**: Business requirements, constraints (budget/timeline), and existing tech stack.  
- **Output**:  
  - Architecture Decision Records (ADRs) with pros/cons.  
  - Visual diagrams + infrastructure-as-code (Terraform) snippets.  
  - 12-month scalability roadmap.  

**Rules**:  
- Prioritize maintainability over hype.  
- Reject unrealistic deadlines threatening system resilience.  
- Cite real-world precedents (e.g., "Netflix's chaos engineering").  
```


---

**Exemple : Lead Developper**

```text
You are a pragmatic **Lead Developer** with 10+ years in full-stack development. Your mandate:  
1. **Code Leadership**:  
   - Enforce clean code standards (SOLID, DRY) and review PRs.  
   - Break epics into tasks (e.g., Jira tickets) with effort estimates.  
2. **Performance Optimization**: Identify bottlenecks via profiling (e.g., Py-Spy/Chrome DevTools).  
3. **Code Quality**: Ensure error handling, test coverage and documentation are up-to-date.   

**Workflow**:  
- **Input**: Feature specs, bug reports, or architecture blueprints.  
- **Output**:  
  - Pseudocode/flowcharts for complex logic.  
  - Code snippets (Python/JS/Go) with error handling.  
  - Refactoring plans with tech debt ratios.  

**Rules**:  
- Reject "quick fixes" compromising long-term maintainability.  
- Advocate for automation (CI/CD, linting).  
- Flag skill gaps requiring training.  
```


---

**Exemple : responsable de tests**

```text

You are a meticulous **Tests Manager** specializing in shift-left QA. Your focus:  
1. **Test Strategy**: Design risk-based test plans (SAFe/Agile) covering:  
   - Regression, security (OWASP ZAP), and performance (Locust/JMeter).  
2. **Automation**: Build scalable frameworks (e.g., Selenium/Cypress + PyTest).  
3. **Metrics**: Track coverage, defect density, and escape rate.  

**Workflow**:  
- **Input**: User stories, build artifacts, or failure reports.  
- **Output**:  
  - Test cases (Gherkin syntax).  
  - Automation scripts with CI integration examples.  
  - Quality dashboards (e.g., Grafana).  

**Rules**:  
- Treat flaky tests as critical failures.  
- Prioritize tests by business impact (e.g., checkout > search).  
- Advocate for observability (logs/traces) in test design.  

```

---

### Un exemple d'automatisation de la production

**On voit qu'à terme les prompts vont être de plus en plus complexes et composés de différentes sources.**

Voici un exemple de workflow pour automatiser la production des roles avec une source de documentation.

---

### 1. Utiliser un modèle avec réflexion

```
En tant qu'analyste métier spécialisé dans le développement logiciel, 
votre objectif est de m'interviewer, moi le client, sur mon projet de 
construction d'un <insérer résumé>. 
Menez l'entretien dans un style conversationnel, en me posant une question 
à la fois et en livrant un document d'exigences détaillé
```

### 2. Continuer avec ce modèle avec réflexion

```
En tant qu'architecte logiciel expert en <vos frameworks choisis>, 
votre objectif est d'analyser le document d'exigences et de livrer un 
aperçu technique détaillé de la structure de projet et de 
l'infrastructure nécessaires pour ce projet
```

### 3. Avec cette analyse technique, prendre un modèle plus simple pour la production des rôles

```
En tant qu'ingénieur logiciel, spécialisé en <vos frameworks choisis>,
votre objectif est d'analyser le document d'exigences et de le croiser 
avec l'analyse technique pour rédiger un document de test détaillé 
orienté comportement en pseudo-code, couvrant tous les chemins heureux 
et d'erreur, afin d'atteindre la couverture de code la plus élevée 
possible pour mon projet
```

### 4. Continuer avec un modèle normal

```
En tant qu'ingénieur de prompts expert et ingénieur logiciel, spécialisé en 
agents IA et <votre framework choisi>, votre objectif est de réviser 
le document BDD, ordonner les tests pour qu'ils puissent être développés 
en isolation, sans avoir besoin de passer aux tests ultérieurs pour les 
dépendances, et créer des prompts IA par test dans le format suivant : 

    'En tant que <Rôle>, spécialisé en <Framework>, votre objectif est d'écrire <Test>. 
    Vous écrirez d'abord le test, puis exécuterez <Commande de Test> et continuerez 
    à corriger les erreurs jusqu'à ce que le test passe. Vous suivrez les principes 
    de codage SOLID et DRY, une classe par fichier, pas de classes globales (ajoutez 
    plus de règles selon vos besoins)
```

### 5. Ajouter vos documents dans un dossier ./docs du projet en cours.

### 6. Créer un fichier .windsurfrules dans le projet en cours et demander à Windsurf :

```
Révisez le document d'analyse technique, puis remplissez mon 
document .windsurfrules avec les règles dont j'ai besoin pour ce projet. 
Utilisez le modèle suivant :

## Framework de test
- /src/my-test-project

## Projet API
- /src/my-api-project

## Documents de contexte
- /docs

## Directives de style de codage
- Toujours suivre les principes SOLID
  - etc
```
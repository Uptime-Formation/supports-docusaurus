---
title: Nouveaux workflows avec MCP et agents
draft: false
weight: 5.5
---

## Du ticket à la PR : automatisation complète

**La nouvelle réalité** : L'IA pilote maintenant tout le workflow de développement.

**Avant** : Lire ticket → Coder → Tests → PR → Review

**Maintenant** : Ticket → Agent IA fait tout → Review humain → Merge

**Votre nouveau rôle** : Se concentrer sur la qualité, la cohérence et la robustesse. Pas sur le code bas niveau.

---

## Le workflow "Ticket to PR"

![Workflow du ticket à la PR](/img/ai/workflow-ticket-to-pr.svg)

Voilà ce qui se passe concrètement :

### 1. User crée ticket (📝)

Un ticket Jira ou GitHub issue décrit une feature ou un bug :

```
Title: Add CSV export for sales reports

Description:
Users need to export sales data to CSV.
- GET /api/reports/sales/export?start_date=X&end_date=Y
- Returns CSV with columns: date, product, quantity, revenue
- Filename: sales_YYYY-MM-DD_to_YYYY-MM-DD.csv
```

---

### 2. Fetch via MCP (🔌)

**MCP** = Model Context Protocol. Un standard pour connecter l'IA à vos outils (Jira, GitHub, databases, etc.).

Le dev utilise un **agent MCP** dans son IDE pour récupérer les tickets :

```bash
# Dans Claude Code
"Liste les tickets Jira assignés à moi avec statut 'To Do'"

# L'agent MCP se connecte à Jira API et récupère les infos
```

**Installation d'un MCP server** (exemple Jira) :

```bash
npm install -g @modelcontextprotocol/server-jira
```

Configuration dans `~/.config/claude/config.json` :

```json
{
  "mcpServers": {
    "jira": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-jira"],
      "env": {
        "JIRA_URL": "https://your-company.atlassian.net",
        "JIRA_EMAIL": "you@company.com",
        "JIRA_API_TOKEN": "your-token"
      }
    }
  }
}
```

**Résultat** : Claude peut maintenant lire vos tickets Jira directement.

---

### 3. Sélection ticket (👆)

Le dev choisit le ticket à traiter en 4 étapes :

#### 3.1 Authentification

Connecter le serveur MCP Jira avec son token :

```bash
claude mcp add --transport sse atlassian https://mcp.atlassian.com/v1/sse
```

Le token Jira est configuré dans l'environnement. Claude peut maintenant accéder aux tickets.

#### 3.2 Lister les projets

```
"Liste mes projets Jira"

→ Affiche les projets accessibles avec le token
```

#### 3.3 Filtrer les tickets

```
"Tickets assignés à moi, statut 'To Do', projet X"

→ Liste des tickets filtrés avec priorité et labels
```

#### 3.4 Choisir un ticket

```
"Je prends le ticket ABC-123"

→ Claude récupère description complète, requirements, acceptance criteria
```

**Résultat** : Contexte complet du ticket dans l'IDE, pas besoin d'ouvrir Jira.

---

### 4. Planification multi-agents (🧠)

L'IA utilise plusieurs **personas/subagents** pour analyser le besoin :

- **Persona Architecte** : "Quelle structure ? Où placer le code ?"
- **Persona Sécurité** : "Quels risques ? Injection SQL ? Rate limiting ?"
- **Persona Testeur** : "Quels tests écrire ? Quels cas limites ?"

Chaque persona donne son avis. L'IA synthétise un plan d'action.

**Exemple de plan généré** :

```
1. Ajouter endpoint GET /api/reports/sales/export dans src/api/reports.ts
2. Utiliser csv-writer pour générer le CSV
3. Ajouter header Content-Type: text/csv et attachment
4. Tester avec données réelles + données vides + dates invalides
5. Vérifier sécurité : pas d'injection, validation des dates
```

---

### 5. Production code (TDD) (⚙️)

L'agent autonome génère le code en suivant le cycle **TDD** :

**Spec → Tests → Code → Tests pass**

**Cadrage par les instructions** : L'agent suit les directives du projet (fichier `CLAUDE.md`, conventions, stack technique). Plus les instructions sont claires, meilleur est le code généré.

**Qualité des inputs** : L'agent a besoin de tickets bien structurés. Utiliser des **templates d'issues** (GitHub, Jira) garantit que toutes les infos nécessaires sont présentes : critères d'acceptation, contraintes techniques, exemples de résultats attendus.

→ [GitHub Issue Templates](https://docs.github.com/en/communities/using-templates-to-encourage-useful-issues-and-pull-requests/configuring-issue-templates-for-your-repository)

L'agent écrit d'abord les tests, puis le code pour les faire passer. Si les tests échouent, il corrige. Boucle jusqu'au vert.

---

### 6. Contrôle qualité (✅)

Les **personas** vérifient le résultat :

- **Persona Sécurité** : "Vérifie qu'il n'y a pas d'injection, que les dates sont validées"
- **Persona Testeur** : "Vérifie que la couverture est > 80%, que tous les tests passent"
- **Persona Architecte** : "Vérifie que ça respecte les conventions du projet, la cohérence globale"
- **Persona Documentation** : "Vérifie que les changements n'ont pas créé d'incohérences dans la doc (README, API spec, guides)"

Si tout est OK, on passe à l'étape suivante. Sinon, retour à l'étape 5.

---

### 7. Pull Request prête → Review humain (👤)

L'agent crée automatiquement la PR avec :

```
Title: feat(reports): add CSV export for sales data

Closes #123

## Implementation
- Added GET /api/reports/sales/export endpoint
- Uses csv-writer for CSV generation
- Returns file with attachment header

## Tests
✓ 15/15 tests passing
✓ Coverage: 87%

## Security
✓ Input validation on dates
✓ No SQL injection risk

## Files changed
- src/api/reports.ts (+28 lines)
- tests/api/reports.test.ts (+24 lines)
- package.json (added csv-writer dependency)

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>
```

**Le dev review** : vérifie la logique métier, teste manuellement, puis merge.

---

## MCP : Connecter l'IA à vos outils

**MCP** = Model Context Protocol. Standard ouvert pour connecter les LLM à des sources de données externes.

### Architecture simple

```
┌─────────────────┐
│   Claude Code   │
│   (MCP Client)  │
└────────┬────────┘
         │ MCP Protocol
         │
┌────────▼────────┐
│   MCP Server    │
│  (ex: Jira)     │
└────────┬────────┘
         │
┌────────▼────────┐
│   Jira API      │
└─────────────────┘
```

### MCP Servers disponibles

- **@modelcontextprotocol/server-jira** : Tickets Jira
- **@modelcontextprotocol/server-github** : Issues, PRs GitHub
- **@modelcontextprotocol/server-postgres** : Bases de données
- **@modelcontextprotocol/server-slack** : Messages Slack
- Et plein d'autres : https://github.com/modelcontextprotocol/servers

### Créer votre propre MCP server

Si vous avez une API interne, créez un MCP server custom :

```typescript
import { Server } from '@modelcontextprotocol/sdk/server/index.js';

const server = new Server({
  name: 'my-api-server',
  version: '1.0.0',
});

// Définir un tool
server.setRequestHandler('tools/list', async () => ({
  tools: [
    {
      name: 'get_sales_data',
      description: 'Query internal sales database',
      inputSchema: {
        type: 'object',
        properties: {
          start_date: { type: 'string' },
          end_date: { type: 'string' }
        }
      }
    }
  ]
}));

// Implémenter le tool
server.setRequestHandler('tools/call', async (request) => {
  if (request.params.name === 'get_sales_data') {
    const { start_date, end_date } = request.params.arguments;
    const results = await myInternalAPI.getSales(start_date, end_date);
    return { content: [{ type: 'text', text: JSON.stringify(results) }] };
  }
});
```

**Résultat** : Claude peut maintenant interroger votre API interne.

---

## Architectures agentiques avec LangChain

**LangChain** = Framework pour créer des agents autonomes qui utilisent des outils pour atteindre un objectif.

### Agent simple avec outils

```python
from langchain.agents import initialize_agent, Tool
from langchain.llms import Anthropic

# Définir les outils disponibles
tools = [
    Tool(
        name="search_code",
        func=search_codebase,
        description="Search for functions/classes in codebase"
    ),
    Tool(
        name="run_tests",
        func=run_pytest,
        description="Execute pytest and return results"
    ),
]

# Créer l'agent
llm = Anthropic(model="claude-3-5-sonnet-20241022")
agent = initialize_agent(
    tools=tools,
    llm=llm,
    agent="zero-shot-react-description",
)

# Utiliser l'agent
result = agent.run("""
    Find all authentication functions,
    check if they have tests,
    and report coverage gaps.
""")
```

**L'agent va** :
1. Utiliser `search_code` pour trouver les fonctions auth
2. Utiliser `run_tests` pour vérifier la couverture
3. Générer un rapport

---

### Multi-agents avec CrewAI

**CrewAI** = Plusieurs agents spécialisés qui collaborent.

```python
from crewai import Agent, Task, Crew

# Agents spécialisés
analyst = Agent(
    role='Requirements Analyst',
    goal='Understand ticket and create plan',
    tools=[jira_tool, search_tool]
)

developer = Agent(
    role='Developer',
    goal='Implement code following plan',
    tools=[code_tool, git_tool]
)

tester = Agent(
    role='QA Tester',
    goal='Write comprehensive tests',
    tools=[test_tool, coverage_tool]
)

# Tâches
task1 = Task(description='Analyze ticket PROJ-123', agent=analyst)
task2 = Task(description='Implement the feature', agent=developer, context=[task1])
task3 = Task(description='Write tests', agent=tester, context=[task2])

# Créer l'équipe et lancer
crew = Crew(agents=[analyst, developer, tester], tasks=[task1, task2, task3])
result = crew.kickoff()
```

**Résultat** : Ticket → Analyse → Code → Tests, entièrement automatisé.

---

**Ressources** :

- MCP Servers : https://github.com/modelcontextprotocol/servers
- Claude GitHub Actions : https://code.claude.com/docs/github-actions
- LangChain : https://python.langchain.com/
- CrewAI : https://www.crewai.com/

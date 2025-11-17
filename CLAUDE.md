# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Docusaurus-based e-learning platform for DevOps training materials, maintained by Uptime Formation. The repository contains hands-on technical courses in French covering Docker, Kubernetes, Terraform, KVM, Prometheus monitoring, and AI for developers.

**Live site**: https://docker.uptime-formation.fr
**Target audience**: DevOps students and professionals
**Language**: French (all content must be in French)

## Core Technologies

- **Docusaurus 2.4.1**: Static site generator optimized for documentation
- **React 17**: UI framework
- **Node.js**: Required version ≥16.14
- **Package Manager**: Both npm (package-lock.json) and yarn (yarn.lock) present

## Common Commands

### Development Workflow
```bash
npm start           # Start dev server at http://localhost:3000 with hot reload
npm run build       # Build static site to build/ directory
npm run serve       # Serve production build locally for testing
npm run clear       # Clear Docusaurus cache (useful when things break)
```

### PDF Generation for Trainers
```bash
docs/pdf.sh         # Interactive script to generate PDFs from training modules
                    # Requires: pdfnice utility (from bin/ directory)
                    # Generates: Combined PDFs (Docker.pdf, CKAD.pdf, etc.)
                    # Process: Copies MD → patches image paths → generates individual PDFs → combines
```

### Deployment
```bash
npm run deploy      # Deploy to GitHub Pages (gh-pages branch)
```

## Pedagogical Architecture

This is fundamentally an **e-learning repository**. Understanding the teaching methodology is crucial.

### Teaching Philosophy

1. **Learning by Doing**: Heavy emphasis on hands-on labs (TPs - Travaux Pratiques)
2. **Progressive Complexity**: Content builds from basics to advanced topics with clear progression
3. **Real-World Scenarios**: Labs use realistic applications (monsterstack, voting app, etc.)
4. **Infrastructure as Code**: All exercises teach declarative approaches (YAML, Terraform HCL)
5. **Action → Observation Pattern**: Labs explicitly show what students do and what they should observe

### Content Organization

Training modules are organized in `docs/` with numeric prefixes controlling order:

```
docs/
├── 0_accueil.md                    # Homepage
├── 0_intro.md                      # General introduction
├── 0_Labs_Comment-ca-marche.md     # Lab infrastructure explanation
├── 1_Docker_Bases/                 # Docker fundamentals
├── 1_Docker_Developer/             # Docker for developers
├── 1_Docker_Production/            # Docker production deployment
├── 2_Docker_Advanced/              # Advanced Docker topics
├── 2_docker+k8s/                   # Combined Docker + Kubernetes course
├── 3_Kubernetes/                   # Core Kubernetes training
├── 3_CKAD/                         # CKAD certification prep
├── 5_Kubernetes-Advanced/          # Advanced Kubernetes
├── 8_Terraform/                    # Infrastructure as Code with Terraform
├── 9_KVM/                          # KVM virtualization
├── 10_AI_For_Developer/            # AI tools for developers
└── 10_Prometheus Monitoring/       # Monitoring with Prometheus
```

**Within each module**, files follow this naming convention:
- **100_, 110_, 120_...**: Numeric prefixes control lesson order (increments of 10 allow insertion)
- **cours_**: Theory/lecture content (e.g., `110_cours_k8s_storage.md`)
- **tp_**: Practical exercises/labs (e.g., `120_tp_k8s_cli.md`)
- **tp_opt_**: Optional advanced labs (e.g., `300_tp_opt_write_monsterchart.md`)
- **Évaluation**: Assessment files to check student progress

### TP (Travaux Pratiques) Structure

**Labs follow a strict pedagogical pattern:**

```markdown
---
title: TP - Descriptive Title
---

## Brief Introduction
Context and what the lab is about

### Objectif
Clear statement of learning goals (what students will accomplish)

### Étapes
Step-by-step instructions, often using this pattern:

- **Action**: What the student should do
  **Observation**: What they should see/verify

- **Action**: Next step
  **Observation**: Expected result

### Advanced/Avancé (optional)
Challenge questions or advanced extensions:
- "Que donne X commande ? Pourquoi ?"
- "Comment faire Y ?"

### Solution
<details><summary>Afficher</summary>

Complete solution with commands and explanations

</details>
```

**Example from actual lab:**
```markdown
- **Action**: Télécharger l'image Docker de base `ubuntu:24.04`
  **Observation**: L'image apparaît dans la liste des images locales via `docker images`.

- **Action**: Lancer un conteneur en mode daemon avec `tail -f /dev/null`
  **Observation**: Le conteneur tourne en arrière-plan (`docker ps` le montre).
```

### Course (Cours) Structure

**Theory content follows this pattern:**

```markdown
---
title: Topic Name
draft: false
---

## Main Concept Title

Clear explanation of the concept with:
- Bullet points for key ideas
- **Bold text** for emphasis on critical points
- Code examples with syntax highlighting
- YAML/JSON/HCL examples
- Links to external documentation

### Subsection
Progressive detail building...

#### Example (Exemple)
Concrete code examples showing the concept in action

## Related Concept
Building on previous knowledge...
```

**Key teaching patterns:**
- Start with "why" before "how"
- Use analogies and comparisons (e.g., "Un Pod est comme un groupe de conteneurs")
- Include warnings about common mistakes
- Reference previous concepts to build knowledge
- End with practical takeaways

### Writing Style Guidelines

1. **Language**: Always French, conversational but professional
2. **Tone**: Encouraging, practical, assumes intelligent learners
3. **Formatting**:
   - Use `**bold**` to emphasize important commands, concepts, or warnings
   - Use `code blocks` with language tags for syntax highlighting
   - Use `>` blockquotes sparingly for important notes
   - Use numbered prefixes (100_, 110_) in filenames for ordering
   - Use collapsible `<details>` tags for solutions

4. **Commands**: Always show complete, runnable commands
   ```bash
   kubectl get pods -n kube-system  # With helpful comments
   ```

5. **Explanations**:
   - Ask rhetorical questions to engage learners: "Sauriez-vous expliquer ce que l'app fait ?"
   - Provide "Observation" checkpoints so students know they're on track
   - Include troubleshooting hints

6. **Progressive Disclosure**:
   - Basic steps first, advanced variations later
   - "Nous y reviendrons plus tard" when introducing concepts to be detailed later

## Lab Infrastructure (Important Context)

Students use **pre-configured VPS environments** provided by Uptime Formation:
- Each student gets a personalized VPS (e.g., `sacha.brx2022.uptime-formation.fr`)
- Access via SSH and browser-based VNC (Apache Guacamole)
- Pre-installed tools: Docker, Kubernetes, kubectl, Lens, etc.
- Labs assume Ubuntu/Debian environment
- Common installation pattern: `sudo snap install <tool> --classic`

**When writing labs:**
- Assume tools may need installation (provide install commands)
- Use realistic hostnames in examples
- Test with `minikube` or `k3s` for Kubernetes labs
- Verify Docker socket permissions

## Site Configuration

**docusaurus.config.js**:
- Title: "Formation DevOps"
- i18n: Default locale is `fr` (French)
- `routeBasePath: '/'` - docs appear at root, not `/docs/`
- Custom symlinks plugin at `src/plugins/symlinks/` (disables webpack symlink resolution)
- Edit URL points to Facebook/Docusaurus (should probably be updated to actual repo)

**sidebars.js**:
- Uses `autogenerated` sidebar from docs folder structure
- Filesystem hierarchy + numeric prefixes = navigation order
- No manual sidebar configuration needed

**Frontmatter required in markdown files**:
```yaml
---
title: "Display Title"
weight: 10              # Used in some modules for ordering
draft: false            # Set to true to hide from production
sidebar_position: 5     # Optional explicit position
---
```

## Key Implementation Details

### Symlinks Plugin
Custom Docusaurus plugin at `src/plugins/symlinks/index.js` disables webpack symlink resolution:
```javascript
resolve: { symlinks: false }
```
**Do not remove this** - it's essential for the content structure to work.

### PDF Generation Workflow
The `docs/pdf.sh` script (for trainers):
1. Prompts for training module selection (e.g., 1_Docker_Bases)
2. Copies all `.md` files to `_pdf/` temp directory
3. Patches image paths: `/img/` → `../../static/img/`
4. Extracts frontmatter and reformats for PDF title pages
5. Converts each markdown to PDF using `pdfnice` utility (must be in `~/bin/`)
6. Combines all PDFs with `pdfunite` into single training PDF
7. Output: `Docker.pdf`, `CKAD.pdf`, `Terraform.pdf`, etc.

**Dependencies:** `pdfnice`, `pdfunite` (part of `poppler-utils`)

### Static Assets
- Images and files go in `static/` directory
- Referenced in markdown as `/img/filename.png` (not `../static/img/`)
- PDF script automatically patches these paths during PDF generation

## Creating New Content

### Adding a New Lab (TP)

1. **Determine the module**: Which training folder? (e.g., `3_Kubernetes/`)
2. **Choose number prefix**: Find next available slot (e.g., `135_` between `130_` and `140_`)
3. **Use naming convention**: `135_tp_descriptive_name.md`
4. **Follow TP structure** (see "TP Structure" above)
5. **Include**:
   - Clear objective
   - Step-by-step actions with observations
   - Advanced challenges
   - Complete solution in `<details>` tag
6. **Test the lab yourself** before committing
7. **Verify ordering** with `npm start` and check sidebar

### Adding a New Course Section (Cours)

1. **Choose appropriate prefix**: `cours_` with number (e.g., `145_cours_topic.md`)
2. **Structure content**:
   - Start with concept explanation
   - Provide examples with code blocks
   - Use **bold** for key takeaways
   - Link to official documentation
   - Reference related TPs
3. **Use French throughout** with technical terms in English when standard
4. **Add diagrams/images** to `static/img/` if helpful

### Adding a New Training Module

1. Create new directory: `docs/X_Module_Name/`
2. Add `_index.md` or intro file with frontmatter
3. Create numbered course and TP files
4. Update main `docs/0_accueil.md` if needed
5. Test build and navigation
6. Consider adding PDF generation support in `pdf.sh`

## Important Constraints

1. **French Language**: All student-facing content must be in French
2. **Numeric Prefixes**: Essential for navigation order - never remove them
3. **Increments of 10**: Allows inserting content later (100, 110, 120...)
4. **TP Structure**: Follow the established pattern for consistency
5. **Solution Tags**: Always use `<details><summary>Afficher</summary>` for solutions
6. **Action/Observation**: Use this pattern in steps for clear learning outcomes
7. **Test Before Commit**: Run labs on actual environment to verify commands work

## Common Patterns & Examples

### Referencing Commands
```markdown
- Listez les pods avec `kubectl get pods`
- Affichez les détails avec `kubectl describe pod/nom-du-pod`
```

### Code Blocks with Explanations
```markdown
Créez le fichier `deployment.yaml`:

\```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mon-app
spec:
  replicas: 3
\```

- `replicas: 3` définit le nombre de copies de l'application
```

### Questions for Students
```markdown
- Sauriez-vous expliquer pourquoi l'application affiche différents conteneurs ?
- Que se passe-t-il si vous réduisez le nombre de réplicats ?
- Quelle différence avec l'exposition précédente ?
```

### Progressive Labs
Start simple, build complexity:
- TP1: Basic deployment with `kubectl create`
- TP2: YAML-based deployment with `kubectl apply`
- TP3: Multi-container application (monsterstack)
- TP4 (opt): Helm charts and Kustomize

## License & Authors

Content licensed under **CC-BY-NC-SA**

**Created by:**
- Alban Crommer
- Elie Gavoty
- Alexandre Aubin
- Aurélien N.
- Hadrien Pélissier

**© Formations Uptime**

---

## Quick Reference

**Start dev server**: `npm start`
**Build site**: `npm run build`
**Generate PDFs**: `docs/pdf.sh`
**Course files**: `XXX_cours_topic.md`
**Lab files**: `XXX_tp_topic.md`
**Solutions**: Always in `<details>` tags
**Language**: French only
**Ordering**: Numeric prefixes (100, 110, 120...)

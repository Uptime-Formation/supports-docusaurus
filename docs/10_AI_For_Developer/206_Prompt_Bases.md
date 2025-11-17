---
title: Bases du prompt
---

## Quickstart 

Utilisez l'interface LLM de votre choix et lancez le prompt suivant.

```text

Décris le prompt engineering sous forme de haiku en français.

```

---


## Maîtriser le prompt pour maîtriser le LLM

**C'est la revanche des littéraires : pour obtenir une bonne sortie texte, il faut une bonne entrée texte.**

Le prompt est la base des échanges avec un modèle de language.

Son texte est le flux en entrée d'un LLM et définit le texte qui va sortir. 

---

**C'est une raison majeure du succès des LLM : toute personne sachant écrire peut en utiliser un, la barrière est (relativement) basse.**

Pour autant, l'expérience courante des utilisateurs est qu'il faut du temps pour parvenir au résultat attendu.

L'objectif est de réduire le temps pour améliorer l'efficacité et réduire les coûts d'exploitation.

---

### Méthode ACTIF : un cadre universel pour vos prompts

**Ces bases du prompt sont valables pour TOUT LE MONDE, pas seulement les développeurs.**

La méthode **ACTIF** de Matthieu Corthesy ([actif.numedu.org](https://actif.numedu.org/)) propose un cadre simple pour structurer vos prompts :

| Élément | Description | Exemple |
|---------|-------------|---------|
| **A**ction | L'objectif, ce que vous voulez | "Rédige un article de blog" |
| **C**ontexte | Les informations de fond | "Mon entreprise vend des chaussures éco-responsables" |
| **T**onalité | Le style, l'ambiance | "Ton professionnel mais accessible" |
| **I**dentité | Le rôle de l'IA | "Tu es un expert en marketing digital" |
| **F**ormat | La structure de sortie | "Article de 500 mots avec 3 sections" |

**Exemple concret :**

```text
[Identité] Tu es un expert en marketing digital spécialisé dans l'éco-responsabilité.
[Action] Rédige un article de blog pour promouvoir notre nouvelle collection.
[Contexte] Mon entreprise vend des chaussures fabriquées à partir de matériaux recyclés.
[Tonalité] Utilise un ton professionnel mais accessible, engageant.
[Format] Article de 500 mots avec introduction, 3 bénéfices clés, et conclusion.
```

:::tip Pour les développeurs
Les développeurs iront **beaucoup plus loin** avec des techniques avancées (few-shot learning, chain-of-thought, agents autonomes...), mais **commençons par maîtriser ces bases** qui s'appliquent à tous les usages.
:::

**Ressource :** [Guide complet de la méthode ACTIF](https://outilia.ch/methode-actif-optimisez-vos-prompts-chatgpt/)

---

### Le Prompt Engineering

**Le Prompt Engineering a émergé notamment via les modèles de diffusion qui permettent de générer des images et des vidéos.**

Le choix des mots était essentiel dans ce cadre pour obtenir l'image voulue, avec des étapes de réécriture du prompt pour le raffiner et l'optimiser, car il n'y a pas de conversation.

---

**Cet art consiste à se spécialiser dans la recherche dans un hyper-espace sémantique en utilisant les mots comme outils.**

Les mots choisis et leur séquence vont définir un vecteur dans l'espace latent du modèle, qui est l'ensemble des représentations possibles.

Référence : La bible par Google https://drive.google.com/file/d/1AbaBYbEa_EbPelsT40-vj64L-2IwUJHy/view?pli=1


---

## Les bonnes pratiques pour les prompts

- Le prompt doit être clair et précis : le choix des mots est essentiel
- Le prompt inclut un contexte, des informations de fond pertinentes 
- Le prompt définit la sortie attendue, via un template par exemple
- Le prompt définit la profondeur de raisonnement et de réflexion 

Un guide intéressant pour creuser le sujet : https://www.promptingguide.ai/

---

### System Prompt et User Prompt

Première chose à comprendre : il existe deux types de prompts : le System Prompt et le User Prompt.

- Le System Prompt est le prompt qui définit le rôle du modèle et les règles à respecter.
- Le User Prompt est le prompt qui définit la demande de l'utilisateur.

--- 

**Pour des exemple de systems prompt**

- https://github.com/0xeb/TheBigPromptLibrary/tree/main/SystemPrompts
- https://github.com/jujumilk3/leaked-system-prompts/tree/main

Avec les modèles locaux il est possible de définir le prompt system, ce qui permet de mieux contrôler le modèle.

---

**Au final, les deux prompts sont concaténés pour former le prompt final.**


```
[CONTEXTE TOTAL = Limite technique (ex: 128K tokens)]
│
├── 📜 **SYSTEM PROMPT**  
│   (Instructions permanentes : rôle, style, règles)  
│
├── ❓ **USER PROMPT**  
│   (Requête actuelle)  
│
└── 💬 **OUTPUT**  
    (Réponse générée en cours, token par token)
```

---

### Le contexte


**Le contexte est une contrainte technique du modèle qui définit le nombre de tokens que le modèle peut utiliser en une seule passe .** 

La *context window* désigne le nombre maximal de **tokens** (mots ou sous-mots) qu'un LLM peut traiter **en cumulant l'entrée et la sortie**.   

Le contexte inclut potentiellement les tokens générés précédemment dans la même session (historique de conversation), pas seulement le prompt initial. 

Les modèles comme GPT-4 Turbo avec 128K traitent l'ensemble prompt + historique comme un bloc contextuel unique.

**On va voir que savoir optimiser le contexte pour obtenir la meilleure sortie possible est une des clés du succès de l'usage des LLM pour le code.**

---

## L'adhérence au prompt 

**L'adhérence au prompt est la mesure de la capacité du modèle à suivre les instructions envoyées.**

C'est une dimension essentielle du **prompt engineering** : obtenir d'un modèle un résultat optimal :
- qualité de la génération (texte, code, image, etc.)
- intégration des contraintes 
- optimisation du temps

---

**Une mauvaise adhérence peut se manifester par plusieurs écarts du modèle.**

- **Incompréhension globale** : la nature de la réponse est faussée  
    > On demande une traduction, le modèle renvoie une analyse 

- **Dérapage contextuel** : le modèle ne prend pas en compte les demandes formulées
    > On demande uniquement du typescript, le modèle renvoie du python
 
- **Incohérence interne** : le modèle hallucine ou répète des réponses déjà données
    > On demande la résolution d'un bug, le modèle renvoie du code avec le même bug

---

## La discussion 

**Les chatbots comme ChatGPT ont habitués les utilisateurs à un format discursif de type question / réponse.**

L'**illusion de l'échange** vient du fait que l'**historique complet de la conversation** (questions, réponses, instructions) est convoyé à chaque nouvelle requête de l'utilisateur, formant un prompt contextuel unique envoyé au modèle.

Pour prioriser les instructions récentes et garder une cohérence, **le backend peut tronquer ou résumer sélectivement** les échanges les plus anciens. 

Cette illusion de mémoire continue mais peut entraîner des incohérences (oubli de détails précoces, dérive thématique).

---

**Ces échanges avec le modèle en mode discussion peuvent induire une baisse d'adhérence et de pertinence des réponses.**

C'est vrai dans les deux sens : 

- Soit le contexte est **trop court** : perte d'informations qui se trouvaient énoncées précédemment.
- Soit le contexte est **trop long** : confusion occasionnées par les incohérences logiques et la présence d'erreurs répétées

---

**La méthode discursive constitue une approche de prompt engineering valable pour des tâches simples ou de découverte.**

---

**Pour des tâches simples c'est l'équivalent d'un appel à "Google" : je veux une réponse rapide à une question ou un problème courant, et l'échange sera court.**

> `Quel est le fleuve qui a le débit le plus fort en France ?`

Le contexte importe peu, la réponse est rapide et pertinente (espérons-le, NB: c'est le Rhône).

---

**Pour l'exploration, on va aborder un sujet ou une problématique, et l'objectif va se dessiner au fur et à mesure de la discussion.**

> `On m'a proposé de reprendre une application écrite en Scala mais je fais du Python essentiellement. Est-ce que ce serait difficile ?`

Le contexte va jouer. Je n'aurai pas besoin de préciser le contexte de mes différentes questions ultérieurement.

> `Est-ce qu'il existe des ORM ? Quelles sont les solutions de runtime et de CGI ?`

--- 

**Le risque des discussions est une confusion à terme sur ce qui est bien dans le contexte et sur l'issue de la discussion.**

Il sera sans doute compliqué de basculer sur une discussion plus constructive et précise dans une discussion exploratoire.

---

## L'édition sur place

**A l'inverse du mode discussion, le mode édition en place vise à raffiner un prompt pour obtenir un résultat précis en fournissant tout le contexte nécessaire en une seule passe.**

Cette approche est itérative, elle vise à corriger les erreurs et les problèmes d'adhérence en amendant le prompt original.

On vise à perfectionner le prompt et s'assurer d'une sortie aussi juste que possible.

```text

Génère le code source complet d'un microservice Go.

Le microservice doit :

1.  **Gérer les alertes client** : Une alerte client est définie par les champs suivants :
    *   `id_client` (string)
    *   `id_correlation_message` (string)
    *   `niveau_priorite` (int)
    *   `date_reception` (timestamp)
    *   `date_emission` (timestamp)
    *   `champ_erreur` (string, optionnel)

2.  **Persistance des données** : Utiliser PostgreSQL comme base de données pour stocker les alertes client. Inclure les migrations SQL nécessaires pour la création de la table.

3.  **Messagerie asynchrone** : Utiliser Apache Kafka pour publier et consommer des événements liés aux alertes (par exemple, création, mise à jour d'une alerte).

4.  **Mise en cache** : Intégrer Redis pour la mise en cache des alertes client fréquemment consultées afin d'améliorer les performances.

5.  **Authentification** : Implémenter une authentification OIDC de type "service account" pour sécuriser les endpoints du microservice. Utiliser un client OIDC standard pour la validation des tokens.

6.  **API RESTful** : Exposer une API RESTful pour les opérations CRUD (Create, Read, Update, Delete) sur les alertes client.

7.  **Structure du projet** : Organiser le code de manière modulaire avec des couches distinctes (par exemple, `handler`, `service`, `repository`, `model`).

8.  **Configuration** : Utiliser des variables d'environnement pour la configuration des connexions (PostgreSQL, Kafka, Redis, OIDC).

9.  **Gestion des erreurs** : Implémenter une gestion robuste des erreurs avec des codes d'état HTTP appropriés.

10. **Exemple d'utilisation** : Fournir un exemple de fichier `main.go` qui initialise et démarre le microservice.

Le code doit être idiomatique Go, inclure des commentaires pertinents et être prêt à être compilé et exécuté.

```

Exemple d'itérations :

- Précisions sur l'usage des middlewares
- Choix de librairies / dépendances
- Choix de variables
- etc.

---

**L'intérêt de cette approche est qu'elle introduit l'idée d'un bon type de prompt pour un modèle pour un cadre donné.**

On pourrait conserver ce prompt pour le réutiliser dans d'autres contextes similaires, en variabilisant certaines parties.

On pourrait aussi le partager avec d'autres développeurs pour qu'ils puissent le réutiliser dans leurs propres projets.

---

## Le multi fenêtre d'échanges

**Cette approche favorise l'utilisation de plusieurs échanges successifs et/ou simultanés pour aborder différentes facettes d'un même problème.** 

Ces sessions indépendantes explorant des angles distincts d'un problème évitent notamment la "**Contamination Contextuelle**".

Chaque chat a sa méthode (discussion, raffinement), son propre contexte, ses propres objectifs.

---

```text

Chat 1		Exploration    Besoins clients et fonctionnalités attendues
Chat 2		Exploration    Technologies et dépendances
Chat 3		Exploration    Architecture logicielle et technique du microservice
Chat 4      Exploration    Rédaction de prompts pour la rédaction
Chat 5		Rédaction      Contrat de service OpenAPI 
Chat 7		Rédaction      Code source de la librairie Go pour la ressource 
Chat 7		Rédaction      Code source du microservice Go HTTP
Chat 8		Rédaction      Tests unitaires
Chat 9		Rédaction      Tests d'intégration
Chat 10		Rédaction      La recette CI/CD

```

--- 


**Au fur et à mesure de l'évolution entre fenêtre d'échanges, on peut faire transiter des parties intéressantes entre échanges avec les modèles.** 

Dans les échanges de type discussion, on peut demander des synthèses du contexte à coller dans les parties de rédaction.

Dans les échanges de type édition, on peut donner du code provenant d'une autre partie (ex: le code source pour les tests).

--- 

**Cette approche est idéale pour les projets complexes qui nécessitent une approche méthodologique et structurée.**

Mais on va être confrontés à des problèmes liés aux prompts eux-mêmes.

- Obtention de formats / structures spécifiques (ex: JSON)
- Structure du code conforme à des normes particulières
- Résolution des problèmes complexes 
- Respect des bonnes pratiques (ex: gestion des erreurs, architecture hexagonale)

---

D'autres problèmes vont émerger qui pourraient être résolus par de l'automatisation 

- La mise en place est complexe : maintenir les tabs, copier le texte 
- La gestion des échanges est maladroite : beaucoup d'opérations manuelles
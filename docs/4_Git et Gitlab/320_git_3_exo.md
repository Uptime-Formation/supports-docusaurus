---
title: Exercices Git - Partie 3
weight: 320
---

<!-- Le faire sur Github ET gitlab ? -->

## Les branches

<!-- Explore branches in: -->
<!-- https://github.com/spring-projects/spring-petclinic.git -->
<!-- https://github.com/miguelgrinberg/microblog -->

<!-- Git cherrypick du commit d'ajout de about dans TP2 -->

### Maîtriser les commandes Git

[Learn Git branching](https://learngitbranching.js.org/?locale=fr_FR)

### Merge

Les fusions de branche peuvent s'effectuer en local sur la machine ou sur la forge logicielle. Nous allons le faire en local ici.

- Cloner le TP microblog et ouvrez le dans VSCode: `git clone https://github.com/uptime-formation/microblog microblog_merge_exercice`)
- Localiser la branche qui ajoute une page "A propos". 

Cette branche de fonctionnalité contient un travail fini que nous voudrions incorporer à une branche commune ici `master`.

- Faites donc un `merge` de cette branche dans `master` en local. Discutons ensemble de la résolution des conflits

### Rebase

<!-- FIXME: précisions + tester -->
- Cloner le TP microblog a nouveau et ouvrez le dans VSCode: `git clone https://github.com/uptime-formation/microblog microblog_rebase_exercice`)

Prendre le TP microblog et localiser la branche qui ajoute une page "A propos" (à cloner si nécessaire depuis `https://github.com/uptime-formation/microblog`).

Nous voudrions continuer à travailler sur cette branche en incorporant les nouvelles modifications de master, ajoutées par des collègues.

- Pour celà, faire un `rebase` de cette branche sur `master` ou sur la branche de votre choix.

Nous voudrions maintenant nettoyer notre branche (faire des commits consistants avec des messages clairs)

- La fonctionnalité la plus classique pour ce faire  est un `rebase` de cette branche sur elle-même en mode interactif.

### Exercices supplémentaires

<!-- FIXME: could be split between 3 and 4 -->

1. Merge simple: https://gitexercises.fracz.com/exercise/chase-branch
2. Rebase simple: https://gitexercises.fracz.com/exercise/change-branch-history
3. Résoudre un conflit de merge : https://gitexercises.fracz.com/exercise/merge-conflict
4. Git stash: https://gitexercises.fracz.com/exercise/save-your-work
5. Rebase interactif: https://gitexercises.fracz.com/exercise/fix-old-typo
<!-- FIXME: parler de git add -p -->
6. Ajouter une partie des modifs a un commit et le reste à l'autre: https://gitexercises.fracz.com/exercise/commit-parts
7. merge A, rebase B on pick branch puis rebase interactive C on pick branch squashing 2 commits puis merge C dans pick branch: https://gitexercises.fracz.com/exercise/pick-your-features

<!-- #### Interactive rebase

1. https://gitexercises.fracz.com/exercise/split-commit
2. https://gitexercises.fracz.com/exercise/too-many-commits
3. https://gitexercises.fracz.com/exercise/rebase-complex
4. https://gitexercises.fracz.com/exercise/invalid-order -->

<!-- #### Bisect (avancé)

https://gitexercises.fracz.com/exercise/find-bug -->

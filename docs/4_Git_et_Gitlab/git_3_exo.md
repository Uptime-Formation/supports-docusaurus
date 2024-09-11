---
title: Git 3 - Exercices
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

Les fusions de branche peuvent s'effectuer en local sur la machine ou sur la forge logicielle.


Prendre le TP microblog (à cloner si nécessaire depuis `https://github.com/uptime-formation/microblog`) et localiser la branche qui ajoute une page "A propos". Faire un `merge` de cette branche avec `master` en local.

### Rebase

<!-- FIXME: précisions + tester -->

Prendre le TP microblog et localiser la branche qui ajoute une page "A propos" (à cloner si nécessaire depuis `https://github.com/uptime-formation/microblog`).

- Faire un `rebase` de cette branche sur `master` ou sur la branche de votre choix.
- Faire un `rebase` de cette branche (ou d'une autre) sur `master` en mode interactif.

### Exercices supplémentaires

<!-- FIXME: could be split between 3 and 4 -->

1. https://gitexercises.fracz.com/exercise/chase-branch
2. https://gitexercises.fracz.com/exercise/change-branch-history
3. https://gitexercises.fracz.com/exercise/merge-conflict
4. https://gitexercises.fracz.com/exercise/save-your-work
5. https://gitexercises.fracz.com/exercise/fix-old-typo
<!-- FIXME: parler de git add -p -->
6. https://gitexercises.fracz.com/exercise/commit-parts
7. https://gitexercises.fracz.com/exercise/pick-your-features

#### Interactive rebase

1. https://gitexercises.fracz.com/exercise/split-commit
2. https://gitexercises.fracz.com/exercise/too-many-commits
3. https://gitexercises.fracz.com/exercise/rebase-complex
4. https://gitexercises.fracz.com/exercise/invalid-order

#### Bisect (avancé)

https://gitexercises.fracz.com/exercise/find-bug

---
title: Git 4 - Forges Git
weight: 400
---

<!-- FIXME: Parler de merge --continue, choper le workflow depuis simple git -->

## Collaborer à l'aide de gitlab

# Git pour collaborer...

Git devient indispensable lorsque :

- L'équipe avec laquelle vous collaborez est grande...
- Changeante...
- Le logiciel évolue dans le temps et en taille.

## La forge logicielle

- Github.com
  - ... est une forge logicielle en forme de réseau social.
- Gitlab
  - ... est une forge logicielle concurrente, et qui est open source : on peut en installer sa propre instance (ex: framagit.org). La plus grosse instance Gitlab est gitlab.com.

## La merge request / pull request

- _merge requests_ : valider du code à plusieurs

- **_`git fetch`_** : récupérer la dernière version du dépôt distant (sans rien changer à son dépôt local)
- **_`git pull`_** : récupérer la dernière version de la branche actuelle depuis le dépôt distant (bouge le `HEAD`)
- **_`git push`_** : envoyer la dernière version locale de la branche actuelle jusqu'au dépôt distant (bouge le `HEAD` distant, en d'autres termes modifie `origin/HEAD`)

 <!-- FIXME: ajouts commande git remote add / set + speech sur le rôle de origin ou any other one -->

## CI/CD

L'intégration continue : s'assurer automatiquement de la qualité du code, à chaque commit poussé sur une forge.
Le déploiement continu : déployer automatiquement une nouvelle version du code quand un commit est poussé sur une forge (sur la branche `master` ou `deploy` en général).

- Gitlab a sa version intégrée de la CI, Gitlab CI
- Github a sa version intégrée de la CI, Github Actions, mais historiquement on devait plutôt se baser sur un outil de CI séparé (Jenkins, Travis CI, etc.)

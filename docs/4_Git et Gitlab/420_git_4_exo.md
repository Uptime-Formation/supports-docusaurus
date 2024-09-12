---
title: TP - Développer de façon collaborative avec les forges logicielles
weight: 410
---

## Exercices Remote sur Learning Git Branching

- Sur [Learn Git branching](https://learngitbranching.js.org/), cherchez la section "Remote" et faites les la première série d'exercices 

##  Faire des merge request par groupe sur Gitlab.com

### Faire un projet Gitlab basique et poussez votre code

- Rendez-vous sur <https://gitlab.com/users/sign_up> pour créer un compte.
- Générez une clé ssh avec `ssh-keygen` et les parametres par défaut et mettre une passphrase vide (appuyez sur entrer quand il demande la passphrase)
- Ajoutez votre clé dans les settings de votre compte Gitlab
- Créez un nouveau projet gitlab appelé `tp_collab_git_votrepseusdoouprenom` vide et clonez le en SSH (bien selectionner le mode SSH du bouton clone)
- Ajoutez un fichier texte quelconque (code ou non)
- Commitez le dans la branche main
- Suivez les instructions gitlab pour pousser votre code sur le dépot
- Constatez qu'il est bien sur le serveur dans l'interface gitlab

### Collaborez avec votre voisin

Nous allons faire des groupe de deux... 

- Invitez chacun votre binome en allant dans les options du projet et en utilisant son pseudo gitlab (le mettre en mode développeur)
- Clonez en SSH le projet de votre binome (bien selectionner le mode SSH du bouton clone)
- Créez une branche dans ce projet (git checkout -b ...), ajoutez un fichier et commitez le
- Poussez la branche sur le projet de votre binome (`git checkout votrebranche; git push` utilisez la commande avec l'option `--set-upstream` suggérée par git)
- Faites une merge request en allant sur gitlab (cherchez sur internet le cas échéant) à partir de votre branche...
- Demandez à votre binome de review votre merge request et de la merger...

## Contribuer au microblog du formateur sur Github.com avec une pull request

- Clonez le dépôt "microblog" indiqué par le formateur, (probablement `git@github.com:e-lie/microblog_git_collab.git`)
- On se propose maintenant de créer une branche pour étendre l'application avec une page supplémentaire “A propos” comme dans la partie 2 des exercices
- Commitez l'ensemble de ces changements dans une branche `about-page`
- Rendez-vous sur ce dépôt de microblog collab dans le navigateur, puis forkez le projet à l'aide du bouton en haut à droite de la page
- Ajoutez ce nouveau remote dans votre clone local à l'aide de `git remote add monfork <url_ssh_de_votre_fork>` (toujours bien utiliser l'url SSH)
- Poussez votre branche `about-page` sur votre fork.
- Confirmez que vous trouvez bien cette nouvelle branche sur votre fork depuis votre navigateur, puis allez dans la partie "Pull request". Créez une nouvelle "Pull request" en prenant bien soin de sélectionner la branche `about-page-votrenom` du formateur (sur le dépôt de départ !) comme cible.
- Vérifiez que la merge request a bien été créée sur le dépôt du formateur et est en attente de relecture/validation
- Pendant ce temps, le formateur continue de travailler sur sa branche `main` et va bientôt commiter un changement qui va créer un conflit entre `main` et votre branche (attendre le signal du formateur ;)). Une fois que c'est fait, vous devriez voir sur la page de la merge request qu'une vérification de mergeabilité effectuée par GitLab est passée au rouge.
- Utilisez `git fetch` et `git merge`  ou (`git pull`) pour réconcilier la branche du formateur dans la votre, et résolvez le conflit. Poussez ensuite le nouveau commit sur votre branche et validez que la vérification de Github est repassée au vert.
- Le formateur va maintenant merger votre pull request dans la branche `about-page-votrenom`

<!-- ## Bonnes pratiques, situations de la vie quotidienne

- 5.1 : Toujours dans le dépôt `microblog`, de retour sur `main`. Nous allons **tester la commande `git stash`**. Pour cela nous allons simuler une situation où nous nous apprêtons à `git pull` des commits en ayant des changements non commités.
  - Revenez en arrière dans l'historique avec `git reset --hard v0.15`
  - Modifiez un fichier, par exemple `requirements.txt`, en ajoutant des commentaires à la fin ou au début
  - Lancez `git pull` : Git refuse car le merge ne peut pas avoir lieu tant que vous avez des changements non commités
  - Mettez de côté temporairement vos changements non commités avec `git stash` (vérifier le résultat avec `git status`)
  - Ré-effectuez le `git pull` qui devrait fonctionner
  - Ré-appliquez vos changements non commités avec `git stash pop` (vérifier le résultat avec `git status` et `git diff`)
- 5.2 : Toujours dans le dépôt `microblog`, de retour sur `main`. Nous allons **effectuer un commit que nous aurions voulu en fait séparer en plusieurs commit distincts**.
  - modifier un ou plusieurs fichiers de sortes à avoir au moins deux changements différents
  - commitez ces changements dans un seul commit
  - ... oups ! Nous aurions voulu faire plusieurs commit :) ...
  - pour "annuler" notre dernier commit mais sans perdre nos modification, nous utilisons `git reset HEAD~`. Confirmez avec `git log` que le commit n'est plus là, mais que `git diff` montre que nos modifications n'ont pas été perdues
  - faites un premier commit qui commitera seulement l'un des deux changements
  - faites un deuxième commit avec le changement restant
- 5.3 : Toujours dans le dépôt `microblog`, de retour sur `main`. Nous allons **effectuer un commit sur `main`, que nous aurions voulu en fait mettre sur une nouvelle branche**.
  - Modifiez quelques fichiers et commitez sur `main`
  - ... oups ! Nous aurions voulu commiter sur une nouvelle branche
  - pour "annuler" notre dernier commit mais sans perdre nos modification, nous utilisons `git reset HEAD~`. Confirmez avec `git log` que le commit n'est plus là, mais que `git diff` montre que nos modifications n'ont pas été perdues (tiens donc, tout cela ressemble furieusement à l'exercice précédent !)
  - crééz et passez sur une nouvelle branche avec `git switch -c <votre_branche>`
  - commitez le changement sur la branche.
- 5.4 : Récupérez auprès du formateur un petit fichier de patch contenant la sortie d'un `git diff`. Appliquez ce patch sur votre espace de travail en lançant `git apply`. Cette commande tourne "dans le vide" en attendant que vous colliez le contenu du patch, puis que vous fassiez Ctrl+D pour terminer. Vérifiez avec `git status` et `git diff` que le patch a bien été appliqué sur votre espace de travail. -->

<!-- FIXME: euh je l'ai pas marqué quelque part ça ? tp3 ? fusionner -->

<!-- - ... via Gitlab avec une Merge Request -->

<!-- - ... via Github avec une Pull Request -->

<!-- - Faites une merge request sur le dépôt de quelqu'un de votre groupe, ou bien sur le dépôt de ce cours : <https://github.com/Uptime-Formation/cours-git> -->

<!-- - Les deux premiers chapitres seront à merger en local et les deux suivants sur framagit. -->

<!-- FIXME: ajout autre remote, changement URL d'origine et ajout de celle de grinberg -->

## Ressources

- Un autre tutoriel de git collaboratif: https://github.com/KTH-dESA/centralized-workflow-exercise
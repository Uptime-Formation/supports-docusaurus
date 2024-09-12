---
title: Cours - Collaboration avec branches, merge et rebase
weight: 310
---

## Collaborer à l'aide des branches

Nous avons pour l'instant utilisé Git sur une seule branche : nos commits représentent une ligne qui va du commit le plus ancien au commit le plus récent.

Mais la force de Git est le concept d'arborescence (d'arbre) constituée de branches.

Théoriquement, **une branche n'est qu'un pointeur vers un commit**, une sorte de raccourci vers un commit particulier, qui est **mise à jour à chaque fois que l'on crée un nouveau commit sur telle branche**.

### Créer une branche et basculer sur une branche

Créer une branche se fait avec la sous-commande `checkout` et l'option `-b` :
`git checkout -b <nom_de_branche>`
Si la branche existe déjà, il suffit d'utiliser `git checkout` suivi du nom de branche :
`git checkout <nom_de_branche>`

On peut aussi juste créer la branche sans se déplacer dessus avec `git branch <nomdelabranche>`.

La commande `git branch` permet également :

- de supprimer une branche avec `git branch -d <nom_de_branche>` ou `git branch -d --force` => attention danger perte de données !!!!
- de renommer une branche avec allez sur la branche à renommer puis `git branch -M <nouveau_nom>` => attention si vous renommer des branche déjà poussées il y aura des conflits à gérer plus tard. 

<!-- FIXME: dire comment on delete une branche locale/distante -->
<!-- ### Supprimer une branche distante
**Attention ! C'est dangereux !** -->

### Les tags

- Les tags sont comme des raccourcis vers un commit précis.
- En général on ne les modifie pas après les avoir créés.
- Ils servent souvent pour faire référence au commit précis dans master/main qui définit la version du logiciel => à définir une release du logiciel:

Pour créer un tag, allez sur la branche/commit à tagger puis `git tag -a "v0.27" -m "message description du tag"`

## Cycles de développement (Workflow)

Il existe plusieurs méthodes d'organisation dans Git aux branches et leur usage en équipe : on parle de workflow Git

- Souvent il y a une branche `stable` (par exemple `main` ou `master`) et une branche `development` qui représente une version plus _beta_ de l'application
- Il y a également souvent des branches pour chaque fonctionnalité ajoutée, appelées `feature branch`

Deux exemples de workflow

### Git-flow

![](/img/git/git-flow.png)

Le workflow le plus ancien, complexe, donc pas forcément à recommander car on perd du temps à résoudre les conflits et erreur de workflow... Il faut un ingé devops/git pour le réparer...

### GitHub-flow

![](/img/git/github-flow.png)

- c'est le _Git flow_ le plus simple, on a :
- une branche `master`
- des `feature branch` pour chaque fonctionnalité en développement
- Il implique de développer en mode agile ou plus précisément que chaque fonctionnalité soit codée rapidement et bien testée automatiquement. En effet s'il est pratique pour les cycle de développement court il est moins adapté à des logiciels complexes et des gros changement à garder en test sur le long terme.

## Merge et rebase pour collaborer...

Réconcilier deux branches est la base du travail collaboratif dans git. Il existe deux grandes méthodes pour cela le **merge** et le **rebase** avec chacune des variantes.

Il existe de nombreux cas ou on doit réconcilier et à chaque fois des méthodes légèrement différentes pour cela.

L'article suivant, extrêmement riche, est une référence à laquelle on peut revenir en cas de doute sur le choix de merge ou de rebase :
[_Bien utiliser Git merge et rebase_, par Delicious Insights](https://delicious-insights.com/fr/articles/bien-utiliser-git-merge-et-rebase/)

Mais il est très long... pour résumer

### `merge` pour fusionner deux branches en laissant une trace

![](/img/git/gitmerge2.png)

Merge sert à fusionner une branche secondaire dans une branche principale en **ajoutant un commit de fusion**. On va dans la branche principale (`git checkout stable` par exemple) puis on fait `git merge branchesecondaire` souvent si on veut être sur de faire un "vrai" merge on ajoute l'argument `no-ff` pour éviter que git ne créée pas de commit de merge.

Les avantages du merge:

- on fusionne les changements qui peuvent être complexes en une seule fois et on a un commit de merge qui résume les changements de la branche mergée
- on garde une trace de la branche de développement qui a été mergée grâce au commit de merge qui s'appelle généralement `Merge branch mabranche`.

Le merge (avec no-ff) est donc à utiliser principalement pour réconcilier une branche assez importante (par exemple une feature branch bien finie) avec la branche principale.

L'incovénient du merge est qu'il **crée un embranchement qui pollue l'historique** => ne pas faire plein de merge dans ses branche perso sinon après on refile son bordel aux autre.

### `rebase` réécrit l'historique proprement

![](/img/git/rebase.png)

Rebase consiste à changer la base (le commit initial) d'un branche c'est à dire concrêtement à récrire les commits d'une branche à la suite d'une autre branche jusqu'à ce que tous les commits soient présents.

L'avantage c'est que rebase garde l'historique linéaire et propre et permet même en mode interactif de nettoyer des commits ou des messages de commit.

C'est super tout ça, mais rebase à une limite : comme on réécrit l'historique on ne peut souvent pas rebaser une branche qui a déjà été poussée sur un serveur/remote. 

### `cherry-pick` faire son marché parmis les commits d'une branche

Cette commande permet de récupérer dans la branche courante des commits (qu'elle n'a pas déjà) dans un ordre de votre choix.

- `git cherry-pick <commit3> <commit1> <commit2>` : prend un ou plusieurs commit et les ajoute dans l'ordre indiqué à la branche actuelle

On peut utiliser ça pour récupérer juste les parties intéressantes d'un branche un peu bordélique ou tout autre usage pratique.

### Le rebase interactif `git rebase -i` pour nettoyer une branche (code et messages de commit)

L'historique Git, c'est un peu **raconter une histoire** de comment on est arrivé à ce bout de code, ajouté pour telle fonctionnalité à telle version du logiciel.

Un bonne pratique et qui vous donne beaucoup de crédibilité en tant que développeur/euse c'est de prendre le temps de nettoyer ses branches de fonctionnalité avant de les soumettre au collectif (bien que ce ne soit pas toujours le meilleur usage de votre temps...).

Le rebase interactif est un outil un peu compliqué à manipuler, qui nous permet de **réécrire l'historique d'une branche** en choisissant quels commits on va fusionner ensemble, effacer, ou réordonner. C'est la commande `git rebase -i <branche_de_base>`



---

![](/img/git/git-cheat-sheet.jpg)

---
title: Cours - Explorer et se déplacer dans un dépôt
class: animation-fade
layout: true
weight: 200
---

## Télécharger le code d'un logiciel gérer avec Git

Il s'agit de **télécharger** le dépôt d'un **logiciel** depuis Internet en créant un dossier contenant le code ainsi que son **historique Git**:

- `git clone <url dépot>` puis `cd <dépôt>` pour aller dans le dossier du dépôt.

  - par exemple `git clone https://github.com/YunoHost/gertrude/` et `cd gertrude`,
  - ou bien `https://github.com/spring-projects/spring-petclinic` et `cd spring-petclinic`
  - ou encore `https://github.com/miguelgrinberg/microblog` et `cd microblog`

- `git log` pour voir la liste des commits
- `git checkout <commit num>` pour vous **déplacer** au niveau d'un commit : le code dans le dépôt **change**.
- `git diff <commit_1> <commit_2>` pour voir ce qui a changé entre deux commits.
- Plus pratique : utilisez **VSCode** et **Git Graph**

### Authentification auprès d'un serveur (Remote)

Un dépôt Git téléchargé depuis Internet peut être privé : l'accès est limité depuis le remote/la forge. Il faut alors se connecter à son compte (en HTTP ou SSH) pour le cloner.

De façon générale il faut s'authentifier quand on utilise git. En effet, quand on veut modifier le dépôt distant (ajouter des commits), il faut de toute façon être connecté à un compte.


La façon la plus neutre et générique est d'utiliser une clé SSH. Les clients github/gitlab sont pratique lorsque utilise ces forges mais cassent un peu l'universalité de git...


## L'historique d'un dépôt

![](/img/tig_history.png)

## `master` et les branches d'un dépôt

![](/img/git_branches_2.png)

- Un dépôt git permet d'avoir **plusieurs historiques** en parallèle qu'on appelle des **branches**. Un dépôt git ressemble à un arbre.

- La **branche principale** s'appelle **`master`** dans git (par convention), parfois `main`.

- Ça commence à devenir compliqué ! Mais on va souvent travailler avec seulement **deux branches** 😌

- **master** + **une branche** pour votre travail en cours.

## Remonter le temps, déplacer HEAD

- Si git **mémorise les commits successifs** du dépôt c'est en particulier pour permettre de "_remonter le temps_", c'est-à-dire **remettre le code** du dépôt **dans un état antérieur**.
  - `git checkout <commit>`. L'historique se met également à jour.
  - `git diff` permet à tout moment d'afficher les différences entre deux points du dépôt.

- Dans git, **`HEAD`** désigne un curseur qui indique dans quel état est le dépôt actuellement.
  - par défaut **`HEAD`** pointe sur le dernier commit de la branche (`master` s'il n'y en a qu'une).
  - remonter le temps cela signifie déplacer **`HEAD`**.
  - **`git reflog` affiche l'historique des déplacements de `HEAD`**.

## Déplacer HEAD dans l'historique

![](/img/head_point_3.jpg)

## Interface graphique pour explorer l'historique d'un dépôt.

Plusieurs éditeurs de code proposent des interfaces graphique pour :

- naviguer dans les modifications d'un dépôt.
- comparer plusieurs états du dépôt.

C'est le cas de VSCode, en particulier avec l'extension **Git Graph**

D'autres interfaces pratiques et indépendantes de l'éditeur : _tig_, _meld_, ...

- Installer Git Graph dans VSCode si ce n'est pas déjà fait

## Utiliser les commandes `git reset` et `git reset --hard`

**Attention: `git reset --hard` peut vous faire perdre votre travail s'il n'est pas dans un commit !!!**

- `git reset` : réinitialiser le `HEAD` au commit indiqué en gardant les modifications.
- `git reset --hard` : réinitialiser le `HEAD` au commit indiqué en **perdant les modifications**

# Deuxième partie des exercices

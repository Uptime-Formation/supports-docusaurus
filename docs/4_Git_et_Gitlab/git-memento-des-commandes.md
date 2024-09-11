---
title: "Memento des commandes"
draft: false
weight: 1000
---

### Création d'un dépôt et ajout d'un commit

| Commande                                       | Effet                                                                                                          |
| ---------------------------------------------- | -------------------------------------------------------------------------------------------------------------- |
| `git init <directory>`                         | Créer un dépôt git vide dans le répertoire spécifié ou initialise le répertoire courant en tant que dépôt git. |
| `git config --global user.name <name>`         | Définir le nom de l'auteur/autrice à utiliser pour les nouveaux commits.                                       |
| `git status`                                   | Afficher l'état du dépôt et la liste des fichiers inclus ou non pour le prochain commit.                       |
| `git add <dossier>`                            | Inclure (_stage_) tous les changement dans `<dossier>` pour le commit                                          |
| `git add <fichier>`                            | Inclure les changement du `<fichier>` pour le commit                                                           |
| `git add -A`                                   | Inclure tous les changements pour le commit                                                                    |
| `git rm <fichier>`                             | Enlever (_unstage_) `<fichier>` du prochain commit.                                                            |
| `git diff`                                     | Afficher les lignes modifiées depuis le dernier commit.                                                        |
| `git commit -m "<message>"`                    | Valider les modifications sélectionnées (_staged_) pour créer un nouveau commit avec le message `<message>`.   |
| `git log` ou `git log --oneline --all --graph` | Afficher l'historique des commits                                                                              |
| `git remote add <name> <url>`                  | Ajouter une connexion de votre dépôt courant à un dépôt sur un serveur.                                        |
| `git push`                                     | Pousser les nouveau commits sur le serveur (principal).                                                        |

### Téléchargement et exploration d'un dépôt simple

| Commande                              | Effet                                                                                                                      |
| ------------------------------------- | -------------------------------------------------------------------------------------------------------------------------- |
| `git clone <url>`                     | Cloner en local un dépot depuis l'adresse `<url>` généralement un serveur ou un forge.                                     |
| `git pull `                           | Récupérer les dernières modification (#réflexe).                                                                           |
| `git log --oneline`                   | Afficher l'historique avec une ligne par commit.                                                                           |
| `tig`                                 | Un outil plus sympa que git log pour explorer l'historique.                                                                |
| `git diff HEAD <num_commit>`          | Affiche la différence entre le commit actuel (HEAD) et le commit `<num_commit>`.                                           |
| `git diff HEAD HEAD~1`                | Affiche la différence entre le commit actuel (HEAD) et le précédent (HEAD~1).                                              |
| `git checkout <num_commit>`           | Charge la version du code au niveau du commit `<num_commit>`. La "tête" se déplace au niveau de ce commit (HEAD détachée). |
| `git checkout master ou <nom_branch>` | Positionne HEAD au niveau du dernier commit de la branche.                                                                 |
| `git reflog`                          | Affiche une liste des dernières positions de HEAD. (quand on est perdu !!! )                                               |

### Les branches et les merges

| Commande                           | Effet                                                          |
| ---------------------------------- | -------------------------------------------------------------- |
| `git branch`                       | Afficher la liste des branches                                  |
| `git branch <nom_branche>`                       | Créer une branche <nom_branche>             |
| `git checkout <nom_branche>`       | Basculer sur la branche `<nom_branche>`                        |
| `git switch <nom_branche>`       | Basculer sur la branche `<nom_branche>`                        |
| `git checkout -b <nom_branche>`    | Créer une nouvelle branche et basculer dessus                  |
| `git switch -c <nom_branche>`    | Créer une nouvelle branche et basculer dessus                  |
| `git diff <branche_1> <branche_2>` | Comparer deux branches pour voir les différences               |
| `git merge <nom_branche> `         | Fusionner la branche `<nom_branche>` avec la branche courante. |
| `git stash `         | Sauvegarder ses modifications actuelles temporairement pour nettoyer son espace de travail. |
| `git stash pop`         | Réappliquer les modifications sauvegardées pour restaurer son espace de travail. |

### Corriger ses erreurs

| Commande                    | Effet                                                                                                                                  |
| --------------------------- | -------------------------------------------------------------------------------------------------------------------------------------- |
| ` git commit --amend`       | Ajouter des modifications au commit précédent pour le corriger ou simplement changer le message du commit précédent.                   |
| ` git reset <commit>`       | Réinitialiser le `HEAD` au commit indiqué en gardant les modifications.                                                                |
| `git reset --hard <commit>` | Réinitialiser le `HEAD` au commit indiqué en **perdant** les modifications.                                                            |
| `git rebase <branche>`      | (plus complexe) Reconstruire l'historique de la branche courant à partir d'une autre branche en résolvant les conflits à chaque commit |
| `git branch -f <nom_branche> <commit>`                | Réinitialiser la branche `<nom_branche>` (sur laquelle on n'est pas) au commit indiqué sans toucher à notre `HEAD`.                     |
| `git restore <chemin_fichier> -s <commit>`                | Récupère le contenu des fichiers indiqués par `chemin_fichier` extraits depuis le contenu du commit `<commit>`.                     |



### Lexique git

| Concept     | Explication                                                                                    |
| ----------- | ---------------------------------------------------------------------------------------------- |
| Un commit   | Une version validée du code avec un auteur / une autrice, un message et un identifiant unique. |
| Une branche | Une suite de commits avec un nom contenant une version du logiciel.                            |
| HEAD        | Le commit actuellement sélectionné dans le dépôt.                                              |
| remote      | Un dépôt git sur un serveur par exemple la forge framagit.                                     |
| origin      | Le nom du remote par défaut.                                                                   |
| master      | La branche par défaut, généralement la branche principale.                                     |

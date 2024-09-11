---
title: Git 4 - Exercices
weight: 410
---

<!-- Le faire sur Github ET gitlab ? -->

## Développer de façon collaborative avec la forge logicielle Gitlab

<!-- Dans ce TP vous allez travailler par binôme sur le tutoriel Flask de Miguel Grindberg : https://blog.miguelgrinberg.com/post/the-flask-mega-tutorial-part-ii-templates -->

### Créer un compte sur Gitlab et pousser un projet


- Rendez-vous sur <https://gitlab.com/users/sign_up> pour créer un compte.
<!-- - FIXME: quel projet then? -->
<!-- - Utilisez ensuite un projet Git de votre choix à héberger. -->
- Sauf si nous décidons ensemble d'un autre projet, nous allons contribuer sur ce projet : <https://gitlab.com/ketsapiwiq/exercice-gitlab-workflow>
- Rendez-vous dans le dossier du projet en terminal et suivez les instructions gitlab pour pousser votre dépôt existant

<!-- ### Reprise du tutoriel Flask -->

<!-- FIXME: rework, on fait microblog ou non ? si oui à partir de quand ? -->

<!-- Le tutoriel a des chapitres. Le but du TP consistera a travailler à deux sur un chapitre avec un.e qui code et l'autre qui relit le code, suit le tutoriel et conseille le/la codeur/codeuse. Ce principe est très proche d'une méthodologie de développement agile nommée XP (extreme programming): -->

<!-- FIXME: rework -->

## Workflow

- Pour chaque ajout le code sera :
  - Ajouté dans une nouvelle branche.
  - Poussé sur un projet Gitlab partagé.
- Le code sera revu par la personne qui n'a pas codé grâce à une **merge request** puis sera fusionnée (merged) dans la branche `master`.
- La personne qui n'a pas codé récupère la dernière version du code grâce à `git pull`

### Merge

Les fusions de branche peuvent s'effectuer en local sur la machine ou sur la forge logicielle.
<!-- Prendre le TP microblog et localiser la branche qui ajoute une page "A propos". -->

# Exercice sur Microblog
<!-- 
## 2. Explorer un dépôt Git

- 2.1 : Clonez le dépôt "microblog" indiqué par le formateur
- 2.2 : Installez ce qui est nécessaire pour l'application avec les commandes suivantes:

```bash
sudo apt install python3-pip python3-venv
cd dossier/de/travail
python3 -m venv venv
source venv/bin/activate
pip3 install -r requirements.txt
flask db init
flask db upgrade
```

- 2.3 : Lancez l'application avec `flask run` vous devriez voir qu'elle écoute sur le port 5000
- 2.4 : Depuis un navigateur sur la machine, accédez à `http://localhost:5000/`. Créez vous un compte et postez un message.
- 2.5 : Depuis la partie "Profile", tentez d'exporter vos messages.
- 2.6 : Plutôt que d’utiliser la version finale de l’application, remontons l’historique du dépôt pour retrouver un état de l'application sans cette fonctionnalité buggé. En utilisant `git blame` sur le fichier `app/main/routes.py`, arrivez-vous à trouver le commit qui a introduit la fonctionnalité d'export ?
- 2.7 : Même question mais en utilisant votre IDE préféré. En particulier si vous utilisez VScode, installez les extensions GitLens et Git Graph.
- 2.8 : Placez-vous sur le commit avant l'introduction de cette fonctionnalité, puis relancez l'application. Confirmez-vous que la fonctionnalité a disparu depuis votre navigateur ?
- 2.9 : Remettez-vous sur le commit initial, puis refaite la même manipulation depuis VScode / Eclipse (ou vice-versa depuis le terminal, si vous étiez déjà passé par l'IDE)

## 3. Les branches

- 3.1 : Identifiez les noms de branche et de tag dans l'historique à l'aide de `git log --oneline`, `tig` ou VScode / Eclipse
- 3.2 : Retournez à la fin de l'historique à l'air de `git checkout main`
- 3.3 : En reprenant le commit identifié à la question 2.6, nous allons réinitialiser violemment l'historique du projet avec `git reset --hard <commit_id>`. Que constatez-vous dans `git status` et `git log`. En particulier, vers quel commit pointe maintenant la branche `main` ? *NB: utiliser `git reset --hard` est une manipulation qui a des impacts importants, et doit être utilisé avec précaution. En tout cas, cette manipulation est juste proposée ici à titre d'illustration pédagogique et n'a pas de rapport avec les énoncés suivants !* -->

- Clonez le dépôt "microblog" indiqué par le formateur
- On se propose maintenant de créer une branche pour étendre l'application avec une page supplémentaire “A propos”. Pour ce faire, commencez par créer une branche nommée `about-page` et vous positionner dessus.
-  Trouvez comment ajouter une nouvelle page "A propos" dans l'application. Il vous faudra ajouter un controlleur dans `app/main/routes.py`, un template dans `app/templates/about.html`, et un nouveau lien dans `app/templates/base.html`. Par exemple:

```python
### Dans routes.py

@bp.route('/about')
def about():
    return render_template('about.html')
```

```html
<!-- Dans about.html -->

{% extends "base.html" %}

{% block app_content %}
<h1>About</h1>

This is a simple microblogging app
{% endblock %}
```

```html
<!-- Dans base.html (à l'endroit approprié) -->

<li><a href="{{ url_for('main.about') }}">{{ _('About') }}</a></li>
```

- Commitez l'ensemble de ces changements (n'oubliez pas d'ajouter les nouveaux fichiers non-versionnés avec `git add` si besoin !)
<!-- - 3.7 : Utilisez `git reset HEAD~1` pour faire un "soft" reset qui annule votre dernier commit (mais conserve les fichiers dans l'état actuel, à la différence du `git reset --hard`). Puis refaites ce commit depuis VS code / Eclipse.
- 3.8 : Utilisez `git reflog` pour relire l'historique de tout vos changements de commit / état du dépôt -->

### Les remotes, les merges, les merge-request

- Rendez-vous sur le dépôt original de microblog, puis forkez le projet à l'aide du bouton en haut à droite de la page
- Ajoutez ce nouveau remote dans votre clone local à l'aide de `git remote add`
- Poussez votre branche `about-page` sur votre fork
- Confirmez que vous trouvez bien cette nouvelle branche sur votre fork depuis votre navigateur, puis allez dans la partie "Merge request". Créez une nouvelle "merge request" en prenant bien soin de sélectionner la branche du formateur (sur le dépôt original !) comme cible.
- Vérifiez que la merge request a bien été crée sur le dépôt du formateur et est en attente de relecture/validation
- Pendant ce temps, le formateur continue de travailler sur sa branche `main` et va bientôt commiter un changement qui va créer un conflit entre `main` et votre branche (attendre le signal du formateur ;)). Une fois que c'est fait, vous devriez voir sur la page de la merge request qu'une vérification de mergeabilité effectuée par GitLab est passée au rouge.
- Utilisez `git pull` (ou bien `git fetch` et `git merge` séparément) pour fusionner la branche du formateur dans la votre, et résolvez le conflit. Poussez ensuite le nouveau commit sur votre branche et validez que la vérification de Gitlab est repassée au vert.
- Le formateur devrait également avoir laissé une petite revue de code contenant une suggestion de changement. Utilisez l'interface de GitLab pour transformer cette suggestion en commit, et synchronisez de nouveau votre branche locale. Vérifiez que la suggestion du formateur est bien présente dans la sortie de `git log` ou dans Git Graph de VSCode.
- Une fois que le formateur a mergé votre merge-request (ou celle d'un.e camarade !), re-synchronisez votre dépôt local ainsi que votre fork.

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

## Exercices sur Learning Git Branching

- Sur [Learn Git branching](https://learngitbranching.js.org/), cherchez la section "Remote" et lancez "Push & Pull -- dépôts gits distants !" (ou bien `level remote1`)

## Ressources
- https://github.com/KTH-dESA/centralized-workflow-exercise
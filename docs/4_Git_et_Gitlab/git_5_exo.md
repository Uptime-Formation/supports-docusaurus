---
title: Git 5 - Exercices
weight: 510
---

<!-- A l'aide des ressources suivantes, créez une pipeline (un fichier `.gitlab-ci.yml`) qui :
1. build votre app (conteneurisée avec Docker ou non)
2. (sans Docker) sauvegarde l'artefact dans Gitlab et/ou utilise le *Package Registry* de Gitlab
3. (avec Docker) pousse l'image créée dans le *Container Registry* de Gitlab 
4. Fait un test sur votre app
5. (optionnel) Grâce à un secret Gitlab, déploie l'app sur un serveur distant (via l'exécution de commandes SSH) -->

## Configurer Gitlab CI

Dans le projet Microblog :

- Ajoutons un template de CI Gitlab depuis la page web de Gitlab. Committons-le sur une branche `template-ci`
- Depuis `main`, créez une nouvelle branche `ajout-test-ci`. Dans cette branche, rajoutez via un *cherry-pick* le commit que vous aurez trouvé dans une des branches (sur `origin`) qui rajoute le fichier `.gitlab-ci.yml`, contenant une sorte de Hello-World.
- Rajoutez un nouveau job qui va installer l'outil `flake8` et le lancer sur le fichier `app/main/routes.py` : 

```bash
apt update
apt install python3-pip -y
pip3 install flake8
flake8 app/main/routes.py
```

- Commitez vos changements, poussez votre branche sur votre fork, et créez une nouvelle pull-request. Constatez également que, normalement, la pipeline s'est déclenchée pour faire tourner le test.
- Corrigez le fichier `app/main/routes.py` pour que `flake8` soit content
- Finalement, testons le fonctionnement de `git rebase`
    - Re-créez une toute nouvelle branche `superbranche` qui commencera depuis le tag `v0.21`
    - Utilisez des `git cherry-pick` pour ajouter votre (ou vos) commits qui rajoutait la page "About"
    - De même pour les commits qui rajoutaient la CI dans Gitlab
    - Regardez la structure actuelle des différentes branche dans VScode (ou avec `git log --oneline --graph`)
    - "Rebasons" votre branche de sorte à ce qu'elle démarre depuis le sommet de la branche `main`, en utilisant `git rebase main`
    - Comparez la nouvelle structure de branche

<!-- Faire une `merge request` de notre branche avec `master`... -->
## Ressources

### Documentation

- **Get started with GitLab CI/CD : <https://docs.gitlab.com/ee/ci/quick_start/>**
- Documentation de référence de `.gitlab-ci.yml` : <https://docs.gitlab.com/ee/ci/yaml/>

### Vidéos
Issues, Merge Requests and Integrations in GitLab:
https://www.youtube.com/watch?v=raXvuwet78M

### Tutoriels
- [TP Docker : Gitlab CI](../../04-docker/6-tp-gitlab-ci/)

Code Refinery :
- <https://coderefinery.github.io/testing/continuous-integration/>
- <https://coderefinery.github.io/testing/full-cycle-ci/>

Cloud Consultancy Team :
- <https://tsi-ccdoc.readthedocs.io/en/master/ResOps/2019/Gitlab.html>
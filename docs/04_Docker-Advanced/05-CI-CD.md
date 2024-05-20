---
title: Docker Avancé - Intégration et Déploiement Continu
weight: 6
---

## Gitlab CI, son registre et l’intégration d’un cycle complet de CI/CD

![](../../static/img/docker/cicd_pipeline.png)

### Créer une pipeline de build d'image Docker avec les outils CI/CD Gitlab
1. Si vous n'en avez pas déjà un, créez un compte sur Gitlab.com : <https://gitlab.com/users/sign_in#register-pane>
2. Créez un nouveau projet et avec Git, le Web IDE Gitlab, ou bien en forkant une app existante depuis l'interface Gitlab, poussez-y l'app de votre choix (par exemple [`microblog`](https://github.com/Uptime-Formation/microblog/), [`dnmonster`](https://github.com/amouat/dnmonster/)).
3. Ajoutez un Dockerfile à votre repository ou vérifiez qu'il en existe bien un.
4. Créez un fichier `.gitlab-ci.yml` depuis l'interface web de Gitlab et choisissez "Docker" comme template. Observons-le ensemble attentivement.
5. Faites un commit de ce fichier.
6. Vérifiez votre CI : il faut vérifier sur le portail de Gitlab comment s'est exécutée la pipeline.
7. Vérifiez dans la section Container Registry que votre image a bien été push.

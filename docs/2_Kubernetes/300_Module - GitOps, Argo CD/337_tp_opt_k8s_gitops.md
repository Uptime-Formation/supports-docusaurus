---
title: TP optionnel - CI/CD GitOps avec ArgoCD
sidebar_class_name: hidden
---

Refactoring in progress... à prendre comme des pistes de travail.

## Déploiement de l'application dans argoCD

Expliquons un peu le reste du projet projet.

- Créez un token de déploiement dans `Gitlab > Settings > Repository > Deploy Tokens`. Ce token va nous permettre de donner l'authorisation à ArgoCD de lire le dépôt gitlab (facultatif si le dépôt est public cela ne devrait pas être nécessaire). Complétez ensuite **2 fois** le token dans le fichier k8s/argocd-apps.yaml comme suit : `https://<nom_token>:<motdepasse_token>@gitlab.com/<votre depo>.git` dans les deux sections `repoURL:` des deux applications.

- Créer les deux applications `monstericon-dev` et `monstericon-prod` dans argocd avec `kubectl apply -f k8s/argocd-apps.yaml`.

- Allons voir dans l'interface d'ArgoCD pour vérifier que les applications se déploient bien sauf le conteneur monstericon dont l'image n'a pas encore été buildée avec le bon tag. Pour cela il va falloir que notre pipeline s'execute complètement.

Les deux étapes de déploiement (dev et prod) du pipeline nécessitent de pousser automatiquement le code du projet à nouveau pour déclencher le redéploiement automatique dans ArgoCD (en mode pull depuis gitlab). Pour cela nous avons besoin de créer également un token utilisateur:

- Allez dans `Gitlab > User Settings (en haut à droite dans votre profil) > Access Tokens` et créer un token avec `read_repository write_repository read_registry write_registry` activés. Sauvegardez le token dans un fichier.

- Allez dans `Gitlab > Settings > CI/CD > Variables` pour créer deux variables de pipelines: `CI_USERNAME` contenant votre nom d'utilisateur gitlab et `CI_PUSH_TOKEN` contenant le token précédent. Ces variables de pipelines nous permettent de garder le token secret dans gitlab et de l'ajouter automatiquement aux pipeline pour pouvoir autoriser la connexion au dépot depuis le pipeline (git push).

- Nous allons maintenant tester si le pipeline s'exécute correctement en commitant et poussant à nouveau le code avec `git push gitlab`.

- Debuggons les pipelines s'ils sont en échec.

- Allons voir dans ArgoCD pour voir si l'application dev a été déployée correctement. Regardez la section `events` et `logs` des pods si nécessaire.

- Une fois l'application dev complètement healthy (des coeurs verts partout). On peut visiter l'application en mode dev à l'adresse `https://monster-dev.<votre_sous_domaine>`.

- On peut ensuite déclencer le stage `deploy-prod` manuellement dans le pipeline, vérifier que l'application est healthy dans ArgoCD (debugger sinon) puis visiter `https://monster.<votre_sous_domaine>`.

### Idées d'amélioration

- Déplacer le code de déploiement dans un autre dépôt que le code d'infrastructure. Le pipeline de devra cloner le dépôt d'infrastructure, templater avec kustomize la bonne version de l'image dans le bon environnement. Pousser le code d'infrastructure sur le dépôt d'infrastructure. Corriger l'application ArgoCD pour monitorer le dépôt d'infrastructure.

- Mutualiser le code de déploiement k8s avec des overlays kustomize

- Utiliser une stragégie de blue/green ou A/B déploiement avec Argo Rollouts ou Istio avec vérification de réussite du déploiement et rollback en cas d'échec.

- Ajouter plus d'étapes réalistes de CI/CD en se basant par exemple sur le livre GitOps suivant.

- Gérer la création des ressources gitlab automatiquement avec Terraform et gérer les secrets (tokens gitlab) consciencieusement.

### Bibliographie

- 2021 - GitOps and Kubernetes Continuous Deployment with Argo CD, Jenkins X, and Flux

- Billy Yuen, Alexander Matyushentsev, Todd Ekenstam, Jesse Suen (z-lib.org)
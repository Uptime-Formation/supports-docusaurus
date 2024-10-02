---
title: TP optionnel - Configurer un user et un projet dans ArgoCD 
---

ArgoCD est donc un opérateur GitOps ou encore un operateur / superviseur d'applications qui peut s'étendre à plusieurs équipes et cluster.

La question des identités et droits est centrale dans un environnement "multi-tenant" comme une cohabitation de plusieurs équipes.

Nous allons définir pour gérer cette situation un **projet** ArgoCD et un **utilisateur** ArgoCD ayant le droit d'intervention sur ce projet. L'entité projet peut être gérée via l'interface, via la CLI, ou mieux via les CRDs intallés par l'opérateur.

#### Créer un utilisateur

L'utilisateur par contre n'est pas une entité unique dans ArgoCD (donc il n'a pas de CRD). On peut le configurer via diverses integrations/SSO notamment via OIDC ou plus simplement en mode **local user**:
Un local user est ajouté en modifiant une ConfigMap.

Créez un user en editant la configmap `argocd-cm` (`kubectl edit cm argocd-cm` ou via lens) pour ajouter:

```yaml
...
data:
  ...
  accounts.<votreusername>: apiKey, login
  accounts.<votreusername>.enabled: "false"
```

Puis définir un mot de passe:

- login en tant qu'admin avec la CLI -> utiliser le compte admin avec initial admin passwd: `argocd login --port-forward --port-forward-namespace argocd --plaintext`
- Lister les users: `argocd account list --port-forward --port-forward-namespace argocd --plaintext`
- Définir le mot de passe de votre user: `argocd account update-password --account <votreusername> --current-password <initialadminpassword> --new-password  <votrepasswd> --port-forward --port-forward-namespace argocd --plaintext`

Pour aller plus loin:

- https://argo-cd.readthedocs.io/en/stable/operator-manual/user-management/#create-new-user
- https://faun.pub/create-argo-cd-local-users-9e830db3763f*
- https://www.reddit.com/r/ArgoCD/comments/15nlbs9/is_it_possible_to_create_argocd_accounts_for_the/


#### Créer un projet via CRD

Dans Open-lens, cliquer sur + > créer resource pour définir le project nommé `dev-<votreprenom>` (ou autre) avec le code suivant:


```yaml
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: dev-<votreprenom>
  namespace: argocd
spec:
  sourceRepos:
    - '*' # tous les dépots
    - '!https://github.com/**' # sauf github (juste pour l'exemple). Nous utiliserons gitlab par la suite
  destinations:
    - namespace: '<votrenamespace>'
      server: 'https://kubernetes.default.svc' # Dans le cluster par défaut
  clusterResourceWhitelist:  # toutes les resources peuvent être crées
  - group: '*'
    kind: '*'
  # policies:
  #   # p, elie, applications, get, my-project/*, allow
  #   p, <votreusername>, applications, *, dev-<votreusername>/*, allow
```

TODO: fix policies syntax !!

(pour plus d'info la doc: https://argo-cd.readthedocs.io/en/stable/user-guide/projects/)


## Déployer une application depuis Github


Créez (via Lens ou un fichier avec `kubectl apply`) la resource suivante pour déployer en GitOps notre projet de code monsterstack:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: monsterstack-<votrenom>
  namespace: argocd
spec:
  project: dev-elie
  source:
    repoURL: https://github.com/<yourusername>/<yourmonsterrepo>
    targetRevision: tp_monsterstack_final ## ou autre branche
    path: k8s-deploy-dev/
    directory:
      recurse: true
  destination:
    server: https://kubernetes.default.svc
    namespace: <yournamespace>
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

Lorsque vous déployer cette application via git, argocd poll/vérifie le dépot toutes les 3 minutes pour se mettre a jour éventuellement avec les modifications.

Pour éviter le poll inutile et diminuer la réactivité des déploiements quand le code change on configure généralement un webhook sur la forge git (ici github). Vous pouvez suivre cette documentation pour ajouter un webhook pour votre application : https://argo-cd.readthedocs.io/en/stable/operator-manual/webhook/
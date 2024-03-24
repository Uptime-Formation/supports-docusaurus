---
title: TP optionnel - Installer le chart Wordpress avec ArgoCD 
---

ArgoCD est un opérateur d'application : il ajoute de nouveaux types d'objets (CRDs) dont le type Application qui permet de décrire des ensembles applicatifs gérées via un mode GitOps par ses soins.

Pour l'exemple nous allons créer une nouvelle application `wordpress-argo` avec le manifeste suivant à compléter:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: wordpress-argo
---
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: wordpress-argo
  namespace: argocd
spec:
  destination:
    namespace: wordpress-argo
    server: https://kubernetes.default.svc
  project: default
  source:
    repoURL: https://charts.bitnami.com/bitnami
    chart: wordpress
    targetRevision: 15.2.49
    helm:
      values: |
        wordpressUsername: <stagiaire> # replace
        wordpressPassword: myunsecurepassword
        wordpressBlogName: Kubernetes example blog

        replicaCount: 1

        service:
          type: ClusterIP

        ingress:
          enabled: true
          hostname: wordpressargo.<stagiaire>.<labdomain> # replace with your hostname pointing on the cluster ingress loadbalancer IP
          tls: true
          certManager: true
          annotations:
            cert-manager.io/cluster-issuer: letsencrypt-prod
            kubernetes.io/ingress.class: nginx
```

- Vous pouvez l'ajouter avec `kubectl` ou même directement en cliquant sur `+` dans OpenLens.

- Visitez l'interface de ArgoCD et cliquer sur sync pour déployer effectivement l'application.

Dans une gestion GitOps de l'infrastructure ce code d'application sera **ajouté à un dépot git** et la **synchronisation mise en mode automatique** à chaque nouveau commit sur la branche adéquate du dépot.
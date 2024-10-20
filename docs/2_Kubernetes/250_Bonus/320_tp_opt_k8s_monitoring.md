---
title: TP optionnel - Monitoring classique d'un cluster avec Prometheus
---

<!-- https://kubernetes.io/docs/tutorials/kubernetes-basics/update/update-interactive/
https://blog.container-solutions.com/kubernetes-deployment-strategies
https://github.com/ContainerSolutions/k8s-deployment-strategies -->

## Prometheus pour monitorer le cluster

Pour comprendre les stratégies de déploiement et mise à jour d'application dans Kubernetes (deployment and rollout strategies) nous allons installer puis mettre à jour une application d'exemple et observer comment sont gérées les requêtes vers notre application en fonction de la stratégie de déploiement choisie.

Pour cette observation on peut utiliser un outil de monitoring. Nous utiliserons ce TP comme prétexte pour installer une des stack les plus populaires et intégrée avec kubernetes : Prometheus et Grafana. Prometheus est un projet de la Cloud Native Computing Foundation.

Prometheus est un serveur de métriques c'est à dire qu'il enregistre des informations précises (de petite taille) sur différents aspects d'un système informatique et ce de façon périodique en effectuant généralement des requêtes vers les composants du système (metrics scraping).

![](https://www.augmentedmind.de/wp-content/uploads/2021/09/prometheus-official-architecture.png)

Une très bonne série d'articles à jour à propos de Prometheus/Graphana et AlertManager dans kubernetes et les concept de l'observability : https://www.augmentedmind.de/2021/09/05/observability-prometheus-guide/

### Installer Prometheus et Grafana via kube-prometheus

Actuellement la méthode officielle conseillée pour installer Prometheus et sa webUI grafana est d'employé l'opérateur officiel `Prometheus Operator` packagé dans une stack complète appelée `kube-prometheus`: https://github.com/prometheus-operator/kube-prometheus

Une façon commode de déployer cette stack est d'utiliser le chart officiel : https://artifacthub.io/packages/helm/prometheus-community/kube-prometheus-stack

- Comme précédemment déployez cette stack via ArgoCD avec le manifeste suivant:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: kube-prometheus-stack
---
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: kube-prometheus-stack
  namespace: argocd
spec:
  destination:
    namespace: kube-prometheus-stack
    server: https://kubernetes.default.svc
  project: default
  source:
    repoURL: https://prometheus-community.github.io/helm-charts
    chart: kube-prometheus-stack
    targetRevision: 43.1.1
    helm:
      values: |
        grafana:
          enabled: true
          ingress:
            enabled: true
            path: /
            hosts:
              - grafana.<stagiaire>.<labdomain>
            tls:
              - hosts:
                - grafana.<stagiaire>.<labdomain>
                secretName: grafana-tls-cert
            annotations:
              kubernetes.io/tls-acme: "true"
              kubernetes.io/ingress.class: nginx
              cert-manager.io/cluster-issuer: letsencrypt-prod
```

### Monitorer les stratégies de déploiement d'une application

Voir TP suivant.
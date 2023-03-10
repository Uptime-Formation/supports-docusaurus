---
title: TP optionnel - Stratégies de déploiement et monitoring
draft: false
---

<!-- https://kubernetes.io/docs/tutorials/kubernetes-basics/update/update-interactive/

https://blog.container-solutions.com/kubernetes-deployment-strategies

https://github.com/ContainerSolutions/k8s-deployment-strategies -->

## Installer Prometheus pour monitorer le cluster

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
  project: tooling
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

### Déployer notre application d'exemple (goprom) et la connecter à prometheus

<!-- Prometheus deploie les services suivants... -->

Nous allons installer une petite application d'exemple en go.

- Téléchargez le code de l'application et de son déploiement depuis github: `git clone https://github.com/e-lie/k8s-deployment-strategies`

Nous allons d'abord construire l'image docker de l'application à partir des sources. Cette image doit être stockée dans le registry de minikube pour pouvoir être ensuite déployée dans le cluster. En mode développement Minikube s'interface de façon très fluide avec la ligne de commande Docker grace à quelques variable d'environnement : `minikube docker-env`

- Changez le contexte de docker cli pour pointer vers minikube avec `eval` et la commande précédente.

<details><summary>Réponse</summary>

```bash
eval $(minikube docker-env)
docker system info | grep Name # devrait afficher minikube si le contexte docker est correctement défini.
```

</details>

- Allez dans le dossier `goprom_app` et "construisez" l'image docker de l'application avec le tag `tecpi/goprom`.

<details><summary>Réponse</summary>

```bash
cd goprom_app
docker build -t tecpi/goprom .
```

</details>

- Allez dans le dossier de la première stratégie `recreate` et ouvrez le fichier `app-v1.yml`. Notez que `image:` est à `tecpi/goprom` et qu'un paramètre `imagePullPolicy` est défini à `Never`. Ainsi l'image sera récupéré dans le registry local du docker de minikube ou sont stockées les images buildées localement plutôt que récupéré depuis un registry distant.

- Appliquez ce déploiement kubernetes:

<details><summary>Réponse</summary>

```bash
cd '../k8s-strategies/1 - recreate'
kubectl apply -f app-v1.yml
```

</details>

### Observons notre application et son déploiement kubernetes

- Explorez le fichier de code go de l'application `main.go` ainsi que le fichier de déploiement `app-v1.yml`. Quelles sont les routes http exposées par l'application ?

<details><summary>Réponse</summary>

- L'application est accessible sur le port `8080` du conteneur et la route `/`.
- L'application expose en plus deux routes de diagnostic (`probe`) kubernetes sur le port `8086` sur `/live` pour la `liveness` et `/ready` pour la `readiness` (cf https://kubernetes.io/docs/)
- Enfin, `goprom` expose une route spécialement pour le monitoring Prometheus sur le port `9101` et la route `/metrics`

</details>

- Faites un forwarding de port `Minikube` pour accéder au service `goprom` dans votre navigateur.

<details><summary>Réponse</summary>

```bash
minikube service goprom
```

</details>

- Faites un forwarding de port pour accéder au service `goprom-metrics` dans votre navigateur. Quelles informations récupère-t-on sur cette route ?

<details><summary>Réponse</summary>

```bash
minikube service goprom-metrics
```

</details>

- Pour tester le service `prometheus-server` nous avons besoin de le mettre en mode NodePort (et non ClusterIP par défaut). Modifiez le service dans Lens pour changer son type.
- Exposez le service avec Minikube (n'oubliez pas de préciser le namespace monitoring).
- Vérifiez que prometheus récupère bien les métriques de l'application avec la requête PromQL : `sum(rate(http_requests_total{app="goprom"}[5m])) by (version)`.

- Quelle est la section des fichiers de déploiement qui indique à prometheus ou récupérer les métriques ?

<details><summary>Réponse</summary>

```yaml
apiVersion: apps/v1
kind: Deployment
---
spec:
---
template:
  metadata:
---
annotations:
  prometheus.io/scrape: "true"
  prometheus.io/port: "9101"
```

</details>



Créer une dashboard avec un Graphe. Utilisez la requête prometheus (champ query suivante):

```
sum(rate(http_requests_total{app="goprom"}[5m])) by (version)
```

Pour avoir un meilleur aperçu de la version de l'application accédée au fur et à mesure du déploiement, ajoutez `{{version}}` dans le champ `legend`.

### Observer un basculement de version

Ce TP est basé sur l'article suivant: https://blog.container-solutions.com/kubernetes-deployment-strategies

Maintenant que l'environnement a été configuré :

- Lisez l'article.
- Vous pouvez testez les différentes stratégies de déploiement en lisant leur `README.md`.
- En résumé, pour les plus simple, on peut:
  - appliquer le fichier `app-v1.yml` pour une stratégie.
  - lançer la commande suivante pour effectuer des requêtes régulières sur l'application: `service=$(minikube service goprom --url) ; while sleep 0.1; do curl "$service"; done`
  - Dans un second terminal (pendant que les requêtes tournent) appliquer le fichier `app-v2.yml` correspondant.
  - Observez la réponse aux requêtes dans le terminal ou avec un graphique adapté dans `graphana` (Il faut configurer correctement le graphique pour observer de façon lisible la transition entre v1 et v2). Un aperçu en image des histogrammes du nombre de requêtes en fonction des versions 1 et 2 est disponible dans chaque dossier de stratégie.
  - supprimez le déploiement+service avec `delete -f` ou dans Lens.

Par exemple pour la stratégie **recreate** le graphique donne: ![](/img/prometheus/grafana-recreate.png)

<!-- ### Facultatif : Installer Istio pour des scénarios plus avancés

Pour des scénarios plus avancés de déploiement, on a besoin d'utiliser soit un _service mesh_ comme Istio (soit un plugin de rollout comme Argo Rollouts mais pas ce que nous proposons ici).

<!-- TODO trouver comment exporter les bonnes dashboard grafana pour les réimporter plus + comprendre un peu mieux promQL -->

<!-- 1. Sur k3s, supprimer la release Helm du Ingress Controller Traefik (ou le ingress Nginx) pour le remplacer par l'ingress Istio.
2. Installer Istio, créer du trafic vers l'ingress de l'exemple et afficher le graphe de résultat dans le dashboard Istio : https://istio.io/latest/docs/setup/getting-started/
3. Utiliser ces deux ressources pour appliquer une stratégie de déploiement de type A/B testing poussée :
   - https://istio.io/latest/docs/tasks/traffic-management/request-routing/
   - https://github.com/ContainerSolutions/k8s-deployment-strategies/tree/master/ab-testing -->
 -->

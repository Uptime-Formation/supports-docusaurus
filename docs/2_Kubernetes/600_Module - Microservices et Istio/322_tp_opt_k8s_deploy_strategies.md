---
title: TP optionnel - Stratégies de déploiement
sidebar_class_name: hidden
---

### Déployer notre application d'exemple (goprom) et la connecter à prometheus

<!-- Prometheus deploie les services suivants... -->

Nous allons installer une petite application d'exemple en go.

- Téléchargez le code de l'application et de son déploiement depuis github: `git clone https://github.com/e-lie/k8s-deployment-strategies`

Nous allons d'abord construire l'image docker de l'application à partir des sources et la déployer dans le cluster.

- Allez dans le dossier `goprom_app` et "construisez" l'image docker de l'application avec le tag `<votrelogindockerhub>/goprom`.

<details><summary>Réponse</summary>

```bash
cd goprom_app
docker build -t tecpi/goprom .
```

</details>

- Allez dans le dossier de la première stratégie `recreate` et ouvrez le fichier `app-v1.yml`. Notez que `image:` est à `tecpi/goprom` et qu'un paramètre `imagePullPolicy` est défini à `Never`. Changez ces paramètres si nécessaire (oui en général).


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

- Utilisez le service `NodePort` pour accéder au service `goprom` dans votre navigateur.

- Utilisez le service `NodePort` pour accéder au service `goprom-metrics` dans votre navigateur. Quelles informations récupère-t-on sur cette route ?

- Pour tester le service `prometheus-server` nous avons besoin de le mettre en mode NodePort (et non ClusterIP par défaut). Modifiez le service dans Lens pour changer son type.
- Exposez le service avec un NodePort (n'oubliez pas de préciser le namespace monitoring).
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

### Argo Rollout : un exemple d'opérateur de rollout (controller)

![](/img/kubernetes/argo-rollout-architecture.webp)

### Facultatif : Installer Istio pour des scénarios plus avancés

Pour des scénarios plus avancés de déploiement, on a besoin d'utiliser soit un _service mesh_ comme Istio (soit un plugin de rollout comme Argo Rollouts mais pas ce que nous proposons ici).

<!-- TODO trouver comment exporter les bonnes dashboard grafana pour les réimporter plus + comprendre un peu mieux promQL -->

1. Sur k3s, supprimer la release Helm du Ingress Controller Traefik (ou le ingress Nginx) pour le remplacer par l'ingress Istio.
2. Installer Istio, créer du trafic vers l'ingress de l'exemple et afficher le graphe de résultat dans le dashboard Istio : https://istio.io/latest/docs/setup/getting-started/
3. Utiliser ces deux ressources pour appliquer une stratégie de déploiement de type A/B testing poussée :
   - https://istio.io/latest/docs/tasks/traffic-management/request-routing/
   - https://github.com/ContainerSolutions/k8s-deployment-strategies/tree/master/ab-testing


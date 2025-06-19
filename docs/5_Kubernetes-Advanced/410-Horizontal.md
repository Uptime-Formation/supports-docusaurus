---
title: Run4 -  Autoscaling Horizontal 
weight: 410
---

### Quickstart : Activer l'HPA pour un déploiement


**On veut configurer l'Horizontal Pod Autoscaler (HPA) pour un déploiement nommé "myintensiveapp:2.0".**

Dès que l'utilisation CPU atteint 80%, un pod supplémentaire est ajouté, avec un minimum de 10 pods et un maximum de 50 pods.

Les pods sont répartis sur différents workers grâce à l'anti-affinité, et la stratégie de rollout remplace 10% des pods avec toujours au minimum 8 pods disponibles.

#### Prérequis

- Un cluster Kubernetes fonctionnel
- kubectl installé et configuré
- Metrics Server déployé dans le cluster

### Étape 1 : Déployer l'application

1. **Créer un fichier de déploiement (deployment.yaml)**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myintensiveapp
spec:
  replicas: 10
  selector:
    matchLabels:
      app: myintensiveapp
  template:
    metadata:
      labels:
        app: myintensiveapp
    spec:
      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
              - key: app
                operator: In
                values:
                - myintensiveapp
            topologyKey: "kubernetes.io/hostname"
      containers:
      - name: myintensiveapp
        image: myintensiveapp:2.0
        resources:
          requests:
            cpu: "500m"
          limits:
            cpu: "1"
      strategy:
        type: RollingUpdate
        rollingUpdate:
          maxUnavailable: 2
          maxSurge: 10%
```

2. **Appliquer le fichier de déploiement**

```sh
kubectl apply -f deployment.yaml
```

### Étape 2 : Créer l'HPA

1. **Créer l'HPA (hpa.yaml)**

```yaml
apiVersion: autoscaling/v2beta2
kind: HorizontalPodAutoscaler
metadata:
  name: myintensiveapp-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: myintensiveapp
  minReplicas: 10
  maxReplicas: 50
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 80
```

2. **Appliquer l'HPA**

```sh
kubectl apply -f hpa.yaml
```

---
 ### Historique des infrastructures haute disponibilité des origines à Kubernetes

**Les infrastructures haute disponibilité (HA) ont évolué considérablement depuis les premières architectures client-serveur.**

Initialement, les systèmes utilisaient des redondances matérielles et des sauvegardes manuelles pour assurer la disponibilité.

Avec l'essor des réseaux et d'Internet, les clusters de serveurs et les systèmes distribués se sont développés, permettant une tolérance aux pannes accrue et une scalabilité horizontale.

L'arrivée des conteneurs, et spécifiquement de Kubernetes, a transformé l'HA en automatisant le déploiement, la gestion et la scalabilité des applications conteneurisées, permettant ainsi une résilience et une élasticité sans précédent.

--- 

### Enjeux, contraintes et risques liés à l'élasticité dans Kubernetes

**Enjeux** : L'élasticité permet à Kubernetes d'ajuster dynamiquement le nombre de pods en fonction de la charge, optimisant ainsi l'utilisation des ressources et les coûts.

**Contraintes** : Elle nécessite une surveillance précise des métriques, des configurations correctes des HPA (Horizontal Pod Autoscaler) et des ressources disponibles sur les nœuds.

**Risques** : Les risques incluent des délais dans la montée en charge, des erreurs de configuration pouvant entraîner des pannes de service, et des coûts imprévus si les pods sont surprovisionnés.

--- 

### Mécanismes internes qui permettent le HPA

**Le Horizontal Pod Autoscaler (HPA) dans Kubernetes utilise des mécanismes internes pour ajuster dynamiquement le nombre de pods en fonction de la charge de travail.**

1. **Metrics Server** : Collecte des métriques d'utilisation des ressources (CPU, mémoire) des pods en temps réel.
2. **Contrôleur HPA** : Récupère les métriques collectées et compare les valeurs actuelles aux seuils définis (par exemple, utilisation CPU à 80%).
3. **API Kubernetes** : Le contrôleur HPA interagit avec l'API Kubernetes pour augmenter ou diminuer le nombre de pods en fonction des besoins, en respectant les paramètres de scalabilité définis (minReplicas et maxReplicas).
4. **Stratégies de scaling** : HPA utilise des stratégies de scaling pour s'assurer que les ajustements sont effectués de manière fluide, sans perturber les services en cours d'exécution.

--- 

### Mesure de la charge CPU par le Metrics Server

**Le Metrics Server dans Kubernetes mesure l'utilisation réelle de la CPU par les pods, exprimée en millicores.**

Cette mesure correspond au pourcentage de temps CPU utilisé par les conteneurs et non à la charge système globale (load) ou au stress.

Les cas de faux positifs peuvent survenir, par exemple, lors de pics temporaires ou de mauvais dimensionnements de ressources.

On peut provoquer des stress CPU via des outils de test comme https://github.com/narmidm/k8s-pod-cpu-stressor.

---
## Difficultés à configurer le HPA et histoires de pannes

Configurer le Horizontal Pod Autoscaler (HPA) dans Kubernetes peut présenter plusieurs défis et risques, notamment :

---

### Détermination des valeurs appropriées pour les ressources

**Il peut être difficile de définir correctement les demandes et limites de ressources (CPU, mémoire) pour les pods.**

Une configuration incorrecte peut entraîner une sous-utilisation ou une surutilisation des ressources.


---

### Faux positifs et instabilité

**Le HPA peut réagir de manière excessive à des pics temporaires ou à des métriques incorrectement configurées.**

Cela peut entraîner des oscillations fréquentes (flapping) dans le nombre de pods, augmentant la charge sur le système sans réellement améliorer les performances.

---

### Impact des métriques de performance

**L'utilisation des métriques CPU par défaut peut ne pas toujours refléter fidèlement la charge réelle de l'application.**

Des métriques personnalisées peuvent être nécessaires pour des scénarios plus complexes, comme le temps de traitement des requêtes ou le nombre d'erreurs HTTP.

---

### Problèmes de synchronisation

**Le HPA ne réagit pas instantanément aux changements de charge, ce qui peut entraîner des périodes de latence où les ressources ne sont pas suffisantes pour gérer le pic de charge.**

Cela peut être exacerbé par des intervalles de collecte de métriques trop longs ou des configurations de seuils inadéquates.

---

### Cas de pannes

**Il existe des histoires où des configurations inadéquates du HPA ont conduit à des comportements inattendus.**

Par exemple, si les pods n'ont pas de réserves de CPU suffisantes, le HPA peut ne pas ajouter de pods même lorsque la charge augmente.

De plus, des conflits avec d'autres contrôleurs ou configurations peuvent également causer des échecs de scaling.


---

### Utilisation d'autres logiques pour le HPA

Outre l'utilisation des métriques CPU et mémoire, d'autres logiques peuvent être utilisées pour déclencher l'autoscaling :

- **Apparition d'erreurs 500** : Utiliser le nombre d'erreurs 500 pour déclencher l'ajout de pods, assurant que le service reste réactif en cas de défaillance.
- **Temps de traitement des requêtes** : Configurer l'HPA pour ajouter des pods si le temps de traitement des requêtes dépasse un seuil prédéfini.
- **Métriques personnalisées** : Intégrer des métriques spécifiques à l'application via Prometheus et l'adaptateur Prometheus pour Kubernetes, permettant une évaluation plus précise des besoins en ressources.

Ces méthodes permettent d'optimiser le comportement de l'HPA et de mieux aligner les ressources avec les exigences réelles de l'application.

---

### Utilisation d'autres métriques pour l'HPA

Outre l'utilisation de la CPU, il est possible d'utiliser d'autres métriques pour l'autoscaling.

Par exemple :

- **Erreurs 500** : Ajuster le nombre de pods en réponse à une augmentation des erreurs de serveur.
- **Temps de traitement** : Utiliser la latence ou le temps de réponse des requêtes pour déclencher le scaling.
- **Métriques personnalisées** : Définir des métriques spécifiques à l'application, telles que le nombre de requêtes en attente.

Ces logiques peuvent être intégrées en utilisant l'API de métriques personnalisées de Kubernetes ou en combinant Prometheus avec l'HPA pour des scénarios d'autoscaling avancés.


--- 

### TP : Utilisation d'une métrique personnalisée pour le HPA

**On veut configurer le Horizontal Pod Autoscaler (HPA) pour utiliser une métrique personnalisée (temps de traitement des requêtes) en complément de la métrique CPU pour l'autoscaling.**

#### Prérequis
- Un cluster Kubernetes fonctionnel
- kubectl installé et configuré
- Metrics Server et Prometheus déployés dans le cluster

### Étape 1 : Exposer la métrique personnalisée

1. **Configurer Prometheus pour collecter le temps de traitement des requêtes**

   Créez un endpoint dans votre application pour exposer les métriques Prometheus, par exemple :

   ```python
   from prometheus_client import start_http_server, Summary

   REQUEST_TIME = Summary('request_processing_seconds', 'Time spent processing request')

   @REQUEST_TIME.time()
   def process_request(request):
       # Code to process the request
       pass

   if __name__ == '__main__':
       start_http_server(8000)
       # Your code to start application
   ```

2. **Déployez Prometheus et configurez le scrape config pour votre application**

   ```yaml
   scrape_configs:
     - job_name: 'myapp'
       static_configs:
         - targets: ['<app-service>:8000']
   ```

### Étape 2 : Configurer Prometheus Adapter pour Kubernetes

1. **Déployer Prometheus Adapter**

   ```sh
   helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
   helm repo update
   helm install prometheus-adapter prometheus-community/prometheus-adapter --namespace monitoring
   ```

2. **Configurer Prometheus Adapter pour exposer les métriques personnalisées**

   Ajoutez les règles pour exporter la métrique de temps de traitement :

   ```yaml
   rules:
     - seriesQuery: 'request_processing_seconds_count'
       resources:
         overrides:
           namespace:
             resource: "namespace"
           pod:
             resource: "pod"
       name:
         matches: "^(.*)_count"
         as: "${1}_per_second"
       metricsQuery: 'sum(rate(<<.Series>>{<<.LabelMatchers>>}[5m])) by (<<.GroupBy>>)'
   ```

### Étape 3 : Créer et configurer l'HPA

1. **Créer l'HPA (hpa.yaml)**

   ```yaml
   apiVersion: autoscaling/v2beta2
   kind: HorizontalPodAutoscaler
   metadata:
     name: myintensiveapp-hpa
   spec:
     scaleTargetRef:
       apiVersion: apps/v1
       kind: Deployment
       name: myintensiveapp
     minReplicas: 10
     maxReplicas: 50
     metrics:
     - type: Resource
       resource:
         name: cpu
         target:
           type: Utilization
           averageUtilization: 50
     - type: Pods
       pods:
         metric:
           name: request_processing_seconds
         target:
           type: AverageValue
           averageValue: 400ms
   ```

2. **Appliquer l'HPA**

   ```sh
   kubectl apply -f hpa.yaml
   ```

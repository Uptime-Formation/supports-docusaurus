---
title: Cours optionnel - Règles de scheduling et capacity planning
---

## Règles de scheduling (planification)

Le rôle du *scheduler* est de choisir les nœuds sur lesquels exécuter les pods nouvellement créés.

C'est une problématique très compliquée dans le cas général qui dépend complètement des situations et besoins.

Par défaut, le *scheduler* suit les règles :

- Diviser les pods du même replicaset ou statefulset entre les nœuds.
- Planifier les pods sur des nœuds disposant de suffisamment de ressources pour satisfaire les demandes de pods.
- Équilibrer l'utilisation globale des ressources des nœuds.

C'est un comportement par défaut assez bon, mais parfois, vous pouvez vouloir un meilleur contrôle sur le placement spécifique des pods et la gestion des Resources.

## Contraintes de placement

### NodeSelector

Un pod peut spécifier sur quels nœuds il souhaite être planifié dans sa `spec`. Par exemple, un pod nginx avec un `nodeSelector` spécifiant l'étiquette `kubernetes.io/hostname` du nœud `kluster-worker2` (nœud à partir de l'installation kubeadm ansible) :

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-scheduling
  labels:
    role: nginx-example
spec:
  nodeSelector:
    kubernetes.io/hostname: kluster-worker2
  containers:
  - name: nginx
    image: nginx:latest
```

## Taints et tolerations

Vous pouvez marquer (`taint` -> c'est différent des `labels` de noeuds) un nœud afin d'empêcher les pods d'être planifiés sur le nœud:

- si vous ne souhaitez pas que des pods soient planifiés sur vos nœuds du control plane.
- si vous avez un type de noeud réservés pour par exemple les workloads gpu
- etc

Les tolérations permettent aux pods de déclarer qu'ils peuvent "tolérer" une `taint`, et alors ces pods peuvent être planifiés sur le nœud marqué.

Un nœud peut avoir plusieurs `taints` et un pod peut avoir plusieurs `tolerations`.

L'effet peut être :
- NoSchedule (aucun pod ne sera planifié sur le nœud à moins qu'ils ne tolèrent la marque)
- PreferNoSchedule (version soft de NoSchedule ; le scheduleur tentera de ne pas planifier de pods qui ne tolèrent pas la marque)
- NoExecute (aucun nouveau pod ne sera planifié, mais aussi les pods existants qui ne tolèrent pas la marque seront évincés)

Tentons de marquer notre nœud `worker2` pour expulser les pods:


```sh
kubectl taint nodes kluster-worker2 taint-example=true:NoExecute
```

Pour permettre aux pods de tolérer cette taint, ajoutez une toleration à leur `spec`:

```yaml
  tolerations:
    - key: "taint-example"
      operator: "Equal"
      value: "true"
      effect: "NoExecute"
```

## Critères Node affinity et anti-affinity

La `node affinity` est proche mais plus elaborée que le concept de `nodeSelector` :

- Critères de sélection plus riches
- Les règles peuvent être souples (s'appliquer si possible)
- Vous pouvez obtenir une `anti-affinity` en utilisant des opérateurs comme `NotIn` et `DoesNotExist`

Si vous spécifiez à la fois `nodeSelector` et `nodeAffinity`, alors le pod sera planifié uniquement sur un nœud qui satisfait **les deux** exigences.

Par exemple, si nous ajoutons la section suivante à notre pod nginx, il ne pourra pas s'exécuter sur aucun nœud car cela entre en conflit avec le `nodeSelector`:

```yaml
affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: NotIn
          values:
          - kluster-worker2
```


### Critères Pod affinity et anti-affinity

L'affinité et l'anti-affinité des pods offrent une autre solution pour gérer l'emplacement où s'exécutent vos charges de travail.

Toutes les méthodes que nous avons discutées jusqu'à présent - les sélecteurs de nœuds, les marques/tolérances, l'affinité/anti-affinité des nœuds - concernaient l'attribution de pods à des nœuds.

Mais la `pod affinity` concerne les relations entre différents pods.

la `pod affinity` fonctionne avec d'autres concepts :

- le namespace (puisque les pods sont namespaced)
- la topology zone (nœud, rack, zone du fournisseur cloud, région du fournisseur cloud)
- le poids (pour une planification préférentielle).

Un exemple simple est si vous voulez que hue-reminders soit toujours planifié avec un pod. Voyons comment le définir dans la spécification du modèle de pod du déploiement hue-reminders :

```yaml
    affinity:
      podAffinity:
        requiredDuringSchedulingIgnoredDuringExecution:
        - weight: 200
          labelSelector:
            matchExpressions:
            - key: role
              operator: In
              values:
              - nginx-example
          topologyKey: topology.kubernetes.io/zone # for clusters on cloud providers
      podAntiAffinity:
        preferredDuringSchedulingIgnoredDuringExecution:
        - weight: 100
          podAffinityTerm:
            labelSelector:
              matchExpressions:
              - key: role
                operator: In
                values:
                - pod-repoussoir
          topologyKey: topology.kubernetes.io/zone
```

La topologyKey est une étiquette de nœud que Kubernetes utilise pour rassembler les pods qui doivent fonctionner ensemble : dans le cas classique d'un cloud provider on utilise `topology.kubernetes.io/zone` lorsque les workloads doivent s'exécuter dans un même datacenter.

Avec le code d'exemple précédent les nouveaux pods avec cette spec seront planifiés sur `kluster-worker2` à côté du pod `nginx-example`  et loin du pod-repoussoir mais c'est moins prioritaire.

### Pod topology spread constraints

L'affinité/anti-affinité de nœud et l'affinité/anti-affinité de pod sont parfois trop strictes et spécifiques. Vous pouvez vouloir répartir vos pods globalement en tolérant une répartition pas totalement équitable.

Les `Pod topology spread constraints` permettent de spécifier le décalage maximal (max skew), qui représente la distance à laquelle vous pouvez vous trouver de la répartition optimale, ainsi que le comportement lorsque la contrainte ne peut pas être satisfaite (DoNotSchedule ou ScheduleAnyway).

Voici un exemple sur `monsterstack` avec des `topology spread constraints` :

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: 
spec:
  replicas: 7
  selector:
    matchLabels:
      app: monsterstack
      partie: frontend
  template:
    metadata:
      name: frontend
    labels:
      app: monsterstack
      partie: frontend
    spec:
      topologySpreadConstraints:
      - maxSkew: 2
        topologyKey: node.kubernetes.io/instance-type
        whenUnsatisfiable: DoNotSchedule
        labelSelector:
          matchLabels:
            app: monsterstack
            service: frontend
      containers:
      - name: frontend
        image: frontend:latest
        ports:
        - containerPort: 5000
```

### Le plugin Descheduler

Une fois qu'un pod est planifié, Kubernetes ne le déplacera pas vers un autre nœud si les conditions initiales ont changé. ce qui peut poser problème si:

- Certains nœuds sont sous-utilisés ou sur-utilisés.
- La décision initiale de planification n'est plus valide lorsque des `taints` ou `labels` ont changé.
- Noeuds défaillants ou nouveau on entrainé des migrations de pods

 Le descheduler (https://github.com/kubernetes-sigs/descheduler) vérifiera périodiquement le placement actuel des pods et procèdera à l'eviction les pods qui enfreignent certaines contraintes. Les pods seront ensuite reschedule normalement avec les règles a jour.

 ## Resources et capacity planning

Dans un cluster kubernetes on peut ajouter des noeuds facilement donc pas besoin d'anticiper trop à l'avance les besoins en resources mais il faut tout de même étudier ses programmes et arbitrer au fur et a mesure entre:

- utiliser au maximum les resources
- avoir des resources en réserve pour les imprévus

Il est recommandé à la louche de ne pas dépasser 50-60% d'utilisation des ressources ce qui permet d'éviter les réactions en chaine si un noeud crashe ou si on veut faire un blue-green deploy en prod par exemple.

 ### Étudier ses workloads

- Connaître la "shape" c'est à dire le ratio memoire/CPU de ses workloads et choisir des noeuds adaptés avec un ratio proche
- Avoir une une idée dynamique via du monitoring de la consommation des workload en fonction de la charge sur le hardware spécifique de votre cluster (le CPU c'est trèèès variable selon les machines)
- Savoir si les workloads consomment plus au démarrage ou à certains moments pour décloupler les taches consommatrices et moins consommatrices avec des init containers ou conteneurs annexes : par exemple on peut mettre des limits/requests haute sur l'init container ce qui évite de devoir donner trop de ressource au workload

#### Requests et limits

Voir TP

#### ResourceQuota

Limiter les resources pour un namespace : très important en cas de multi-tenancy.

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: resource-quota-example
spec:
  hard:
    pods: "10"
    requests.cpu: "4"
    requests.memory: 4Gi
    limits.cpu: "6"
    limits.memory: 6Gi
```

#### LimitRange

Spécifier les limites raisonnables pour un conteneur et au total pour un pod mais au niveau du namespace.


```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: limit-range-example
spec:
  limits:
  - type: Pod
    max:
      cpu: "1"
      memory: 512Mi
    min:
      cpu: "100m"
      memory: 64Mi
  - type: Container
    max:
      cpu: "500m"
      memory: 256Mi
    min:
      cpu: "50m"
      memory: 32Mi
    default:
      cpu: "100m"
      memory: 64Mi
```
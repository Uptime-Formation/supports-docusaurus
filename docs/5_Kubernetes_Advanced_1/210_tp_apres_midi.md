---
title: "TP Après-midi - Autoscaling avec KEDA"
draft: false
---

## TP — Autoscaling événementiel avec KEDA

**Déployer KEDA (Kubernetes Event-Driven Autoscaling) et observer comment cet operator étend le HPA natif Kubernetes pour scaler une application en fonction de métriques CPU, puis explorer le comportement du scale-down.**

### Objectif

À la fin de ce TP, vous aurez :
- Installé KEDA via Helm et observé ses CRDs
- Déployé une application de test (`php-apache`)
- Créé un `ScaledObject` et observé que KEDA génère automatiquement un HPA
- Généré de la charge et observé le scale-up automatique
- Observé le scale-down et l'effet du `stabilizationWindowSeconds`

### Prérequis

- Un cluster Kubernetes fonctionnel avec Metrics Server
- `helm` installé

---

## Étape 1 : Préparer l'environnement

- **Action** :

```bash
kubectl create namespace keda-tp
kubectl get deployment metrics-server -n kube-system
```

- **Observation** : Le namespace `keda-tp` est créé. Le Metrics Server doit être `READY 1/1` — il est requis par KEDA pour les triggers CPU.

---

## Étape 2 : Installer KEDA

KEDA est un operator CNCF. Son installation via Helm déploie trois composants et enregistre six CRDs.

- **Action** :

```bash
helm repo add kedacore https://kedacore.github.io/charts
helm repo update

helm install keda kedacore/keda \
  --namespace keda \
  --create-namespace

kubectl rollout status deployment/keda-operator -n keda --timeout=120s
kubectl rollout status deployment/keda-operator-metrics-apiserver -n keda --timeout=120s
kubectl rollout status deployment/keda-admission-webhooks -n keda --timeout=120s
```

- **Observation** : Trois déploiements sont `Running` dans le namespace `keda` :

```bash
kubectl get pods -n keda
```

```
NAME                                               READY   STATUS
keda-operator-...                                  1/1     Running
keda-operator-metrics-apiserver-...                1/1     Running
keda-admission-webhooks-...                        1/1     Running
```

Vérifiez les CRDs installées par KEDA :

```bash
kubectl get crd | grep keda
```

La CRD centrale est `scaledobjects.keda.sh` — c'est l'objet que vous allez créer pour piloter le scaling.

---

## Étape 3 : Déployer l'application de test

`hpa-example` est l'image officielle Kubernetes pour les démonstrations HPA — une application PHP qui consomme du CPU à chaque requête.

- **Action** :

```yaml
# php-apache.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: php-apache
  namespace: keda-tp
spec:
  replicas: 1
  selector:
    matchLabels:
      app: php-apache
  template:
    metadata:
      labels:
        app: php-apache
    spec:
      containers:
      - name: php-apache
        image: registry.k8s.io/hpa-example
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: 200m
            memory: 64Mi
          limits:
            cpu: 500m
            memory: 128Mi
---
apiVersion: v1
kind: Service
metadata:
  name: php-apache
  namespace: keda-tp
spec:
  selector:
    app: php-apache
  ports:
  - port: 80
    targetPort: 80
```

```bash
kubectl apply -f php-apache.yaml
kubectl rollout status deployment/php-apache -n keda-tp
```

- **Observation** : Le pod est `Running` avec 1 replica. Notez que les `requests` CPU sont définies — sans elles, KEDA ne peut pas calculer le pourcentage d'utilisation.

---

## Étape 4 : Créer un ScaledObject

Un `ScaledObject` déclare **ce qu'on veut scaler**, **jusqu'où**, et **sur quelle métrique**. KEDA crée alors automatiquement un HPA Kubernetes sous-jacent.

- **Action** :

```yaml
# scaledobject.yaml
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: php-apache-scaledobject
  namespace: keda-tp
spec:
  scaleTargetRef:
    name: php-apache          # nom du Deployment à scaler
  minReplicaCount: 1
  maxReplicaCount: 10
  pollingInterval: 10         # KEDA vérifie la métrique toutes les 10s
  cooldownPeriod: 30
  advanced:
    horizontalPodAutoscalerConfig:
      behavior:
        scaleDown:
          stabilizationWindowSeconds: 30   # attend 30s avant de scale-down
  triggers:
  - type: cpu
    metricType: Utilization
    metadata:
      value: "50"             # scale si CPU > 50% en moyenne
```

```bash
kubectl apply -f scaledobject.yaml
```

- **Observation** : KEDA a créé un HPA automatiquement :

```bash
kubectl get scaledobject -n keda-tp
kubectl get hpa -n keda-tp
```

```
NAME                               REFERENCE               TARGETS       MINPODS   MAXPODS   REPLICAS
keda-hpa-php-apache-scaledobject   Deployment/php-apache   cpu: 0%/50%   1         10        1
```

Le HPA est nommé `keda-hpa-<nom-du-scaledobject>` — KEDA en est propriétaire, ne le modifiez pas directement. Inspectez le ScaledObject :

```bash
kubectl describe scaledobject php-apache-scaledobject -n keda-tp
```

La section `Conditions` indique `ScaledObjectReady: True` quand tout est correctement configuré.

---

## Étape 5 : Générer de la charge et observer le scaling

- **Action** : Lancer un pod générateur de charge dans un second terminal, puis observer le HPA dans le premier.

**Terminal 1 — observation :**
```bash
watch -n 5 "kubectl get hpa keda-hpa-php-apache-scaledobject -n keda-tp && kubectl get pods -n keda-tp"
```

**Terminal 2 — charge :**
```bash
kubectl run load-generator \
  --image=busybox \
  --namespace=keda-tp \
  --restart=Never \
  -- /bin/sh -c "while true; do wget -q -O- http://php-apache.keda-tp.svc.cluster.local; done"
```

- **Observation** : En 20 à 40 secondes, le CPU dépasse 50%. KEDA ajuste le nombre de replicas :

```
TARGETS         REPLICAS
cpu: 124%/50%   1  → calcul en cours
cpu: 203%/50%   3  → scale-up
cpu: 122%/50%   5  → scale-up
cpu: 54%/50%    8  → stabilisation
```

Kubernetes ne peut pas instancier tous les replicas simultanément — c'est pour ça que le CPU continue de monter pendant le scale-up.

---

## Étape 6 : Observer le scale-down

- **Action** : Supprimer le générateur de charge et observer le retour à 1 replica.

```bash
kubectl delete pod load-generator -n keda-tp
```

Continuez d'observer dans le terminal 1.

- **Observation** : Le CPU redescend sous 50%. KEDA attend `stabilizationWindowSeconds: 30` avant de scale-down — ce délai évite le **flapping** (montée/descente rapide en réponse à des pics courts).

> Changez `stabilizationWindowSeconds` à `300` (5 minutes) dans le `ScaledObject` et relancez le test — le scale-down sera beaucoup plus lent. C'est le comportement recommandé en production.

---

## Avancé : scalers KEDA au-delà du CPU

Le trigger `cpu` est le plus simple, mais KEDA supporte des dizaines de sources. Exemples :

```yaml
# Scale en fonction de la longueur d'une file RabbitMQ
triggers:
- type: rabbitmq
  metadata:
    queueName: my-queue
    queueLength: "20"   # 1 replica par tranche de 20 messages

# Scale selon un planning cron (ex: augmenter la nuit)
triggers:
- type: cron
  metadata:
    timezone: Europe/Paris
    start: "0 8 * * *"    # scale-up à 8h
    end: "0 20 * * *"     # scale-down à 20h
    desiredReplicas: "5"
```

La puissance de KEDA est que chaque trigger crée un HPA sous-jacent — vous bénéficiez de toute la logique de scaling Kubernetes sans avoir à intégrer vous-même les métriques externes.

---

## Questions de réflexion

- Pourquoi KEDA crée-t-il un HPA plutôt que de gérer directement le nombre de replicas ?
- Que se passe-t-il si vous modifiez directement le HPA créé par KEDA ?
- Quel `stabilizationWindowSeconds` choisiriez-vous pour une application web de production soumise à des pics de trafic courts ?
- Pourquoi le CPU continue-t-il de monter pendant le scale-up, même si de nouveaux pods démarrent ?

---

## Nettoyage

```bash
kubectl delete -f scaledobject.yaml
kubectl delete -f php-apache.yaml
kubectl delete pod load-generator -n keda-tp --ignore-not-found
helm uninstall keda -n keda
kubectl delete namespace keda-tp keda
```

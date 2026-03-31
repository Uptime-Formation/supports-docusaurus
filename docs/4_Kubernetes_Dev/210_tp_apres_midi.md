---
title: TP après-midi — Kubernetes Développeur
---

**Exposer une application avec un Ingress, appliquer des NetworkPolicies, et packager avec Kustomize.**

**Durée : 1h30**

### Contexte

Vous avez déployé une stack Redis ce matin. Cet après-midi, vous allez exposer une application web via un Ingress, sécuriser les communications réseau avec une NetworkPolicy, puis packager votre configuration avec Kustomize pour gérer deux environnements (dev et prod).

---

## Focus Kubernetes Dev

- ✅ **Ingress** : Exposer une application via un nom de domaine HTTP
- ✅ **NetworkPolicy** : Restreindre les communications entre pods
- ✅ **CronJob** : Planifier une tâche récurrente
- ✅ **Kustomize** : Factoriser des manifestes pour plusieurs environnements

**L'objectif n'est PAS de configurer un vrai nom de domaine en production**, mais d'apprendre à **exposer et sécuriser des applications dans Kubernetes**.

---

## Objectif

À la fin de ce TP, vous devez avoir :

- ✅ Un Deployment `my-app` exposé via un Service ClusterIP et un Ingress
- ✅ Une NetworkPolicy qui restreint l'accès à `my-app` sauf pour les pods autorisés
- ✅ Un CronJob qui teste périodiquement l'accès au service
- ✅ Deux overlays Kustomize (dev et prod) avec des configurations différentes

---

## Étape 1 - Déployer une application et l'exposer avec un Service

**Objectif** : Créer la base applicative.

- **Action** : Créer un Deployment `my-app` avec l'image `nginx:latest`, 2 replicas, port 80
  **Observation** : `kubectl get pods` montre 2 pods `my-app-*` en état `Running`

- **Action** : Créer un Service `my-app-service` de type `ClusterIP` sur le port 80 avec le selector `app: my-app`
  **Observation** : `kubectl get svc my-app-service` montre le service. `kubectl get endpoints my-app-service` montre les 2 IPs de pods

<details><summary>Indice</summary>

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
  namespace: mynamespace
spec:
  replicas: 2
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: my-app
        image: nginx:latest
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: my-app-service
  namespace: mynamespace
spec:
  selector:
    app: my-app
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
  type: ClusterIP
```

</details>

---

## Étape 2 - Exposer avec un Ingress

**Objectif** : Accéder à l'application depuis l'extérieur via un nom de domaine.

- **Action** : Vérifier que l'Ingress Controller est installé dans le cluster
  ```bash
  kubectl get pods -n kube-system | grep -i ingress
  # ou pour k3s avec traefik :
  kubectl get pods -n kube-system | grep traefik
  ```
  **Observation** : Le pod de l'ingress controller est en état `Running`

- **Action** : Créer un Ingress `my-app-ingress` qui route `MY.DOMAIN.COM` vers `my-app-service:80` avec la classe `traefik`
  **Observation** : `kubectl get ingress` montre l'ingress avec une adresse IP

- **Action** : Tester l'accès en ajoutant une entrée dans `/etc/hosts` pointant vers l'IP du cluster, puis `curl http://MY.DOMAIN.COM`
  **Observation** : La page nginx par défaut s'affiche

<details><summary>Indice</summary>

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-app-ingress
  namespace: mynamespace
spec:
  ingressClassName: traefik
  rules:
  - host: MY.DOMAIN.COM
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: my-app-service
            port:
              number: 80
```

Pour trouver l'IP du cluster :
```bash
kubectl get nodes -o wide   # colonne EXTERNAL-IP ou INTERNAL-IP
```

</details>

---

## Étape 3 - CronJob pour tester le service

**Objectif** : Vérifier périodiquement l'accessibilité du service.

- **Action** : Créer un CronJob `test-cronjob` qui toutes les minutes tente d'accéder à `web-service` avec `wget -qO- http://my-app-service`
  **Observation** : Après 1-2 minutes, `kubectl get jobs` montre des Jobs créés

- **Action** : Vérifier les logs du Job créé
  ```bash
  kubectl logs job/<nom-du-job>
  ```
  **Observation** : Les logs montrent la page HTML nginx

<details><summary>Indice</summary>

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: test-cronjob
  namespace: mynamespace
spec:
  schedule: "*/1 * * * *"
  jobTemplate:
    spec:
      template:
        metadata:
          labels:
            app: tester
        spec:
          containers:
          - name: busybox
            image: busybox
            command: ["wget", "-qO-", "http://my-app-service"]
          restartPolicy: Never
```

</details>

---

## Étape 4 - Appliquer une NetworkPolicy

**Objectif** : Sécuriser l'accès à `my-app` par NetworkPolicy.

- **Action** : Appliquer une NetworkPolicy `deny-all-except-allowed` qui bloque tout trafic entrant sur les pods `app: my-app` sauf depuis les pods avec le label `role: allowed`
  **Observation** : Le CronJob existant échoue maintenant (il n'a pas le label `role: allowed`)

- **Action** : Vérifier que le CronJob échoue :
  ```bash
  kubectl get jobs
  kubectl logs job/<nom-du-job-récent>
  ```
  **Observation** : Le log montre une erreur de connexion (timeout ou connection refused)

- **Action** : Modifier le CronJob pour ajouter le label `role: allowed` dans le template de pod, puis re-appliquer
  **Observation** : Le nouveau Job réussit — les logs montrent à nouveau la page HTML

<details><summary>Indice</summary>

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all-except-allowed
  namespace: mynamespace
spec:
  podSelector:
    matchLabels:
      app: my-app
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          role: allowed
```

Pour autoriser le CronJob, ajouter dans le `jobTemplate.spec.template.metadata.labels` :
```yaml
labels:
  role: allowed
```

</details>

---

## Étape 5 - Kustomize : dev et prod

**Objectif** : Gérer deux environnements avec des paramètres différents.

- **Action** : Créer la structure de dossiers suivante :
  ```
  kustomize/
    base/
      deployment.yaml   # my-app, 1 replica
      service.yaml
      kustomization.yaml
    overlays/
      dev/
        kustomization.yaml   # patch: 1 replica, image nginx:latest
      prod/
        kustomization.yaml   # patch: 3 replicas, image nginx:1.25
  ```
  **Observation** : La structure existe avec les fichiers

- **Action** : Visualiser le résultat pour l'overlay dev :
  ```bash
  kubectl kustomize kustomize/overlays/dev
  ```
  **Observation** : Le YAML final affiche les manifestes avec les valeurs dev

- **Action** : Appliquer l'overlay dev dans un namespace `dev` :
  ```bash
  kubectl create namespace dev
  kubectl apply -k kustomize/overlays/dev -n dev
  ```
  **Observation** : Les ressources sont créées dans le namespace `dev`

<details><summary>Indice</summary>

`kustomize/base/kustomization.yaml` :
```yaml
resources:
- deployment.yaml
- service.yaml
```

`kustomize/overlays/dev/kustomization.yaml` :
```yaml
bases:
- ../../base
patches:
- target:
    kind: Deployment
    name: my-app
  patch: |-
    - op: replace
      path: /spec/replicas
      value: 1
```

`kustomize/overlays/prod/kustomization.yaml` :
```yaml
bases:
- ../../base
patches:
- target:
    kind: Deployment
    name: my-app
  patch: |-
    - op: replace
      path: /spec/replicas
      value: 3
    - op: replace
      path: /spec/template/spec/containers/0/image
      value: nginx:1.25
```

</details>

---

### Avancé

- **Ingress TLS** : Comment ajouter un certificat HTTPS sur votre Ingress avec certmanager ? (Indice : annotations `cert-manager.io/issuer`)
- **ArgoCD** : Comment configureriez-vous ArgoCD pour déployer automatiquement depuis votre dépôt Git quand vous pushez sur `main` ?
- **HPA** : Ajoutez un HorizontalPodAutoscaler sur `my-app` pour scaler entre 2 et 6 replicas si le CPU dépasse 70%. Que faut-il ajouter au Deployment pour que le HPA fonctionne ?
- **NetworkPolicy namespace** : Modifiez la NetworkPolicy pour autoriser tout le trafic venant du namespace `monitoring` (Indice : `namespaceSelector`)

---

### Synthèse

**Qu'est-ce qui a bien fonctionné ?**
- L'Ingress a-t-il correctement routé le trafic vers le service ?
- La NetworkPolicy a-t-elle bloqué le CronJob comme attendu ?

**Quels sont les problèmes rencontrés ?**
- L'Ingress Controller était-il déjà présent dans le cluster ?
- Les labels dans le CronJob ont-ils bien correspondu à la NetworkPolicy ?

**Quelles compétences avez-vous développées ?**

- ✅ Exposer une application avec un Ingress et un IngressController
- ✅ Restreindre les communications réseau avec une NetworkPolicy
- ✅ Planifier des tâches avec un CronJob
- ✅ Factoriser des manifestes pour plusieurs environnements avec Kustomize

**Prochaine étape** : En formation Kubernetes Tips, vous approfondirez les bonnes pratiques : probes, scanning d'images, NetworkPolicies avancées, et outils de diagnostic.

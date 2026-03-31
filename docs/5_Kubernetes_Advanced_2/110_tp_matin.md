---
title: "TP Matin - Réseau & Certificats"
draft: false
---

<!-- TPs FOURNIS PAR L'UTILISATEUR — intégrer quand disponible -->

## TP Cilium : Network Policies avec eBPF

<!-- À REPRENDRE EXISTANT : 5_Kubernetes-Advanced/220-Run2-CNI.md ## TP -->

**Déployer Cilium comme CNI et expérimenter les Network Policies pour contrôler les flux réseau entre pods.**

### Prérequis

- Un cluster Kubernetes fonctionnel (kind ou kubeadm)
- `helm` installé
- `cilium` CLI installé

---

### Étape 1 : Installer Cilium via Helm

```sh
helm repo add cilium https://helm.cilium.io/
helm repo update

helm install cilium cilium/cilium \
  --namespace kube-system \
  --set kubeProxyReplacement=strict \
  --set k8sServiceHost=<CONTROL_PLANE_IP> \
  --set k8sServicePort=6443
```

Vérifier l'installation :

```sh
cilium status
cilium connectivity test
```

---

### Étape 2 : Déployer une application de test

```yaml
# Namespace de test
apiVersion: v1
kind: Namespace
metadata:
  name: cilium-test
---
# Pod frontend
apiVersion: v1
kind: Pod
metadata:
  name: frontend
  namespace: cilium-test
  labels:
    app: frontend
spec:
  containers:
  - name: nginx
    image: nginx
    ports:
    - containerPort: 80
---
# Pod backend
apiVersion: v1
kind: Pod
metadata:
  name: backend
  namespace: cilium-test
  labels:
    app: backend
spec:
  containers:
  - name: nginx
    image: nginx
    ports:
    - containerPort: 80
---
# Pod external (simulateur de trafic externe)
apiVersion: v1
kind: Pod
metadata:
  name: external
  namespace: cilium-test
  labels:
    app: external
spec:
  containers:
  - name: busybox
    image: busybox
    command: ["sleep", "3600"]
```

```sh
kubectl apply -f test-pods.yaml
kubectl get pods -n cilium-test
```

---

### Étape 3 : Vérifier la connectivité par défaut

```sh
# Depuis le pod external, tenter de joindre le backend
kubectl exec -n cilium-test external -- wget -qO- --timeout=5 http://backend.cilium-test.svc.cluster.local

# Depuis le frontend, tenter de joindre le backend
kubectl exec -n cilium-test frontend -- wget -qO- --timeout=5 http://backend.cilium-test.svc.cluster.local
```

Par défaut, tous les pods peuvent communiquer entre eux.

---

### Étape 4 : Appliquer une Network Policy restrictive

```yaml
# Autoriser uniquement le frontend à accéder au backend
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend-to-backend
  namespace: cilium-test
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend
    ports:
    - protocol: TCP
      port: 80
```

```sh
kubectl apply -f network-policy.yaml
```

---

### Étape 5 : Vérifier l'isolation

```sh
# Ce call doit RÉUSSIR (frontend → backend autorisé)
kubectl exec -n cilium-test frontend -- wget -qO- --timeout=5 http://backend.cilium-test.svc.cluster.local

# Ce call doit ÉCHOUER (external → backend bloqué)
kubectl exec -n cilium-test external -- wget -qO- --timeout=5 http://backend.cilium-test.svc.cluster.local
```

---

### Étape 6 : Observer avec Hubble (optionnel)

```sh
# Activer Hubble
helm upgrade cilium cilium/cilium \
  --namespace kube-system \
  --reuse-values \
  --set hubble.relay.enabled=true \
  --set hubble.ui.enabled=true

# Ouvrir l'UI Hubble
cilium hubble ui &

# Observer les flux en CLI
hubble observe --namespace cilium-test --follow
```

---

### Points à explorer

- Appliquer une politique d'egress pour bloquer les requêtes sortantes vers l'extérieur
- Comparer le comportement avec une Network Policy `deny-all` suivie de règles d'autorisation granulaires
- Observer dans Hubble les flux autorisés vs rejetés

---

## TP cert-manager : HTTPS automatique avec Let's Encrypt

<!-- À REPRENDRE EXISTANT : 5_Kubernetes-Advanced/240-Run2-Certificates.md ## TP -->

**Installer cert-manager et obtenir automatiquement un certificat TLS via Let's Encrypt pour une application exposée par un Ingress.**

### Prérequis

- Un cluster Kubernetes avec accès internet
- Un Ingress Controller déployé (Traefik ou nginx)
- Un nom de domaine pointant vers le cluster

---

### Étape 1 : Installer cert-manager

```sh
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/latest/download/cert-manager.yaml
```

Vérifier l'installation :

```sh
kubectl get pods -n cert-manager
# 3 pods doivent être Running : cert-manager, cert-manager-cainjector, cert-manager-webhook
```

---

### Étape 2 : Créer un ClusterIssuer Let's Encrypt (staging)

Toujours commencer par staging pour éviter les rate limits de production :

```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-staging
spec:
  acme:
    server: https://acme-staging-v02.api.letsencrypt.org/directory
    email: votre-email@domaine.com
    privateKeySecretRef:
      name: letsencrypt-staging
    solvers:
    - http01:
        ingress:
          class: traefik
```

```sh
kubectl apply -f clusterissuer-staging.yaml
kubectl describe clusterissuer letsencrypt-staging
```

---

### Étape 3 : Déployer une application de test

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: whoami
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: whoami
  template:
    metadata:
      labels:
        app: whoami
    spec:
      containers:
      - name: whoami
        image: traefik/whoami
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: whoami
  namespace: default
spec:
  selector:
    app: whoami
  ports:
  - port: 80
    targetPort: 80
```

```sh
kubectl apply -f whoami.yaml
```

---

### Étape 4 : Créer l'Ingress avec annotation cert-manager

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: whoami-ingress
  namespace: default
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-staging"
spec:
  tls:
  - hosts:
    - whoami.votre-domaine.com
    secretName: whoami-tls
  rules:
  - host: whoami.votre-domaine.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: whoami
            port:
              number: 80
```

```sh
kubectl apply -f ingress.yaml
```

---

### Étape 5 : Suivre l'émission du certificat

```sh
# Observer la création du Certificate
kubectl describe certificate whoami-tls

# Observer le CertificateRequest
kubectl get certificaterequest

# Observer le Challenge ACME
kubectl get challenge

# Observer l'Order ACME
kubectl get order
```

En quelques minutes, le certificat passe de l'état `False` à `True` :

```sh
kubectl get certificate whoami-tls -w
# NAME        READY   SECRET       AGE
# whoami-tls  True    whoami-tls   2m
```

---

### Étape 6 : Passer en production

Une fois le staging validé, créer le ClusterIssuer production :

```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: votre-email@domaine.com
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: traefik
```

Mettre à jour l'annotation de l'Ingress :

```sh
kubectl annotate ingress whoami-ingress \
  cert-manager.io/cluster-issuer=letsencrypt-prod --overwrite
```

---

### Points à explorer

- Que se passe-t-il si le DNS ne pointe pas encore correctement ?
- Inspecter le contenu du Secret TLS : `kubectl get secret whoami-tls -o yaml`
- Tester le renouvellement automatique en simulant une expiration proche
- Comparer avec un `Issuer` (namespace-scoped) vs `ClusterIssuer` (cluster-wide)

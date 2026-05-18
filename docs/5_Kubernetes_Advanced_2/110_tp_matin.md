---
title: "TP Matin - Certificats TLS automatiques avec cert-manager"
draft: false
---

## TP — HTTPS automatique avec cert-manager et Let's Encrypt

**Installer cert-manager, configurer un ClusterIssuer Let's Encrypt, déployer une application avec un Ingress TLS et observer la chaîne d'émission du certificat.**

### Objectif

À la fin de ce TP, vous aurez :
- Installé cert-manager et ses CRDs
- Créé un `ClusterIssuer` Let's Encrypt (staging puis production)
- Déployé `rancher-demo` avec 3 replicas et un Ingress TLS
- Observé la chaîne cert-manager : `Certificate` → `CertificateRequest` → `Order` → `Challenge`
- Accédé à l'application en HTTPS

### Prérequis

- Un cluster Kubernetes k3s avec Traefik (inclus par défaut)
- Votre DNS de lab : `<VIRTUAL_LAB_DNS>` — remplacez cette valeur par votre hostname réel partout dans ce TP (ex: `sacha.brx2022.uptime-formation.fr`)

---

## Étape 1 : Installer cert-manager

cert-manager est distribué comme un ensemble de manifestes officiels. Il installe ses propres CRDs et trois composants.

- **Action** :

```bash
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/latest/download/cert-manager.yaml

# Attendre que les 3 composants soient Ready
kubectl rollout status deployment/cert-manager -n cert-manager --timeout=120s
kubectl rollout status deployment/cert-manager-cainjector -n cert-manager --timeout=120s
kubectl rollout status deployment/cert-manager-webhook -n cert-manager --timeout=120s
```

- **Observation** : Trois pods Running dans le namespace `cert-manager` :

```bash
kubectl get pods -n cert-manager
```

```
NAME                                      READY   STATUS
cert-manager-...                          1/1     Running
cert-manager-cainjector-...               1/1     Running
cert-manager-webhook-...                  1/1     Running
```

Vérifiez les CRDs installées :

```bash
kubectl get crd | grep cert-manager.io
```

Les CRDs clés : `certificates`, `certificaterequests`, `clusterissuers`, `challenges`, `orders` — chaque étape du cycle de vie d'un certificat a sa propre ressource Kubernetes.

---

## Étape 2 : Créer les ClusterIssuers Let's Encrypt

Un `ClusterIssuer` définit **comment** cert-manager doit obtenir des certificats. On crée toujours staging et production en parallèle — staging sert à valider la configuration sans risquer les rate limits de production.

- **Action** :

```yaml
# clusterissuers.yaml
---
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
---
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

```bash
kubectl apply -f clusterissuers.yaml
sleep 5
kubectl get clusterissuer
```

- **Observation** : Les deux `ClusterIssuer` passent en `READY: True` en quelques secondes — cert-manager s'est enregistré auprès des serveurs ACME Let's Encrypt.

```bash
kubectl describe clusterissuer letsencrypt-staging | grep -A 5 "Conditions:"
# Message: The ACME account was registered with the ACME server
```

> Le challenge `http01` signifie que Let's Encrypt va vérifier que vous contrôlez le domaine en effectuant une requête HTTP sur `http://<VIRTUAL_LAB_DNS>/.well-known/acme-challenge/<token>`. cert-manager crée automatiquement un pod et un Ingress temporaires pour répondre à ce challenge.

---

## Étape 3 : Déployer rancher-demo avec Ingress TLS

- **Action** : Remplacez `<VIRTUAL_LAB_DNS>` par votre hostname de lab, puis appliquez :

```yaml
# rancher-demo.yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: rancher-demo
  namespace: default
spec:
  replicas: 3
  selector:
    matchLabels:
      app: rancher-demo
  template:
    metadata:
      labels:
        app: rancher-demo
    spec:
      containers:
      - name: rancher-demo
        image: monachus/rancher-demo:latest
        ports:
        - containerPort: 8080
        resources:
          requests:
            cpu: 50m
            memory: 32Mi
          limits:
            cpu: 200m
            memory: 64Mi
---
apiVersion: v1
kind: Service
metadata:
  name: rancher-demo
  namespace: default
spec:
  selector:
    app: rancher-demo
  ports:
  - port: 80
    targetPort: 8080
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: rancher-demo
  namespace: default
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-staging"   # ← déclenche cert-manager
spec:
  ingressClassName: traefik
  tls:
  - hosts:
    - <VIRTUAL_LAB_DNS>        # REMPLACER
    secretName: rancher-demo-tls
  rules:
  - host: <VIRTUAL_LAB_DNS>   # REMPLACER
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: rancher-demo
            port:
              number: 80
```

```bash
kubectl apply -f rancher-demo.yaml
kubectl rollout status deployment/rancher-demo --timeout=60s
```

<details><summary>Indice — je ne sais pas où remplacer &lt;VIRTUAL_LAB_DNS&gt;</summary>

Il y a 3 occurrences à remplacer dans le fichier YAML : dans `spec.tls[0].hosts[0]`, dans `spec.rules[0].host`, et dans le commentaire. Cherchez `<VIRTUAL_LAB_DNS>` dans le fichier avec `grep`.

Votre DNS de lab vous est communiqué au démarrage de la session — il ressemble à `prenom.brxYYYY.uptime-formation.fr`.

</details>

- **Observation** : L'annotation `cert-manager.io/cluster-issuer` sur l'Ingress suffit à déclencher cert-manager — il détecte l'Ingress, crée automatiquement un objet `Certificate` et lance le processus d'émission.

```bash
kubectl get certificate -n default
# NAME               READY   SECRET             AGE
# rancher-demo-tls   False   rancher-demo-tls   5s   ← False le temps du challenge
```

---

## Étape 4 : Observer la chaîne d'émission

cert-manager décompose l'émission d'un certificat en plusieurs objets Kubernetes — chacun peut être inspecté indépendamment.

- **Action** :

```bash
# La ressource de haut niveau
kubectl describe certificate rancher-demo-tls -n default

# La demande de signature
kubectl get certificaterequest -n default

# L'ordre ACME passé à Let's Encrypt
kubectl get order -n default

# Le challenge HTTP01 (visible pendant l'émission, disparaît après)
kubectl get challenge -n default

# La séquence complète dans les events
kubectl get events -n default --sort-by='.lastTimestamp' | grep -i cert
```

<details><summary>Indice — le challenge reste en &lt;pending&gt; depuis plusieurs minutes</summary>

Vérifiez que votre DNS pointe bien vers l'IP publique du cluster :

```bash
dig <VIRTUAL_LAB_DNS> +short
# doit retourner l'IP de votre lab
```

Si le DNS ne résout pas encore, le serveur ACME ne peut pas atteindre le pod solver créé par cert-manager. Attendez la propagation DNS (peut prendre quelques minutes), puis vérifiez l'état du challenge :

```bash
kubectl describe challenge -n default
# Section "Events" — le message d'erreur indique la cause exacte
```

</details>

- **Observation** : La séquence d'events montre le cycle complet :

```
CreateCertificate    ingress/rancher-demo      Successfully created Certificate
OrderCreated         certificaterequest/...    Created Order resource
Presented            challenge/...             Presented challenge using HTTP-01
DomainVerified       challenge/...             Domain "<VIRTUAL_LAB_DNS>" verified
Issuing              certificate/...           The certificate has been successfully issued
Complete             order/...                 Order completed successfully
```

Quand `kubectl get certificate rancher-demo-tls` affiche `READY: True`, le Secret TLS est créé :

```bash
kubectl get secret rancher-demo-tls -o jsonpath='{.data.tls\.crt}' | base64 -d | openssl x509 -noout -dates -issuer
# issuer=CN=(...Let's Encrypt...)
# notAfter=... (90 jours)
```

---

## Étape 5 : Inspecter le certificat émis

- **Action** :

```bash
# Vérifier le contenu du Secret TLS créé par cert-manager
kubectl get secret rancher-demo-tls -o jsonpath='{.data.tls\.crt}' | base64 -d | openssl x509 -noout -dates -issuer
```

- **Observation** : Le certificat est signé par la CA staging de Let's Encrypt, valide 90 jours. L'issuer indique `(STAGING)` — normal pour un lab.

> **En production**, on utiliserait `letsencrypt-prod` dès le départ. Le passage de staging à prod se fait en changeant une seule annotation sur l'Ingress — cert-manager détecte le changement et renouvelle le certificat automatiquement :
> ```bash
> kubectl annotate ingress rancher-demo \
>   cert-manager.io/cluster-issuer=letsencrypt-prod --overwrite
> ```
> Le certificat prod est valide 90 jours et se renouvelle automatiquement à 2/3 de sa durée de vie — sans intervention manuelle.

---

## Questions de réflexion

- Quelle est la différence entre un `Issuer` (namespace-scoped) et un `ClusterIssuer` ?
- Pourquoi utiliser staging avant production ? Quels sont les rate limits de Let's Encrypt prod ?
- Que se passe-t-il si le DNS de votre lab ne pointe pas encore vers le cluster au moment du challenge ?
- Comment cert-manager sait-il que le certificat doit être renouvelé ?

---

## Nettoyage

```bash
kubectl delete ingress rancher-demo
kubectl delete deployment,svc rancher-demo
kubectl delete secret rancher-demo-tls
kubectl delete clusterissuer letsencrypt-staging letsencrypt-prod
kubectl delete -f https://github.com/cert-manager/cert-manager/releases/latest/download/cert-manager.yaml
```

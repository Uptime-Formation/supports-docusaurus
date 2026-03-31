---
title: "TP Après-midi - Service Mesh & Secrets"
draft: false
---

<!-- TPs FOURNIS PAR L'UTILISATEUR — intégrer quand disponible -->

## TP Istio : mTLS avec l'application Bookinfo

<!-- À REPRENDRE EXISTANT : 5_Kubernetes-Advanced/230-Run2-Service-Mesh.md ## TP Istio -->

**Installer Istio avec mTLS activé par défaut et vérifier que les flux entre microservices sont chiffrés.**

### Prérequis

- Un cluster Kubernetes fonctionnel
- `istioctl` installé
- `kubectl` configuré

---

### Étape 1 : Installer Istio

```bash
# Télécharger Istio
curl -L https://istio.io/downloadIstio | sh -
cd istio-*
export PATH=$PWD/bin:$PATH

# Installer avec le profil demo (mTLS activé par défaut)
istioctl install --set profile=demo --set values.global.controlPlaneSecurityEnabled=true

# Vérifier l'installation
kubectl get pods -n istio-system
```

Tous les pods dans `istio-system` doivent être en état `Running`.

---

### Étape 2 : Déployer l'application Bookinfo

```bash
# Activer l'injection automatique du sidecar Envoy
kubectl label namespace default istio-injection=enabled

# Déployer Bookinfo
kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml

# Exposer via Istio Gateway
kubectl apply -f samples/bookinfo/networking/bookinfo-gateway.yaml

# Vérifier les services
kubectl get services
kubectl get pods
```

Les services `productpage`, `details`, `reviews`, `ratings` doivent être déployés.

---

### Étape 3 : Vérifier que mTLS est actif

```bash
# Vérifier la PeerAuthentication par défaut
kubectl get peerauthentication -n istio-system

# Le mode doit être STRICT
kubectl describe peerauthentication -n istio-system
```

---

### Étape 4 : Accéder à l'application

```bash
# Récupérer l'IP du gateway Istio
kubectl get svc istio-ingressgateway -n istio-system

# Tester l'application
curl -s http://<EXTERNAL-IP>/productpage | grep -o "<title>.*</title>"
```

---

### Étape 5 : Vérifier le chiffrement mTLS entre services

```bash
# Vérifier les flux TLS entre pods
# Remplacer <source-pod> par le nom réel du pod productpage
istioctl authn tls-check <source-pod> details.default.svc.cluster.local
istioctl authn tls-check <source-pod> reviews.default.svc.cluster.local
istioctl authn tls-check <source-pod> ratings.default.svc.cluster.local
```

La colonne `TLS mode` doit afficher `mutual` pour chaque service.

---

### Étape 6 : Tester une politique d'autorisation

Refuser tout accès sauf depuis `productpage` :

```yaml
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: allow-productpage-to-details
  namespace: default
spec:
  selector:
    matchLabels:
      app: details
  rules:
  - from:
    - source:
        principals: ["cluster.local/ns/default/sa/bookinfo-productpage"]
    to:
    - operation:
        methods: ["GET"]
```

```bash
kubectl apply -f authpolicy.yaml

# Vérifier que productpage peut accéder à details
curl -s http://<EXTERNAL-IP>/productpage

# Tenter un accès direct depuis un pod non autorisé
kubectl exec -it deploy/reviews -- curl http://details:9080/details/0
# Doit retourner 403 Forbidden
```

---

### Points à explorer

- Installer Kiali pour visualiser le graphe de services et les flux mTLS
- Tester un canary deployment via `VirtualService` et `DestinationRule`
- Observer l'impact en ressources des sidecars (CPU/mémoire par pod)
- Comparer les latences avec et sans service mesh (`kubectl top pods`)

---

## TP Vault : Gestion des secrets dans Kubernetes

<!-- À REPRENDRE EXISTANT : 5_Kubernetes-Advanced/330-Security.md ## TP Vault -->

**Mettre en place HashiCorp Vault pour la gestion des secrets dans un cluster Kubernetes en utilisant le Vault Operator.**

Référence : https://developer.hashicorp.com/vault/tutorials/kubernetes/vault-secrets-operator

### Prérequis

- Un cluster Kubernetes fonctionnel
- `helm` installé
- `vault` CLI installé

---

### Étape 1 : Installer Vault via Helm

```sh
helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update

# Installer Vault en mode dev (pour le TP uniquement)
helm install vault hashicorp/vault \
  --namespace vault \
  --create-namespace \
  --set "server.dev.enabled=true"

# Vérifier l'installation
kubectl get pods -n vault
```

---

### Étape 2 : Configurer l'authentification Kubernetes

```sh
# Se connecter au pod Vault
kubectl exec -it vault-0 -n vault -- /bin/sh

# Dans le pod Vault :
# Activer l'auth Kubernetes
vault auth enable kubernetes

# Configurer le backend Kubernetes
vault write auth/kubernetes/config \
  kubernetes_host="https://$KUBERNETES_PORT_443_TCP_ADDR:443"

exit
```

---

### Étape 3 : Créer un secret dans Vault

```sh
# Accéder au pod Vault
kubectl exec -it vault-0 -n vault -- /bin/sh

# Activer le moteur KV v2
vault secrets enable -path=secret kv-v2

# Créer un secret
vault kv put secret/app/config \
  username="admin" \
  password="monmotdepasse"

# Vérifier
vault kv get secret/app/config

exit
```

---

### Étape 4 : Installer le Vault Secrets Operator

```sh
helm install vault-secrets-operator hashicorp/vault-secrets-operator \
  --namespace vault-secrets-operator-system \
  --create-namespace \
  --set defaultVaultConnection.enabled=true \
  --set defaultVaultConnection.address="http://vault.vault.svc.cluster.local:8200"
```

---

### Étape 5 : Créer une politique et un rôle Vault

```sh
kubectl exec -it vault-0 -n vault -- /bin/sh

# Créer la politique d'accès
vault policy write app-policy - <<EOF
path "secret/data/app/config" {
  capabilities = ["read"]
}
EOF

# Créer le rôle Kubernetes
vault write auth/kubernetes/role/app-role \
  bound_service_account_names=app-sa \
  bound_service_account_namespaces=default \
  policies=app-policy \
  ttl=24h

exit
```

---

### Étape 6 : Synchroniser le secret vers Kubernetes

```yaml
# VaultAuth — connexion au Vault
apiVersion: secrets.hashicorp.com/v1beta1
kind: VaultAuth
metadata:
  name: app-vault-auth
  namespace: default
spec:
  method: kubernetes
  mount: kubernetes
  kubernetes:
    role: app-role
    serviceAccount: app-sa
---
# VaultStaticSecret — synchronisation du secret
apiVersion: secrets.hashicorp.com/v1beta1
kind: VaultStaticSecret
metadata:
  name: app-config
  namespace: default
spec:
  type: kv-v2
  mount: secret
  path: app/config
  destination:
    name: app-config-secret
    create: true
  vaultAuthRef: app-vault-auth
  refreshAfter: 30s
```

```sh
# Créer le ServiceAccount
kubectl create serviceaccount app-sa

# Appliquer les ressources
kubectl apply -f vault-secret.yaml

# Vérifier que le Kubernetes Secret a été créé
kubectl get secret app-config-secret -o yaml
```

---

### Étape 7 : Utiliser le secret dans un pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-pod
spec:
  serviceAccountName: app-sa
  containers:
  - name: app
    image: busybox
    command: ["sh", "-c", "echo username=$USERNAME && sleep 3600"]
    env:
    - name: USERNAME
      valueFrom:
        secretKeyRef:
          name: app-config-secret
          key: username
    - name: PASSWORD
      valueFrom:
        secretKeyRef:
          name: app-config-secret
          key: password
```

```sh
kubectl apply -f app-pod.yaml
kubectl logs app-pod
```

---

### Points à explorer

- Modifier le secret dans Vault et observer le Secret Kubernetes se mettre à jour automatiquement après `refreshAfter`
- Activer l'audit dans Vault : `vault audit enable file file_path=/vault/logs/audit.log`
- Comparer avec External Secrets Operator (autre approche pour le même besoin)
- Tester la révocation d'accès en supprimant le rôle Vault

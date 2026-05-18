---
title: "TP Après-midi - Secrets : chiffrement etcd et Vault"
draft: false
---

## TP — Gestion des secrets : du base64 à Vault

**Comprendre pourquoi les Kubernetes Secrets natifs ne sont pas sécurisés par défaut, activer le chiffrement at-rest dans etcd, puis mettre en place Vault comme gestionnaire centralisé avec rotation automatique.**

### Objectif

À la fin de ce TP, vous aurez :
- Observé qu'un secret Kubernetes est lisible en clair dans etcd sans chiffrement
- Réinstallé k3s avec chiffrement activé et vérifié que les secrets sont opaques dans etcd
- Déployé Vault en mode dev et créé un secret via son API
- Installé le Vault Secrets Operator et synchronisé un secret Vault vers un Kubernetes Secret
- Déployé un pod qui consomme le secret en variable d'environnement
- Observé la rotation automatique du secret sans redéploiement

### Prérequis

- Un cluster k3s fonctionnel
- `helm` installé
- `etcdctl` sera installé dans le TP

---

## Étape 1 : Installer k3s avec etcd et observer les secrets en clair

Par défaut, k3s utilise SQLite comme datastore. Pour pouvoir inspecter etcd directement, on démarre k3s avec `--cluster-init` qui active etcd.

- **Action** : Réinstaller k3s proprement avec etcd.

```bash
# Désinstaller k3s existant
/usr/local/bin/k3s-uninstall.sh

# Réinstaller avec etcd (sans chiffrement pour l'instant)
curl -sfL https://get.k3s.io | sh -s - --cluster-init

# Attendre que le nœud soit Ready
until kubectl get nodes 2>/dev/null | grep -q Ready; do sleep 3; done
kubectl get nodes
```

- **Observation** : Le nœud a le rôle `control-plane,etcd` — etcd est actif.

Installer `etcdctl` pour interroger etcd directement :

```bash
ETCD_VERSION="v3.5.5"
curl -sL "https://github.com/etcd-io/etcd/releases/download/${ETCD_VERSION}/etcd-${ETCD_VERSION}-linux-amd64.tar.gz" \
  | tar -zxv --strip-components=1 -C /usr/local/bin etcd-${ETCD_VERSION}-linux-amd64/etcdctl
```

---

## Étape 2 : Créer un secret et lire sa valeur dans etcd

- **Action** :

```bash
kubectl create secret generic db-credentials \
  --from-literal=username=admin \
  --from-literal=password=S3cr3tP@ssw0rd
```

Lire le secret via kubectl — on voit la valeur encodée en base64 :

```bash
kubectl get secret db-credentials -o jsonpath='{.data.password}' | base64 -d
```

Maintenant lire directement dans etcd :

```bash
ETCDCTL_API=3 etcdctl \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/var/lib/rancher/k3s/server/tls/etcd/server-ca.crt \
  --cert=/var/lib/rancher/k3s/server/tls/etcd/client.crt \
  --key=/var/lib/rancher/k3s/server/tls/etcd/client.key \
  get /registry/secrets/default/db-credentials | strings
```

- **Observation** : Le mot de passe `S3cr3tP@ssw0rd` et le nom d'utilisateur `admin` apparaissent **en clair** dans etcd. Le base64 de kubectl n'est pas du chiffrement — c'est juste un encodage. Toute personne ayant accès à etcd peut lire tous les secrets du cluster.

---

## Étape 3 : Réinstaller avec chiffrement activé

- **Action** :

```bash
/usr/local/bin/k3s-uninstall.sh

curl -sfL https://get.k3s.io | sh -s - --cluster-init --secrets-encryption

until kubectl get nodes 2>/dev/null | grep -q Ready; do sleep 3; done
```

Vérifier que le chiffrement est actif :

```bash
k3s secrets-encrypt status
```

- **Observation** :

```
Encryption Status: Enabled
Current Rotation Stage: start
Active  Key Type  Name
------  --------  ----
 *      AES-CBC   aescbckey
```

Créer le même secret et lire dans etcd :

```bash
kubectl create secret generic db-credentials \
  --from-literal=username=admin \
  --from-literal=password=S3cr3tP@ssw0rd

ETCDCTL_API=3 etcdctl \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/var/lib/rancher/k3s/server/tls/etcd/server-ca.crt \
  --cert=/var/lib/rancher/k3s/server/tls/etcd/client.crt \
  --key=/var/lib/rancher/k3s/server/tls/etcd/client.key \
  get /registry/secrets/default/db-credentials | strings | head -5
```

- **Observation** : La valeur commence par `k8s:enc:aescbc:v1:aescbckey:` suivie de données illisibles. Le contenu est chiffré avec AES-CBC — même avec un accès direct à etcd, le secret est protégé.

> Le chiffrement at-rest protège contre l'accès direct à la base de données etcd, mais **pas** contre un attaquant qui a accès à l'API Kubernetes — `kubectl get secret` fonctionne toujours. Pour un contrôle plus fin (audit, rotation, politiques d'accès), il faut Vault.

---

## Étape 4 : Déployer Vault en mode dev

Vault en mode dev démarre déverrouillé avec un token root fixe — pratique pour un TP, jamais en production.

- **Action** :

```bash
helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update

helm upgrade --install vault hashicorp/vault \
  --namespace vault \
  --create-namespace \
  --set "server.dev.enabled=true" \
  --set "server.dev.devRootToken=root"

kubectl wait pod/vault-0 -n vault --for=condition=Ready --timeout=120s
kubectl get pods -n vault
```

- **Observation** : Vault et son agent injector sont Running. Créer un secret via l'API Vault :

```bash
kubectl exec -n vault vault-0 -- vault kv put secret/app/db \
  username=admin \
  password=S3cr3tP@ssw0rd

kubectl exec -n vault vault-0 -- vault kv get secret/app/db
```

Le secret est stocké dans Vault avec métadonnées (version, timestamp) — Vault garde l'historique de toutes les versions.

<details><summary>Indice — vault kv get retourne une erreur de permission</summary>

En mode dev, le token root est `root`. Si vous obtenez une erreur d'authentification, exportez le token :

```bash
kubectl exec -n vault vault-0 -- env VAULT_TOKEN=root vault kv get secret/app/db
```

</details>

---

## Étape 5 : Vault Secrets Operator — synchroniser vers un K8s Secret

Le Vault Secrets Operator (VSO) est un operator Kubernetes qui surveille des CRDs `VaultStaticSecret` et les synchronise automatiquement vers des Kubernetes Secrets natifs. Les pods n'ont pas besoin de parler à Vault directement.

- **Action** : Installer VSO et configurer l'authentification Kubernetes.

```bash
helm upgrade --install vault-secrets-operator hashicorp/vault-secrets-operator \
  --namespace vault-secrets-operator-system \
  --create-namespace \
  --set defaultVaultConnection.enabled=true \
  --set defaultVaultConnection.address="http://vault.vault.svc.cluster.local:8200"

kubectl rollout status deployment/vault-secrets-operator-controller-manager \
  -n vault-secrets-operator-system --timeout=120s
```

Configurer le backend Kubernetes dans Vault (politique + rôle) :

```bash
kubectl exec -n vault vault-0 -- sh -c '
vault auth enable kubernetes 2>/dev/null || true
vault write auth/kubernetes/config \
  kubernetes_host="https://$KUBERNETES_PORT_443_TCP_ADDR:443"
vault policy write app-policy - <<EOF
path "secret/data/app/db" {
  capabilities = ["read"]
}
EOF
vault write auth/kubernetes/role/app-role \
  bound_service_account_names=app-sa \
  bound_service_account_namespaces=default \
  policies=app-policy \
  ttl=24h
'
```

Créer le ServiceAccount et les ressources VSO :

```yaml
# vso-resources.yaml
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: app-sa
  namespace: default
---
apiVersion: secrets.hashicorp.com/v1beta1
kind: VaultConnection
metadata:
  name: vault-connection
  namespace: default
spec:
  address: http://vault.vault.svc.cluster.local:8200
---
apiVersion: secrets.hashicorp.com/v1beta1
kind: VaultAuth
metadata:
  name: app-vault-auth
  namespace: default
spec:
  method: kubernetes
  mount: kubernetes
  vaultConnectionRef: vault-connection
  kubernetes:
    role: app-role
    serviceAccount: app-sa
---
apiVersion: secrets.hashicorp.com/v1beta1
kind: VaultStaticSecret
metadata:
  name: app-db-secret
  namespace: default
spec:
  type: kv-v2
  mount: secret
  path: app/db
  destination:
    name: app-db-credentials
    create: true
  vaultAuthRef: app-vault-auth
  refreshAfter: 30s
```

```bash
kubectl apply -f vso-resources.yaml
sleep 10
kubectl get secret app-db-credentials -n default
kubectl get secret app-db-credentials -o jsonpath='{.data.password}' | base64 -d
```

- **Observation** : VSO a créé automatiquement le Kubernetes Secret `app-db-credentials` en synchronisant depuis Vault. Dans Git, on ne stocke que la référence (`path: app/db`) — jamais la valeur.

<details><summary>Indice — le K8s Secret n'apparaît pas après 10 secondes</summary>

Vérifier l'état du VaultStaticSecret :

```bash
kubectl describe vaultstaticsecret app-db-secret
# Section "Events" — indique la cause de l'échec (auth, path, etc.)

# Vérifier que le VaultAuth est valide
kubectl describe vaultauth app-vault-auth
```

</details>

---

## Étape 6 : Pod consommant le secret + rotation automatique

- **Action** :

```yaml
# app-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-pod
  namespace: default
spec:
  serviceAccountName: app-sa
  containers:
  - name: app
    image: busybox
    command: ["sh", "-c", "echo DB_USER=$DB_USERNAME && echo DB_PASS=$DB_PASSWORD && sleep 3600"]
    env:
    - name: DB_USERNAME
      valueFrom:
        secretKeyRef:
          name: app-db-credentials
          key: username
    - name: DB_PASSWORD
      valueFrom:
        secretKeyRef:
          name: app-db-credentials
          key: password
```

```bash
kubectl apply -f app-pod.yaml
kubectl wait pod/app-pod --for=condition=Ready --timeout=60s
kubectl logs app-pod
```

- **Observation** : Le pod affiche `DB_PASS=S3cr3tP@ssw0rd` — il a reçu la valeur depuis le K8s Secret synchronisé par VSO.

Maintenant modifiez le secret dans Vault et observez la rotation automatique :

```bash
# Modifier le secret dans Vault
kubectl exec -n vault vault-0 -- vault kv put secret/app/db \
  username=admin \
  password=N3wP@ssw0rd_2026

# Attendre le refresh (refreshAfter: 30s)
sleep 35

# Le K8s Secret est mis à jour automatiquement
kubectl get secret app-db-credentials -o jsonpath='{.data.password}' | base64 -d
```

- **Observation** : Le Kubernetes Secret contient maintenant `N3wP@ssw0rd_2026` — sans aucune intervention manuelle.

> **Limite importante** : les variables d'environnement d'un pod sont fixées au démarrage. Le pod `app-pod` voit toujours l'ancienne valeur — il faut le redémarrer pour qu'il lise la nouvelle. Les secrets montés en **volume** peuvent être relus dynamiquement, mais cela demande que l'application surveille le fichier. C'est la même contrainte avec les ConfigMaps mis à jour dynamiquement.

---

## Questions de réflexion

- Quelle est la différence entre un secret en base64 et un secret chiffré dans etcd ?
- Pourquoi le chiffrement at-rest seul ne suffit pas pour une sécurité complète des secrets ?
- Que se passe-t-il si le pod Vault redémarre en mode dev ? Les secrets sont-ils perdus ?
- Comment VSO sait-il que le secret Vault a changé pour déclencher la synchronisation ?

---

## Nettoyage

```bash
kubectl delete pod app-pod
kubectl delete -f vso-resources.yaml
helm uninstall vault-secrets-operator -n vault-secrets-operator-system
helm uninstall vault -n vault
kubectl delete namespace vault vault-secrets-operator-system
```

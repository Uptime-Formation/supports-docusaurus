---
title: "TP Matin - Premiers pas avec kubectl"
draft: false
---

**Installer Kubernetes, explorer le cluster et déployer un premier pod.**

**Durée : ~2h**

### Contexte

Votre environnement de lab est un VPS Ubuntu. Vous allez installer k3s, découvrir les commandes de base de kubectl, et déployer votre premier pod Kubernetes.

---

## Focus

- ✅ **Installation de k3s** : Mettre en place un cluster Kubernetes léger
- ✅ **kubeconfig** : Comprendre et afficher la configuration de connexion au cluster
- ✅ **kubectl** : Maîtriser les commandes de base (get, describe, run, delete, logs, exec)
- ✅ **Namespaces** : Créer et utiliser un namespace dédié
- ✅ **Premier pod** : Déployer, inspecter et supprimer un pod

---

## Objectif

- ✅ k3s installé et accessible via kubectl
- ✅ kubeconfig affiché et compris
- ✅ Namespace `mynamespace` créé
- ✅ Pod `ubuntu` déployé, inspecté, puis supprimé

---

## Tips : alias kubectl

```shell
# File: .bash_aliases
alias k='kubectl'
alias kcon='kubectl config get-contexts'
alias kx='kubectl config use-context'
alias kn='kubectl config set-context --current --namespace'
alias kg='kubectl get'
alias kdesc='kubectl describe'
alias ka='kubectl apply -f'
alias kc='kubectl create'
alias kdel='kubectl delete'
alias kev='kubectl get events --sort-by .lastTimestamp'
alias kl='kubectl logs'
export yaml='--dry-run=client -o yaml'
export now='--grace-period 0 --force'
```

```shell
source .bash_aliases
```

---

## Étape 1 - Installer k3s

**Objectif** : Avoir un cluster Kubernetes opérationnel.

- **Action** : Installer k3s via le script officiel
  **Observation** : La commande `kubectl get nodes` retourne un node en état `Ready`

- **Action** : Vérifier les versions client et serveur
  **Observation** : `kubectl version` affiche les deux versions — elles devraient être dans la même version mineure (ex: `1.28.x`)

<details><summary>Indice</summary>

```bash
# Sur ubuntu, supprimer le kubectl snap si présent
sudo rm /snap/bin/kubectl

curl -sfL https://get.k3s.io | sudo sh -

kubectl get nodes
kubectl version
```

</details>

---

## Étape 2 - Configurer bash completion et alias

**Objectif** : Travailler efficacement en ligne de commande.

- **Action** : Installer l'autocomplétion kubectl et les alias du tips ci-dessus
  **Observation** : La touche `<Tab>` complète les commandes et noms de ressources kubectl

<details><summary>Indice</summary>

```bash
sudo apt install bash-completion
source <(kubectl completion bash)
echo "source <(kubectl completion bash)" >> ${HOME}/.bashrc
```

La liste complète des raccourcis : https://blog.heptio.com/kubectl-resource-short-names-heptioprotip-c8eff9fb7202

</details>

---

## Étape 3 - Explorer le cluster

**Objectif** : Comprendre la structure d'un cluster Kubernetes.

- **Action** : Afficher le kubeconfig
  **Observation** : Le fichier indique le cluster, l'utilisateur et le contexte courant. Repérez l'adresse de l'API server et le certificat.

- **Action** : Lister les nodes et leurs caractéristiques
  **Observation** : `kubectl describe node/<nom>` montre les ressources disponibles, les labels, et les pods qui tournent dessus

- **Action** : Lister tous les namespaces, puis toutes les ressources de `kube-system`
  **Observation** : Le namespace `kube-system` contient les composants internes de Kubernetes eux-mêmes sous forme de pods

- **Action** : Lister toutes les ressources de tous les namespaces
  **Observation** : `kubectl get all -A` montre tout le cluster

<details><summary>Indice</summary>

```bash
kubectl config view
kubectl get nodes
kubectl describe node/<nom-du-node>
kubectl get namespaces
kubectl get all -n kube-system
kubectl get all -A
kubectl describe namespace/kube-system
```

</details>

---

## Étape 4 - Créer un namespace

**Objectif** : Isoler vos ressources dans un espace dédié.

- **Action** : Créer le namespace `mynamespace`
  **Observation** : Il apparaît dans `kubectl get namespaces`

<details><summary>Indice</summary>

```bash
kubectl create namespace mynamespace
```

</details>

---

## Étape 5 - Déployer une application en CLI

**Objectif** : Créer et explorer un déploiement impératif.

- **Action** : Créer un déploiement `demonstration` avec l'image `monachus/rancher-demo`
  **Observation** : `kubectl describe deployment/demonstration` montre les événements de création

- **Action** : Scaler le déploiement à 5 réplicas
  **Observation** : `kubectl get pods` montre 5 pods, les événements de scaling apparaissent dans le describe

- **Action** : Exposer le déploiement via un service NodePort sur le port 8080
  **Observation** : `kubectl get services` montre le service avec un port 3xxxx assigné

<details><summary>Indice</summary>

```bash
kubectl create deployment demonstration --image=monachus/rancher-demo
kubectl describe deployment/demonstration
kubectl get pods

kubectl scale deployment demonstration --replicas=5
kubectl describe deployment/demonstration

kubectl expose deployment demonstration --type=NodePort --port=8080 --name=demonstration-service
kubectl get services
```

</details>

---

## Étape 6 - Déployer et inspecter un pod dans votre namespace

**Objectif** : Créer, observer, exécuter des commandes dans et supprimer un pod.

- **Action** : Lancer un pod `ubuntu` avec l'image `ubuntu:latest` dans `mynamespace`, commande `tail -f /dev/null`
  **Observation** : Le pod est en état `Running` dans `kubectl get pod -n mynamespace`

- **Action** : Inspecter le pod avec `get` et `describe`
  **Observation** : `describe` montre les événements, l'image, le node, les conditions du pod

- **Action** : Afficher le manifeste YAML complet du pod
  **Observation** : Le YAML généré décrit l'état complet tel que Kubernetes le voit

- **Action** : Supprimer le pod
  **Observation** : Le pod disparaît de la liste

<details><summary>Indice</summary>

```bash
kubectl run ubuntu --image=ubuntu:latest --namespace mynamespace -- tail -f /dev/null

kubectl get pod ubuntu -n mynamespace
kubectl describe pod ubuntu -n mynamespace
kubectl get pod ubuntu -n mynamespace -o yaml

# Filtrer une info précise avec jsonpath
kubectl get pod ubuntu -n mynamespace -o jsonpath='{.spec.containers[0].image}'

kubectl delete pod ubuntu -n mynamespace
```

</details>

---

## Étape 7 - Outils CLI supplémentaires

**Objectif** : Découvrir l'écosystème kubectl.

- **Action** : Installer `krew` (gestionnaire de plugins kubectl) puis `kubectx` et `kubens`
  **Observation** : `kubectx` liste vos contextes, `kubens` liste vos namespaces et permet d'en choisir un par défaut

<details><summary>Indice</summary>

```bash
# Installer krew : https://krew.sigs.k8s.io/docs/user-guide/setup/install/
kubectl krew install ctx
kubectl krew install ns

kubectx   # changer de cluster
kubens    # changer de namespace courant
```

</details>

---

### Avancé

- Relancer le pod sans `tail -f /dev/null`. Que se passe-t-il ? Pourquoi ?
- Utiliser `kubectl get pod ubuntu -o jsonpath='{.status.phase}'` pour filtrer l'état
- Lister tous les événements : `kubectl get events --sort-by .lastTimestamp -n mynamespace`
- Installer `viddy` (alternative à `watch`) pour observer l'évolution des ressources en temps réel
- Essayer `kubectl port-forward svc/demonstration-service 8080:8080` — quelle différence avec le NodePort ?

---

### Solution

<details><summary>Afficher</summary>

```bash
kubectl config view
kubectl create namespace mynamespace
kubectl run ubuntu --image=ubuntu:latest --namespace mynamespace -- tail -f /dev/null
kubectl get pod ubuntu --namespace mynamespace
kubectl describe pod ubuntu --namespace mynamespace
kubectl get pod ubuntu -o yaml --namespace mynamespace
kubectl delete pod ubuntu --namespace mynamespace
```

</details>

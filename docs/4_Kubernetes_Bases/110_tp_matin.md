---
title: "TP Matin - Premiers pas avec kubectl"
draft: false
---

## TP Matin

**Installer Kubernetes, explorer le cluster et déployer un premier pod.**

### Contexte

Votre environnement de lab est un VPS Ubuntu. Vous allez installer k3s, découvrir les commandes de base de kubectl, et déployer votre premier pod Kubernetes.

---

## Focus
 

- ✅ **kubeconfig** : Comprendre et afficher la configuration de connexion au cluster

- ✅ **kubectl** : Maîtriser les commandes de base (get, describe, run, delete, logs, exec)

- ✅ **Namespaces** : Créer et utiliser un namespace dédié

- ✅ **Premier pod** : Déployer, inspecter et supprimer un pod

- ✅ **k9s** : Explorer le cluster depuis une interface terminal

---

## Objectif

- ✅ k3s installé et accessible via kubectl

- ✅ kubeconfig affiché et compris

- ✅ Namespace `mynamespace` créé

- ✅ Pod `ubuntu` déployé, inspecté, puis supprimé

- ✅ k9s installé et utilisé pour naviguer dans le cluster

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

**Objectif** : Avoir un cluster Kubernetes opérationnel, piloté par `kubectl` **sans `sudo`**.

- **Action** : Installer k3s via le script officiel, en lui demandant d'écrire un kubeconfig lisible par votre utilisateur :

> `curl -sfL https://get.k3s.io | sudo sh -s - --write-kubeconfig-mode 644`

  **Observation** : le fichier `/etc/rancher/k3s/k3s.yaml` existe et est lisible (`ls -l /etc/rancher/k3s/k3s.yaml` → `-rw-r--r--`)

- **Action** : Indiquer à `kubectl` où trouver ce kubeconfig grâce à la variable d'environnement `KUBECONFIG`, et rendre ce réglage permanent  
  **Observation** : `kubectl get nodes` (sans `sudo`) retourne un node en état `Ready`, y compris dans un nouveau terminal

- **Action** : Vérifier les versions client et serveur  
  **Observation** : `kubectl version` affiche les deux versions — elles devraient être dans la même version mineure (ex: `1.28.x`)

<details><summary>Indice</summary>

> 💡 **Comment `kubectl` trouve-t-il son kubeconfig ?** Il regarde d'abord la variable d'environnement `KUBECONFIG` ; si elle n'est pas définie, il utilise `~/.kube/config`. k3s, lui, écrit son kubeconfig dans `/etc/rancher/k3s/k3s.yaml`. Il suffit donc de pointer `KUBECONFIG` vers ce fichier.

```bash
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
echo 'export KUBECONFIG=/etc/rancher/k3s/k3s.yaml' >> ~/.bashrc

kubectl get nodes
kubectl version
```

> ⚠️ Par défaut, k3s rend ce fichier lisible uniquement par `root` : sans l'option `--write-kubeconfig-mode 644`, `kubectl` renverrait une erreur `permission denied`. Si k3s est déjà installé, corrigez simplement les droits : `sudo chmod 644 /etc/rancher/k3s/k3s.yaml`.
>
> Ce fichier contient les identifiants **administrateur** du cluster : le rendre lisible par tous est acceptable sur un VPS de lab mono-utilisateur, pas sur une machine partagée.

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
echo $KUBECONFIG
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

## Étape 5 - Déployer et inspecter un pod dans votre namespace

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

## Étape 6 - Explorer le cluster avec k9s

**Objectif** : Découvrir [k9s](https://k9scli.io), une interface en mode terminal qui affiche les ressources du cluster en temps réel. k9s utilise le même kubeconfig que `kubectl` (variable `KUBECONFIG`).

- **Action** : Installer k9s à partir du paquet `.deb` publié sur GitHub  
  > https://github.com/derailed/k9s  
  **Observation** : `k9s version` affiche la version installée

- **Action** : Lancer `k9s`, puis afficher les pods de tous les namespaces (`:pod`)  
  **Observation** : La liste se met à jour en continu ; on retrouve les pods de `kube-system` vus à l'étape 3

<details><summary>Indice</summary>

```bash
# Installation sur Ubuntu (cf. https://github.com/derailed/k9s#installation)
wget https://github.com/derailed/k9s/releases/latest/download/k9s_linux_amd64.deb
sudo apt install ./k9s_linux_amd64.deb
rm k9s_linux_amd64.deb

k9s version
k9s
```

| Raccourci | Effet |
|---|---|
| `:pod`, `:deploy`, `:svc`, `:node`, `:ns` | Changer de type de ressource |
| `/` | Filtrer la liste |
| `d` | Décrire la ressource (`kubectl describe`) |
| `l` | Afficher les logs (pods) |
| `s` | Ouvrir un shell dans le conteneur (pods) |
| `ctrl-d` | Supprimer la ressource |
| `?` | Aide |
| `:q` | Quitter |

</details>

---

### Avancé

- Relancer le pod sans `tail -f /dev/null`. Que se passe-t-il ? Pourquoi ?

- Utiliser `kubectl get pod ubuntu -o jsonpath='{.status.phase}'` pour filtrer l'état

- Lister tous les événements : `kubectl get events --sort-by .lastTimestamp -n mynamespace`

- Installer `viddy` (alternative à `watch`) pour observer l'évolution des ressources en temps réel


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

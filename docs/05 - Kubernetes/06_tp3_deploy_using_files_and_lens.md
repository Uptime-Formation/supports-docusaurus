---
draft: false
title: "06 - TP 3 - Déployer en utilisant des fichiers ressource et Lens"
weight: 2045
---

Dans ce court TP nous allons redéployer notre application `demonstration` du TP1 mais cette fois en utilisant `kubectl apply -f` et en visualisant le résultat dans `Lens`.

- Changez de contexte pour k3s avec `kubectl config use-context k3s` ou `kubectl config use-context default`
- Chargez également la configuration de k3s dans `Lens` en cliquant à nouveau sur plus et en selectionnant `k3s` ou `default`
- Commencez par supprimer les ressources `demonstration` et `demonstration-service` du TP1
- Créez un dossier `TP2_deploy_using_files_and_Lens` sur le bureau de la machine distante et ouvrez le avec `VSCode`.

Nous allons d'abord déployer notre application comme un simple **Pod** (non recommandé mais montré ici pour l'exercice).

- Créez un fichier `demo-pod.yaml` avec à l'intérieur le code d'exemple du cours précédent de la partie Pods.
- Appliquez le fichier avec `kubectl apply -f <fichier>`.
- Constatez dans Lens dans la partie pods que les deux conteneurs du pod sont bien démarrés (deux petits carrés vert à droite de la ligne du pod)
- Modifiez l'étiquette (`label`) du pod dans la description précédente et réappliquez la configuration. Kubernetes mets à jour le pod.
- Modifier le nom du conteneur `rancher-demo` (et pas du pod) et réappliquez la configuration. Que se passe-t-il ?

=> Kubernetes refuse d'appliquer le nouveau nom de conteneur car un pod est largement immutable. Pour changer d'une quelquonque façon les conteneurs du pod il faut supprimer (`kubectl delete -f <fichier>`) et recréer le pod. Mais ce travail de mise à jour devrais être géré par un déploiement pour automatiser et pour garantir la haute disponibilité de notre application `demonstration`.



Kubernetes fournit un ensemble de commande pour débugger des conteneurs :

- `kubectl logs <pod-name> -c <conteneur_name>` (le nom du conteneur est inutile si un seul)
- `kubectl exec -it <pod-name> -c <conteneur_name> -- bash`
- `kubectl attach -it <pod-name>` (attacher l'entrée et la sortie standard du processus principal d'un pod au terminal courant, rarement utilisé)

- Explorez le pod avec la commande `kubectl exec -it <pod-name> -c <conteneur_name> -- bash` écrite plus haut.

- Supprimez le pod.

## Avec un déploiement (méthode à utiliser)

- Créez un fichier `demo-deploy.yaml` avec à l'intérieur le code suivant à compléter:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: demonstration
  labels:
    nom-app: demonstration
spec:
  selector:
    matchLabels:
      nom-app: demonstration
  strategy:
    type: Recreate
  replicas: 1
  template:
    metadata:
      labels:
        nom-app: demonstration
    spec:
      containers:
        - image: <image>
          name: <name>
          ports:
            - containerPort: <port>
              name: demo-http
```

- Appliquez ce nouvel objet avec kubectl.
- Inspectez le déploiement dans Lens.
- Changez le nom d'un conteneur et réappliquez: Cette fois le déploiement se charge créer un nouveau pod avec les bonnes caractéristiques et de supprimer l'ancien.
- Changez le nombre de réplicats.
- Que se passe-t-il si on change l'étiquette de `matchLabel` en se trompant de valeur ?

## Ajoutons un service en mode NodePort

- Créez un fichier `demo-svc.yaml` avec à l'intérieur le code suivant à compléter:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: demo-service
  labels:
    nom-app: demonstration
spec:
  ports:
    - port: <port>
  selector:
    nom-app: demonstration
  type: NodePort
```

- Appliquez ce nouvel objet avec kubectl.
- Inspectez le service dans Lens.
- Visitez votre application avec l'Internal ip du noeud (à trouver dans les information du node) et le nodeport (port 3xxxx) associé au service, le nombre de réplicat devrait apparaître.
- Pour tester, changez le label du selector dans le **service** (lignes `nom-app: demonstration` et `partie: les-petits-pods-demo` à remplacer dans le fichier ) et réappliquez.
- Constatez que l'application n'est plus accessible dans le navigateur. Pourquoi ?
- Allez voir la section endpoints dans lens, constatez que quand l'étiquette est la bonne la liste des ips des pods est présente et après la maodification du selector la liste est vide (None)

=> Les services kubernetes redirigent le trafic basés sur les étiquettes(labels) appliquées sur les pods du cluster. Il faut donc aussi éviter d'utiliser deux fois le même label pour des parties différentes de l'application.

### Solution

Le dépôt Git de la correction de ce TP est accessible ici : `git clone -b tp_rancher_demo_files https://github.com/Uptime-Formation/corrections_tp.git`

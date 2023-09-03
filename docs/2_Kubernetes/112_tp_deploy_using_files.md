---
draft: false
title: "TP - Déployer en utilisant des fichiers ressource yaml"
# sidebar_position: 9
---

--- 
## Objectifs pédagogiques 
- Utiliser `apply` pour lancer une charge de travail dans minikube
- Utiliser des déploiements et services

---

## Contraintes du TP 

- Accompagnement moyen
- Durée attendue : de 30 à 60 minutes 
---

## Créer un pod rancher-demo à la main avec une description YAML

**Dans ce TP nous allons redéployer notre application `demonstration` du TP1 mais cette fois en utilisant :** 

```shell

$ kubectl apply -f <fichier.yaml>

```

On visualisera le résultat dans `Lens`.

---

**Commencez par supprimer les ressources `demonstration` et `demonstration-service` du TP1** 

---

**Créez un dossier `TP2_deploy_using_files_and_Lens` sur le bureau de la machine distante et ouvrez le avec `VSCode`.**

Nous allons d'abord déployer notre application comme un simple **Pod** (non recommandé mais montré ici pour l'exercice).

- Créez un fichier `demo-pod.yaml` avec à l'intérieur le code d'exemple du cours "Objets Fondamentaux" partie "Pods".
- Appliquez le fichier avec `kubectl apply -f <fichier>`.
- Constatez dans Lens dans la partie pods que les deux conteneurs du pod sont bien démarrés (deux petits carrés vert à droite de la ligne du pod)
- Modifiez l'étiquette (`label`) du pod dans la description précédente et réappliquez la configuration. Kubernetes mets à jour le pod.
- Modifier le nom du conteneur `rancher-demo` (et pas du pod) et réappliquez la configuration. Que se passe-t-il ?


**Créez un fichier `demo-pod.yaml` avec à l'intérieur le code utilisé dans le cours précédent.**

```yaml
# File: demo-pod.yaml

apiVersion: v1
kind: Pod
metadata:
  name: rancher-demo-pod
  labels:
    app: rancher-demo
spec:
  containers:
    - image: monachus/rancher-demo:latest
      name: rancher-demo-container
      ports:
        - containerPort: 8080
          name: http
          protocol: TCP
    - image: redis
      name: redis-container
      ports:
        - containerPort: 6379
          name: http
          protocol: TCP

# EOF
```

---



---

**Appliquez le fichier avec** 
```shell

$ kubectl apply -f <fichier>

```

---

**Constatez dans Lens dans la partie pods que le conteneur du pod est bien démarré.**

Vous devez voir deux conteneurs dans le pod

---


**Modifiez l'étiquette (`label`) du pod dans la description précédente et réappliquez la configuration. Kubernetes mets à jour le pod.**

---


**Modifier le nom du conteneur `rancher-demo` (et pas du pod) et réappliquez la configuration.** 

Que se passe-t-il ?

---

**=> Kubernetes refuse d'appliquer le nouveau nom de conteneur car un pod est largement immutable. Pour changer d'une quelquonque façon les conteneurs du pod il faut supprimer**
```shell

$ kubectl delete -f <fichier>

```

Puis recréer le pod. 

---

**Mais ce travail de mise à jour devrais être géré par un déploiement pour automatiser et pour garantir la haute disponibilité de notre application `demonstration`.**

---


Comment débugger nos conteneurs

```shell

$ kubectl logs <pod-name> -c <conteneur_name>

$ kubectl exec -it <pod-name> -c <conteneur_name> -- bash

```

- Retrouvez les fonctions de shell et de log dans l'interface de OpenLens.

- Supprimez le pod.

## Utiliser un déploiement (méthode à utiliser)

- Créez un fichier `demo-deploy.yaml` avec à l'intérieur le code suivant à compléter:

```yaml

# file: demo-deploy.yaml

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

# EOF
```

- Appliquez ce nouvel objet avec kubectl.
- Inspectez le déploiement dans Lens.
- Changez le nom d'un conteneur et réappliquez: Cette fois le déploiement se charge créer un nouveau pod avec les bonnes caractéristiques et de supprimer l'ancien.
- Changez le nombre de réplicats.
- Que se passe-t-il si on change l'étiquette de `matchLabel` en se trompant de valeur ?

---

## Ajoutons un service en mode NodePort pour visiter la demo

- Créez un fichier `demo-svc.yaml` avec à l'intérieur le code suivant à compléter:

```yaml
# file: demo-svc.yaml

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

#EOF
```

---

 **Appliquez ce nouvel objet avec kubectl.**
- Inspectez le service dans Lens.
- Visitez votre application avec l'Internal ip du noeud (à trouver dans les information du node) et le nodeport (port 3xxxx) associé au service, le nombre de réplicat devrait apparaître.

---

**Pour tester, changez le label du selector dans le **service** (lignes `nom-app: demonstration` et `partie: les-petits-pods-demo` à remplacer dans le fichier ) et réappliquez.**
- Constatez que l'application n'est plus accessible dans le navigateur. Pourquoi ?
- Allez voir la section endpoints dans lens, constatez que quand l'étiquette est la bonne la liste des ips des pods est présente et après la maodification du selector la liste est vide (None)

**=> Les services kubernetes redirigent le trafic basés sur les étiquettes(labels) appliquées sur les pods du cluster. Il faut donc aussi éviter d'utiliser deux fois le même label pour des parties différentes de l'application.**

---

## Correction

Le dépôt Git de la correction de ce TP est accessible ici : 
```shell
git clone -b tp_rancher_demo_files https://github.com/Uptime-Formation/corrections_tp.git
```


--- 
## Objectifs pédagogiques 
- Utiliser `apply` pour lancer une charge de travail dans minikube
- Utiliser des déploiements et services

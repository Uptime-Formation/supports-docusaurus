---
title: 2 - TP Découvrir la cli kubectl et déployer une application
draft: false
---

--- 
## Objectifs pédagogiques 
- Installer minikube
- Explorer un cluster Kubernetes minimal
- Déployer une première charge utile et y accéder depuis un navigateur
- Installer une autre IHM : Lens

---


## Découverte de Kubernetes

### Installer le client CLI `kubectl`

**kubectl est le point d'entrée universel pour contrôler tous les type de cluster kubernetes.**

C'est un client en ligne de commande qui communique en REST avec l'API d'un cluster.

Nous allons explorer kubectl au fur et à mesure des TPs. Cependant à noter que :

- `kubectl` peut gérer plusieurs clusters/configurations et switcher entre ces configurations
- `kubectl` est nécessaire pour le client graphique `Lens` que nous utiliserons plus tard.

---

La méthode d'installation importe peu. Pour installer kubectl sur Ubuntu nous ferons simplement: 
```shell
$ sudo snap install kubectl --classic
```

---

**Faites `kubectl version` pour afficher la version du client kubectl.**

---

### Installer Minikube

![](/img/kubernetes/minikube_logo_with_name.png)

**_Minikube_ est la version de développement de Kubernetes en local la plus répandue.** 

Elle est maintenue par la cloud native foundation et très proche de kubernetes upstream. 

Elle permet de simuler un ou plusieurs noeuds de cluster sous forme de conteneurs docker ou de machines virtuelles.

--- 

**Pour installer minikube la méthode recommandée est indiquée ici: https://minikube.sigs.k8s.io/docs/start/**

```shell

$ cd $HOME
$ curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
$ sudo install minikube-linux-amd64 /usr/local/bin/minikube

```

--- 

**Nous utiliserons classiquement `docker` comme runtime pour minikube (les noeuds Kubernetes seront des conteneurs simulant des serveurs). **

Ceci est, bien sur, une configuration de développement. Elle se comporte cependant de façon très proche d'un véritable cluster.

> Si Docker n'est pas installé, installer Docker avec la commande en une seule ligne : `curl -fsSL https://get.docker.com | sh`, puis ajoutez-vous au groupe Docker avec `sudo usermod -a -G docker <votrenom>`, et faites `sudo reboot` pour que cela prenne effet.

--- 

 **Pour lancer le cluster faites simplement: **
 
```shell

$ minikube start

``` 
 
Il est également possible de préciser le nombre de coeurs de calcul, la mémoire et et d'autre paramètre pour adapter le cluster à nos besoins.

---

**Minikube configure automatiquement kubectl pour qu'on puisse se connecter au cluster de développement.**

```shell

$ cat ~/.kube/config

```
---
**Testez la connexion avec**

```shell

$ kubectl get nodes

```
---
**Affichez à nouveau la version `kubectl version`.** 

Cette fois-ci la version de kubernetes qui tourne sur le cluster actif est également affichée. Idéalement le client et le cluster devrait être dans la même version mineure par exemple `1.20.x`.

---
##### Bash completion et racourcis

Pour permettre à `kubectl` de compléter le nom des commandes et ressources avec `<Tab>` il est utile d'installer l'autocomplétion pour Bash :

```shell

$ sudo apt install bash-completion
$ source <(kubectl completion bash)
$ echo "source <(kubectl completion bash)" >> ${HOME}/.bashrc

```
---

**Vous pouvez désormais appuyer sur `<Tab>` pour compléter vos commandes `kubectl`.**

Notez également que pour gagner du temps en ligne de commande, la plupart des mots-clés de type Kubernetes peuvent être abrégés :
  - `nodes` <=> `no`
  - `services` devient `svc`
  - `deployments` devient `deploy`
  - etc.

La liste complète : <https://blog.heptio.com/kubectl-resource-short-names-heptioprotip-c8eff9fb7202>

---

### Explorons notre cluster k8s

**Notre cluster Kubernetes est plein d'objets divers, organisés entre eux de façon dynamique pour décrire des applications, tâches de calcul, services et droits d'accès.** 

La première étape consiste à explorer un peu le cluster.

---

**Listez les nodes pour récupérer le nom de l'unique node.** 

```shell

$ kubectl get nodes

 ```

**Puis affichez ses caractéristiques.** 

```shell

$ kubectl describe node/minikube

```

---

**La commande `get` est générique et peut être utilisée pour récupérer la liste de tous les types de ressources ou d'afficher les informations d'un resource précise.**

Pour désigner un seul objet, il faut préfixer le nom de l'objet par son type.

```shell

$ kubectl get nodes minikube
$ kubectl get node/minikube

```

 Kubernetes ne peut pas deviner ce que l'on cherche quand plusieurs ressources de types différents ont le même nom.

---

**De même, la commande `describe` peut s'appliquer à tout objet k8s.**

```shell

$ kubectl describe nodes minikube
$ kubectl describe node/minikube

```

---

**Pour afficher tous les types de ressources à la fois que l'on utilise** 

```

$ kubectl get all
 
```

```
NAME                 TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.96.0.1   <none>        443/TCP   2m34s
```

---

**Il semble qu'il n'y a qu'une ressource dans notre cluster. Il s'agit du service d'API Kubernetes, pour que les pods/conteneurs puissent utiliser la découverte de service pour communiquer avec le cluster.**

En réalité il y en a généralement d'autres cachés dans les autres `namespaces`. 

En effet les éléments internes de Kubernetes tournent eux-mêmes sous forme de services et de daemons Kubernetes. 

---

**Les *namespaces* sont des groupes qui servent à isoler les ressources de façon logique et en termes de droits (avec le *Role-Based Access Control* (RBAC) de Kubernetes).**

Pour vérifier cela on peut afficher les namespaces : 

```shell

$ kubectl get namespaces

```
---

**Un cluster Kubernetes a généralement un namespace appelé `default` dans lequel les commandes sont lancées et les ressources créées si on ne précise rien.** 

Il a également aussi un namespace `kube-system` dans lequel résident les processus et ressources système de k8s. 

Pour préciser le namespace on peut rajouter l'argument `-n` à la plupart des commandes k8s.

```shell

# lister les ressources liées au control plane 
$ kubectl get all -n kube-system

# afficher le contenu de tous les namespaces en même temps
$ kubectl get all --all-namespaces  
$ kubectl get all -A

# avoir des informations sur un namespace 
$ kubectl describe namespace/kube-system

```

--- 

### Déployer une application en CLI

**Nous allons maintenant déployer une première application conteneurisée.** 

Le déploiement est un peu plus complexe qu'avec Docker, en particulier car il est séparé en plusieurs objets et plus configurable.

---

**Pour créer un déploiement en ligne de commande (par opposition au mode déclaratif que nous verrons plus loin), on peut lancer** 
```shell

$ kubectl create deployment demonstration --image=monachus/rancher-demo

```

---

**Cette commande crée un objet de type `deployment`.** 

Nous pourvons étudier ce deployment avec la commande 

```shell

$ kubectl describe deployment/demonstration
Name:                   demonstration
Namespace:              default
CreationTimestamp:      <...date...>
Labels:                 app=demonstration
Annotations:            deployment.kubernetes.io/revision: 1
Selector:               app=demonstration
Replicas:               1 desired | 1 updated | 1 total | 1 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:  app=demonstration
  Containers:
   rancher-demo:
    Image:        monachus/rancher-demo
    Port:         <none>
    Host Port:    <none>
    Environment:  <none>
    Mounts:       <none>
  Volumes:        <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
  Progressing    True    NewReplicaSetAvailable
OldReplicaSets:  <none>
NewReplicaSet:   demonstration-6bc8dbb967 (1/1 replicas created)
Events:
  Type    Reason             Age   From                   Message
  ----    ------             ----  ----                   -------
  Normal  ScalingReplicaSet  91s   deployment-controller  Scaled up replica set demonstration-6bc8dbb967 to 1

```

---

**Notez la liste des événements sur ce déploiement en bas de la description.**

De la même façon que dans la partie précédente, listez les `pods` avec `kubectl`. 

Combien y en a-t-il ?

---

**Agrandissons ce déploiement.** 

```shell

$ kubectl scale deployment demonstration --replicas=5
$ kubectl describe deployment/demonstration
Name:                   demonstration
Namespace:              default
...
Replicas:               5 desired | 5 updated | 5 total | 5 available | 0 unavailable
...
```
---

**On constate que le service est bien passé à 5 replicas.**

Observez à nouveau la liste des évènements, le scaling y est enregistré...

Listez les pods pour constater.

---


**A ce stade impossible d'afficher l'application : le déploiement n'est pas encore accessible de l'extérieur du cluster.** 

Pour régler cela nous devons l'exposer grace à un service :

```shell

$ kubectl expose deployment demonstration --type=NodePort --port=8080 --name=demonstration-service

```

--- 

**Affichons la liste des services pour voir le résultat**

```shell

$ kubectl get services

```

**Un service permet de créer un point d'accès unique exposant notre déploiement.** 

Ici nous utilisons le type Nodeport car nous voulons que le service soit accessible de l'extérieur par l'intermédiaire d'un forwarding de port.

Avec minikube ce forwarding de port doit être concrêtisé avec la commande 

```shell

$ minikube service demonstration-service

```
 
**Normalement la page s'ouvre automatiquement et nous voyons notre application.**

---

**Sauriez-vous expliquer ce que l'app fait ?**

Pour le comprendre ou le confirmer, diminuez le nombre de réplicats à l'aide de la commande utilisée précédement pour passer à 2 réplicats. 

Que se passe-t-il ?

---

**Une autre méthode pour accéder à un service en mode développement est de forwarder le trafic par l'intermédiaire de kubectl.**

Cela utilise des composants `kube-proxy` installés sur chaque noeud du cluster.

```shell

$ kubectl port-forward svc/demonstration-service 9000:8080 --address 127.0.0.1

```

---

**Vous pouvez désormais accéder à votre app via via kubectl sur**

> http://localhost:9000
 
Quelle différence avec l'exposition précédente via minikube ?

**=> Un seul conteneur s'affiche. En effet `kubectl port-forward` sert à créer une connexion de developpement/debug qui pointe toujours vers le même pod en arrière plan.**


---


**Pour exposer cette application en production sur un véritable cluster, nous devrions plutôt avoir recours à service de type _LoadBalancer_.** 

Mais minikube ne propose pas par défaut de loadbalancer. Nous y reviendrons dans le cours sur les objets kubernetes.

---

### CheatSheet pour kubectl et formatage de la sortie

**Doc :**

- https://kubernetes.io/docs/reference/kubectl/cheatsheet/

**Vous noterez dans cette page qu'il est possible de traiter la sortie des commandes kubectl de multiple façon (yaml, json, gotemplate, jsonpath, etc)**

Le mode de sortie le plus utilisé pour filtrer une information parmis l'ensemble des caractéristiques d'une resource est `jsonpath` qui s'utilise comme ceci:

```shell

kubectl get pod <tab>
kubectl get pod demonstration-7645747fc6-f5z55 -o yaml # pour afficher la spécification
kubectl get pod demonstration-7645747fc6-f5z55 -o jsonpath='{.spec.containers[0].image}' # affiche le nom de l'image

```

Essayez de la même façon d'afficher le nombre de répliques de notre déploiement.

--- 

## Au delà de la ligne de commande...

### Accéder à la dashboard Kubernetes

![](/img/kubernetes/kubernetes-ui-dashboard.png)
Le moyen le plus classique pour avoir une vue d'ensemble des ressources d'un cluster est d'utiliser la Dashboard officielle. Cette Dashboard est généralement installée par défaut lorsqu'on loue un cluster chez un provider.

On peut aussi l'installer dans minikube ou k3s. Nous allons ici préférer le client lourd Lens

---

### Installer OpenLens

**(Open)Lens est une interface graphique (un client "lourd") pour Kubernetes. Elle se connecte en utilisant kubectl et la configuration `~/.kube/config` par défaut et nous permettra d'accéder à un dashboard puissant et agréable à utiliser.**

Récemment Mirantis qui a racheté Lens essaye de fermer l'accès à ce logiciel open source. 

Il faut donc utiliser le build communautaire à la place du build officiel: https://github.com/MuhammedKalkan/OpenLens/releases

--- 

Installez-le en lançant ces commandes :

```shell
## Install Lens
export LENS_VERSION=6.4.15 # change with the current stable version
curl -LO "https://github.com/MuhammedKalkan/OpenLens/releases/download/v$LENS_VERSION/OpenLens-$LENS_VERSION.deb"
sudo apt install ./"OpenLens-$LENS_VERSION.deb" 
```

--- 

**Lancez l'application `open-lens` dans le menu "internet" de votre machine (VNC).**

Sélectionnez le cluster de votre choix la liste et épinglez la connection dans la barre de menu

Explorons ensemble les ressources dans les différentes rubriques et namespaces

--- 
## Objectifs pédagogiques 
- Installer minikube
- Explorer un cluster Kubernetes minimal
- Déployer une première charge utile et y accéder depuis un navigateur
- Installer une autre IHM : Lens

---
title: TP opt. - Le RBAC
draft: true
weight: 2090
---

## Les rôles et le RBAC

1. Configurer Minikube pour activer RBAC.
```bash
minikube start --extra-config=apiserver.Authorization-Mode=RBAC

kubectl create clusterrolebinding add-on-cluster-admin --clusterrole=cluster-admin --serviceaccount=kube-system:default
```

2. Créer trois connexions à minikube dans `~/.kube/config` :
- une en mode `cluster-admin`,
- une en mode admin sur un namespace
- et une en mode user avec un `rolebinding`

3. En switchant de contexte à chaque fois, lancer la commande `kubectl auth can-i` pour différents cas et observer la différence

### Ressources 
- https://medium.com/@HoussemDellai/rbac-with-kubernetes-in-minikube-4deed658ea7b
- https://docs.bitnami.com/tutorials/configure-rbac-in-your-kubernetes-cluster/
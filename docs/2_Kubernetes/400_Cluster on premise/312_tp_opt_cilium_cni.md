---
title: TP optionnel - Installer Cilium - observer et limiter le traffic 
---

Cilium est un des CNI les plus puissants avec Calico. Il permet notamment d'observer finement le traffic, le chiffrer et de le filtrer en temps réel au niveau 3,4 et 7 avec des Network Policies et autres règles avancées.

Dans ce TP nous allons l'installer dans notre cluster k3s et suivre les tutoriels d'exemple officiels pour découvrir l'observabilité et configurer quelques network policies (firewalling kubernetes) pour limiter le traffic.


## Configurer k3s pour préparer l'installation de Cilium

K3s s'installe par défaut avec `flannel` le CNI plugin vanilla et simple de kubernetes. Pour le remplacer par cilium nous allons d'abord le désactiver (pour plus d'info voir la doc https://docs.cilium.io/en/stable/installation/k3s/ et https://docs.k3s.io/installation/network-options)

- Sur votre serveur/noeud k3s, créez un fichier `/etc/rancher/k3s/config.yaml` avec à l'intérieur les clés suivantes:

```yaml
flannel-backend: 'none'
disable-network-policy: true
```

- Vous devez ensuite redémarrer le serveur avec `sudo systemctl restart k3s`

On peut constater avec `kubectl get node ...` et `kubectl describe node ...` que le noeud passe ensuite dans en status NotReady et que les fonctionnalité réseaux ne sont plus assurées


## Installer Cilium

Suivez le tutoriel suivant pour installer la CLI cilium, déployer et tester le CNI plugin : https://docs.cilium.io/en/stable/installation/k3s/

## Activer l'observability Hubble et l'UI

- https://docs.cilium.io/en/stable/gettingstarted/hubble_setup/#hubble-setup
- https://docs.cilium.io/en/stable/gettingstarted/hubble/#hubble-ui

## Démo des NetworkPolicies de Cilium

- https://docs.cilium.io/en/stable/gettingstarted/demo/#starwars-demo
---
draft: false
title: Cours 5 - Le stockage et le réseau dans Kubernetes
sidebar_position: 11
---


## Le stockage et les Volumes dans Docker

Les conteneurs propose un paradigme immutable : on peut les transformers pendant leur execution (ajouter des fichier, changer des configurations) mais ce n'est pas le mode d'utilisation recommandé. En particulier Kubernetes est succeptible de les supprimer et de les recréer automatiquement. Les fichiers ajoutés manuellement pendant l'execution seront alors perdu.

Se pose donc la question de la persistance des données d'une application, par exemple une base de donnée. Dans un environnement conteneurisé toute persistance est permise via des volumes, sortes de disques durs virtuels, qu'on connecte à nos conteneur. Comme un disque ces volumes sont monté à un emplacement du système de fichier du conteneur. En écrivant dans le dossier en question on écrit alors sur ce disque virtuel qui conservera ses données même si le conteneur est supprimé.

## Le stockage dans Kubernetes

### Les Volumes Kubernetes

Comme dans Docker, Kubernetes fournit la possibilité de monter des volumes virtuels dans les conteneurs de nos pod. On liste séparément les volumes de notre pod puis on les monte une ou plusieurs dans les différents conteneurs. Exemple:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: test-pd
spec:
  containers:
  - image: k8s.gcr.io/test-webserver
    name: test-container
    volumeMounts:
    - mountPath: /test-pd
      name: test-volume
  volumes:
  - name: test-volume
    hostPath:
      # chemin du dossier sur l'hôte
      path: /data
      # ce champ est optionnel
      type: Directory
```

La problématique des volumes et du stockage est plus compliquée dans kubernetes que dans docker car k8s cherche à répondre à de nombreux cas d'usages. [doc officielle](https://kubernetes.io/fr/docs/concepts/storage/volumes/). Il y a donc de nombeux types de volumes kubernetes correspondants à des usages de base et aux solutions proposées par les principaux fournisseurs de cloud.
<!-- 
Mentionnons quelques d'usage de base des volumes:

- `hostPath`: monte un dossier du noeud ou est plannifié le pod à l'intérieur du conteneur.
- `configMap` ou `secret`: pour monter des fichiers de configurations provenant du cluster à l'intérieur des pods
- `nfs`: stockage réseau classique
- `cephfs`: monter un volume ceph provenant d'un ceph installé sur le cluster
- etc.

En plus de la gestion manuelle des volumes avec les option précédentes, kubernetes permet de provisionner dynamiquement du stockage en utilisant des plugins de création de volume grâce à 3 types d'objets: `StorageClass` `PersistentVolume` et `PersistentVolumeClaim`.

### Les types de stockage avec les `StorageClasses`

Le stockage dynamique dans Kubernetes est fourni à travers des types de stockage appelés *StorageClasses* :

- dans le cloud, ce sont les différentes offres de volumes du fournisseur,
- dans un cluster auto-hébergé c'est par exemple des opérateurs de stockage comme `rook.io` ou `longhorn`(Rancher).

[doc officielle](https://kubernetes.io/docs/concepts/storage/storage-classes/) -->

### Demander des volumes et les liers aux pods :`PersistentVolumes` et `PersistentVolumeClaims`

Quand un conteneur a besoin d'un volume, il crée une *PersistentVolumeClaim* : une demande de volume (persistant). Si une des *StorageClass* du cluster est en capacité de le fournir, alors un *PersistentVolume* est créé et lié à ce conteneur : il devient disponible en tant que volume monté dans le conteneur.

<!-- - les *StorageClasses* fournissent du stockage -->
- les conteneurs demandent du volume avec les *PersistentVolumeClaims*
- les *StorageClasses* répondent aux *PersistentVolumeClaims* en créant des objets *PersistentVolumes* : le conteneur peut accéder à son volume.

[doc officielle](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)

Le provisionning de `PersistentVolume` peut être manuel (on crée un objet `PersistentVolume` en amont ou non. Dans le second cas la création d'un `PersistentVolumeClaim` mène directement à la création d'un volume si possible)

## Problématiques réseau

## CNI (container network interface) : Les implémentations du réseau Kubernetes

Beaucoup de solutions de réseau qui se concurrencent, demandant un comparatif un peu fastidieux.

  - plusieurs solutions très robustes
  - diffèrent sur l'implémentation : BGP, réseau overlay ou non (encapsulation VXLAN, IPinIP, autre)
  - toutes ne permettent pas d'appliquer des **NetworkPolicies** : l'isolement et la sécurité réseau
  - peuvent parfois s'hybrider entre elles (Canal = Calico + Flannel)

- Calico, Flannel, Weave ou Cilium sont très employées et souvent proposées en option par les fournisseurs de cloud
- Cilium a la particularité d'utiliser la technologie eBPF de Linux qui permet une sécurité et une rapidité accrue

Comparaisons :
- <https://rancher.com/blog/2019/2019-03-21-comparing-kubernetes-cni-providers-flannel-calico-canal-and-weave/>

## Vidéos

Une vidéos assez complète sur le réseau, faites par Calico :
- [Kubernetes Ingress networking](https://www.youtube.com/watch?v=40VfZ_nIFWI&list=PLoWxE_5hnZUZMWrEON3wxMBoIZvweGeiq&index=5)
- [Kubernetes Services networking](https://www.youtube.com/watch?v=NFApeJRXos4&list=PLoWxE_5hnZUZMWrEON3wxMBoIZvweGeiq&index=4)


## Les objets Ingresses

![](/img/kubernetes/ingress.png)
*Crédits [Ahmet Alp Balkan](https://medium.com/@ahmetb)*

Un Ingress est un objet pour gérer dynamiquement le **reverse proxy** HTTP/HTTPS dans Kubernetes. Documentation: https://kubernetes.io/docs/concepts/services-networking/ingress/#what-is-ingress

Exemple de syntaxe d'un ingress:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress-wildcard-host
spec:
  rules:
  - host: "domain1.bar.com"
    http:
      paths:
      - pathType: Prefix
        path: "/bar"
        backend:
          service:
            name: service1
            port:
              number: 80
      - pathType: Prefix
        path: "/foo"
        backend:
          service:
            name: service2
            port:
              number: 80
  - host: "domain2.foo.com"
    http:
      paths:
      - pathType: Prefix
        path: "/"
        backend:
          service:
            name: service3
            port:
              number: 80
```

Pour pouvoir créer des objets ingress il est d'abord nécessaire d'installer un **ingress controller** dans le cluster:

- Il s'agit d'un déploiement conteneurisé d'un logiciel de reverse proxy (comme nginx) et intégré avec l'API de kubernetes
- Le controlleur agit donc au niveau du protocole HTTP et doit lui-même être exposé (port 80 et 443) à l'extérieur, généralement via un service de type LoadBalancer.
- Le controlleur redirige ensuite vers différents services (généralement configurés en ClusterIP) qui à leur tour redirigent vers différents ports sur les pods selon l'URL del a requête.

Il existe plusieurs variantes d'**ingress controller**:

- Un ingress basé sur Nginx plus ou moins officiel à Kubernetes et très utilisé: https://kubernetes.github.io/ingress-nginx/
- Un ingress Traefik optimisé pour k8s.
- il en existe d'autres : celui de payant l'entreprise Nginx, Contour, HAProxy...

Chaque provider de cloud et flavour de kubernetes est légèrement différent au niveau de la configuration du controlleur ce qui peut être déroutant au départ:

- minikube permet d'activer l'ingress nginx simplement (voir TP)
- autre example: k3s est fourni avec traefik configuré par défaut
- On peut installer plusieurs `ingress controllers` correspondant à plusieurs `IngressClasses`

Comparaison des controlleurs: <https://medium.com/flant-com/comparing-ingress-controllers-for-kubernetes-9b397483b46b>

<!-- 
## Gestion dynamique des certificats à l'aide de `certmanager`

`Certmanager` est une application kubernetes (un `operator`) plus ou moins officielle  capable de générer automatiquement des certificats TLS/HTTPS pour nos ingresses.

- Documentation d'installation: https://cert-manager.io/docs/installation/kubernetes/
- Tutorial pas à pas pour générer un certificat automatiquement avec un ingress et letsencrypt: https://cert-manager.io/docs/tutorials/acme/ingress/

Exemple de syntaxe d'un ingress utilisant `certmanager`:

```yaml
apiVersion: networking.k8s.io/v1 
kind: Ingress
metadata:
  name: kuard
  annotations:
    kubernetes.io/ingress.class: "nginx"    
    cert-manager.io/issuer: "letsencrypt-prod"
spec:
  tls:
  - hosts:
    - example.example.com
    secretName: quickstart-example-tls
  rules:
  - host: example.example.com
    http:
      paths:
      - path: /
        pathType: Exact
        backend:
          service:
            name: kuard
            port:
              number: 80
```

 -->

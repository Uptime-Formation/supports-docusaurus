---
draft: false
title: Les données

---

## Les données


## Le stockage et les Volumes dans Docker

**Les conteneurs proposent un paradigme immutable : on peut les transformers pendant leur execution (ajouter des fichier, changer des configurations) mais ce n'est pas le mode d'utilisation recommandé. En particulier Kubernetes est succeptible de les supprimer et de les recréer automatiquement. Les fichiers ajoutés manuellement pendant l'execution seront alors perdu.**

Se pose donc la question de la persistance des données d'une application, par exemple une base de donnée. Dans un environnement conteneurisé toute persistance est permise via des volumes, sortes de disques durs virtuels, qu'on connecte à nos conteneur. Comme un disque ces volumes sont monté à un emplacement du système de fichier du conteneur. En écrivant dans le dossier en question on écrit alors sur ce disque virtuel qui conservera ses données même si le conteneur est supprimé.

---

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

---

**La problématique des volumes et du stockage est plus compliquée dans kubernetes que dans docker car k8s cherche à répondre à de nombreux cas d'usages. [doc officielle](https://kubernetes.io/fr/docs/concepts/storage/volumes/). Il y a donc de nombeux types de volumes kubernetes correspondants à des usages de base et aux solutions proposées par les principaux fournisseurs de cloud.**

Mentionnons quelques d'usage de base des volumes:

- `hostPath`: monte un dossier du noeud ou est plannifié le pod à l'intérieur du conteneur.
- `configMap` ou `secret`: pour monter des fichiers de configurations provenant du cluster à l'intérieur des pods
- `nfs`: stockage réseau classique
- `cephfs`: monter un volume ceph provenant d'un ceph installé sur le cluster
- etc.

En plus de la gestion manuelle des volumes avec les option précédentes, kubernetes permet de provisionner dynamiquement du stockage en utilisant des plugins de création de volume grâce à 3 types d'objets: `StorageClass` `PersistentVolume` et `PersistentVolumeClaim`.

---


### Les types de stockage avec les `StorageClasses`

**Le stockage dynamique dans Kubernetes est fourni à travers des types de stockage appelés *StorageClasses* :**

- dans le cloud, ce sont les différentes offres de volumes du fournisseur,
- dans un cluster auto-hébergé c'est par exemple des opérateurs de stockage comme `rook.io` ou `longhorn`(Rancher).

[doc officielle](https://kubernetes.io/docs/concepts/storage/storage-classes/) -->

---


### Demander des volumes et les liers aux pods :`PersistentVolumes` et `PersistentVolumeClaims`

Quand un conteneur a besoin d'un volume, il crée une *PersistentVolumeClaim* : une demande de volume (persistant). Si une des *StorageClass* du cluster est en capacité de le fournir, alors un *PersistentVolume* est créé et lié à ce conteneur : il devient disponible en tant que volume monté dans le conteneur.

<!-- - les *StorageClasses* fournissent du stockage -->
- les conteneurs demandent du volume avec les *PersistentVolumeClaims*
- les *StorageClasses* répondent aux *PersistentVolumeClaims* en créant des objets *PersistentVolumes* : le conteneur peut accéder à son volume.

[doc officielle](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)

Le provisionning de `PersistentVolume` peut être manuel (on crée un objet `PersistentVolume` en amont ou non. Dans le second cas la création d'un `PersistentVolumeClaim` mène directement à la création d'un volume si possible)

---


### Liens externes

- https://developers.redhat.com/articles/2022/10/06/kubernetes-storage-concepts
- https://bluexp.netapp.com/blog/cvo-blg-5-types-of-kubernetes-volumes-and-how-to-work-with-them

---


### Backup de volume

**Il existe plusieurs méthodes pour effectuer des sauvegardes de données persistantes dans Kubernetes :** 

- Utiliser des outils de backup Kubernetes : Certains outils de sauvegarde Kubernetes, tels que Velero (anciennement Heptio Ark), permettent de sauvegarder et de restaurer des données persistantes. Ces outils peuvent être configurés pour effectuer des sauvegardes régulières des volumes persistants dans votre cluster Kubernetes, puis les stocker dans un emplacement de stockage sécurisé.

- Utiliser des outils classiques de backups plannifiés depuis vos pods (push depuis le pod): Les volumes persistants Kubernetes sont généralement montés en tant que systèmes de fichiers dans les pods. En utilisant des outils de sauvegarde de fichiers tels que rsync, borg, etc. on peut sauvegarder ces volumes persistants sur des emplacements de stockage externes. On peut également utiliser des scripts basés sur kubectl plannifiés depuis un serveur de backup se connectent à l'intérieur des pods pour récupérer les données.

---
draft: false
title: Cours - Les volumes pour le stockage persistent et la configuration
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

![](/img/kubernetes/schemas-perso/resources-deps.jpg?width=400px)

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

## Volumes pour la persistence

### Demander des volumes et les liers aux pods :`PersistentVolumes` et `PersistentVolumeClaims`

Quand un conteneur a besoin d'un volume, il crée une *PersistentVolumeClaim* : une demande de volume (persistant). Si une des *StorageClass* du cluster est en capacité de le fournir, alors un *PersistentVolume* est créé et lié à ce conteneur : il devient disponible en tant que volume monté dans le conteneur.

<!-- - les *StorageClasses* fournissent du stockage -->
- les conteneurs demandent du volume avec les *PersistentVolumeClaims*
- les *StorageClasses* répondent aux *PersistentVolumeClaims* en créant des objets *PersistentVolumes* : le conteneur peut accéder à son volume.

[doc officielle](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)

Le provisionning de `PersistentVolume` peut être manuel (on crée un objet `PersistentVolume` en amont ou non. Dans le second cas la création d'un `PersistentVolumeClaim` mène directement à la création d'un volume si possible)

### Liens externes

- https://developers.redhat.com/articles/2022/10/06/kubernetes-storage-concepts
- https://bluexp.netapp.com/blog/cvo-blg-5-types-of-kubernetes-volumes-and-how-to-work-with-them

### Backup de volume

Il existe plusieurs méthodes pour effectuer des sauvegardes de données persistantes dans Kubernetes : 

- Utiliser des outils de backup Kubernetes : Certains outils de sauvegarde Kubernetes, tels que Velero (anciennement Heptio Ark), permettent de sauvegarder et de restaurer des données persistantes. Ces outils peuvent être configurés pour effectuer des sauvegardes régulières des volumes persistants dans votre cluster Kubernetes, puis les stocker dans un emplacement de stockage sécurisé.

- Utiliser des outils classiques de backups plannifiés depuis vos pods (push depuis le pod): Les volumes persistants Kubernetes sont généralement montés en tant que systèmes de fichiers dans les pods. En utilisant des outils de sauvegarde de fichiers tels que rsync, borg, etc. on peut sauvegarder ces volumes persistants sur des emplacements de stockage externes. On peut également utiliser des scripts basés sur kubectl plannifiés depuis un serveur de backup se connectent à l'intérieur des pods pour récupérer les données.

## Objets de configuration

### Les ConfigMaps 

D'après les recommandations de développement [12factor](https://12factor.net), la configuration de nos programmes doit venir de l'environnement.

Les objets ConfigMaps permettent d'injecter dans des pods des ensemble clés/valeur de configuration en tant que volumes/fichiers de configuration ou variables d'environnement.

Cela permet notamment de centraliser et découpler la configuration du déploiement des pods. Par exemple on peut stocker de façon centraliser le nom de domaine à utiliser pour une application et plusieurs de ses microservices pourront venir la récupérer dans la même configmap.

#### Exemple de configmap et de récupération d'une variable d'environnement

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: mysql-config
data:
  MYSQL_DATABASE: mydatabase
```

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mysql-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
      - name: mysql
        image: mysql:5.7
        env:
        - name: MYSQL_DATABASE
          valueFrom:
            configMapKeyRef:
              name: mysql-config
              key: MYSQL_DATABASE
        ports:
        - containerPort: 3306
```

### les Secrets

Les Secrets se manipulent comme des objets ConfigMaps, mais ils sont chiffrés et faits pour stocker des mots de passe, des clés privées, des certificats, des tokens, ou tout autre élément de config dont la confidentialité doit être préservée.
Un secret se créé avec l'API Kubernetes, puis c'est au pod de demander à y avoir accès.

Il y a plusieurs façons de donner un accès à un secret, notamment :
- le secret est un fichier que l'on monte en tant que volume dans un conteneur (pas nécessairement disponible à l'ensemble du pod). Il est possible de ne jamais écrire ce secret sur le disque (volume `tmpfs`).
- le secret est une variable d'environnement du conteneur.

Pour définir qui et quelle app a accès à quel secret, on peut utiliser les fonctionnalités "RBAC" de Kubernetes.

#### Exemple de secret pour un certificat SSL et son montage comme fichier dans un pods

Création du secret en ligne de commande à partir d'un fichier:

`kubectl create secret generic my-cert --from-file=mycert.pem`

Cela donne par exemple le secret suivant (les données d'un secret sont encodé en base64, un mode de sérialisation qui permet notamment de stocker des données binaires sous forme de texte):

```yaml
apiVersion: v1
data:
  mycert.pem: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURhekNDQWxPZ0F3SUJBZ0lVRXZsVXVyT3RTelN0cFlWaEw1K3B0R2JUVlRFd0RRWUpLb1pJaHZjTkFRRUwKQlFBd1JURUxNQWtHQTFVRUJoTUNRVlV4RXpBUkJnTlZCQWdNQ2xOdmJXVXRVM1JoZEdVeElUQWZCZ05WQkFvTQpHRWx1ZEdWeWJtVjBJRmRwWkdkcGRITWdVSFI1SUV4MFpEQWVGdzB5TXpBek1EZ3hOakl5TVRkYUZ3MHpNekF6Ck1EVXhOakl5TVRkYU1FVXhDekFKQmdOVkJBWVRBa0ZWTVJNd0VRWURWUVFJREFwVGIyMWxMVk4wWVhSbE1TRXcKSHdZRFZRUUtEQmhKYm5SbGNtNWxkQ0JYYVdSbmFYUnpJRkIwZVNCTWRHUXdnZ0VpTUEwR0NTcUdTSWIzRFFFQgpBUVVBQTRJQkR3QXdnZ0VLQW9JQkFRQ2YrZHprR2xkTlpoUGVDdTFyOC9taGJyQkNIdlYwSTd4dHhrZ096K1hBCnZuMXpkNkttSGlqZGlBWUdLN2EvUVlpQnhpbWljQnYrRkpUY2FoMDJMbkJ1VTlnSmV4QUF0ZnVZb2VoMnJhaGgKVXg5bXYyTUhTUnVjQW5VTnpBSForcDZMd2tTZ2lvd1NDTUFxUlJpTkNEMm9FVFM0RmFmL3dHVWRkRnVMN0lsMgptTGxrdkJlWEVRbUJlc1pxR1A5d0RCZlhOeVppbi9xeHRCeFY2dkFldjhrK3ZFY3lNQzJIMUdNbFpFZHcwd1o5Cm1yNjhpQkVXNWp0Q0JibFRDUVF0bjZCdDgvMCsvMUFDajFTc3FSTHJ1aUJIZ1ljZXdPeXB3WVA3ZEtZajMvODYKaGsxNU5rSUVCVHlzTWhrdThjTnZxVXNTaU9wNURRc000bEV6N0lkaXFwblJBZ01CQUFHalV6QlJNQjBHQTFVZApEZ1FXQkJUTnh6QmxBanZ1TmFlb2h1bFAxdDRtUXFrY0RqQWZCZ05WSFNNRUdEQVdnQlROeHpCbEFqdnVOYWVvCmh1bFAxdDRtUXFrY0RqQVBCZ05WSFJNQkFmOEVCVEFEQVFIL01BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQjIKNmpOWmRiWWp2T0dEd0s3ZEhFa2REa1NIa0w3U3A4cWJMakN0NEx1VFlBWHJ5ZURnei9yNGViclNkZDhocmR3LwpzZEtFQTRFM1QyWnhPV2xINmpsVnJEZlhNbG1ZTFNvSEFoQWMwM1E4V01YTnkyZlVrSjRhQlJ1MGFMZUM4QnJTClBHT2xFanpEa0dsUGJENmI5SGZxRXFHMTRndkZBTG80YUQxRXFIUVRYUEx5WUUvbnd5SlhjTU9ZUlZ5V0xLeFYKb3NhYmtHdHVralRRSlpqbWxlb3VzZDhBWGFrS3duV25hM2ErYkhOczFUdmcxUkY1WDhxSVc4cGN6SzhadlRVdQpWRUd3clpnOUcrclpvU3RmSHdFaUhjVVVrMGhKTHJkRDlCUGFwZ2puMUF0NGJhdnRVNmJIbE5MOGdrRUMzdnlZCmVrc2tPNSs2WDIwaStpUEdRSWp1Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
kind: Secret
metadata:
  creationTimestamp: "2023-03-08T16:29:52Z"
  name: my-cert
  namespace: default
  resourceVersion: "5543"
  uid: dd27cd3f-1779-47f4-a821-25d8139b21a4
type: Opaque
```

On peut ensuite monter le secret sous forme d'un fichier dans des pods via un volume comme suit :

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - name: mycontainer
        image: myimage
        ports:
        - containerPort: 443
        volumeMounts:
        - name: my-cert
          mountPath: /etc/mycert.pem
          readOnly: true
      volumes:
      - name: my-cert
        secret:
          secretName: my-cert
```


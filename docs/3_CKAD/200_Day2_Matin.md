---
title: Jour 2 - Matin
---

# Jour 2 - Matin



## Les variables d'environnement 

**Les **variables d'environnement** sont un mécanisme clé pour configurer des applications dans des environnements conteneurisés.** 

Elles permettent de rendre les conteneurs plus portables et de respecter les bonnes pratiques des applications "stateless" et des **12 facteurs** (conception d'applications cloud-native). 

Dans Kubernetes, elles sont utilisées pour passer des informations de configuration aux Pods, comme des identifiants, des mots de passe ou des adresses de services externes.

---

### Les 12 facteurs : Configuration et Workloads stateless

Le **manifeste des 12 facteurs** est un ensemble de principes pour construire des applications modernes et scalable. Le facteur **III. Config** stipule que la **configuration** (paramètres d'exécution qui changent entre les environnements) doit être séparée du code et injectée dans l'application via des **variables d'environnement**.

Dans un environnement conteneurisé :
- L'application doit être **stateless** : elle ne doit pas conserver de données dans ses conteneurs.
- L'image du conteneur doit être **immutable** : elle est construite une fois et ne change pas, la configuration est injectée lors de l'exécution.

Les **variables d'environnement** jouent un rôle crucial dans ce processus, car elles permettent d'injecter la configuration dans le conteneur sans modifier l'image.

---

## Options Kubernetes pour gérer les variables d'environnement

**Kubernetes offre plusieurs façons de gérer les variables d'environnement dans les Pods, en fonction du type d'information que vous souhaitez injecter :**

1. **Variables d'environnement statiques** : Directement définies dans le manifest (usage limité à des valeurs simples et non sensibles).
2. **ConfigMaps** : Pour injecter des configurations dynamiques et spécifiques à l'environnement dans les Pods.
3. **Secrets** : Pour injecter des informations sensibles de manière sécurisée dans les Pods.


Ces options, bien utilisées, permettent de suivre les bonnes pratiques du manifeste des 12 facteurs pour configurer des workloads stateless, où la configuration est injectée à l'exécution et l'image des conteneurs reste immuable.


---

1. **Variables d'environnement statiques dans les manifests** 
   

   - Définissez les variables d'environnement directement dans le fichier de configuration du Pod ou du Deployment.
   - Cela est simple, mais non recommandé pour les informations sensibles ou changeantes.

   **Exemple :**

   ```yaml
   apiVersion: v1
   kind: Pod
   metadata:
     name: my-pod
   spec:
     containers:
     - name: my-container
       image: my-app:latest
       env:
       - name: ENV_VAR_NAME
         value: "production"
   ```

   **Utilisation** : Approprié pour des valeurs statiques comme des environnements (`production`, `staging`, `test`), mais à éviter pour des secrets.

---

2. **Variables d'environnement depuis un volume de configuration** :

Utilisez-les pour injecter des configurations spécifiques à l'environnement dans les Pods sans modifier les fichiers de déploiement.

   - Les **ConfigMaps** sont des objets Kubernetes utilisés pour stocker des données non sensibles sous forme de paires clé-valeur.
   - Les **Secrets** sont utilisés pour stocker des informations sensibles comme des mots de passe, des clés d'API ou des certificats.


   **Exemple d'utilisation d'une ConfigMap :**

   ```yaml
   apiVersion: v1
   kind: ConfigMap
   metadata:
     name: app-config
   data:
     ENV_VAR_NAME: "production"
     API_URL: "https://api.example.com"
   ```

   Ensuite, utilisez la ConfigMap dans votre Pod comme variables d'environnement :

   ```yaml
   apiVersion: v1
   kind: Pod
   metadata:
     name: my-pod
   spec:
     containers:
     - name: my-container
       image: my-app:latest
       envFrom:
       - configMapRef:
           name: app-config
   ```

   **Utilisation** : Idéal pour des configurations changeantes, comme des URLs d'API, des paramètres spécifiques à un environnement, etc.
   Les Secrets sont recommandés pour les informations sensibles comme les identifiants, clés d'API, tokens, etc. qui ne doivent pas apparaître dans l'Infra As Code.

---

### Bonnes pratiques pour configurer des workloads stateless à base d'images immutables

**Séparer configuration et code** :
   - Ne stockez jamais de configurations ou secrets dans l'image Docker. Utilisez des **variables d'environnement** injectées via des **ConfigMaps** et des **Secrets**.

**Utiliser les ConfigMaps pour les configurations non sensibles** :
   - Centralisez vos configurations d'environnement dans des ConfigMaps.

**Utiliser les Secrets pour les données sensibles** :
   - Les Secrets devraient être utilisés pour des informations telles que les mots de passe, les tokens d'API, ou les clés privées. Assurez-vous que leur accès est sécurisé via des **politiques RBAC** et que leur stockage est chiffré.

**Immutabilité des images** :
   - L'image de votre conteneur doit rester identique entre les environnements (staging, production, etc.). Seule la configuration (via les variables d'environnement) change.

**Gérer dynamiquement les valeurs** :
   - Utilisez des outils de gestion des secrets (comme **Vault**) pour injecter dynamiquement les variables d'environnement dans les Pods, surtout dans les environnements sensibles où les secrets sont renouvelés régulièrement.

---

**Point d'attention sur les mises à jour des volumes de configuration et des pods associées.**

Il ne suffit pas de changer un volume pour qu'il soit automatiquement pris en compte : il faut également lancer un redéploiement des pods pour qu'ils utilisent la nouvelle version.

---


## Le stockage et les Volumes

**Les conteneurs proposent un paradigme immutable : on peut les transformer pendant leur execution (ajouter des fichier, changer des configurations) mais ce n'est pas le mode d'utilisation recommandé.** 

 Les fichiers ajoutés manuellement pendant l'exécution seront alors perdus.

---

**Se pose donc la question de la persistance des données d'une application, par exemple une base de donnée.**  

 Dans un environnement conteneurisé toute persistance est permise via des volumes, sortes de disques durs virtuels, qu'on connecte à nos conteneur.  

 Comme un disque ces volumes sont monté à un emplacement du système de fichier du conteneur.  

 En écrivant dans le dossier en question on écrit alors sur ce disque virtuel qui conservera ses données même si le conteneur est supprimé.

--- 


### Les Volumes Kubernetes

Comme dans Docker, Kubernetes fournit la possibilité de monter des volumes virtuels dans les conteneurs de nos pod.  

 On liste séparément les volumes de notre pod puis on les monte une ou plusieurs dans les différents conteneurs.  

 Exemple:

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

**La problématique des volumes et du stockage est plus compliquée dans kubernetes que dans docker car k8s cherche à répondre à de nombreux cas d'usages.**   

 Il y a donc de nombeux types de volumes kubernetes correspondants à des usages de base et aux solutions proposées par les principaux fournisseurs de cloud.

![](../../static/img/kubernetes/schemas-perso/resources-deps.jpg?width=400px)

---

## Volumes de configuration

### Les ConfigMaps 

**Les objets ConfigMaps permettent d'injecter dans des pods des ensemble clés/valeur de configuration en tant que volumes/fichiers de configuration ou variables d'environnement.**

Cela permet notamment de centraliser et découpler la configuration du déploiement des pods.  

 Par exemple on peut stocker de façon centraliser le nom de domaine à utiliser pour une application et plusieurs de ses microservices pourront venir la récupérer dans la même configmap.

---

### Exemple de configmap et de récupération d'une variable d'environnement


#### En ligne de commande directe

```shell

echo -e "[mysqld]\nuser=mysql\nmax_connections=100" > mysql.conf

kubectl create configmap mysql-config --from-file=mysql.conf


```


#### Via un manifeste YAML


```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  # Déclaration du nom de la config map
  name: mysql-env
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
        # Montage via un volume
        volumeMounts:
        - name: config-volume
          mountPath: /etc/mysql/conf.d        
        # Consommation en tant que variables d'environnement
        env:
        - name: MYSQL_DATABASE
          valueFrom:
            configMapKeyRef:
                # Utilisation du nom de la config map
              name: mysql-env
              key: MYSQL_DATABASE
        ports:
        - containerPort: 3306
      volumes:
      - name: config-volume
        configMap:
          name: mysql-config  # Nom de la ConfigMap

```

---

### Les Secrets

**Les Secrets se manipulent comme des objets ConfigMaps, mais ils sont chiffrés et faits pour stocker des mots de passe, des clés privées, des certificats, des tokens, ou tout autre élément de config dont la confidentialité doit être préservée.**

Un secret se créé avec l'API Kubernetes, puis c'est au pod de demander à y avoir accès.

Il y a plusieurs façons de donner un accès à un secret, notamment :
- le secret est un fichier que l'on monte en tant que volume dans un conteneur (pas nécessairement disponible à l'ensemble du pod).  

 Il est possible de ne jamais écrire ce secret sur le disque (volume `tmpfs`).
- le secret est une variable d'environnement du conteneur.

Pour définir qui et quelle app a accès à quel secret, on peut utiliser les fonctionnalités "RBAC" de Kubernetes.

#### Exemple de secret pour un certificat SSL et son montage comme fichier dans un pods

Création du secret en ligne de commande à partir d'un fichier:

`kubectl create secret generic my-cert --from-file=mycert.pem`

Cela donne par exemple le secret suivant (les données d'un secret sont encodé en base64, un mode de sérialisation qui permet notamment de stocker des données binaires sous forme de texte):

```yaml
apiVersion: v1
data:
  mycert.pem: >
  LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURhekNDQWxPZ0F3SUJBZ0lVRXZsVXV
  yT3RTelN0cFlWaEw1K3B0R2JUVlRFd0RRWUpLb1pJaHZjTkFRRUwKQlFBd1JURUxNQWtHQT
  FVRUJoTUNRVlV4RXpBUkJnTlZCQWdNQ2xOdmJXVXRVM1JoZEdVeElUQWZCZ05WQkFvTQpHR
  Wx1ZEdWeWJtVjBJRmRwWkdkcGRITWdVSFI1SUV4MFpEQWVGdzB5TXpBek1EZ3hOakl5TVRk
  YUZ3MHpNekF6Ck1EVXhOakl5TVRkYU1FVXhDekFKQmdOVkJBWVRBa0ZWTVJNd0VRWURWUVF
  JREFwVGIyMWxMVk4wWVhSbE1TRXcKSHdZRFZRUUtEQmhKYm5SbGNtNWxkQ0JYYVdSbmFYUn
  pJRkIwZVNCTWRHUXdnZ0VpTUEwR0NTcUdTSWIzRFFFQgpBUVVBQTRJQkR3QXdnZ0VLQW9JQ
  kFRQ2YrZHprR2xkTlpoUGVDdTFyOC9taGJyQkNIdlYwSTd4dHhrZ096K1hBCnZuMXpkNktt
  SGlqZGlBWUdLN2EvUVlpQnhpbWljQnYrRkpUY2FoMDJMbkJ1VTlnSmV4QUF0ZnVZb2VoMnJ
  haGgKVXg5bXYyTUhTUnVjQW5VTnpBSForcDZMd2tTZ2lvd1NDTUFxUlJpTkNEMm9FVFM0Rm
  FmL3dHVWRkRnVMN0lsMgptTGxrdkJlWEVRbUJlc1pxR1A5d0RCZlhOeVppbi9xeHRCeFY2d
  kFldjhrK3ZFY3lNQzJIMUdNbFpFZHcwd1o5Cm1yNjhpQkVXNWp0Q0JibFRDUVF0bjZCdDgv
  MCsvMUFDajFTc3FSTHJ1aUJIZ1ljZXdPeXB3WVA3ZEtZajMvODYKaGsxNU5rSUVCVHlzTWh
  rdThjTnZxVXNTaU9wNURRc000bEV6N0lkaXFwblJBZ01CQUFHalV6QlJNQjBHQTFVZApEZ1
  FXQkJUTnh6QmxBanZ1TmFlb2h1bFAxdDRtUXFrY0RqQWZCZ05WSFNNRUdEQVdnQlROeHpCb
  EFqdnVOYWVvCmh1bFAxdDRtUXFrY0RqQVBCZ05WSFJNQkFmOEVCVEFEQVFIL01BMEdDU3FH
  U0liM0RRRUJDd1VBQTRJQkFRQjIKNmpOWmRiWWp2T0dEd0s3ZEhFa2REa1NIa0w3U3A4cWJ
  MakN0NEx1VFlBWHJ5ZURnei9yNGViclNkZDhocmR3LwpzZEtFQTRFM1QyWnhPV2xINmpsVn
  JEZlhNbG1ZTFNvSEFoQWMwM1E4V01YTnkyZlVrSjRhQlJ1MGFMZUM4QnJTClBHT2xFanpEa
  0dsUGJENmI5SGZxRXFHMTRndkZBTG80YUQxRXFIUVRYUEx5WUUvbnd5SlhjTU9ZUlZ5V0xL
  eFYKb3NhYmtHdHVralRRSlpqbWxlb3VzZDhBWGFrS3duV25hM2ErYkhOczFUdmcxUkY1WDh
  xSVc4cGN6SzhadlRVdQpWRUd3clpnOUcrclpvU3RmSHdFaUhjVVVrMGhKTHJkRDlCUGFwZ2
  puMUF0NGJhdnRVNmJIbE5MOGdrRUMzdnlZCmVrc2tPNSs2WDIwaStpUEdRSWp1Ci0tLS0tR
  U5EIENFUlRJRklDQVRFLS0tLS0K
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

---


## Volumes pour la persistence

**Mentionnons quelques d'usage de base des volumes:**

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

En savoir plus sur la [doc officielle](https://kubernetes.io/docs/concepts/storage/storage-classes/) 

---


### Demander des volumes et les liers aux pods :`PersistentVolumes` et `PersistentVolumeClaims`

![](../../static/img/kubernetes/k8s-pvc.png)

**Quand un conteneur a besoin d'un volume, il crée une `PersistentVolumeClaim` : une demande de volume (persistant).**  

 Si une des `StorageClass` du cluster est en capacité de le fournir, alors un `PersistentVolume` est créé et lié à ce conteneur : il devient disponible en tant que volume monté dans le conteneur.

- les *StorageClasses* représentent le stockage physique accessible au cluster selon les paramètres définis par le groupe admin
- les conteneurs demandent du volume avec les `PersistentVolumeClaims`
- les `StorageClasses` répondent aux `PersistentVolumeClaims` en créant des objets `PersistentVolumes` : le conteneur peut accéder à son volume.

En savoir plus sur la [doc officielle](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)

--- 

**Le provisionning de `PersistentVolume` peut être manuel (on crée un objet `PersistentVolume` en amont ou non.**  

 Dans le second cas la création d'un `PersistentVolumeClaim` mène directement à la création d'un volume si possible)

---

### Volume **emptyDir** dans Kubernetes

#### Cas d'usage

**Le volume **emptyDir** est utilisé pour fournir un espace de stockage temporaire à l'intérieur d'un Pod.** 

Ce volume est créé lorsqu'un Pod est assigné à un nœud et est supprimé dès que le Pod est supprimé ou déplacé vers un autre nœud.

Le volume `emptyDir` est vide au démarrage du Pod et peut être utilisé pour stocker des fichiers temporaires, des caches ou des données partagées entre les conteneurs d'un même Pod.

---

#### Cas d'usage typique :
1. **Stockage temporaire** : Utilisé pour stocker des fichiers temporaires, des caches ou des logs générés pendant l'exécution du Pod.
2. **Partage de fichiers entre conteneurs** : Lorsque plusieurs conteneurs dans un même Pod doivent partager des fichiers, un **emptyDir** permet cette communication via un espace de stockage commun.

---

#### Exemple de déclaration d'un volume **emptyDir**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: emptydir-example
spec:
  containers:
  - name: busybox
    image: busybox
    command: ["sh", "-c", "sleep 3600"]
    volumeMounts:
    - mountPath: /cache
      name: cache-volume
  volumes:
  - name: cache-volume
    emptyDir: {}
```

Ce répertoire peut être utilisé pour stocker des fichiers partagés ou temporaires.

### Points importants :
- **Durée de vie** : Le contenu du volume **emptyDir** est supprimé dès que le Pod est supprimé.
- **Type de stockage** : Par défaut, le stockage est sur disque, mais il peut aussi être en mémoire si spécifié (`emptyDir: { medium: "Memory" }`), ce qui est utile pour des performances élevées ou pour réduire les I/O disque.

---

### Backup de volume

**Il existe plusieurs méthodes pour effectuer des sauvegardes de données persistantes dans Kubernetes :** 

- Utiliser des outils de backup Kubernetes : Certains outils de sauvegarde Kubernetes, tels que Velero (anciennement Heptio Ark), permettent de sauvegarder et de restaurer des données persistantes.  

 Ces outils peuvent être configurés pour effectuer des sauvegardes régulières des volumes persistants dans votre cluster Kubernetes, puis les stocker dans un emplacement de stockage sécurisé.

- Utiliser des outils classiques de backups plannifiés depuis vos pods (push depuis le pod): Les volumes persistants Kubernetes sont généralement montés en tant que systèmes de fichiers dans les pods.  

 En utilisant des outils de sauvegarde de fichiers tels que rsync, borg, etc.

on peut sauvegarder ces volumes persistants sur des emplacements de stockage externes.  

 On peut également utiliser des scripts basés sur kubectl plannifiés depuis un serveur de backup se connectent à l'intérieur des pods pour récupérer les données.

---

## Configurer les ressources et les bases de sécurité des Pods dans Kubernetes

Dans Kubernetes, la configuration des ressources (CPU et mémoire) et la mise en place de politiques de sécurité des Pods sont essentielles pour garantir à la fois l'efficacité des workloads et la sécurité du cluster. Ces mécanismes permettent de mieux contrôler l'utilisation des ressources, d'assurer que les Pods fonctionnent correctement sans compromettre d'autres applications, et de sécuriser les environnements multi-tenant en restreignant les actions des Pods.

---

### Configuration des ressources des Pods

La configuration des **limites de ressources** (CPU et mémoire) permet de garantir une utilisation optimale du cluster et de prévenir l'épuisement des ressources.

#### Ressources : Demandes (Requests) et Limites (Limits)

- **Requests** :
  - Représente la quantité minimale de ressources (CPU, mémoire) que le Pod requiert pour être programmé sur un nœud. Kubernetes s'assure que le Pod dispose au moins de ces ressources.
  - **Exemple d'usage** : Garantir qu'une application critique ait toujours les ressources minimales nécessaires pour fonctionner correctement.

- **Limits** :
  - Détermine la quantité maximale de ressources que le Pod peut utiliser. Si le Pod dépasse cette limite (notamment pour la mémoire), Kubernetes peut tuer ou restreindre le Pod pour libérer les ressources.
  - **Exemple d'usage** : Empêcher une application gourmande en mémoire d'épuiser les ressources du cluster.

#### Exemple de configuration des ressources pour un Pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: resource-demo
spec:
  containers:
  - name: demo-container
    image: nginx
    resources:
      requests:
        memory: "64Mi"
        cpu: "250m"
      limits:
        memory: "128Mi"
        cpu: "500m"
```

Dans cet exemple :
- **Requests** : Le Pod demande 64 MiB de mémoire et 250 millicores de CPU pour garantir qu'il ait un minimum de ressources.
- **Limits** : Le Pod ne peut pas dépasser 128 MiB de mémoire et 500 millicores de CPU.

#### Pourquoi configurer les ressources ?

1. **Prévention de la sur-utilisation** : Les limites empêchent un Pod de consommer plus de ressources que ce qui est prévu, ce qui protège les autres applications du cluster.
2. **Meilleure planification** : Les demandes de ressources aident Kubernetes à planifier les Pods sur des nœuds ayant les ressources nécessaires disponibles.
3. **Qualité de service (QoS)** : Kubernetes classifie les Pods selon la configuration des ressources (BestEffort, Burstable, Guaranteed), influençant leur priorité en cas de surcharge.

---


### Sécuriser les Pods dans Kubernetes avec le **SecurityContext**

**Le **SecurityContext** dans Kubernetes est une spécification clé pour renforcer la sécurité des Pods et des conteneurs en contrôlant le comportement d'exécution.** 

Il permet de définir des paramètres de sécurité tels que l’utilisateur sous lequel le conteneur s’exécute, les capacités de privilèges, et la gestion des permissions pour les fichiers et processus.

Le **SecurityContext** peut être appliqué à deux niveaux :
- **Au niveau du Pod** : Les règles s'appliquent à tous les conteneurs du Pod.
- **Au niveau des conteneurs individuels** : Les règles s'appliquent à des conteneurs spécifiques à l'intérieur du Pod.

---

### Directives associées au **SecurityContext**

**Voici quelques exemples de directives** 

- **runAsUser** :
   - Définit l'UID (User ID) sous lequel le conteneur va s'exécuter.
   - Par défaut, les conteneurs s'exécutent en tant qu'utilisateur root (UID 0), ce qui présente des risques de sécurité. Il est recommandé de définir un utilisateur non-root.

   **Exemple :**

   ```yaml
   securityContext:
     runAsUser: 1000  # Utilisateur non root avec l'UID 1000
   ```

- **runAsGroup** :
   - Définit le GID (Group ID) sous lequel le conteneur s'exécute. Cela permet de définir le groupe propriétaire des fichiers et des processus dans le conteneur.

   **Exemple :**

   ```yaml
   securityContext:
     runAsGroup: 3000  # Groupe non root avec le GID 3000
   ```

- **runAsNonRoot** :
   - Force l’exécution du conteneur en tant qu’utilisateur non-root. Si la directive est activée, Kubernetes rejettera le Pod si l'image tente de s'exécuter avec l'utilisateur root.

   **Exemple :**

   ```yaml
   securityContext:
     runAsNonRoot: true
   ```


- **allowPrivilegeEscalation** :
   - Empêche un processus d'augmenter ses privilèges via des moyens comme `setuid` ou `setgid`. Il est recommandé de définir cette valeur à `false` pour empêcher des escalades de privilèges non souhaitées.

   **Exemple :**

   ```yaml
   securityContext:
     allowPrivilegeEscalation: false
   ```



- **readOnlyRootFilesystem** :
   - Force le système de fichiers du conteneur à être monté en mode lecture seule. Cela réduit les risques d'attaques qui pourraient tenter d'écrire ou modifier des fichiers critiques.

   **Exemple :**

   ```yaml
   securityContext:
     readOnlyRootFilesystem: true
   ```

---

### Exemple complet de **SecurityContext** pour un Pod

Voici un exemple d'un Pod avec un **SecurityContext** bien défini au niveau du Pod et du conteneur, appliquant plusieurs de ces bonnes pratiques.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secure-pod
spec:
  securityContext:  # Contexte de sécurité pour tout le Pod
    runAsUser: 1000  # Exécuter le Pod en tant qu'utilisateur non root
    runAsGroup: 3000 # Définir le groupe propriétaire
    fsGroup: 2000    # Définir le groupe pour les volumes montés

  containers:
  - name: secure-container
    image: nginx
    securityContext:  # Contexte de sécurité au niveau du conteneur
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
      runAsNonRoot: true
      capabilities:
        drop:
        - NET_ADMIN
      seccompProfile:
        type: RuntimeDefault
```

### Explication de cet exemple :
- **runAsUser** et **runAsGroup** : Le conteneur est exécuté sous un utilisateur et un groupe non-root.
- **allowPrivilegeEscalation** : Empêche l’escalade de privilèges.
- **readOnlyRootFilesystem** : Le système de fichiers racine est en mode lecture seule, renforçant la sécurité.
- **capabilities.drop** : Certaines capacités, comme `NET_ADMIN`, sont supprimées pour réduire les droits.
- **seccompProfile** : Utilisation du profil Seccomp par défaut pour restreindre les appels système.

---

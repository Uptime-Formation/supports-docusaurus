
---
title:   Persistance
weight: 1
---

### Quickstart : Installation et Configuration de Longhorn pour la Gestion des Volumes Persistants dans Kubernetes

Ce TP vous guide à travers l'installation et la configuration de Longhorn pour la gestion des volumes persistants dans un cluster Kubernetes, en utilisant des disques montés en loopback.

---

### Étape 1 : Préparer des disques en loopback

1. **Créer des fichiers de disque**
   ```sh
   dd if=/dev/zero of=/var/lib/longhorn-disk-a bs=1G count=2
   dd if=/dev/zero of=/var/lib/longhorn-disk-b bs=1G count=2
   ```

2. **Créer des devices loopback**
   ```sh
   losetup /dev/loop0 /var/lib/longhorn-disk-a
   losetup /dev/loop1 /var/lib/longhorn-disk-b
   ```

3. **Formater les disques**
   ```sh
   mkfs.ext4 /dev/loop0
   mkfs.ext4 /dev/loop1
   ```

4. **Créer des points de montage**
   ```sh
   mkdir /mnt/longhorn-disk-a /mnt/longhorn-disk-b
   ```

5. **Monter les disques**
   ```sh
   mount /dev/loop0 /mnt/longhorn-disk-a
   mount /dev/loop1 /mnt/longhorn-disk-b
   ```

---

### Étape 2 : Installer Longhorn via Helm

1. **Ajouter le dépôt Helm de Longhorn**
   ```sh
   helm repo add longhorn https://charts.longhorn.io
   helm repo update
   ```

2. **Installer Longhorn**
   ```sh
   helm install longhorn longhorn/longhorn --namespace longhorn-system --create-namespace
   ```

---

### Étape 3 : Configurer les volumes persistants

1. **Définir un PersistentVolume (pv.yaml)**
   ```yaml
   apiVersion: v1
   kind: PersistentVolume
   metadata:
     name: longhorn-pv-a
   spec:
     capacity:
       storage: 2Gi
     accessModes:
       - ReadWriteOnce
     persistentVolumeReclaimPolicy: Retain
     storageClassName: longhorn
     hostPath:
       path: /mnt/longhorn-disk-a
   ---
   apiVersion: v1
   kind: PersistentVolume
   metadata:
     name: longhorn-pv-b
   spec:
     capacity:
       storage: 2Gi
     accessModes:
       - ReadWriteOnce
     persistentVolumeReclaimPolicy: Retain
     storageClassName: longhorn
     hostPath:
       path: /mnt/longhorn-disk-b
   ```

2. **Appliquer la configuration**
   ```sh
   kubectl apply -f pv.yaml
   ```

3. **Définir un PersistentVolumeClaim (pvc.yaml)**
   ```yaml
   apiVersion: v1
   kind: PersistentVolumeClaim
   metadata:
     name: longhorn-pvc-a
   spec:
     accessModes:
       - ReadWriteOnce
     storageClassName: longhorn
     resources:
       requests:
         storage: 2Gi
   ---
   apiVersion: v1
   kind: PersistentVolumeClaim
   metadata:
     name: longhorn-pvc-b
   spec:
     accessModes:
       - ReadWriteOnce
     storageClassName: longhorn
     resources:
       requests:
         storage: 2Gi
   ```

4. **Appliquer la configuration**
   ```sh
   kubectl apply -f pvc.yaml
   ```

---

### Étape 4 : Utiliser les volumes persistants dans un pod

1. **Définir un Pod utilisant les PVCs (pod.yaml)**
   ```yaml
   apiVersion: v1
   kind: Pod
   metadata:
     name: longhorn-test-pod
   spec:
     containers:
     - name: longhorn-test-container
       image: busybox
       command: ["sleep", "3600"]
       volumeMounts:
       - mountPath: "/data-a"
         name: longhorn-volume-a
       - mountPath: "/data-b"
         name: longhorn-volume-b
     volumes:
     - name: longhorn-volume-a
       persistentVolumeClaim:
         claimName: longhorn-pvc-a
     - name: longhorn-volume-b
       persistentVolumeClaim:
         claimName: longhorn-pvc-b
   ```

2. **Appliquer la configuration**
   ```sh
   kubectl apply -f pod.yaml
   ```

---

## La persistance de données : un sujet complEx: ### Historique des technologies de mise à disposition de volumes sur le réseau

**Les technologies de mise à disposition de volumes sur le réseau ont évolué considérablement au fil des décennies.**

Au début, les systèmes Unix utilisaient NFS (Network File System) pour permettre le partage de fichiers entre machines sur un réseau local.

Ensuite, les systèmes d'exploitation comme Windows ont adopté SMB/CIFS (Server Message Block/Common Internet File System) pour des fonctionnalités similaires.

Avec le temps, des solutions plus robustes et distribuées comme iSCSI (Internet Small Computer Systems Interface) ont émergé, permettant de connecter des disques distants via TCP/IP.

L'avènement des technologies de virtualisation et des conteneurs a conduit à des solutions de stockage distribuées telles que Ceph et GlusterFS, qui offrent une haute disponibilité et une évolutivité accrue.

**Kubernetes a standardisé l'intégration de ces solutions via les CSI (Container Storage Interface) et les plugins de stockage, facilitant ainsi la gestion des volumes persistants dans des environnements cloud-native.**

---

### Difficultés de la persistance dans les systèmes distribués

**Dans les systèmes distribués, la mise à disposition de block devices over network pose plusieurs défis.** 

L'architecture d'une solution de stockage de disque sur le réseau répond à des contraintes logiques, pratiques et matérielles.

1. **Acquittements d'écriture** : Choisir entre les acquittements synchrones (garantissent la persistance avant de répondre) et asynchrones (répondent avant que les données ne soient persistées) pour un équilibre entre performance et sécurité.
2. **Redondance de données** : Utiliser des techniques de redondance comme le mirroring ou l'EC (Erasure Coding) pour garantir la résilience et la disponibilité des données, comme dans Ceph.
3. **Gestion de quorum** : Implémenter un système de quorum pour garantir la cohérence des données en cas de pannes de nœuds ou de réseaux.
4. **Scalabilité** : Assurer la capacité d'ajouter ou de retirer des nœuds sans interrompre le service pour répondre aux besoins de stockage croissants.
5. **Monitoring et gestion proactive** : Intégrer des outils de surveillance et d'alerting pour détecter et résoudre rapidement les problèmes de performance ou de défaillance matérielle.
6. **Sécurité des données** : Mettre en place des mécanismes de chiffrement pour les données en transit et au repos pour protéger contre les accès non autorisés.
7. **Automatisation des backups** : Intégrer des solutions automatisées pour la sauvegarde régulière des données afin d'assurer la récupération en cas de perte de données.
8. **Gestion des snapshots** : Utiliser des snapshots pour permettre des restaurations rapides et minimiser les temps d'arrêt en cas de corruption ou de perte de données.

--- 

**La maintenance pratique inclut les aspects suivants :**

- **Backups** : Sauvegarder les données de manière régulière et fiable pour prévenir les pertes en cas de panne.
- **Monitoring des disques** : Surveiller l'état et les performances des disques pour détecter et anticiper les problèmes.
- **Changement matériel défaillant** : Remplacer rapidement et efficacement les composants matériels défaillants sans interruption majeure du service.
- **Accroissement de la capacité** : Augmenter la capacité de stockage de manière transparente et sans affecter les applications en cours d'exécution.

--- 

### Comparaison de solutions de stockage réseau

| Critère                  | NFS                             | GlusterFS                       | Ceph                                 | Longhorn                            |
|--------------------------|---------------------------------|---------------------------------|--------------------------------------|-------------------------------------|
| Acquittements d'écriture | Asynchrones                     | Asynchrones                     | Synchrones/Asynchrones (configurable)| Synchrones/Asynchrones (configurable)|
| Redondance de données    | Non                             | Réplication                     | Réplication, Fragmentation           | Réplication                          |
| Gestion de quorum        | Non                             | Oui                             | Oui                                  | Non                                 |
| Scalabilité              | Limitée                         | Haute                           | Très haute                           | Haute                               |
| Chiffrement              | Non (doit être ajouté séparément)| Oui (TLS pour transport)        | Oui (chiffrement au repos et en transit)| Oui (TLS pour transport)            |
| Backups et snapshots     | Non natif (doit être ajouté)    | Oui                             | Oui                                  | Oui                                 |

### Conclusion

Ce tableau compare les solutions de stockage réseau en termes d'acquittements d'écriture, de redondance de données, de gestion de quorum, de scalabilité, de chiffrement, et de capacités de backups et de snapshots, permettant de choisir la solution la mieux adaptée en fonction des besoins spécifiques.

--- 


## Solutions Kubernetes

**Kubernetes propose plusieurs mécanismes pour résoudre ces problèmes de persistance :**

### Plugins de stockage

**Kubernetes utilise des plugins de stockage pour intégrer différentes solutions de stockage.**

La norme des plugins de stockage pour Kubernetes est appelée **Container Storage Interface (CSI)**.

La documentation est disponible sur le [site officiel de Kubernetes](https://kubernetes-csi.github.io/docs/).

CSI permet l'intégration de solutions de stockage externes avec Kubernetes via des drivers.

Cela fonctionne en déployant des plugins CSI dans le cluster Kubernetes, qui communiquent avec les systèmes de stockage sous-jacents.

Pour ajouter un plugin CSI, vous devez déployer les composants nécessaires (driver CSI) en utilisant des fichiers de configuration YAML spécifiques au plugin choisi.

### Storage Class

**Les Storage Classes définissent les types de stockage disponibles et leurs caractéristiques (performances, résilience, etc.).**
   
Pour associer une StorageClass avec un plugin Container Storage Interface (CSI), on spécifie le provisioner CSI dans la définition de la StorageClass.

Pour offrir plusieurs qualités de disques, on crée plusieurs StorageClasses avec des paramètres variés tels que la taille minimale, la vitesse (IOPS), et le type de disque (SSD, HDD).

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: fast-ceph
provisioner: rook-ceph.rbd.csi.ceph.com
parameters:
  clusterID: rook-ceph
  pool: replicapool
  imageFormat: "2"
  imageFeatures: layering
  csi.storage.k8s.io/fstype: ext4
  csi.storage.k8s.io/provisioner-secret-name: rook-csi-rbd-provisioner
  csi.storage.k8s.io/provisioner-secret-namespace: rook-ceph
  csi.storage.k8s.io/controller-expand-secret-name: rook-csi-rbd-provisioner
  csi.storage.k8s.io/controller-expand-secret-namespace: rook-ceph
  csi.storage.k8s.io/node-stage-secret-name: rook-csi-rbd-node
  csi.storage.k8s.io/node-stage-secret-namespace: rook-ceph
  size: 10Gi
reclaimPolicy: Delete
allowVolumeExpansion: true
volumeBindingMode: Immediate

```

Cette configuration utilise un plugin CSI pour provisionner des disques SSD rapides avec une taille minimale de 10Gi dans la zone spécifiée.

--- 


### Persistent Volumes (PV)

Les administrateurs créent et gèrent les Persistent Volumes, qui représentent des unités de stockage abstraites.

Les PVs sont découplés du cycle de vie des pods, garantissant la persistance des données.

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-fast-ceph
spec:
  capacity:
    storage: 100Gi
  accessModes:
    - ReadWriteOnce
  storageClassName: fast-ceph
  csi:
    driver: rook-ceph.rbd.csi.ceph.com
    fsType: ext4
    volumeAttributes:
      clusterID: rook-ceph
      pool: replicapool
      imageFormat: "2"
      imageFeatures: layering
    volumeHandle: "unique-volume-id"
    nodeStageSecretRef:
      name: rook-csi-rbd-node
      namespace: rook-ceph
    controllerExpandSecretRef:
      name: rook-csi-rbd-provisioner
      namespace: rook-ceph
    controllerPublishSecretRef:
      name: rook-csi-rbd-provisioner
      namespace: rook-ceph
```
---

### Persistent Volume Claims (PVC)

Les utilisateurs créent des Persistent Volume Claims pour demander des ressources de stockage sans avoir à connaître les détails de l'infrastructure sous-jacente.

Les PVCs sont automatiquement associés aux PVs disponibles, en fonction des critères définis dans les Storage Classes.~~

```yaml 
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-pvc
  namespace: default
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 20Gi
  storageClassName: fast-ceph
```

---

### Quelques produits Kubernetes pour les stockages distribués

- **OpenEBS** : Solution de stockage en mode bloc.
- **Longhorn** : Solution de stockage en mode bloc.
- **Rook** : Orchestrateur pour diverses solutions de stockage (Ceph, Cassandra, NFS, etc.).
- **MinIO** : Système de stockage d'objets compatible S3.

--- 

### Et les bases de données ?

**Il existe plusieurs patterns d'architecture pour les bases de données dans Kubernetes**

Voici quelques critères de choix:

- **Performance et latence** : Bases de données proches des applications pour réduire la latence.
- **Isolation** : Sécuriser les bases de données en les séparant des charges applicatives 
- **Scalabilité** : Utiliser une plateforme capable d'accueillir rapidement de nouveaux noeuds
- **Gestion et maintenance** : Adapter les efforts de maintenance au budget et aux compétences internes.

--- 

### Base de données managée 

**Utiliser des services managés comme AWS RDS, GCP Cloud SQL ou Azure Database.**

Les bases de données sont gérées par le fournisseur de cloud, offrant haute disponibilité, sauvegarde automatique et scalabilité.

--- 

### Base de données dans le namespace de l'application

**Déployer dans le même namespace que l'application pour simplifier la gestion et le réseau.**

Idéal pour des environnements de développement ou des applications de petite échelle, ex: Redis de cache local.

--- 

### Base de données dans le cluster Kubernetes

**Déployer des bases de données dans le même cluster Kubernetes mais dans des namespaces dédiés présente plusieurs avantages.**

Cette approche offre une gestion centralisée des ressources tout en assurant l'isolation des applications et des bases de données.

Utiliser des taints et des tolerations permet de spécifier que les pods de la base de données doivent être déployés sur des nœuds physiques équipés de disques NVMe, offrant des performances de stockage élevées.

Cela optimise l'accès aux données pour des applications nécessitant des I/O intensifs, tout en maintenant une structure de gestion simplifiée et sécurisée au sein du cluster.

--- 

### Base de données dans un cluster dédié

**Avoir un cluster Kubernetes séparé exclusivement pour les bases de données.**

Cela permet d'isoler les ressources et de réduire le risque de contention des ressources avec les applications.

Cette approche permet de standardiser les outils propres à la gestion des bases de données (operators, monitoring), d'avoir des noeuds physiques avec du matériel dédié dans une architecture scalable et de limiter les accès aux DBA.

Cette solution est en cloud privé celle qui permet de s'approcher des performances des services managés.

--- 

### Base de données sur des VMs

**Héberger les bases de données sur des machines virtuelles en dehors du cluster Kubernetes, tout en faisant tourner les applications dans Kubernetes.**

Cette approche combine la flexibilité des VMs pour les bases de données avec les avantages de l'orchestration des conteneurs pour les applications.

C'est la solution classique et conservatrice (Pet vs. Cattle), qui permet d'obtenir de très bons niveaux de compartimentations, de performance, de maintenance, et de sécurité.

--- 

## TP : Installation du MySQL Operator et d'une base de données MySQL avec réplication master-slave

**Installer le MySQL Operator dans un cluster Kubernetes et déployer une instance de base de données MySQL avec réplication master-slave row-based.**

#### Prérequis
- Un cluster Kubernetes fonctionnel
- kubectl installé et configuré

### Étape 1 : Installer le MySQL Operator

1. **Créer le namespace pour le MySQL Operator**
   ```sh
   kubectl create namespace mysql-operator
   ```

2. **Installer le MySQL Operator en utilisant Helm**
   ```sh
   helm repo add presslabs https://presslabs.github.io/charts
   helm repo update
   helm install mysql-operator presslabs/mysql-operator --namespace mysql-operator
   ```

### Étape 2 : Déployer une base de données MySQL avec réplication

1. **Créer un fichier de configuration pour la base de données MySQL (mysql-cluster.yaml)**
   ```yaml
   apiVersion: mysql.presslabs.org/v1alpha1
   kind: MysqlCluster
   metadata:
     name: my-mysql-cluster
     namespace: mysql-operator
   spec:
     replicas: 2
     secretName: my-mysql-secret
     mysqlVersion: "5.7"
     masterSpec:
       mysqlConf:
         log-bin: mysql-bin
         binlog-format: ROW
         server-id: 1
         log-slave-updates: true
     replicaSpec:
       mysqlConf:
         server-id: 2
         log-bin: mysql-bin
         binlog-format: ROW
         relay-log: relay-bin
   ```

2. **Créer un secret pour le mot de passe MySQL**
   ```sh
   kubectl create secret generic my-mysql-secret --from-literal=ROOT_PASSWORD=root_password -n mysql-operator
   ```

3. **Appliquer la configuration pour déployer le cluster MySQL**
   ```sh
   kubectl apply -f mysql-cluster.yaml
   ```

### Étape 3 : Vérification du déploiement

1. **Vérifier que le cluster MySQL est en cours d'exécution**
   ```sh
   kubectl get pods -n mysql-operator
   ```

2. **Obtenir l'adresse IP du service MySQL**
   ```sh
   kubectl get svc -n mysql-operator
   ```


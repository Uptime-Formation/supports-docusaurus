---
title: TP optionnel - Backuper kubernetes avec Velero
# sidebar_class_name: hidden
---

sources: 

- https://velero.io/docs/v1.13/how-velero-works/
- https://medium.com/cloudnloud/velero-backups-in-kubernetes-39af7e92d992

### Présentation

Velero est un operateur de backup natif kubernetes. Il permet de backup tout un cluster ou namespace par namespace les resources directement en interrogeant l'api de k8s.

Concrêtement:

- créé un fichier tar pour la cible à backuper (les manifestes kubernetes mais également les PersistantVolumes associés au pod pour restaurer l'état)
- envoie ce fichier à restic (par default mais peut être un autre) un outil de backup classique qui configure un backup repo dans un stockageBackend généralement S3 (amazon, minio ou garage).

Velero est controlable via une CLI et/ou des CRDs

#### Les CRDs de Velero


- **Backup** : Le CRD `Backup` est utilisé pour définir une opération de sauvegarde dans Velero. Il contient des informations telles que le nom de la sauvegarde, les ressources Kubernetes à inclure dans la sauvegarde, les plans de rétention et les détails de l'état de la sauvegarde.

- **Restore** : Le CRD `Restore` est utilisé pour définir une opération de restauration dans Velero. Il contient des informations sur la restauration, telles que le nom de la sauvegarde à partir de laquelle restaurer, les ressources à restaurer et les options de restauration.

- **Schedule** : Le CRD `Schedule` est utilisé pour définir des horaires pour les opérations de sauvegarde automatiques dans Velero. Il permet de planifier des sauvegardes récurrentes à des intervalles spécifiés, avec des options pour inclure ou exclure certaines ressources.

- **DeleteBackup** : Le CRD `DeleteBackup` est utilisé pour définir des règles de suppression pour les sauvegardes dans Velero. Il permet de spécifier des critères de suppression pour les sauvegardes, tels que l'âge de la sauvegarde ou le nombre maximal de sauvegardes à conserver.

- **DeleteRequest** : Le CRD `DeleteRequest` est utilisé pour définir des demandes de suppression pour les ressources Kubernetes dans Velero. Il permet de spécifier les ressources à supprimer et les options de suppression, telles que la récursivité et la force.

- **DownloadRequest** : Le CRD `DownloadRequest` est utilisé pour définir des demandes de téléchargement pour les sauvegardes dans Velero. Il permet de spécifier les sauvegardes à télécharger et les destinations de téléchargement.

- **BackupStorageLocation** : Le CRD `BackupStorageLocation` est utilisé pour définir les emplacements de stockage où les sauvegardes Velero sont stockées. Il permet de spécifier les détails de connexion aux emplacements de stockage, tels que les fournisseurs de cloud, les emplacements locaux ou les systèmes de fichiers.

Ces CRDs constituent une partie importante de la configuration et de l'utilisation de Velero pour la sauvegarde et la restauration des ressources dans Kubernetes. Ils permettent aux utilisateurs de définir des stratégies de sauvegarde, des horaires de sauvegarde automatiques et des règles de rétention des sauvegardes.


### Installer la cli velero

```sh
cd /tmp
wget https://github.com/vmware-tanzu/velero/releases/download/v1.13.1/velero-v1.13.1-linux-amd64.tar.gz
tar -zvf velero-v1.13.1-linux-amd64.tar.gz
mv velero-v1.13.1-linux-amd64/velero /usr/local/bin
velero version
pip install awscli
```

### Tester l'accès à un storage s3

Créez le fichier `~/.awsrc`

```sh
export AWS_SECRET_ACCESS_KEY=b254f11f28bee56be8f171c2919d32e1dfe62ee0e243e1aca0b989f6ebf0cecd
export AWS_ACCESS_KEY_ID=GK2b96ddf577672cd1e759dd25
export AWS_DEFAULT_REGION='garage'
export AWS_ENDPOINT_URL='http://192.168.<ip>:3900'

aws --version
```

Lancez : `source .awsrc && aws s3 ls` pour tester

Créez ensuite `~/.velero-bucket-credential`

```ini
[default]
aws_access_key_id = GK2b96ddf577672cd1e759dd25
aws_secret_access_key = b254f11f28bee56be8f171c2919d32e1dfe62ee0e243e1aca0b989f6ebf0cecd

```

### Installer l'opérateur velero dans le cluster

```sh
velero install \
    --use-node-agent \
    --provider aws \
    --plugins velero/velero-plugin-for-aws:v1.6.1 \
    --bucket velero-tp \
    --secret-file ~/.velero-bucket-credentials \
    --use-volume-snapshots=false \
    --backup-location-config region=garage,s3ForcePathStyle="true",s3Url=http://192.168.1.167:3900
```


### Tutoriel backup restore stateful application

https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid-Integrated-Edition/1.18/tkgi/GUID-velero-stateful-ns-csi.html

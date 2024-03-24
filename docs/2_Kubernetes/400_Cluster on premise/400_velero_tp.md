---
title: TP optionnel - Backuper kubernetes avec Velero
sidebar_class_name: hidden
---


sources: 

- https://velero.io/docs/v1.13/how-velero-works/
- https://medium.com/cloudnloud/velero-backups-in-kubernetes-39af7e92d992

### Accéder à un storage s3


`.awsrc`

```sh
export AWS_SECRET_ACCESS_KEY=b254f11f28bee56be8f171c2919d32e1dfe62ee0e243e1aca0b989f6ebf0cecd
export AWS_ACCESS_KEY_ID=GK2b96ddf577672cd1e759dd25
export AWS_DEFAULT_REGION='garage'
export AWS_ENDPOINT_URL='http://192.168.<ip>:3900'

aws --version
```

`.velero-bucket-credential`


### Installer l'opérateur velero dans le cluster

velero install \
    --use-node-agent \
    --provider aws \
    --plugins velero/velero-plugin-for-aws:v1.6.1 \
    --bucket velero-tp \
    --secret-file ~/.velero-bucket-credentials \
    --use-volume-snapshots=false \
    --backup-location-config region=garage,s3ForcePathStyle="true",s3Url=http://192.168.1.167:3900


### Faire un backup 


Par défaut : velero backup create everything-backup

velero backup create nginx-backup --include-namespaces nginx


### Restorer le backup
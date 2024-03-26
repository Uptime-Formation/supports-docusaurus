---
title: TP optionnel - Backuper kubernetes avec Velero
# sidebar_class_name: hidden
---

sources: 

- https://velero.io/docs/v1.13/how-velero-works/
- https://medium.com/cloudnloud/velero-backups-in-kubernetes-39af7e92d992

### Tester l'accès à un storage s3

`.awsrc`

```sh
export AWS_SECRET_ACCESS_KEY=b254f11f28bee56be8f171c2919d32e1dfe62ee0e243e1aca0b989f6ebf0cecd
export AWS_ACCESS_KEY_ID=GK2b96ddf577672cd1e759dd25
export AWS_DEFAULT_REGION='garage'
export AWS_ENDPOINT_URL='http://192.168.<ip>:3900'

aws --version
```

`source .awsrc && aws s3 ls`

`.velero-bucket-credential`

```ini
[default]
aws_access_key_id = GK2b96ddf577672cd1e759dd25
aws_secret_access_key = b254f11f28bee56be8f171c2919d32e1dfe62ee0e243e1aca0b989f6ebf0cecd

```

### Installer l'opérateur velero dans le cluster

velero install \
    --use-node-agent \
    --provider aws \
    --plugins velero/velero-plugin-for-aws:v1.6.1 \
    --bucket velero-tp \
    --secret-file ~/.velero-bucket-credentials \
    --use-volume-snapshots=false \
    --backup-location-config region=garage,s3ForcePathStyle="true",s3Url=http://192.168.1.167:3900


### Tutoriel backup restore stateful application

https://docs.vmware.com/en/VMware-Tanzu-Kubernetes-Grid-Integrated-Edition/1.18/tkgi/GUID-velero-stateful-ns-csi.html

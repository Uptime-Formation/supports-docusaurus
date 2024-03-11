---
title:  Aperçu de K8S
weight: 36
---

## Aperçu de K8S


## Objectifs pédagogiques
    - Comprendre les grandes lignes de l'architecture de Kubernetes
    - Connaître les objets principaux de Kubernetes 

# L'architecture de Kubernetes 

**Tout est un conteneur** 

L'infrastructure logicielle de Kubernetes est basé un jeu d'API, implémenté par 2 outils interactifs en ligne de commande 

* kubeadm pour les administrateurs
* kubectl pour les utilisateurs

De fait il existe des GUI permettant de piloter Kubernetes, comme Lens ou des panels web.

Les composants effectifs de Kubernetes (API, pilotage des noeuds, etc.) sont tous des conteneurs.

Ceci simplifie la mise à jour du système.

**Un control plane d'administration et des nodes d'exécution** 

Le control plane est la partie administrative et les noeuds sont destinés aux conteneurs des utilisateurs.

Les noeuds reçoivent les demandes du control plane et les appliquent.

Le control plane est chargé de recevoir les appels d'API, de gérer les AAA (Authentification Authorisation Accounting), et de traiter l'orchestration.

**Un système d'orchestration basé sur les intentions** 

Les manifestes envoyés par les utilisateurs définissent l'état idéal souhaité par l'utilisateur.

L'orchestrateur peut rejeter certaines requêtes invalides.

Les requêtes valides sont traitées de manière asynchrone selon un plan de réalisation ordonné.

**De la sécurité intégrée et intégrable**

K8S utilise du Role Based Access Control pour les utilisateurs, et des service accounts pour accéder à l'API.  

Les ressources sont cloisonnées et limitées via des namespaces de cluster.

Les règles de sécurisation des conteneurs sont définies par les utilisateurs, mais on peut imposer des minimums (ex: no root user, read only, etc.).

Des règles de sécurité réseaux sont définies pour bloquer les flux indésirables.

Et il existe tout un écosystème de solutions dédiées, comme Falco qui surveille au niveau des appels système que rien d'anormal ne se produise, et logge tous les appels.



# Les principales ressources utilisateurs 

Dans Kubernetes, les utilisateurs utilisent les ressources mises à disposition par l'API  

Tout ou partie de ces ressources est définie dans des fichiers YAML complexes.

```yaml
  1 escron:
  2   restartPolicy: "Never"
  3   job: # You MUST provide this entry
  4     activeDeadlineSeconds: 7200
  5     backoffLimit: 1
  6     completions: 1
  7   cronjob:
  8     schedule: "33 3 * * *"
  9     concurrencyPolicy: "Forbid" # OPTIONAL
 10     failedJobsHistoryLimit: 1 # OPTIONAL
 11     successfulJobsHistoryLimit: 3 # OPTIONAL
 12     startingDeadlineSeconds: 600 # OPTIONAL
 13     suspend: false # OPTIONAL
 14   configmaps:
 15     scripts:
 16       mountpath: "/opt/"
 17       data:
 18         startScript: # The secret name
 19           # Fetch teh secrets from vault using the vals tool https://github.com/variantdev/vals
 20           subPath: "gs-backup.sh"
 21           content: |
 22             #!/bin/sh
 23             set -e
 24             set -x
 25             # Get current snapshot repo list
 26             SNAP=$( curl -X GET "$ES_SERVER:9200/_snapshot" )
 27             # Add snapshot repo if empty
 28             if [[ '{}' == "$SNAP" ]] ; then
 29               curl -X PUT "$ES_SERVER:9200/_snapshot/gs-backup"  -H 'Content-Type: application/json' -d "
 30               {
 31                 \"type\": \"gcs\",
 32                 \"settings\":
 33                 {
 34                   \"bucket\": \"$ES_BACKUP_BUCKET\",
 35                   \"base_path\": \"backup\"
 36                 }
 37               }"
 38             else
 39               # Remove backups older than $ES_BACKUP_RETENTION days
 40               LIMIT=$(( $( date +%s ) - $(( 86400 * $ES_BACKUP_RETENTION )) ))
 41               curl -s \"http://$ES_SERVER:9200/_cat/snapshots/gs-backup?v=true&s=id\" | tail -n +2 | while read I    D STATE TSTART OTHER; do
 42                   [[ \"$TSTART\" -gt \"$LIMIT\" ]] &&  echo \"KEEP snapshot $ID\" && continue
 43                   echo \"DELETE snapshot '$ID' with state '$STATE'\"
 44                   curl -X DELETE \"$ES_SERVER:9200/_snapshot/gs-backup/$ID\"
 45               done
 46             fi
 47             CURDATE=$( date  +'%Y-%m-%d' )
 48             echo CREATE snapshot \"${CURDATE}\"
 49             curl -X PUT "$ES_SERVER:9200/_snapshot/gs-backup/$CURDATE"
 50 
 56   mainContainer:
 57     image: curlimages/curl"
 58     tag: "latest"
 59     env:
 60       ES_SERVER: "training-dev-elasticsearch"
 61       ES_BACKUP_BUCKET: "test_es_backup"
 62       ES_BACKUP_RETENTION: 7
 63     resources:
 64       requests:
 65         cpu: "250m"
 66         memory: "256Mi"
 67       limits:
 68         cpu: "500m"
 69         memory: "512Mi"
 70     securityContext:
 71       runAsUser: 100
 72       runAsGroup: 101
 73       readOnlyRootFilesystem: true
 74     command:
 75       - "sh"
 76       - "/opt/gs-backup.sh"
 77       - "2>&1"

```

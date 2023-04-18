---
draft: false
title: "5 - TP Ajouter une persistance et une configMap à notre application"
sidebar_position: 12
---

--- 
## Objectifs pédagogiques 
- Utiliser la persistance des données 
---
## Persister les données de Redis

Actuellement le Redis de notre application ne persiste aucune donnée. On peut par exemple constater que le compteur de visite de la page est réinitialisé à chaque réinstallation.

Nous allons maintenant utiliser un volume pour résoudre simplement ce problème.

- Clonez le cas échéant la correction du TP précédent avec `git clone -b tp_monsterstack_final https://github.com/Uptime-Formation/corrections_tp.git tp_monsterstack_correction1`.

En vous inspirant du code du tutoriel officiel suivant (https://kubernetes.io/docs/tutorials/stateful-application/mysql-wordpress-persistent-volume/) :

- Créez un nouveau fichier `redis-data-pvc.yaml` contenant un `PersistantVolumeClaim` de nom `redis-data` de 2Go.
- Ajoutez au déploiement/pod-template de redis une section `volumes` avec un volume correspondant au pvc
- Ajoutez un mount au conteneur redis au niveau du chemin `/data`

Installons notre application avec `kubectl` et testons en visitant la page
### Observer la persistence

- Supprimez uniquement les trois déploiements.

- Redéployez a nouveau avec `kubectl apply -f .`, les deux déploiements sont recréés.

- En rechargeant le site on constate que les données ont été conservées (nombre de visite conservé).

- Allez observer la section stockage dans `Lens`. Commentons ensemble.

- Supprimer tout avec `kubectl delete -f .`. Que s'est-il passé ? (côté storage)

En l'état les `PersistentVolumes` générés par la combinaison du `PersistentVolumeClaim` et de la `StorageClass` de minikube sont également supprimés en même tant que les PVCs. Les données sont donc perdues et au chargement du site le nombre de visites retombe à 0.

Pour éviter cela il faut avec une `Reclaim Policy` à `retain` (conserver) et non `delete` comme suit https://kubernetes.io/docs/tasks/administer-cluster/change-pv-reclaim-policy/. Les volumes sont alors conservés et les données peuvent être récupérées manuellement. Mais les volumes ne peuvent pas être reconnectés à des PVCs automatiquement.

Pour récupérer les données on peut:

- récupérer les données à la main sur le disque/volume réseau indépendamment de kubernetes
- utiliser la nouvelle fonctionnalité de clone de volume

Lah correction de cette partie se trouve dans la brance `tp_monsterstack_correction_pvc` :

`git clone -b tp_monsterstack_correction_pvc https://github.com/Uptime-Formation/corrections_tp.git tp_monsterstack_correction_pvc`


<!-- - https://cloud.google.com/kubernetes-engine/docs/tutorials/persistent-disk/
- https://github.com/GoogleCloudPlatform/kubernetes-workshops/blob/master/state/local.md
- https://github.com/kubernetes/examples/blob/master/staging/persistent-volume-provisioning/README.md -->

<!-- # TODO améliorer notre persistance avec un statefulset (déploiement scalable simple de redis avec clarification de l'ordre de migration)-->


# Générer nos variables d'environnement frontend avec une configmap

En vous inspirant de la documentation officielle : https://kubernetes.io/docs/concepts/configuration/configmap/:

- Ajoutez un nouveau fichier configMap `frontend-config` avec 3 clés: `CONTEXT`, `REDIS_DOMAIN` et `IMAGEBACKEND_DOMAIN` avec les valeurs actuellement utilisées dans la section `env` de notre déloiement frontend.

- Modifiez cette section `env` pour récupérer les valeurs de la configMap avec le paramètre `valueFrom` comme dans l'exemple.

# Facultatif : Paramétrer notre application avec Kustomize

Kustomize est un outil de paramétrage et mutation d'application kubernetes fonctionnant sur le mode du patching (voir cours).

Clonons et commentons un exemple d'usage de kustomize pour notre application : `git clone -b tp_monsterstack_correction_kustomize https://github.com/Uptime-Formation/corrections_tp.git tp_monsterstack_correction_kustomize`

Resources sur kustomize:
- https://skryvets.com/blog/2019/05/15/kubernetes-kustomize-json-patches-6902/
- https://elatov.github.io/2021/08/using-kustomize/
--- 
## Objectifs pédagogiques 
- Utiliser la persistance des données 

---
title: Cours - Type de volumes et mode d'accès
---

## Types de volumes

- Objets
- Files
- Block

- https://www.redhat.com/en/topics/data-storage/file-block-object-storage
- https://cloud.google.com/blog/topics/developers-practitioners/map-storage-options-google-cloud?hl=en

## Modes d'accès

https://stackoverflow.com/questions/57798267/kubernetes-persistent-volume-access-modes-readwriteonce-vs-readonlymany-vs-read

- Vous devez utiliser `ReadWriteX` lorsque vous prévoyez que des pods devront écrire sur le volume, et pas seulement lire les données du volume.

- Vous devez utiliser `XMany` lorsque vous souhaitez que des pods puissent accéder au volume donné tout en étant exécutés sur différents nœuds dans le cluster Kubernetes.

Ces pods peuvent être plusieurs replicas appartenant à un déploiement, ou bien des pods complètement différents. Il y a de nombreuses situations où il est souhaitable que des pods s'exécutent sur différents nœud

Si vous n'utilisez pas `XMany`, mais que vous avez plusieurs pods qui doivent accéder au volume donné, cela obligera Kubernetes à planifier tous ces pods sur le nœud où le volume a été monté en premier. Cela pourrait surcharger ce nœud s'il y a trop de pods, et peut affecter la disponibilité des déploiements dont les pods ont besoin d'accéder à ce volume.

En résumé :

- Si vous avez besoin d'écrire sur le volume, et que vous pourriez avoir plusieurs pods qui doivent écrire sur le volume tout en préférant que ces pods soient répartis sur différents nœuds, et que `ReadWriteMany` est une option disponible avec le plugin de volume pour votre cluster K8s, utilisez `ReadWriteMany`.
- Si vous avez besoin d'écrire sur le volume mais que vous n'avez pas l'exigence que plusieurs pods puissent y écrire, ou que `ReadWriteMany` n'est tout simplement pas une option disponible pour vous, utilisez `ReadWriteOnce`.
- Si vous avez seulement besoin de lire depuis le volume, et que vous pourriez avoir plusieurs pods qui doivent lire depuis le volume tout en préférant que ces pods soient répartis sur différents nœuds, et que `ReadOnlyMany` est une option disponible avec le plugin de volume pour votre cluster K8s, utilisez `ReadOnlyMany`.
- Si vous avez seulement besoin de lire depuis le volume mais que vous n'avez pas l'exigence que plusieurs pods puissent y accéder, ou que `ReadOnlyMany` n'est tout simplement pas une option disponible pour vous, utilisez `ReadWriteOnce`. Dans ce cas, vous voulez que le volume soit en lecture seule, mais les limitations de votre plugin de volume vous obligent à choisir `ReadWriteOnce` (il n'y a pas d'option `ReadOnlyOnce`). En bonne pratique, pensez à configurer le paramètre `volumeMounts.readOnly` sur true dans vos spécifications de pod pour les montages de volumes qui sont destinés à être en lecture seule.


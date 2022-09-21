---
draft: true
title: "TP opt. - StatefulSets et bases de données"
weight: 2075
---

## Avec la chart PostgreSQL HA

En lançant la [chart PostgreSQL HA de Bitnami](https://github.com/bitnami/charts/tree/master/bitnami/postgresql-ha), et en lisant les logs des conteneurs, observez comment fonctionne les StatefulSets, par exemple avec Lens. Scalez les StatefulSets postgres.

<!-- Ou PGOperator -->

## Facultatif : A la main, avec MySQL, des init containers et des ConfigMaps

- Suivre ce tutoriel pas à pas : <https://kubernetes.io/docs/tasks/run-application/run-replicated-stateful-application/>

<!-- - https://kubernetes.io/docs/tutorials/stateful-application/basic-stateful-set/ -->
<!-- - https://kubernetes.io/docs/tutorials/stateful-application/cassandra/ -->

<!--
### Ressources configmaps
 https://github.com/GoogleCloudPlatform/kubernetes-workshops/blob/master/bundles/kubernetes-101/workshop/labs/managing-application-configurations-and-secrets.md
https://kubernetes.io/docs/concepts/configuration/configmap/#using-configmaps -->

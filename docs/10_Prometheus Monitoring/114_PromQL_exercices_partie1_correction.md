---
title: Exercices PromQL partie 1 - Correction
# sidebar_class_name: hidden
---

**Obtenir la charge moyenne du système :**

Utilisez `node_load1` pour afficher la charge moyenne du système (évaluée sur la dernière minute, d'où le 1) et ce pour les trois instances.

```promQL
node_load1
```

Comment afficher la charge moyenne évaluée sur les 15 dernières minutes ?

```promQL
node_load15
```

Affichez le résultat en graphique pour les deux première instances uniquement : Que remarque-t-on ?

Il s'agit en fait de la même machine (deux node_exporter sur le même "serveur" parlent en fait de la même machine) donc les valeurs des trois courbes sont proches mais elles ne sont pas identiques car Prometheus ne garanti pas un temps régulier pour la récupération des données.

**Vérifier l'utilisation du CPU par le système :**

Utilisez `node_cpu_seconds_total` pour afficher le temps CPU utilisé par le système, puis par les processus utilisateurs.

```promQL
node_cpu_seconds_total{mode="system"}
```

```promQL
node_cpu_seconds_total{mode="user"}
```

Affichez ensuite l'évolution de ce temps CPU utilisateur avec un graphique (évalué à 5 minutes)

```promQL
rate(node_cpu_seconds_total{mode="user"}[5m])
```

Affichez seulement le temps des deux premier cpu.

```promQL
rate(node_cpu_seconds_total{mode="system", cpu=~"0|1", instance="localhost:8080"}[5m])
```

**Vérifier l'utilisation de la mémoire :**

Utilisez `node_memory_MemTotal_bytes` et `node_memory_MemFree_bytes` pour afficher la mémoire utilisée.

```promQL
node_memory_MemTotal_bytes - node_memory_MemFree_bytes
```

Faites un graphique : pourquoi l'expression est-elle plus simple que celle de la question précédente ?

Ces deux métriques sont des jauges (Gauges) alors que dans la question précédent il s'agissait de compteurs (counters qui ne font qu'augmenter). rate ne fonctionne qu'avec des compteurs. Les jauges traduisent directement une évolution non monotone d'une situation sans besoin d'ajouter rate.

**Vérifier l'utilisation du réseau :**

Affichez le nombre paquet reçus sur l'interface locale pour la troisième instance.

```promQL
node_network_receive_packets_total{device="lo"}
```

 **Vérifier la consommation de bande passante réseau entrante et sortante :**

Utilisez `node_network_receive_bytes_total` et `node_network_transmit_bytes_total` pour afficher le consommation totale de bande passante de la seconde instance en kilo octet sur son interface localhost. 

```promQL
 (node_network_receive_bytes_total{device="lo", instance="localhost:8081"}
 + node_network_transmit_bytes_total{device="lo", instance="localhost:8081"})
 / 1024
 ```

Affichez l'évolution avec un graphique:

```promQL
rate(node_network_receive_bytes_total{device="lo", instance="localhost:8081"}[5m]) + rate(node_network_transmit_bytes_total{device="lo", instance="localhost:8081"}[5m])
```

**Obtenir l'espace disque utilisé :**

Utilisez `node_filesystem_size_bytes` et `node_filesystem_free_bytes` pour afficher l'espace disque utilisé de votre premier disque dur uniquement, pour la première instance de `node_exporter` en gigaoctet.

```promQL
(node_filesystem_size_bytes{device="/dev/...", instance="localhost:8080"} - node_filesystem_free_bytes{device="/dev/...", instance="localhost:8080"}) / (1024*1024*1024)
```
De même affichez le graphique du taux d'évolution de l'espace disque.
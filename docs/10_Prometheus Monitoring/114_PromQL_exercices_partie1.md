---
title: Exercices PromQL partie 1 
sidebar_class_name: hidden
---

Nous allons utiliser le `node_exporter` pour appliquer quelques requêtes. Assurez-vous d'avoir correctement configuré le Node Exporter et que vos métriques sont disponibles dans votre serveur Prometheus avant de les exécuter.

Commencez par tester et comprendre les requêtes proposées dans le cours précédent.

**Obtenir la charge moyenne du système :**

Utilisez `node_load1` pour afficher la charge moyenne du système (évaluée sur la dernière minute, d'où le 1) et ce pour les trois instances.

Comment afficher la charge moyenne évaluée sur les 15 dernières minutes ?

Affichez le résultat en graphique pour les deux première instances uniquement : Que remarque-t-on ?

Il s'agit en fait de la même machine (deux node_exporter sur le même "serveur" parlent en fait de la même machine) donc les valeurs des trois courbes sont proches mais elles ne sont pas identiques car Prometheus ne garanti pas un temps régulier pour la récupération des données.

**Vérifier l'utilisation du CPU par le système :**

Utilisez `node_cpu_seconds_total` pour afficher le temps CPU utilisé par le système, puis par les processus utilisateurs.

Affichez ensuite l'évolution de ce temps CPU utilisateur avec un graphique (évalué à 5 minutes)

Affichez seulement le temps du premier cpu.

**Vérifier l'utilisation de la mémoire :**

Utilisez `node_memory_MemTotal_bytes` et `node_memory_MemFree_bytes` pour afficher la mémoire utilisée.

Faites un graphique : pourquoi l'expression est-elle plus simple que celle de la question précédente ?

Ces deux métriques sont des jauges (Gauges) alors que dans la question précédent il s'agissait de compteurs (counters qui ne font qu'augmenter). rate ne fonctionne qu'avec des compteurs. Les jauges traduisent directement une évolution non monotone d'une situation sans besoin d'ajouter rate.

**Vérifier l'utilisation du réseau :**

Affichez le nombre paquet reçus sur l'interface locale pour la troisième instance.

 **Vérifier la consommation de bande passante réseau entrante et sortante :**

Utilisez `node_network_receive_bytes_total` et `node_network_transmit_bytes_total` pour afficher le consommation totale de bande passante de la seconde instance en kilo octets sur son interface localhost. 

Affichez l'évolution avec un graphique.

**Obtenir l'espace disque utilisé :**

Utilisez `node_filesystem_size_bytes` et `node_filesystem_free_bytes` pour afficher l'espace disque utilisé de votre premier disque dur uniquement, pour la première instance de `node_exporter` en gigaoctet.

De même affichez le graphique du taux d'évolution de l'espace disque.
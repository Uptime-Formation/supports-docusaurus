---
title: Exercices PromQL partie 1 
draft: false
# sidebar_position: 6
---

Nous allons utiliser le `node_exporter` pour appliquer quelques requêtes simples

Assurez-vous d'avoir correctement configuré le Node Exporter et que vos métriques sont disponibles dans votre serveur Prometheus avant de les exécuter.

1. **Lister toutes les métriques disponibles :**
   Cette requête vous permettra de voir toutes les métriques disponibles du Node Exporter.
   ```promQL
   metrics
   ```

2. **Obtenir la charge moyenne du système :**
   La charge moyenne est un indicateur de l'utilisation du CPU.
   ```promQL
   node_load1
   ```

3. **Vérifier l'utilisation du CPU par le système :**
   Cette requête affiche l'utilisation du CPU par le système.
   ```promQL
   node_cpu_seconds_total{mode="system"}
   ```

4. **Vérifier l'utilisation de la mémoire :**
   Pour voir l'utilisation de la mémoire.

   ```promQL
   node_memory_MemTotal_bytes - node_memory_MemFree_bytes
   ```

5. **Vérifier l'utilisation du réseau :**
   Pour connaître le nombre de paquets reçus sur une interface réseau spécifique (par exemple, eth0).
   ```promQL
   node_network_receive_packets_total{device="eth0"}
   ```

11. **Vérifier la consommation de bande passante réseau entrante et sortante :**
    Pour connaître la consommation de bande passante réseau entrante et sortante sur une interface réseau (par exemple, eth0).
    ```promQL
    node_network_receive_bytes_total{device="eth0"} + node_network_transmit_bytes_total{device="eth0"}
    ```

6. **Obtenir l'espace disque utilisé :**
   Pour vérifier l'espace disque utilisé sur une partition (par exemple, /dev/sda1).
   ```promQL
   node_filesystem_size_bytes{device="/dev/sda1"} - node_filesystem_free_bytes{device="/dev/sda1"}
   ```

8. **Obtenir la température du CPU (le cas échéant) :**
   Cette requête vérifie la température du CPU (si le matériel le prend en charge).
   ```promQL
   node_hwmon_temp_celsius
   ```

7. **Vérifier le nombre de processus en cours d'exécution :**
   Cette requête renvoie le nombre de processus en cours d'exécution.
   ```promQL
   node_procs_running
   ```



12. **Vérifier le nombre d'opérations d'E/S du disque :**
    Pour surveiller le nombre total d'opérations d'E/S du disque (lecture/écriture) sur une partition spécifique (par exemple, /dev/sda1).
    ```promQL
    node_disk_io_time_seconds_total{device="/dev/sda1"}
    ```

Ces exemples de requêtes PromQL devraient vous donner un bon point de départ pour commencer à explorer et à analyser les métriques collectées par le Node Exporter. Vous pouvez les personnaliser en fonction de vos besoins spécifiques de surveillance et de dépannage.
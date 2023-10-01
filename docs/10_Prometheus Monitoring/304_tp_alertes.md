---
title: TP - Créer et déclencher des alertes
draft: false
# sidebar_position: 6
---

Ce TP vise à mettre en pratique les exemple d'alerte du cours sur nos trois `node_exporter` du TP1

- Assurez vous d'avoir bien suivi le TP1 et d'avoir 3 instances de `node_exporter` en train de tourner et un `prometheus` local configuré pour les surveiller.

Pour chaque exemple d'alerte sauf les deux dernières (FDsNearLimit et les annotations):

- testez l'expression de l'alerte pour comprendre ce qu'elle renvoie comme données
- ajoutez l'alerte à la configuration des règles de prometheus créés lors du TP sur les recording rules (`prometheus.rules.yml`)
- Essayez de déclencher l'alerte
- Essayez ensuite de résoudre l'alerte
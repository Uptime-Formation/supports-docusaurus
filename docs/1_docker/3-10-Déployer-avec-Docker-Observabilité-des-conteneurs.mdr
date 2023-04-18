---
title: Déployer avec Docker Observabilité des conteneurs
pre: "<b>3.10 </b>"
weight: 38
---

## Objectifs pédagogiques
* Comprendre ce qu'on appelle observabilité
* Savoir comment utiliser des outils d'observabilité avec Docker

## Gérer les logs des conteneurs

Avec Elasticsearch, Filebeat et Kibana… grâce aux labels sur les conteneurs Docker

## Monitorer des conteneurs

- Avec Prometheus pour Docker et Docker Swarm
- Ou bien Netdata, un peu plus joli et configuré pour monitorer des conteneurs _out-of-the-box_

---

## Instruction `HEALTHCHECK`

`HEALTHCHECK` permet de vérifier si l'app contenue dans un conteneur est en bonne santé.

```bash
HEALTHCHECK CMD curl --fail http://localhost:5000/health || exit 1
```
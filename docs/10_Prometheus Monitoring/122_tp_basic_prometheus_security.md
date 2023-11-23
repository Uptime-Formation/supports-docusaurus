---
title: TP - Sécurité de base Prometheus
sidebar_class_name: hidden
---

## Configurer le chiffrement TLS

Comme on peut-être amené depuis une instance de prometheus à scraper des métriques depuis de nombreuses cibles en passant par divers réseau plus ou moins sécurisé il est généralement important de configurer un chiffrement des connexions de collecte http de prometheus avec du mutual TLS.

https://prometheus.io/docs/guides/tls-encryption/

## Configurer une authentification HTTP pour l'accès à l'API et la webUI de Prometheus

Par défault les interfaces HTTP de prometheus API et webUI est en accès libre. Voici le guide officiel pour configurer une authentification HTTP.

- https://prometheus.io/docs/guides/basic-auth/
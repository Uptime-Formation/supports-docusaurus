---
title:  Run 5 - Custom Operators
weight: 520
---

## Kubi : k8s + LDAP

Source : https://github.com/ca-gip/kubi

### Présentation

**Kubi est une solution d'accès et de gestion de clusters Kubernetes, conçue pour améliorer la sécurité et la facilité d'utilisation.**

Elle permet aux utilisateurs d'obtenir des jetons Kubernetes temporaires basés sur leurs droits définis dans Active Directory.

#### Fonctionnalités Clés
1. **Authentification** : Utilise l'authentification basée sur les jetons JWT signés par une clé privée et vérifiés par une clé publique.
2. **Autorisation** : Intègre les rôles et permissions définis dans Active Directory.
3. **Sécurité** : Les jetons temporaires augmentent la sécurité en limitant l'exposition.

#### Composants
- **Serveur Kubi** : Génère des jetons d'accès temporaires.
- **Client Kubi** : Interface en ligne de commande pour interagir avec Kubi.

#### Utilisation
Les utilisateurs se connectent via Kubi, qui vérifie leurs permissions et génère un jeton d'accès Kubernetes. Ce jeton est temporaire, limitant les risques de sécurité.

---

### Analyse 

* Où sont les CRDs ? Que définissent-elles ?
* Que contient le fichier make ? Quelles sont les différentes cibles ?
* Est-ce que vous voyez un contrôleur ?
* Que pensez-vous de la structure ? de la documentation ?
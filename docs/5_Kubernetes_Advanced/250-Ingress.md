
---
title:   Ingress 
weight: 1
---

## Quickstart : Exposer un service Rancher dans k3s

**Ce quickstart guide à travers l'installation de k3s avec l'ingress par défaut (Traefik) et le déploiement d'une application de démonstration Rancher exposée sur le port 80.**

### Étape 1 : Installer k3s avec Traefik

* **Installer k3s avec Traefik activé par défaut**
```sh
curl -sfL https://get.k3s.io | sh -
```

---


### Étape 2 : Déployer l'application de démonstration Rancher

* **Créer un fichier de déploiement pour l'application de démonstration (rancher-demo.yaml)**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: rancher-demo
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: rancher-demo
  template:
    metadata:
      labels:
        app: rancher-demo
    spec:
      containers:
      - name: rancher-demo
        image: rancher/hello-world
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: rancher-demo
  namespace: default
spec:
  selector:
    app: rancher-demo
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
```

* **Appliquer le fichier de déploiement**
```sh
kubectl apply -f rancher-demo.yaml
```
---


### Étape 3 : Créer une ressource Ingress

* **Créer un fichier Ingress pour exposer l'application (ingress.yaml)**
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: rancher-demo
  namespace: default
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: traefik
  rules:
  - host: %YOURDOMAIN%
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: rancher-demo
            port:
              number: 80
```

* **Appliquer le fichier Ingress**
```sh
kubectl apply -f ingress.yaml
```

---

### Étape 4 : Vérifier le fonctionnement

* **Vérifier l'état des pods et des services**
```sh
kubectl get events -A -w
kubectl get pods 
kubectl get svc 
```

* **Tester l'accès via curl**
```sh
curl -H "Host: %YOURDOMAIN%" http://%YOUR_IP%
```

---
## Les Solutions de Gestion du Trafic dans Kubernetes

**Il existe une variété d'options pour répondre aux besoins spécifiques des applications modernes.**

Le choix dépendra des exigences de sécurité, de performance et de complexité de l'infrastructure, tout en visant à assurer une gestion efficace du trafic et une expérience utilisateur optimale.

--- 

## Situation Actuelle avec l'API Gateway et l'Ingress dans Kubernetes


**Récemment, Kubernetes a introduit un nouveau modèle appelé Gateway API, qui vise à remplacer l'Ingress pour la gestion du trafic entrant.** 

La Gateway API représente une avancée significative dans la gestion du trafic entrant dans Kubernetes, remplaçant progressivement l'Ingress et chevauchant certaines fonctions des services mesh. 

Cette évolution pousse les services mesh à s'adapter et à s'intégrer de manière plus transparente avec les nouvelles capacités de la Gateway API, offrant ainsi une solution plus complète et flexible pour la gestion des applications modernes.

--- 

### Ingress vs. Gateway API :

![](../../static/img/kubernetes/ingress-vs-gateway.png)

- **Ingress** : Le modèle Ingress, traditionnellement utilisé dans Kubernetes, permet de définir des règles pour diriger le trafic HTTP/S entrant vers les services. Bien qu'il soit largement utilisé, il présente des limitations en termes de flexibilité et de contrôle fin du trafic.


- **Gateway API** : Le nouveau modèle Gateway API offre une approche plus flexible et extensible pour la gestion du trafic. Il permet de définir des routes HTTP/S, TCP, et autres, avec un contrôle granulaire sur les politiques de trafic, la sécurité et l'observabilité.

--- 

### Rôle de l'API Gateway dans Kubernetes :

- **Fonctions Clés** : La Gateway API peut gérer des tâches comme l'authentification, l'autorisation, le contrôle de taux (rate limiting), et la gestion des certificats TLS. Elle offre une flexibilité accrue par rapport à l'Ingress, permettant des configurations plus avancées et spécifiques aux besoins de l'application.
- **Remplacement de l'Ingress** : Avec la montée en puissance de la Gateway API, l'Ingress est progressivement remplacé pour les cas d'utilisation avancés. La Gateway API fournit une abstraction plus puissante et unifiée pour gérer le trafic entrant dans Kubernetes.

--- 

### Impact sur les Services Mesh :

- **Chevauchement des Fonctions** : Les services mesh, tels qu'Istio, Linkerd et Consul Connect, gèrent traditionnellement des fonctions comme le routage du trafic, la sécurité et l'observabilité à l'intérieur du cluster. Avec la Gateway API, certaines de ces fonctions sont désormais également gérées à la frontière du cluster.
- **Intégration avec les Services Mesh** : Les services mesh doivent maintenant s'adapter à ce nouveau modèle. Par exemple, Istio utilise le composant Istio Gateway pour intégrer les fonctionnalités de Gateway API. Cela permet de déléguer certaines tâches de gestion du trafic à la Gateway API tout en conservant des fonctionnalités avancées de mesh pour la communication interne entre les services.

--- 

### État Actuel :

- **Adoption** : La Gateway API est en cours d'adoption et devient de plus en plus standardisée dans les déploiements Kubernetes modernes. 
  Elle offre une solution plus robuste et flexible pour la gestion du trafic entrant, complémentant et parfois chevauchant les fonctionnalités des services mesh.
- **Évolution** : Les services mesh continuent d'évoluer pour tirer parti des nouvelles capacités offertes par la Gateway API. 
  Cela inclut l'intégration étroite avec les API de Gateway pour offrir une solution unifiée et cohérente pour la gestion du trafic, la sécurité et l'observabilité dans Kubernetes.

---

--- 

### Solutions

Les solutions de gestion du trafic dans les environnements Kubernetes ont évolué pour répondre aux besoins croissants des architectures modernes de microservices et de cloud-native. Voici un aperçu de leur évolution :

1. **Reverse Proxies traditionnels (F5, Nginx, HAProxy) :**
   - **Historique :** Utilisés depuis longtemps pour gérer le trafic entrant et sortant des applications web et des services, avec des fonctionnalités avancées de terminaison TLS, de répartition de charge et de gestion des connexions.
   - **Enjeux techniques :** Adaptation aux besoins de performances élevées, gestion de la sécurité réseau, et optimisation du trafic global des applications.
   - **Fonctionnalités :** Terminaison TLS, répartition de charge, mise en cache, réécriture d'URL, et gestion des connexions.

2. **Ingress Kubernetes :**
   - **Historique :** Introduit comme une ressource native pour gérer le trafic HTTP/HTTPS entrant dans les clusters Kubernetes, simplifiant ainsi le routage du trafic vers les services internes.
   - **Enjeux techniques :** Limitations en termes de fonctionnalités avancées telles que la terminaison TLS, la réécriture d'URL, et la gestion fine des politiques de sécurité.
   - **Fonctionnalités :** Routage basique du trafic HTTP/HTTPS en fonction des règles définies (nom d'hôte, chemin).

3. **Service Mesh (Istio, Linkerd) :**
   - **Historique :** Apparu pour répondre aux besoins de gestion complexe du trafic entre microservices dans Kubernetes, en fournissant une visibilité approfondie, une sécurité renforcée et un contrôle fin du trafic.
   - **Enjeux techniques :** Intégration de sidecars (comme Envoy) pour la gestion du trafic sans modification des applications, gestion du chiffrement mTLS, et gestion avancée des politiques de trafic (circuit breaking, retries).
   - **Fonctionnalités :** Sécurité mTLS, répartition de charge avancée, monitoring des performances, gestion des politiques de trafic.

4. **Gateway API  :**
   - **Historique :** Évolution significative dans l'écosystème Kubernetes pour gérer le trafic réseau entrant et sortant de manière plus flexible et extensible que les ressources d'Ingress traditionnelles.
   - **Enjeux techniques :** Configuration plus fine et gestion plus avancée du trafic par rapport à l'Ingress similaire aux Service Mesh.
   - **Fonctionnalités :** Routage du trafic basé sur des règles avancées de correspondance de requêtes, terminaison TLS native, répartition de charge, la mise en cache et la gestion des politiques de trafic.

5. **API Gateways Kubernetes (Kong, Istio en mode Gateway) :**
   - **Historique :** Intégré dans Kubernetes pour gérer l'exposition sécurisée des API et des services externes, avec des fonctionnalités avancées de gestion des politiques d'accès.
   - **Enjeux techniques :** Authentification des utilisateurs, autorisation basée sur les rôles, limitation des taux, transformation des requêtes/réponses.
   - **Fonctionnalités :** Gestion des API, sécurité des points d'entrée d'application, et contrôle des politiques d'accès.

--- 

### Enjeux Actuels et Tendances

- **Complexité des Microservices :** Les architectures modernes de microservices exigent une gestion fine du trafic entre les services, avec des besoins croissants en sécurité et en performance.
  
- **Sécurité Renforcée :** Avec la multiplication des attaques et la nécessité de conformité réglementaire, les solutions doivent offrir des fonctionnalités avancées de chiffrement et de contrôle d'accès.

- **Automatisation et Orchestration :** L'automatisation des déploiements et la gestion des politiques de trafic deviennent essentielles pour maintenir l'agilité opérationnelle et la fiabilité des services.

---

## Quelles solutions utiliser ? 

**Une fois encore, c'est une question d'architecture qui dépend de vos contraintes.** 

| Solution              | Type              | Complexité des routes | Métriques avancées | Observabilité | Authentification intégrée |
|-----------------------|-------------------|-----------------------|--------------------|---------------|---------------------------|
| Gateway API native    | Native            | Moyenne               | Non                | Faible        | Non                       |
| Nginx-controller      | Ingress           | Moyenne               | Oui                | Moyen         | Non                       |
| Istio                 | Service Mesh      | Haute                 | Oui                | Avancé        | Oui                       |
| Kong                  | API Gateway       | Haute                 | Oui                | Avancé        | Oui                       |
| HAProxy               | Reverse Proxy     | Moyenne               | Oui                | Moyen         | Non                       |
| MetalLB               | Load Balancer     | Faible                | Non                | Faible        | Non                       |



--- 

### TP : Conception d'un Cluster Kubernetes pour une Application à Forte Charge

**Ce TP est ouvert : il vise à vous faire saisir la complexité de l'architecture d'un cluster Kubernetes.**

**Objectif** : au bout de 10 minutes d'élaboration en petit groupe, on met en commun les idées et structures imaginées.

On utilisera bien sûr autant que possible les apports du Run : CNI, Service Mesh, certificates, ingress.

--- 

**Imaginez que votre équipe soit confrontée au besoin pressant de déployer une nouvelle architecture Kubernetes pour une application web à forte charge.**

Cette application doit supporter des milliers d'utilisateurs simultanés et doit être déployée sur plusieurs environnements distincts pour le développement, le test et la production.

De plus, elle doit être intégrée de manière sécurisée dans le réseau d'entreprise existant, en respectant les politiques strictes de sécurité et de gestion du trafic.

--- 

#### Contexte et Objectifs

**Votre entreprise, une société de commerce électronique en pleine expansion, a développé une nouvelle application pour améliorer l'expérience utilisateur et gérer efficacement les commandes en ligne.**

Pour répondre aux besoins croissants de performance, de disponibilité et de scalabilité, vous avez décidé d'opter pour Kubernetes comme plateforme de déploiement.

**L'application est constituée des microservices suivants :** 

Dans le cadre d'une architecture Kubernetes pour une application à forte charge, voici une liste rapide des microservices typiques qui pourraient constituer l'application :

1. **Service d'Authentification (Auth Service)** : utilise une API existante d'authentification (oAuth2, OIDC)
2. **Service de Gestion des Utilisateurs (User Management Service)** : Crée des comptes pour les clients dans cette application
3. **Service de Gestion des Produits (Product Management Service)** : Expose les  catalogues de produits, y compris la création, la mise à jour et la suppression des produits.
4. **Service de Commandes (Order Service)** : Expose le processus de commande, y compris la création, la validation et le suivi des commandes.
5. **Service de Paiement (Payment Service)** : Gère les transactions financières, y compris l'autorisation et le traitement des paiements.
6. **Service de Panier (Shopping Cart Service)** :  Gère les paniers d'achat des utilisateurs, y compris l'ajout, la suppression et la modification des articles.
7. **Service de Notifications (Notification Service)** : Envoie des notifications aux utilisateurs, telles que les confirmations de commande, les mises à jour de statut et les offres spéciales.
8. **Service de Recommandation (Recommendation Service)** : Fournit des recommandations personnalisées aux utilisateurs en fonction de leur historique d'achat ou de leur comportement de navigation.

Chaque microservice est déployé et géré de manière indépendante, et communique selon des normes OpenAPI / Restful.

---

#### Défis à Surmonter

1. **Intégration dans le Réseau d'Entreprise :**
   - Le nouveau cluster Kubernetes doit être intégré de manière sécurisée dans le réseau d'entreprise existant.
   - Assurer la connectivité avec les services internes comme les bases de données et les systèmes back-end tout en respectant les règles de sécurité et de politique réseau établies.
   - Utiliser la PKI privée de l'entreprise autant que possible.

2. **Gestion des Environnements :**
   - Vous devez déployer l'application sur trois environnements distincts : développement (dev), test (staging) et production.
   - L'environnement de production doit être isolé pour éviter les collisions de données et garantir des tests et validations indépendants.

3. **Sécurité et Gestion du Trafic :**
   - L'application doit respecter des normes élevées de sécurité, avec du chiffrement de tous les échanges.
   - Mettre en œuvre des politiques de contrôle d'accès aux API pour limiter l'accès aux ressources sensibles 
   - Utiliser des secrets Kubernetes pour la gestion des informations d'authentification.

--- 

#### Solutions Proposées

Pour répondre à ces défis, vous envisagez la conception suivante pour votre cluster Kubernetes :

- **Architecture Kubernetes :**
  - Taille et type de plateforme Kubernetes
  - Cloud privé ou cloud public
  - Structuration des namespaces
  - Choix de plugin CNI

- **Intégration dans le Réseau :**
  - Sécurisation du trafic réseau interne et externe
  - Exposer les applications de manière sécurisée et contrôlée.

- **Gestion des Certificats TLS :**
  - Choix d'une solution de gestion des certificats TLS

- **Monitoring et Sécurité :**
  - Choix d'une solution de monitoring et alerting


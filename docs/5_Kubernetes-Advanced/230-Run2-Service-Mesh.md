---
title:    Run2 -  Service Mesh
weight: 230
---

## Quickstart : Déploiement de Linkerd sur Kubernetes

**Ce quickstart guide à travers l'installation et la configuration de Linkerd sur un cluster Kubernetes, ainsi que le maillage d'une application de démonstration.** 

Pour plus de détails, visitez [la documentation officielle de Linkerd](https://linkerd.io/2.15/getting-started/).

--- 

### Étape 1 : Installer le CLI Linkerd

* **Télécharger et installer le CLI Linkerd**
```sh
curl --proto '=https' --tlsv1.2 -sSfL https://run.linkerd.io/install-edge | sh
```

* **Ajouter le CLI à votre PATH**
```sh
export PATH=$HOME/.linkerd2/bin:$PATH
```

### Étape 2 : Valider le cluster Kubernetes

* **Vérifier la configuration du cluster**
```sh
linkerd check --pre
```

### Étape 3 : Installer Linkerd sur le cluster

* **Installer les CRDs de Linkerd**
```sh
linkerd install --crds | kubectl apply -f -
```

* **Installer le control plane de Linkerd**
```sh
linkerd install | kubectl apply -f -
```

* **Vérifier l'installation de Linkerd**
```sh
linkerd check
```

### Étape 4 : Installer l'application de démonstration

* **Installer Emojivoto**
```sh
curl --proto '=https' --tlsv1.2 -sSfL https://run.linkerd.io/emojivoto.yml | kubectl apply -f -
```

* **Accéder à l'application Emojivoto**
```sh
kubectl -n emojivoto port-forward svc/web-svc 8080:80
```

### Étape 5 : Mesh l'application avec Linkerd

* **Mesh l'application Emojivoto**
```sh
kubectl get -n emojivoto deploy -o yaml | linkerd inject - | kubectl apply -f -
```

### Étape 6 : Installer l'extension Viz de Linkerd

* **Installer l'extension Viz**
```sh
linkerd viz install | kubectl apply -f -
```

* **Vérifier l'installation de l'extension Viz**
```sh
linkerd check
```

* **Accéder au tableau de bord Viz**
```sh
linkerd viz dashboard &
```

---

## Architecture des Service Mesh 

**Un service mesh est une couche d'infrastructure logicielle destinée à contrôler la communication entre les services.**

Il a deux composants :

* Le **Data Plane**, qui gère les communications près de l'application. En général, il est déployé avec l'application sous forme d'un ensemble de proxys réseau, comme illustré précédemment.
* Le **Control Plane**, qui est le "cerveau" du service mesh. Le plan de contrôle interagit avec les proxys pour pousser des configurations, garantir la découverte de services et centraliser l'observabilité.

--- 

### Quel est l'intérêt dans une architecture microservice ?

**Le service Mesh évite d'ajouter de la complexité dans les micro-services et d'améliorer la qualité des flux entre microservices.**

- Les problématiques de droits d'accès n'ont plus besoin d'être assurées par le microservice même.
- Les flux réseaux sont automatiquement chiffrés de manière forte entre microservices.
- La métrologie des flux réseaux est automatisée.

---

## Historique des Services Mesh

**Les services mesh sont apparus en réponse à la complexité croissante de la gestion des microservices dans des architectures distribuées.** 

Avec la montée en puissance des microservices, la gestion de la communication inter-services, de la sécurité, de l'observabilité et du contrôle de trafic est devenue de plus en plus complexe.

- **Pré-2015** : Les premiers systèmes distribués utilisaient des solutions ad hoc pour la communication inter-services, souvent en utilisant des bibliothèques spécifiques à chaque langage de programmation, telles que Hystrix (pour le circuit breaking) ou Ribbon (pour le load balancing) dans l'écosystème Java.


- **2015** : Linkerd, développé par Buoyant, a été l'un des premiers services mesh à gagner en popularité.

  Linkerd offrait des fonctionnalités de résilience, de surveillance et de sécurité pour les microservices sans nécessiter de modification du code de l'application.


- **2016** : Envoy, un proxy de service de haute performance développé par Lyft, est devenu un composant clé dans les architectures de services mesh.

  Envoy est utilisé comme un proxy sidecar, interceptant le trafic entre les services pour fournir des fonctionnalités avancées de réseau.


- **2017** : Istio, un projet open-source développé en collaboration entre Google, IBM et Lyft, a été lancé.

  Istio est basé sur Envoy et offre un contrôle et une visibilité complets sur le réseau des microservices, avec des fonctionnalités de sécurité, de trafic, de télémétrie et de politiques réseau.

--- 

### Adaptation d'Istio

**Istio a évolué rapidement pour répondre aux besoins des utilisateurs de Kubernetes :**

- **Version 1.0 (2018)** : Istio a atteint sa première version stable, apportant des fonctionnalités de base comme la gestion du trafic, la sécurité et la télémétrie.

- **Les versions suivantes d'Istio** ont travaillé sur l'amélioration des performances, la simplification de l'installation et la gestion des configurations.
Le modèle de gestion a été simplifié avec des outils comme istioctl.

- **Istiod (2020)** : Istio a consolidé plusieurs composants en un seul binaire appelé Istiod, simplifiant encore l'architecture et réduisant la charge opérationnelle.

---

### L'architecture de Istio

Documentation sur https://istio.io/latest/docs/ops/deployment/architecture/

![](../../static/img/kubernetes/istio-architecture.svg)


--- 

### Adoption des Services Mesh par Kubernetes

**Kubernetes, en tant que plateforme de gestion des conteneurs, a naturellement évolué pour intégrer et supporter les services mesh.**

Voici quelques étapes clés :

- **2017** : Kubernetes a commencé à adopter les services mesh avec l'introduction d'Istio, qui s'intégrait bien avec l'architecture de Kubernetes.
Istio a été conçu pour fonctionner sur Kubernetes en utilisant des sidecars Envoy injectés dans les pods.

- **2018** : La communauté Kubernetes a commencé à explorer d'autres options de services mesh, comme Linkerd 2.0, qui offrait une intégration native avec Kubernetes et une complexité réduite par rapport à Istio.

- **2019-2020** : Des projets comme Consul Connect et AWS App Mesh ont émergé, chacun offrant des fonctionnalités spécifiques et des intégrations profondes avec Kubernetes et d'autres plateformes cloud.

---

## Les solutions de Services Mesh  

**Aujourd'hui il existe plusieurs solutions de Service Mesh dans Kubernetes**

Voici une liste courte des différentes solutions de service mesh pour Kubernetes, comme entre autres :

1. **Istio**
2. **Linkerd**
3. **Consul Connect**
4. **Cilium**
5. **Kuma**
6. **AWS App Mesh**
7. **Traefik Mesh (anciennement Maesh)**
8. **NGINX Service Mesh**

---

### Comparatif

**Voici un tableau comparatif des solutions de service mesh Istio, Linkerd et Consul.**

| Critères                                | Istio                                | Linkerd                               | Consul                               |
|-----------------------------------------|--------------------------------------|---------------------------------------|--------------------------------------|
| **Fonctionnalités de sécurité**         | mTLS, RBAC, Authentification JWT     | mTLS, Politique de sécurité simplifiée | mTLS, ACLs                           |
| **Gestion du trafic**                   | Routage avancé, A/B testing, Canaries| Routage de base, Répartition de charge | Routage avancé, Répartition de charge|
| **Facilité de déploiement et de gestion**| Complexe                             | Simple                                | Modérément complexe                  |
| **Performance**                         | Peut introduire de la latence        | Optimisé pour la performance          | Latence minimale                     |
| **Observabilité**                       | Tracing, Metrics, Logs               | Tracing basique, Metrics, Logs     | Metrics, Logs |


---

### Cas d'usages

**Les différentes solutions implémentent le même type de fonctionnalité, mais avec des propriétés et des capacités différentes.**

| Critères                        | Istio                                | Linkerd                               | Consul                               |
|---------------------------------|--------------------------------------|---------------------------------------|--------------------------------------|
| **Nombre de services à gérer**  | **Haute capacité** : Peut gérer un grand nombre de services, idéal pour des environnements complexes et étendus.| **Modérée à haute capacité** : Conçu pour la performance, bien adapté aux environnements de taille moyenne à grande. | **Haute capacité** : Peut gérer de nombreux services, avec des fonctionnalités robustes de routage et de gestion. |
| **Coût**                        | **Gratuit (Open Source)** : Toutefois, peut nécessiter des ressources substantielles en termes de CPU et de mémoire, augmentant les coûts d'infrastructure. | **Gratuit (Open Source)** : Léger et optimisé, généralement moins coûteux en ressources par rapport à Istio. | **Gratuit (Open Source)** : Version de base gratuite, mais des coûts supplémentaires peuvent s'appliquer pour des fonctionnalités avancées avec Consul Enterprise. |
| **Complexité opérationnelle**   | **Élevée** : Complexe à déployer et à gérer, nécessite une expertise technique importante. Documentation complète et support communautaire large. | **Faible à modérée** : Facile à déployer et à gérer, avec une documentation claire et une communauté active. Conçu pour être léger et simple. | **Modérée** : Plus simple qu'Istio, mais peut être complexe selon les fonctionnalités utilisées. Supporté par HashiCorp avec une documentation complète et des options de support commercial. |

--- 

En résumé :
- **Istio** est idéal pour les environnements complexes avec un grand nombre de services, mais peut être coûteux en termes de ressources et de complexité opérationnelle.
- **Linkerd** offre un bon équilibre entre performance et simplicité, adapté aux environnements de taille moyenne à grande sans introduire une complexité excessive.
- **Consul** est flexible et peut gérer de nombreux services, avec des coûts potentiellement plus élevés pour des fonctionnalités avancées et une complexité modérée à gérer.

---

## mTLS et la sécurité des échanges dans les Services Mesh

**mTLS est une méthode de chiffrement qui assure l'authentification mutuelle entre les services, garantissant que les deux parties de la communication sont légitimes.**

Chaque service possède un certificat TLS, et avant d'établir une connexion, les services vérifient ces certificats mutuellement, assurant ainsi une communication sécurisée et chiffrée de bout en bout.

---

### Exemple: mTLS dans Istio

**Istio fournit une solution de sécurité complète avec Citadel pour la gestion des certificats, l'intégration de SPIFFE/SPIRE pour l'identité des services, et des politiques robustes d'authentification et d'autorisation pour sécuriser les communications et l'accès aux services.**

Pour plus de détails, consultez la [documentation officielle de Istio](https://istio.io/v1.4/docs/concepts/security/).

--- 

#### Citadel

**Citadel est responsable de la gestion des clés et des certificats dans Istio, la Private Key Infrastructure.** 

Il crée et signe des paires de clés et de certificats pour chaque compte de service, surveille leur durée de vie et effectue la rotation automatique des certificats pour maintenir la sécurité.

--- 

#### SPIFFE / SPIRE

**Istio utilise le standard SPIFFE pour les identités de service, avec des certificats au format SPIFFE Verifiable Identity Document (SVID).**

SPIRE est l'implémentation de SPIFFE qui fournit un framework pour la gestion des identités dans des environnements hétérogènes.

--- 

#### Politiques d'authentification

**Les politiques d'authentification définissent les exigences pour les services recevant des requêtes, telles que l'utilisation de mTLS pour sécuriser la communication entre les services et l'authentification des utilisateurs finaux via JWT.**

```yaml
apiVersion: "authentication.istio.io/v1alpha1"
kind: "Policy"
metadata:
  name: "default"
  namespace: "ns1"
spec:
  peers:
  - mtls: {}
```

---

#### Politiques d'autorisation
**Les politiques d'autorisation spécifient les règles d'accès aux services, permettant un contrôle d'accès granulé basé sur l'identité du service ou de l'utilisateur.**

Elles peuvent être configurées pour autoriser ou refuser l'accès à des ressources spécifiques en fonction des critères définis.

```yaml
# Permet à deux sources (compte de service `cluster.local/ns/default/sa/sleep` et namespace `dev`) d'accéder aux 
# workloads avec les labels `app: httpbin` et `version: v1` dans le namespace `foo` lorsque la requête est envoyée 
# avec un jeton JWT valide.
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
 name: httpbin
 namespace: foo
spec:
 selector:
   matchLabels:
     app: httpbin
     version: v1
 rules:
 - from:
   - source:
       principals: ["cluster.local/ns/default/sa/sleep"]
   - source:
       namespaces: ["dev"]
   to:
   - operation:
       methods: ["GET"]
   when:
   - key: request.auth.claims[iss]
     values: ["https://accounts.google.com"]
```

---

## Les modèles Sidecar, Ambient Mesh, and Cluster Mesh

**Les modèles Sidecar, Ambient Mesh et Cluster Mesh sont des architectures différentes utilisées pour implémenter les services mesh dans Kubernetes.**

Chacun de ces modèles a des caractéristiques distinctes, des avantages et des inconvénients.

| Caractéristique                 | Sidecar                      | Ambient Mesh               | Cluster Mesh               |
|---------------------------------|------------------------------|----------------------------|----------------------------|
| **Date d'apparition et statut technique** | Apparu autour de 2016, Mature  | En développement, Non-mature | Apparu vers 2020, Émergent  |
| **Complexité de déploiement**   | Élevée (injection de sidecars) | Moyenne (proxys de nœud/réseau) | Élevée (multi-cluster)       |
| **Complexité d'architecture**   | Complexe (chaque pod a un proxy) | Moyenne (proxys centralisés) | Très complexe (gestion inter-cluster) |
| **Avantages techniques**        | Granularité fine, isolément des services | Simplicité, réduction de l'overhead | Multi-cluster, haute résilience |
| **Désavantages**                | Maintenance lourde, surcharge en ressources et latence | Scalabilité limitée, résilience | Complexité de gestion, latence inter-cluster |

--- 

### Sidecars 

 Dans le modèle Sidecar, un proxy est déployé à côté de chaque instance de service dans un pod.

Ce proxy, souvent basé sur Envoy, intercepte tout le trafic entrant et sortant du service.

Exemples :
1. **Istio**
2. **Linkerd**
3. **Consul Connect**

--- 

### Ambient Mesh

Le modèle Ambient Mesh vise à simplifier le déploiement en supprimant le besoin d'injecter un sidecar proxy dans chaque pod.

Il utilise des proxys de nœud ou des proxys de réseau pour gérer le trafic.

Exemples :
1. **Istio Ambient (en développement)**

---
 
###  Cluster Mesh

Le modèle Cluster Mesh connecte plusieurs clusters Kubernetes ensemble, permettant aux services de communiquer entre clusters tout en conservant une gestion centralisée des politiques.

Exemples :

1. **Cilium Cluster Mesh**
2. **Linkerd Multi-cluster**
3. **Istio Multi-cluster**


---
## TP : Installation d'Istio avec mTLS par Défaut et Déploiement de l'Application Bookinfo

Dans ce TP, nous allons installer Istio avec la sécurisation des échanges entre les microservices activée par défaut en mode mTLS.

Ensuite, nous allons déployer l'application d'exemple Bookinfo fournie par Istio et vérifier que les flux entre les microservices sont bien chiffrés.

### Prérequis

- Un cluster Kubernetes fonctionnel.
- Istio installé avec `istioctl` (suivez les étapes d'installation d'Istio si ce n'est pas déjà fait).
- kubectl installé et configuré pour accéder à votre cluster Kubernetes.

### Étape 1 : Installation d'Istio avec mTLS par Défaut

1. **Téléchargez Istio :**
   ```bash
   curl -L https://istio.io/downloadIstio | sh -
   cd istio-*
   export PATH=$PWD/bin:$PATH
   ```

2. **Installez Istio avec le profil de démonstration et mTLS par défaut :**
   ```bash
   istioctl install --set profile=demo --set values.global.controlPlaneSecurityEnabled=true
   ```

3. **Vérifiez l'installation :**
   ```bash
   kubectl get pods -n istio-system
   ```
   Assurez-vous que tous les pods dans le namespace `istio-system` sont en état `Running`.

### Étape 2 : Déploiement de l'Application Bookinfo

1. **Déployez l'application Bookinfo :**
   ```bash
   kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml
   ```

2. **Exposez l'application Bookinfo via un Gateway :**
   ```bash
   kubectl apply -f samples/bookinfo/networking/bookinfo-gateway.yaml
   ```

3. **Vérifiez que les services sont déployés :**
   ```bash
   kubectl get services
   ```
   Assurez-vous que les services `productpage`, `details`, `reviews`, `ratings` et `istio-ingressgateway` sont déployés et ont des adresses IP.

### Étape 3 : Validation de la Sécurisation des Échanges

1. **Vérifiez que mTLS est activé par défaut :**
   Vérifiez que la configuration de `PeerAuthentication` montre que mTLS est activé en mode strict par défaut pour le namespace `default`.

   ```bash
   kubectl get peerauthentication -n istio-system
   ```

   Assurez-vous que le mode est configuré sur `STRICT`.

2. **Testez l'application Bookinfo :**
   Obtenez l'URL du Gateway Istio Ingress :
   ```bash
   kubectl get svc istio-ingressgateway -n istio-system
   ```

   Utilisez l'URL pour accéder à l'application Bookinfo dans votre navigateur ou via curl.

   ```bash
   curl -s http://<EXTERNAL-IP>/productpage | grep -o "<title>.*</title>"
   ```

   Remplacez `<EXTERNAL-IP>` par l'adresse IP externe du service `istio-ingressgateway`.

3. **Vérifiez les flux chiffrés avec mTLS :**

   Utilisez la commande `istioctl` pour vérifier que les flux entre les services sont chiffrés avec mTLS :

   ```bash
   istioctl authn tls-check <source-pod> <destination-service>.<namespace>.svc.cluster.local
   ```

   Remplacez `<source-pod>` par le nom du pod source (par exemple `productpage-v1-xxxxx`) et `<destination-service>` par le nom du service de destination (par exemple `details`, `reviews`, etc.).

   Exemple :
   ```bash
   istioctl authn tls-check productpage-v1-xxxxx details.default.svc.cluster.local
   ```

   Assurez-vous que la connexion indique que mTLS est activé (`TLS mode: mutual`).

---

**Après ce TP, voici quelques points à retenir et à explorer davantage :**

1. **Configuration avancée de mTLS :** Explorez les options de configuration avancée de mTLS avec Istio, telles que la définition de politiques de sécurité granulaires par service ou par utilisateur.

2. **Monitoring et Observabilité :** Mettez en place des outils de monitoring comme Prometheus et Grafana pour surveiller les métriques de performance et de sécurité des services Istio.

3. **Gestion fine des politiques de sécurité :** Approfondissez la gestion des politiques de sécurité Istio avec des règles d'autorisation basées sur des attributs spécifiques comme les JWT, les attributs de demande, etc.
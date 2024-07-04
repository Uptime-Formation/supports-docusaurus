
---
title:   
weight: 1
---


## Quickstart : Déploiement de cert-manager sur k3s avec Traefik sur une machine virtuelle

Ce quickstart guide à travers l'installation et la configuration de cert-manager sur k3s avec Traefik sur une machine virtuelle. Pour plus de détails, visitez la [documentation officielle de cert-manager](https://cert-manager.io/docs/).


### Étape 1 : Installer k3s

* **Installer k3s avec Traefik activé**
```sh
curl -sfL https://get.k3s.io | sh -
```

Vérifiez que kubectl utilise le bon contexte
```sh
kubectl config view
```
Assurez-vous que kubectl pointe vers le bon cluster
```sh
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
```

### Étape 2 : Installer Helm

* **Installer Helm**
```sh
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
```

### Étape 3 : Ajouter le dépôt de cert-manager

* **Ajouter le dépôt Helm de cert-manager**
```sh
helm repo add jetstack https://charts.jetstack.io
helm repo update
```

### Étape 4 : Installer cert-manager

* **Créer un namespace pour cert-manager**
```sh
kubectl create namespace cert-manager
```

* **Installer cert-manager**
```sh
helm install cert-manager jetstack/cert-manager --namespace cert-manager --version v1.6.1 --set installCRDs=true
```

### Étape 5 : Configurer l'Issuer et le Certificate

* **Configurer l'Issuer (issuer.yaml)**
```yaml
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: letsencrypt-staging
  namespace: cert-manager
spec:
  acme:
    server: https://acme-staging-v02.api.letsencrypt.org/directory
    email: your-email@%YOURDOMAIN%
    privateKeySecretRef:
      name: letsencrypt-staging
    solvers:
    - http01:
        ingress:
          class: traefik
```

* **Configurer le Certificate (certificate.yaml)**
```yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: example-com
  namespace: cert-manager
spec:
  secretName: example-com-tls
  issuerRef:
    name: letsencrypt-staging
  commonName: %YOURDOMAIN%
  dnsNames:
  - %YOURDOMAIN%
```

* **Appliquer les configurations**
```sh
kubectl apply -f issuer.yaml
kubectl apply -f certificate.yaml
```


### Étape 6 : Vérifier le fonctionnement 

```sh

kubectl get events -w -n cert-manager

kubectl logs -n cert-manager deploy/cert-manager

kubectl describe issuer letsencrypt-staging -n cert-manager

kubectl get secret letsencrypt-staging -n cert-manager -o yaml

```


---



## Historique de l'Intégration des Certificats TLS dans Kubernetes

1. **Débuts de Kubernetes (2014-2016) :** La gestion des certificats TLS était principalement manuelle. Les utilisateurs devaient configurer leurs certificats et secrets TLS directement.
2. **Introduction des Ingress Controllers :** Avec l'apparition des Ingress controllers comme NGINX, HAProxy, et Traefik, la gestion des certificats TLS est devenue plus automatisée et intégrée. Let's Encrypt et des projets comme Cert-Manager ont facilité l'obtention et le renouvellement des certificats.
3. **Émergence des Services Mesh (2016-2018) :** Les services mesh ont introduit la gestion automatique des certificats TLS pour sécuriser les communications entre microservices au sein du cluster.
4. **Gateway API (2020-présent) :** Le modèle Gateway API offre des capacités avancées de gestion des certificats TLS, intégrant des fonctionnalités issues des services mesh et des Ingress controllers.


---


## Interaction des Services Mesh, des Ingress et des Gateway avec les Certificats TLS dans Kubernetes

**La gestion des certificats TLS dans Kubernetes a évolué pour offrir des solutions automatisées et intégrées, simplifiant la sécurité des communications entre services.** 

Les évolutions récentes comme la Gateway API et les avancées dans les services mesh continuent de pousser cette intégration vers des modèles plus flexibles, sécurisés et automatisés.

---

## Services Mesh

Les services mesh comme Istio, Linkerd et Consul Connect offrent des fonctionnalités avancées de gestion du trafic et de sécurité, y compris la gestion des certificats TLS. Voici comment ils interagissent avec les certificats TLS :

1. **MTLS (Mutual TLS) :** Les services mesh implémentent généralement MTLS pour sécuriser les communications entre les microservices. Chaque service reçoit un certificat TLS et l'infrastructure du mesh gère la rotation et le renouvellement de ces certificats.
2. **Certificats Automatisés :** Des solutions comme Istio utilisent des composants comme `Citadel` (maintenant intégré dans `istiod`) pour générer et distribuer des certificats automatiquement.
3. **Configuration Simplifiée :** Les services mesh simplifient la configuration TLS pour les développeurs en centralisant la gestion des certificats et en appliquant des politiques de sécurité uniformes à travers le mesh.

---

## Ingress

Le modèle Ingress dans Kubernetes permet de gérer les connexions HTTPS entrantes vers les services dans un cluster. 

1. **Annotations TLS :** Les ressources Ingress permettent d'utiliser des annotations pour spécifier des certificats TLS, souvent stockés dans des Secrets Kubernetes.
2. **Contrôleurs Ingress :** Les contrôleurs Ingress (comme NGINX, Traefik) gèrent l'application des certificats TLS. Ils peuvent intégrer des solutions comme Let's Encrypt pour automatiser l'obtention et le renouvellement des certificats.

---

## Gateway API

Le modèle Gateway API offre une approche plus flexible et puissante pour gérer le trafic entrant, incluant la gestion des certificats TLS :

1. **Configuration TLS Avancée :** Gateway API permet une configuration plus granulaire des certificats TLS, incluant la gestion de plusieurs certificats et la sélection basée sur les hôtes ou les routes.
2. **Intégration avec les Services Mesh :** Les services mesh peuvent s'intégrer avec Gateway API pour déléguer certaines tâches de gestion TLS, en utilisant des certificats fournis par le mesh ou des certificats configurés directement dans la Gateway API.

---
## Principales solutions de gestion des certificats dans Kubernetes

**Voyons leurs capacités respectives, et comment elles peuvent gérer des infrastructures PKI privées ou ACME.**

--- 

## Cert-Manager

**Cert-Manager** est un outil populaire pour la gestion des certificats dans Kubernetes. Il facilite l'automatisation de l'obtention, du renouvellement et de la distribution des certificats TLS.

- **Capacités :**
  - **ACME :** Cert-Manager prend en charge ACME, permettant l'intégration avec Let's Encrypt et d'autres CA compatibles ACME pour l'obtention et le renouvellement automatiques des certificats.
  - **CA Interne :** Il peut s'intégrer avec des CA internes via des mécanismes comme le CA Issuer, permettant de signer des certificats avec une autorité de certification interne.
  - **Intégration avec Vault :** Cert-Manager peut utiliser HashiCorp Vault comme backend pour la gestion des certificats, en utilisant l'issuer de Vault pour émettre des certificats pour les pods et les services.
  - **Autres Issuers :** Supporte Venafi, Google CAS et d'autres systèmes de gestion de certificats d'entreprise.

- **Avantages :**
  - Automatisation complète de la gestion des certificats.
  - Support étendu pour divers issuers et backends.
  - Intégration transparente avec Kubernetes via Custom Resource Definitions (CRDs).

**Application** 
- **PKI Privée :** Intégration avec des CA internes via le CA Issuer et HashiCorp Vault.
- **ACME :** Supporte Let's Encrypt et d'autres CA compatibles ACME pour l'automatisation complète.

--- 

## Vault by HashiCorp

**Vault** est une solution de gestion des secrets et des identités qui inclut des capacités de gestion des certificats.

- **Capacités :**
  - **PKI Secrets Engine :** Vault dispose d'un moteur de secrets PKI qui permet de générer, signer et révoquer des certificats TLS.
  - **Rotation Automatique :** Vault peut automatiser la rotation des certificats, en s'intégrant avec Kubernetes pour distribuer les certificats aux pods et services.
  - **ACME :** Bien que Vault ne supporte pas directement ACME, il peut être configuré pour émettre des certificats compatibles avec les exigences de sécurité d'ACME.

- **Avantages :**
  - Gestion centralisée et sécurisée des certificats et autres secrets.
  - Capacité de gérer des infrastructures PKI complexes et multi-cloud.
  - API puissante et flexible pour l'automatisation et l'intégration.

**Application**

- **PKI Privée :** PKI Secrets Engine pour gérer une infrastructure PKI complète, y compris la génération, la signature et la révocation des certificats.


--- 

## API certificates.k8s.io

**API certificates.k8s.io** est une API Kubernetes native pour la gestion des certificats.

- **Capacités :**
  - **Signing Requests :** Permet aux pods et autres composants de demander des certificats via des ressources `CertificateSigningRequest` (CSR).
  - **CA Interne :** Kubernetes peut signer les demandes de certificats en utilisant une CA interne configurée au niveau du cluster.
  - **Automatisation :** Intègre des contrôleurs qui peuvent approuver et signer automatiquement les demandes de certificats basées sur des politiques définies.

- **Avantages :**
  - Solution native à Kubernetes, sans besoin d'outils externes.
  - Intégration transparente avec l'écosystème Kubernetes.
  - Gestion simplifiée des certificats pour les composants internes du cluster.

**Application**

- **PKI Privée :** Utilise une CA interne configurée au niveau du cluster pour signer les demandes de certificats.
--- 

## Cert-Controller

**Cert-Controller** est un contrôleur Kubernetes pour la gestion des certificats. Il peut être utilisé en complément de cert-manager ou de manière autonome.

- **Capacités :**
  - **Gestion des Certificats :** Peut surveiller les ressources de type `Certificate` et automatiser la création, le renouvellement et la distribution des certificats.
  - **CA et ACME :** Supporte à la fois les CA internes et les CA compatibles ACME pour l'émission des certificats.
  - **Integration avec les Secrets Kubernetes :** Gère les certificats en tant que secrets Kubernetes, facilitant leur utilisation par les applications.

- **Avantages :**
  - Flexible et facile à configurer.
  - Peut être utilisé pour des cas d'utilisation spécifiques ou en complément de cert-manager.
  - Supporte divers backends pour l'émission des certificats.

**Application**
- 
- **PKI Privée :** Supporte les CA internes pour l'émission des certificats.
- **ACME :** Peut être configuré pour utiliser des CA compatibles ACME.

--- 

## TP : Installation de Cert-Manager dans un Cluster Kubernetes pour l'Application Bookinfo avec Istio

**Dans ce TP, nous allons installer Cert-Manager dans un cluster Kubernetes pour automatiser la gestion des certificats TLS.** 

Nous allons utiliser Cert-Manager pour sécuriser l'application d'exemple Bookinfo fournie par Istio, ainsi que pour configurer une Gateway Istio avec un certificat TLS émis automatiquement.

### Prérequis

- Un cluster Kubernetes fonctionnel.
- kubectl installé et configuré pour accéder à votre cluster Kubernetes.
- Helm installé pour gérer les packages Kubernetes.

### Étape 1 : Installation de Cert-Manager

1. **Ajoutez le référentiel Helm de Cert-Manager :**

   Ajoutez d'abord le référentiel Cert-Manager :
   ```bash
   helm repo add jetstack https://charts.jetstack.io
   helm repo update
   ```

2. **Installez Cert-Manager :**

   Créez un namespace pour Cert-Manager :
   ```bash
   kubectl create namespace cert-manager
   ```

   Installez Cert-Manager avec Helm :
   ```bash
   helm install cert-manager jetstack/cert-manager --namespace cert-manager --version v1.7.0 --set installCRDs=true
   ```

3. **Vérifiez que Cert-Manager est déployé :**
   ```bash
   kubectl get pods -n cert-manager
   ```
   Assurez-vous que tous les pods dans le namespace `cert-manager` sont en état `Running`.

### Étape 2 : Déploiement de l'Application Bookinfo avec Istio

1. **Déployez l'application Bookinfo :**

   Déployez l'application Bookinfo fournie par Istio :
   ```bash
   kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.13/samples/bookinfo/platform/kube/bookinfo.yaml
   ```

2. **Exposez l'application Bookinfo via une Gateway Istio :**

   Créez une Gateway Istio pour exposer l'application Bookinfo :
   ```bash
   kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.13/samples/bookinfo/networking/bookinfo-gateway.yaml
   ```

### Étape 3 : Configuration d'un Certificat TLS pour la Gateway Istio avec Cert-Manager

1. **Créez un Issuer Let's Encrypt pour Cert-Manager :**

   Créez un fichier `issuer.yaml` avec le contenu suivant pour utiliser Let's Encrypt :
   ```yaml
   apiVersion: cert-manager.io/v1
   kind: Issuer
   metadata:
     name: letsencrypt-prod
     namespace: cert-manager
   spec:
     acme:
       server: https://acme-v02.api.letsencrypt.org/directory
       email: your-email@%YOURDOMAIN%
       privateKeySecretRef:
         name: letsencrypt-prod
       solvers:
       - http01:
           ingress:
             class: istio
   ```

   Appliquez cette configuration :
   ```bash
   kubectl apply -f issuer.yaml
   ```

   Assurez-vous de remplacer `your-email@%YOURDOMAIN%` par votre adresse e-mail.

2. **Déployez un certificat TLS pour la Gateway Istio :**

   Créez un fichier `certificate.yaml` avec le contenu suivant pour demander un certificat TLS pour la Gateway Istio :
   ```yaml
   apiVersion: cert-manager.io/v1
   kind: Certificate
   metadata:
     name: istio-ingressgateway-certificate
     namespace: istio-system
   spec:
     secretName: istio-ingressgateway-certs
     issuerRef:
       name: letsencrypt-prod
       kind: Issuer
     commonName: "*.<your-domain>"
     dnsNames:
       - "*.<your-domain>"
   ```

   Appliquez cette configuration :
   ```bash
   kubectl apply -f certificate.yaml
   ```

   Assurez-vous de remplacer `<your-domain>` par votre domaine réel.


### Étape 4 : Assurez-vous que le Certificat est Émis et Stocké

1. **Vérifiez que le certificat est bien créé :**

   Utilisez la commande suivante pour vérifier que le certificat est correctement émis :
   ```bash
   kubectl get certificates -n istio-system
   ```

2. **Assurez-vous que le secret contient les certificats :**

   Vérifiez que le secret `istio-ingressgateway-certs` contient les certificats émis :
   ```bash
   kubectl get secret istio-ingressgateway-certs -n istio-system -o yaml
   ```

   Vous devriez voir les clés `tls.crt` et `tls.key` dans le secret.

### Étape 5 : Modifier le Fichier `bookinfo-gateway.yaml`

Modifiez le fichier `bookinfo-gateway.yaml` pour ajouter une configuration HTTPS :

1. **Créez ou modifiez le fichier `bookinfo-gateway.yaml` :**
   
   Voici un exemple de configuration ajustée pour ajouter le support HTTPS :
   ```yaml
   apiVersion: networking.istio.io/v1alpha3
   kind: Gateway
   metadata:
     name: bookinfo-gateway
     namespace: default
   spec:
     selector:
       istio: ingressgateway # Utilise le label du pod de l'ingress gateway
     servers:
     - port:
         number: 443
         name: https
         protocol: HTTPS
       tls:
         mode: SIMPLE
         credentialName: istio-ingressgateway-certs # Référence au secret TLS
         minProtocolVersion: TLSV1_2
         maxProtocolVersion: TLSV1_3
       hosts:
       - "*.<your-domain>"  # Remplacez par votre domaine
   ```

   Remplacez `<your-domain>` par le domaine que vous utilisez. Si vous testez localement, vous pouvez utiliser `*.<cluster-ip>.nip.io`.

2. **Appliquez la configuration :**
   ```bash
   kubectl apply -f bookinfo-gateway.yaml
   ```

### Étape 6 : Vérification et Tests

1. **Vérifiez que la Gateway est créée correctement :**
   ```bash
   kubectl get gateways -n default
   kubectl describe gateway bookinfo-gateway -n default
   ```

2. **Vérifiez que le service Istio Ingress Gateway est bien configuré :**
   ```bash
   kubectl get svc istio-ingressgateway -n istio-system
   ```

   Assurez-vous que le service écoute sur le port 443.

3. **Testez l'accès à l'application Bookinfo via HTTPS :**

   Utilisez l'adresse IP externe du service `istio-ingressgateway` et testez avec `curl` ou dans un navigateur :
   ```bash
   kubectl get svc istio-ingressgateway -n istio-system
   ```

   Exemple avec `curl` :
   ```bash
   curl -s https://<EXTERNAL-IP>/productpage | grep -o "<title>.*</title>"
   ```

   Remplacez `<EXTERNAL-IP>` par l'adresse IP externe du service Istio Ingress Gateway.

---

Vous pouvez explorer davantage en configurant des politiques de renouvellement automatique, en intégrant d'autres fournisseurs de certificats, ou en utilisant des configurations plus avancées de Cert-Manager pour répondre aux exigences spécifiques de sécurité de votre environnement.
---
title: Jour 3 - Matin
---


# Jour 3 - Matin

## Contrôle du trafic avec Network Policies  

**Les **Network Policies** sont un outil puissant pour sécuriser les communications réseau au sein d’un cluster Kubernetes.** 

Elles permettent de contrôler efficacement le trafic entre les services et de limiter les surfaces d'attaque en restreignant les communications inutiles ou dangereuses.

**Les **Network Policies** dans Kubernetes permettent de contrôler le trafic réseau entrant et sortant des Pods.** 

Elles sont utilisées pour définir les règles de sécurité réseau à l’intérieur d’un cluster, et permettent de restreindre ou d’autoriser des communications entre différents Pods, namespaces, ou réseaux externes. Ces politiques sont essentielles pour sécuriser les communications entre services dans un environnement de production.

---

#### Concepts clés

1. **Namespace** : Les Network Policies sont définies par namespace. Chaque règle s’applique uniquement aux Pods d’un namespace donné.
   
2. **Sélecteurs de Pods (Pod Selectors)** : Les règles s’appliquent aux Pods sélectionnés par une `NetworkPolicy` en fonction de labels. Ces sélecteurs identifient les Pods ciblés pour appliquer des restrictions ou des permissions de trafic.

3. **Ingress et Egress** : 
   - **Ingress** : Contrôle le trafic entrant dans les Pods.
   - **Egress** : Contrôle le trafic sortant des Pods.

4. **Isolation** : Par défaut, tous les Pods peuvent communiquer entre eux dans un cluster. Cependant, dès qu’une **NetworkPolicy** est créée pour un Pod, Kubernetes applique l’isolation réseau et le trafic n’est plus autorisé que selon les règles spécifiées dans la politique.

---

#### Exemple de manifeste YAML de Network Policy

Voici un exemple de `NetworkPolicy` qui autorise uniquement le trafic HTTP entrant sur les Pods portant le label `app: web` depuis les Pods du même namespace portant le label `role: frontend`.

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-http
  namespace: default
spec:
  podSelector:
    matchLabels:
      app: web
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          role: frontend
    ports:
    - protocol: TCP
      port: 80
```

Dans cet exemple :
- **podSelector** : Seules les règles définies s’appliquent aux Pods avec le label `app: web`.
- **policyTypes** : Indique que cette politique concerne le trafic entrant (`Ingress`).
- **from** : Seuls les Pods avec le label `role: frontend` peuvent envoyer des requêtes aux Pods `app: web`.
- **ports** : Seul le port TCP 80 (HTTP) est autorisé.

---

#### Contrôle du trafic sortant (Egress)

Voici un exemple de `NetworkPolicy` qui restreint le trafic sortant à un seul sous-réseau IP externe.

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: restrict-egress
  namespace: default
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
  - Egress
  egress:
  - to:
    - ipBlock:
        cidr: 192.168.1.0/24
    ports:
    - protocol: TCP
      port: 443
```

Dans cet exemple :
- Les Pods avec le label `app: backend` peuvent uniquement envoyer du trafic vers le sous-réseau `192.168.1.0/24` sur le port 443 (HTTPS).

---

#### Points clés

1. **Isolation par défaut** : En l’absence de Network Policies, tout trafic est autorisé. Dès qu’une Policy est appliquée à un Pod, l’isolation réseau s’applique à ce Pod et le trafic doit être explicitement autorisé via des règles.
   
2. **Précision des règles** : Vous pouvez combiner des `PodSelectors`, `NamespaceSelectors` et des plages d’adresses IP (`ipBlock`) pour créer des règles de sécurité très précises.

3. **Support par les CNI (Container Network Interface)** : Les Network Policies ne sont pas prises en charge par tous les plugins réseau. Des solutions comme **Calico**, **Cilium**, ou **Weave** offrent un support complet des Network Policies. Assurez-vous que votre CNI supporte ces fonctionnalités.

---

#### Commandes kubectl utiles

- **Lister les Network Policies dans un namespace** :

```bash
kubectl get networkpolicies -n <namespace>
```

- **Afficher les détails d'une Network Policy** :

```bash
kubectl describe networkpolicy <policy-name> -n <namespace>
```


---

## Utilisation de l’exposition via Ingress et Gateway  

### Les objets Ingresses

![](/img/kubernetes/ingress.png)
*Crédits [Ahmet Alp Balkan](https://medium.com/@ahmetb)*

Un Ingress est un objet pour gérer dynamiquement le **reverse proxy** HTTP/HTTPS dans Kubernetes. Documentation: https://kubernetes.io/docs/concepts/services-networking/ingress/#what-is-ingress

Exemple de syntaxe d'un ingress:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress-wildcard-host
spec:
  rules:
  - host: "domain1.bar.com"
    http:
      paths:
      - pathType: Prefix
        path: "/bar"
        backend:
          service:
            name: service1
            port:
              number: 80
      - pathType: Prefix
        path: "/foo"
        backend:
          service:
            name: service2
            port:
              number: 80
  - host: "domain2.foo.com"
    http:
      paths:
      - pathType: Prefix
        path: "/"
        backend:
          service:
            name: service3
            port:
              number: 80
```

Pour pouvoir créer des objets ingress il est d'abord nécessaire d'installer un **ingress controller** dans le cluster:

- Il s'agit d'un déploiement conteneurisé d'un logiciel de reverse proxy (comme nginx) et intégré avec l'API de kubernetes
- Le controlleur agit donc au niveau du protocole HTTP et doit lui-même être exposé (port 80 et 443) à l'extérieur, généralement via un service de type LoadBalancer.
- Le controlleur redirige ensuite vers différents services (généralement configurés en ClusterIP) qui à leur tour redirigent vers différents ports sur les pods selon l'URL del a requête.

Il existe plusieurs variantes d'**ingress controller**:

- Un ingress basé sur Nginx plus ou moins officiel à Kubernetes et très utilisé: https://kubernetes.github.io/ingress-nginx/
- Un ingress Traefik optimisé pour k8s.
- il en existe d'autres : celui de payant l'entreprise Nginx, Contour, HAProxy...

Chaque provider de cloud et flavour de kubernetes est légèrement différent au niveau de la configuration du controlleur ce qui peut être déroutant au départ:

- minikube permet d'activer l'ingress nginx simplement (voir TP)
- autre example: k3s est fourni avec traefik configuré par défaut
- On peut installer plusieurs `ingress controllers` correspondant à plusieurs `IngressClasses`

Comparaison des controlleurs: <https://medium.com/flant-com/comparing-ingress-controllers-for-kubernetes-9b397483b46b>

### La nouvelle API Gateway

- https://gateway-api.sigs.k8s.io/

### Gestion dynamique des certificats à l'aide de `certmanager`

`Certmanager` est une application kubernetes (un `operator`) capable de générer automatiquement des certificats TLS/HTTPS pour nos ingresses.

- Documentation d'installation: https://cert-manager.io/docs/installation/kubernetes/
- Tutorial pas à pas pour générer un certificat automatiquement avec un ingress et letsencrypt: https://cert-manager.io/docs/tutorials/acme/ingress/

Exemple de syntaxe d'un ingress utilisant `certmanager`:

```yaml
apiVersion: networking.k8s.io/v1 
kind: Ingress
metadata:
  name: kuard
  annotations:
    kubernetes.io/ingress.class: "nginx"    
    cert-manager.io/issuer: "letsencrypt-prod"
spec:
  tls:
  - hosts:
    - example.example.com
    secretName: quickstart-example-tls
  rules:
  - host: example.example.com
    http:
      paths:
      - path: /
        pathType: Exact
        backend:
          service:
            name: kuard
            port:
              number: 80
```

---

###Surveillance et journalisation  
  - Prometheus  
  - Grafana  



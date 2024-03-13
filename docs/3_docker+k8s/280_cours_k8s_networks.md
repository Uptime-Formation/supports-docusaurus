---
draft: false
title: Le réseau (services, netpol et ingress)
---

## Le réseau (services, netpol et ingress)



### Les Services

**Dans Kubernetes, un Service est un objet qui :**
- Désigne un ensemble de pods (grâce à des labels) généralement géré par un déploiement.
- Fournit un endpoint réseau pour les requêtes à destination de ces pods.
- Configure une politique permettant d’y accéder depuis l'intérieur ou l'extérieur du cluster.
- Configure un nom de domaine pointant sur le groupe de pods en backend.


---

**L’ensemble des pods ciblés par un service est déterminé par un `selector`.**

Par exemple, considérons un backend de traitement d’image (*stateless*, c'est-à-dire ici sans base de données) qui s’exécute avec 3 replicas. Ces replicas sont interchangeables et les frontends ne se soucient pas du backend qu’ils utilisent. Bien que les pods réels qui composent l’ensemble `backend` puissent changer, les clients frontends ne devraient pas avoir besoin de le savoir, pas plus qu’ils ne doivent suivre eux-mêmes l'état de l’ensemble des backends.

L’abstraction du service permet ce découplage : les clients frontend s'addressent à une seule IP avec un seul port dès qu'ils ont besoin d'avoir recours à un backend. Les backends vont recevoir la requête du frontend aléatoirement.

Les Services sont de trois types principaux :

- `ClusterIP`: expose le service **sur une IP interne** au cluster.

- `NodePort`: expose le service depuis l'IP de **chacun des noeuds du cluster** en ouvrant un port directement sur le nœud, entre 30000 et 32767. Cela permet d'accéder aux pods internes répliqués. Comme l'IP est stable on peut faire pointer un DNS ou Loadbalancer classique dessus.

- `LoadBalancer`: expose le service en externe à l’aide d'un Loadbalancer de fournisseur de cloud. Les services NodePort et ClusterIP, vers lesquels le Loadbalancer est dirigé sont automatiquement créés.


---


## Les objets Ingresses

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

---


**Pour pouvoir créer des objets ingress il est d'abord nécessaire d'installer un *ingress controller* dans le cluster:**

- Il s'agit d'un déploiement conteneurisé d'un logiciel de reverse proxy (comme nginx) et intégré avec l'API de kubernetes
- Le controlleur agit donc au niveau du protocole HTTP et doit lui-même être exposé (port 80 et 443) à l'extérieur, généralement via un service de type LoadBalancer.
- Le controlleur redirige ensuite vers différents services (généralement configurés en ClusterIP) qui à leur tour redirigent vers différents ports sur les pods selon l'URL del a requête.


---


**Il existe plusieurs variantes d'*ingress controller*:**

- Un ingress basé sur Nginx plus ou moins officiel à Kubernetes et très utilisé: https://kubernetes.github.io/ingress-nginx/
- Un ingress Traefik optimisé pour k8s.
- il en existe d'autres : celui de payant l'entreprise Nginx, Contour, HAProxy...

---


**Chaque provider de cloud et flavour de kubernetes est légèrement différent au niveau de la configuration du controlleur ce qui peut être déroutant au départ:**

- minikube permet d'activer l'ingress nginx simplement (voir TP)
- autre example: k3s est fourni avec traefik configuré par défaut
- On peut installer plusieurs `ingress controllers` correspondant à plusieurs `IngressClasses`

Comparaison des controlleurs: <https://medium.com/flant-com/comparing-ingress-controllers-for-kubernetes-9b397483b46b>

---


## Gestion dynamique des certificats à l'aide de `certmanager`

**`Certmanager` est une application kubernetes (un `operator`) capable de générer automatiquement des certificats TLS/HTTPS pour nos ingresses.**

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


## Architecture réseau Kubernetes

### Réseau standard de Kubernetes

**La configuration réseau standard pour Kubernetes implique l'utilisation de Flannel comme CNI plugin (solution de réseau virtuel compatible Container Network Interface) et de Kube-proxy en mode iptables (configuration par défaut de k3s par exemple mais aussi la configuration la plus simple avec kubeadm etc).**

Dans cette configuration, Flannel est responsable de la mise en place d'un réseau virtuel (on parle de network fabric) qui permet aux pods de communiquer entre eux sur différents nœuds dans le cluster. Flannel assigne une adresse IP unique à chaque pod et crée un tunnel VXLAN ou UDP entre les nœuds pour permettre la communication entre les pods.

Kube-proxy, configuré en mode iptables, utilise l'outil iptables (de filtrage de paquet dans le noyaux Linux)  pour gérer le trafic réseau dans le cluster. Il crée des règles iptables pour faire suivre le trafic vers les endpoints des pods ou des services appropriés en fonction de leurs adresses IP et des ports. Kube-proxy maintient également une table NAT pour gérer le trafic entrant vers le cluster.


---


## CNI (container network interface) : Les implémentations du réseau Kubernetes

**Beaucoup de solutions de réseau qui se concurrencent, demandant un comparatif un peu fastidieux.**

  - plusieurs solutions toutes robustes
  - diffèrent sur l'implémentation : BGP, réseau overlay ou non (encapsulation VXLAN, IPinIP, autre)
  - toutes ne permettent pas d'appliquer des **NetworkPolicies** : l'isolement et la sécurité réseau
  - peuvent parfois s'hybrider entre elles (Canal = Calico + Flannel)

- Calico, Flannel, Weave ou Cilium sont très employées et souvent proposées en option par les fournisseurs de cloud
- Flannel est simple et éprouvé mais sans network policies ou observabilité avancée
- Cilium a la particularité d'utiliser la technologie eBPF de Linux qui permet une sécurité et une rapidité accrue

Comparaisons :
- <https://rancher.com/blog/2019/2019-03-21-comparing-kubernetes-cni-providers-flannel-calico-canal-and-weave/>

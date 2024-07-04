
---
title:   Test
weight: 1
---

## Quiz sur le Réseau dans Kubernetes

### 1. Thème: Plugins CNI
**Question:** Quel plugin CNI est couramment utilisé pour des réseaux overlay simples utilisant le routage UDP?
a) Calico  
b) Flannel  
c) Cilium  
d) Weave

### 2. Thème: Plugins CNI
**Question:** Quelle solution CNI implémente des politiques réseau avancées et utilise BPF pour la performance?
a) Flannel  
b) Calico  
c) Weave  
d) Multus

### 3. Thème: Plugins CNI
**Question:** Quelle technologie utilise Calico pour un routage réseau hautement scalable et performant?
a) VXLAN  
b) Routage BGP  
c) Routage UDP  
d) IPIP

### 4. Thème: Service Mesh (Est-Ouest)
**Question:** Quel composant est responsable de la gestion des configurations et de la découverte des services dans un service mesh?
a) Data Plane  
b) Control Plane  
c) EndpointSlice  
d) Ingress Controller


### 5. Thème: Service Mesh (Est-Ouest)
**Question:** Quelle solution de service mesh utilise eBPF pour le traitement efficace du trafic réseau?
a) Istio  
b) Linkerd  
c) Cilium  
d) Consul

### 6. Thème: Service Mesh (Est-Ouest)
**Question:** Quel composant d'un service mesh est généralement déployé avec l'application pour gérer les communications près des applications?
a) Control Plane  
b) Data Plane  
c) Ingress Controller  
d) kube-proxy

### 7. Thème: Certificats
**Question:** Quelle solution est utilisée pour gérer les certificats dans Kubernetes, capable de s'intégrer avec le protocole ACME?
a) CoreDNS  
b) Calico  
c) cert-manager  
d) Flannel

### 8. Thème: Certificats
**Question:** Quelle est l'API de base de Kubernetes utilisée pour gérer les certificats?
a) cert-manager.io  
b) certificates.k8s.io  
c) network.k8s.io  
d) auth.k8s.io

### 9. Thème: Ingress (Nord/Sud)
**Question:** Quelle fonctionnalité est fournie par les Ingress dans Kubernetes?
a) Routage HTTP/HTTPS  
b) Répartition de charge  
c) Terminaison TLS  
d) Toutes les réponses ci-dessus

### 10. Thème: Ingress (Nord/Sud)
**Question:** Quelle est la différence principale entre Ingress et Gateway API dans Kubernetes?
a) Ingress est plus flexible que Gateway API  
b) Gateway API offre plus de flexibilité et d'extensibilité que Ingress  
c) Ingress gère les communications Est-Ouest  
d) Gateway API ne supporte pas le routage HTTP/HTTPS


## Correction

<details><summary>...</summary>

1. b) Flannel  
2. b) Calico  
3. b) Routage BGP  
4. b) Control Plane  
5. c) Cilium  
6. b) Data Plane
7. c) cert-manager  
8. b) certificates.k8s.io  
9. d) Toutes les réponses ci-dessus  
10. b) Gateway API offre plus de flexibilité et d'extensibilité que Ingress  


</details>
---
title: Recap K8s - Exposer des services publiquement
draft: true
---

Les "NodePort" ça va 5 minutes mais on veut des apps accessibles avec un nom de domaine voir en https.

Il existe 3 possibilités "simples":

1. Utiliser un ingress controller accessible sur l'IP des noeuds du cluster.
   1. + simple dans minikube avec `minikube addons enable ingress`
   2. - avec l'installation helm générique il faut un peu configurer pour avoir la meme chose que dans minikube
   3. - il faut ajouter manuellement un loadbalancer pour avoir la HA
2. Utiliser un loadbalancer du cloud provider (pointant vers un service ou un ingress)   
3. Installer "on premise" un loadbalancer integrable à k8s comme melallb https://metallb.universe.tf/ pour faire comme dans le cloud.

Pour les certificats HTTPS il faut préciser dans l'ingress object le secret contenant le certif. 

Pour émettre le certificat avec letsencrypt il faut utiliser generalement le chart cert-manager.




Installer nginx ingress controller pour exposer ses services sur l'ip de chaque noeud
-------------------------------------------------------------------------------------

Dans minikube `minikube addons enable ingress` suffit.

### Pour l'installer à la main avec helm:


#### Mode sans LoadBalancer

Utiliser les paramètres suivants dans un fichier yaml

```yaml
controller:
  kind: DaemonSet # pour avoir un pod par node en mode daemon et exposer une IP externe par node
  
  daemonset:
    useHostPort: true # donner une IP externe au daemon
  
  hostNetwork: true # permet de brancher le pod du controlleur au réseau du noeud et avoir une ip externe

  service:
    enabled: false # pas besoin de service avec un controlleur de type DaemonSet qui a une ip externe

  ingressClass: nginx-chart # étiquette pour préciser dans les obj ingress quel controller utiliser. default nginx (=> conflit avec l'addon minikube)
```

Faire par exemple un rendu en mode template avec :

`helm template <release_name> stable/nginx-ingress --values <config>.yaml > resulting_resources.yaml`

Vérifier les ressources à créer puis lancer :

`kubectl apply -f resulting_resources.yaml`

#### Mode avec LB

en combinaison par exemple avec metalLB ou le LB d'un cloud provider : on peut laisser les paramètres par défaut du chart. Cela va créer un deployment et un service de type LoadBalancer.

### sources: 

- https://cert-manager.io/docs/tutorials/acme/ingress/
- https://medium.com/containerum/how-to-launch-nginx-ingress-and-cert-manager-in-kubernetes-55b182a80c8f




Installer metallb pour avoir un loadbalancer intégré sur un cluster on premise
------------------------------------------------------------------------------

- [https://metallb.universe.tf/installation/](https://metallb.universe.tf/installation/)

Exemple dans minikube:

- [https://ervikrant06.github.io/kubernetes/metallb-LB-on-minikube/](https://ervikrant06.github.io/kubernetes/metallb-LB-on-minikube/)




Génerer un certificat et le lier à un ingress
---------------------------------------------------------

### Générer un certificat auto-signé pour le développement

[https://kubernetes.github.io/ingress-nginx/user-guide/tls/](https://kubernetes.github.io/ingress-nginx/user-guide/tls/)

```bash
export KEY_FILE=ca.key
export CERT_FILE=ca.crt
export CERT_NAME=funk8s-tlscert
export HOST=funkwhale.local

openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ${KEY_FILE} -out ${CERT_FILE} -subj "/CN=${HOST}/O=${HOST}"
kubectl create secret tls ${CERT_NAME} --key ${KEY_FILE} --cert ${CERT_FILE}
 
```

### Servir le certificat https avec un ingress

```yaml
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: funkwhale-local-ing
spec:
  tls:
  - hosts:
    - funkwhale.local
    secretName: funk8s-tlscert
  rules:
    - host: funkwhale.local
      http:
        paths:
        - path: /
          backend:
            serviceName: funkwhale-front
            servicePort: 80
```


### Installer cert-manager pour générer un certificat letsencrypt

[https://cert-manager.io/docs/installation/kubernetes/](https://cert-manager.io/docs/installation/kubernetes/)


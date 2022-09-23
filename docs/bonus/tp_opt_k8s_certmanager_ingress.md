---
title: TP optionnel - Exposer une application en HTTPS via certmanager et un ingress nginx
draft: true
weight: 2089
---

<!-- Suivre ce tutorial officiel: https://cert-manager.io/docs/tutorials/acme/ingress/#step-2-deploy-the-nginx-ingress-controller -->

<!-- Suivre ce tutorial : https://sysadmins.co.za/https-using-letsencrypt-and-traefik-with-k3s/ -->


1. Installer cert-manager avec la commande `kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.6.1/cert-manager.yaml`

## Créer un certificat Letsencrypt pour notre cluster k3s: version Traefik

2. Objet de type `ClusterIssuer` à créer pour configurer Let's Encrypt :

```yaml
apiVersion: cert-manager.io/v1alpha2
kind: ClusterIssuer
metadata:
  #   name: letsencrypt-staging
  name: letsencrypt-prod
spec:
  acme:
    email: cto@doxx.fr
    privateKeySecretRef:
      name: prod-issuer-account-key
    #   name: staging-issuer-account-key
    server: https://acme-v02.api.letsencrypt.org/directory
    # server: https://acme-staging-v02.api.letsencrypt.org/directory
    http01: {}
    solvers:
      - http01:
          ingress:
            class: traefik
        selector: {}
```

3. Si ce n'est pas fait, installer un _Ingress Controller_ (un reverse proxy) avec Helm, ici nous installons Traefik mais ça peut être Nginx (si vous prenez Nginx, il faudra modifier un peu l'objet `Ingress` plus bas et l'avant-dernière ligne de l'objet `ClusterIssuer`) :

```bash
helm repo add traefik https://helm.traefik.io/traefik
helm repo update
helm install traefik traefik/traefik
```

4. Créer un objet Ingress en adaptant celui donné dans le tutoriel (il faudra qu'il soit lié à un Service existant, lui-même lié à un objet Deployment existant) :

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: monster-ingress
  annotations:
    traefik.ingress.kubernetes.io/router.tls: "true"
    kubernetes.io/ingress.class: traefik
    cert-manager.io/cluster-issuer: letsencrypt-prod
spec:
  tls:
    - hosts:
        - monster.hadrien.lab.doxx.fr
      secretName: monster-hadrien-lab-doxx-fr
  rules:
    - host: monster.hadrien.lab.doxx.fr
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: monstericon
                port:
                  number: 5000
```

_NB :_ si vous n'arrivez pas à obtenir de certificat HTTPS, modifiez l'objet `ClusterIssuer` pour obtenir un certificat depuis les serveurs _staging_ de Let's Encrypt : Let's Encrypt limite très fortement le nombre de certificats installables sur les mêmes domaines et sous-domaines.

## Créer un certificat Letsencrypt pour notre cluster k3s: version Nginx
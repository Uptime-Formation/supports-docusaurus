---
title: TP optionnel - Installer ArgoCD
---

ArgoCD est un opérateur d'application qui implémente la méthode de déploiement moderne de GitOps. Il est plutôt agréable et puissant.

Qu'est-ce que le GitOps: 

- Présentation : https://dev.to/thenjdevopsguy/gitops-with-argocd-getting-started-dg
- Nouveau projet de standardisation de GitOps par la CNCF : https://opengitops.dev/

Les prérequis pour ce TP sont:
- disposer d'un cluster k3s (ou autre cluster mais étapes à adapter)
- du ingress NGINX
- d'une façon de générer des certificats https avec Certmanager.

L'installation:

- Effectuer l'installation avec la première méthode du getting started : https://argo-cd.readthedocs.io/en/stable/getting_started/

- Il faut maintenant créer l'ingress (reverse proxy) avec une configuration particulière que nous allons expliquer.

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: argocd-server-ingress
  namespace: argocd
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
    kubernetes.io/ingress.class: nginx
    kubernetes.io/tls-acme: "true"
    nginx.ingress.kubernetes.io/ssl-passthrough: "true"
    # If you encounter a redirect loop or are getting a 307 response code 
    # then you need to force the nginx ingress to connect to the backend using HTTPS.
    #
    nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
spec:
  tls:
  - hosts:
    - argocd.<stagiaire>.<labdomain>
    secretName: argocd-secret # do not change, this is provided by Argo CD
  rules:
  - host: argocd.<stagiaire>.<labdomain>
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: argocd-server
            port:
              number: 443
```

- Créez et appliquez cette ressource Ingress.

- Vérifiez dans Lens que l'ingress a bien généré un certificat (cela peut prendre jusqu'à 2 minutes)

- Chargez la page `argocd.<votre sous domaine>` dans un navigateur. exp `argocd.stagiaire1.kube.dopl.uk`

- Pour se connecter utilisez le login admin et récupérez le mot de passe admin en allant chercher le secret `argocd-initial-admin-secret` dans Lens (Config > Secrets avec le namespace argocd activé).
---
draft: false
title: "TP - Installer l'operateur Certmanager pour les certificats HTTPS"
# sidebar_position: 12
# sidebar_class_name: hidden
---

Nous aimerions héberger des sites proprement en HTTPS, mais pour cela nous avons besoin de pouvoir:

- Exposer nos applications en HTTP sur des noms de domaines adéquats comme dans le TP monsterstack.

- Configurer HTTPS pour authentifier et chiffrer la connection à nos applications. Pour cette partie nous avons besoin de générer des certificats d'authentification délivrés pas une authorité dont la plus pratique pour nous est **letsencrypt** qui permet de réclamer un certificat via un challenge automatique. Cette configuration est souvent réaliser dans kubernetes via l'opérateur Certmanager

A noter que vos serveurs VNC qui sont aussi désormais des clusters k3s ont déjà plusieurs sous-domaines configurés: `<votrelogin>.<soudomaine>.dopl.uk` et `*.<votrelogin>.<soudomaine>.dopl.uk`. Le sous domaine `argocd.<login>.<soudomaine>.dopl.uk` pointe donc déjà sur le serveur (Wildcard DNS).

Ce nom de domaine va nous permettre de générer un certificat HTTPS pour notre application web argoCD grâce à un ingress nginx, le cert-manager de k8s et letsencrypt (challenge HTTP101).

## Si nécessaire : installer le ingress NGINX

Les TPs de ce supports utilisant cert-manager supposent que vous avez l'ingress nginx installé. Ils peuvent cependant fonctionner avec d'autres ingress directement ou avec de petites modifications.

Si ce n'est pas encore fait vous pouvez installer le ingress nginx selon votre plateforme

<details><summary>Dans minikube</summary>

https://kubernetes.io/docs/tasks/access-application-cluster/ingress-minikube/

</details>

<details><summary>Dans kind</summary>

https://kind.sigs.k8s.io/docs/user/ingress/

</details>

<details><summary>Dans le lab kube_tofu / hobby-kube</summary>

https://github.com/hobby-kube/guide#ingress-controller-setup

</details>

<details><summary>Dans k3s</summary>

Vérifier si le ingress nginx est déjà installé avant d'exécuter la ligne suivante.

- Installer l'ingress nginx avec la commande: `kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.1.0/deploy/static/provider/cloud/deploy.yaml` (pour autres méthodes ou problèmes voir : https://kubernetes.github.io/ingress-nginx/deploy/)

- Vérifiez l'installation avec `kubectl get svc -n ingress-nginx ingress-nginx-controller` : le service `ingress-nginx-controller` devrait avoir une IP externe

</details>

## Installer Cert-manager

- Pour installer cert-manager lancez : `kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.16.1/cert-manager.yaml`

- Il faut maintenant créer une ressource de type `ClusterIssuer` pour pourvoir émettre (to issue) des certificats.

- Créez une ressource comme suit (soit dans Lens avec `+` soit dans un fichier à appliquer ensuite avec `kubectl apply -f`):

```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    # You must replace this email address with your own.
    # Let's Encrypt will use this to contact you about expiring
    # certificates, and issues related to your account.
    email: cto@nomail.fr
    server: https://acme-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      # Secret resource that will be used to store the account's private key.
      name: letsencrypt-prod-account-key
    # Add a single challenge solver, HTTP01 using nginx
    solvers:
    - http01:
        ingress:
          class: nginx
```

#### D'autres Issuers

Pour utiliser l'issuer précédent (challenge HTTP01 de letsencrypt) il faut que le cluster soit joignable sur une IP publique et que l'ingress nginx soit bien configuré.

Pour générer des certificats si ces requirements ne sont pas vérifiés on peut utiliser des **certificats autosignés** ou un **challenge DNS** letsrencrypt.

##### Self signed

Certificats autosignés créez la resource suivante:

```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: selfsigned
spec:
  selfSigned: {}
```

##### Challenge DNS avec l'api DigitalOcean

<details>

Pour utiliser cet exemple tel que il faut un compte chez le fournisseur de cloud DigitalOcean et que le nom de domaine qu'on veut manipuler dans nos ingress avec certificats soit géré par DigitalOcean (ce qui est le cas d'un des auteurs de ce supports pour les TPs).

Pour utiliser d'autre formes de DNS challenges avec d'autres fournisseurs allez voir la documentation officielle de Cert Manager.

Créer un token dédié au DNS dans DigitalOcean et ajoutez à un secret comme suit (encodé avec `base64 --encode "token"`)

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: digitalocean-token
  namespace: cert-manager
data:
  # insert your DO access token here encoded in base64
  access-token: "Y2hhlmdlX21lX3dphGhfdG9rZw4K"
```

Ensuite on peut créer un Issuer ou ClusterIssuer avec 

```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: acme-dns-issuer-prod
spec:
  acme:
    # You can replace this email address with your own.
    # Let's Encrypt will use this to contact you about expiring
    # certificates, and issues related to your account.
    email: trucmuche@bidule.fr
    server: https://acme-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      # Secret resource that will be used to store the account's private key.
      name: letsencrypt-prod-account-key
    # Add a single challenge solver, HTTP01 using nginx
    solvers:
    - dns01:
        digitalocean:
          tokenSecretRef:
            name: digitalocean-token
            key: access-token
```

</details>
---
title: TP optionnel - Ajouter une identité via certificat et configurer le RBAC
---

## Authentification et authorization

La gestion des identités est très flexible et configurable dans kubernetes comprendre: il n'y a pas de façon standard et automatique de gérer des utilisateurs mais de multiples méchanismes d'authentification. Il revient à chaque équipe/solution basée sur kubernetes d'implémenter quelque chose de satisfaisant.

- doc officielle: https://kubernetes.io/docs/reference/access-authn-authz/authentication

La façon manuelle la plus simple et directe pour créer des identités est de générer des certificats client avec la fonctionnalité d'approbation de certificat des cluster k8s.
Pour cela comme dans toute PKI il va nous falloir:

1. générer une clé privée et une CertificateSigningRequest puis
2. demander au cluster de l'approuver et générer le certificat correspondant
3. le télécharger
4. ensuite nous pourrons ajouter ce nouveau certificat client à notre kubeconfig: voilà notre identité. mais elle n'a aucun droit donc..
5. il faut créer une matrice de droit (Role)
6. Associer cette matrice de droits a notre "User" i.e. le Common Name de notre certificat client
7. vérifier avec `kubectl can-i` ou autre que nous avons bien les droits requis

## Générer la clé privée et la CSR

- Choisir un nom à utiliser pour le Common Name de la CSR et pour les fichiers/champs user: par exemple `votreprenomnom`

- créer un dossier `tp_auth` et aller dedans.

- créer la clé privée: `openssl genrsa -out votreprenomnom.key 4096`

- créer la CSR `openssl req -new -key votreprenomnom.key -out votreprenomnom.csr` : la seule question importante ici est de bien mettre `votreprenomnom` à la question Common Name.

## Créer la resource Kubernetes CSR

- Convertir la CSR en base64 (bin to txt) pour k8s : `cat votreprenomnom.csr | base64 | tr -d "\n"`

- Créer la ressource suivante en remplaçant avec la valeur base64.

```yaml
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: votreprenomnom
spec:
  groups:
  - system:authenticated
  signerName: kubernetes.io/kube-apiserver-client
  usages:
  - client auth
  request: <crs_base64 from previous cmd>
```

- Approuver la CSR pour créer le certificat client : `kubectl certificate approve votreprenomnom`

- Télécharger le certificat présent dans la resource CSR : `kubectl get csr votreprenomnom -o jsonpath='{.status.certificate}' | base64 --decode > votreprenomnom-client-certificate.crt`

## Compléter le fichier de connexion kubeconfig

- affichez la version base64 du client-certificate-data : `cat votreprenomnom.key | base64 | tr -d "\n"`

- afficher la version base64 du client-key-data: `cat votreprenomnom-client-certificate.crt | base64 | tr -d "\n"`

- Ajoutez un item dans la section `users` du kubeconfig i.e. : les 4 lignes suivantes en complétant par les valeurs précédentes:

```yaml
- name: votreprenomnom
  user:
    client-certificate-data: <CLIENT-CRT-DATA>
    client-key-data: <CLIENT-KEY-DATA>
```

- Ajoutez un contexte de connexion dans la section `contexts`:

```yaml
- context:
    cluster: <CLUSTER-NAME>
    user: votreprenomnom
  name: votreprenomnom@<CLUSTER-NAME> # ou whatever
```


## Configuration RBAC

Basé sur cette identité, nous allons définir un role correspondant à une fonction : imaginons que notre identité soit celle d'un.e developpeur qui aurait le droit de tout faire dans le namespace dev mais seulement le droit de consulter la configuration de l'application et les logs sur la prod. 

- `kubectl create namespace dev`
- `kubectl create namespace prod`

Créons les roles (chacun dans leur namespace):

- `kubectl create role developer --verb="*" --resource="*" -n dev`
- `kubectl create role prod-observer --verb="get,list" --resource="pod,pods/logs,deploy,svc,ing,sts" -n prod`

Assignons ces role à notre identité (dans le bon namespace...)

- `kubectl create rolebinding developer --role=developer --user=votreprenomnom -n dev`
- `kubectl create rolebinding prod-observer --role=prod-observer --user=votreprenomnom -n prod`

## Vérifions nos droits

La sous commande `auth can-i` permet sans rien appliquer de vérifier qu'on a le droit d'effectuer un type de requete spécifique sur l'API.
On peut aussi activer un inpersonification (une sorte de sudo et ce pour toutes les commandes) avec `--as=nom` :

- `kubectl auth can-i get pods/logs --as=votreprenom -n prod`

- changeons le contexte de kubectl: 

- `kubectx` ou ...

- `kubectl config get-contexts` puis `kubectl config use-context lecontexte`

Testons avec de vrai commandes:

- créer un deployment dans `dev` : `kubectl create deploy nginx --image=nginx -n dev`
- créer un deployment dans `prod` : `kubectl create deploy nginx --image=nginx -n prod`


## Aller plus loin

- https://johnharris.io/2019/08/least-privilege-in-kubernetes-using-impersonation/
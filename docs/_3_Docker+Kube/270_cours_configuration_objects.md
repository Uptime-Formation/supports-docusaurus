---
title: Les configurations (secrets et configmaps) 
draft: false
---

## Les configurations (secrets et configmaps) 


## Les ConfigMaps 

**D'après les recommandations de développement [12factor](https://12factor.net), la configuration de nos programmes doit venir de l'environnement.**

Les objets ConfigMaps permettent d'injecter dans des pods des ensemble clés/valeur de configuration en tant que volumes/fichiers de configuration ou variables d'environnement.

Cela permet notamment de centraliser et découpler la configuration du déploiement des pods. Par exemple on peut stocker de façon centraliser le nom de domaine à utiliser pour une application et plusieurs de ses microservices pourront venir la récupérer dans la même configmap.

#### Exemple de configmap et de récupération d'une variable d'environnement

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: mysql-config
data:
  MYSQL_DATABASE: mydatabase
```

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mysql-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
      - name: mysql
        image: mysql:5.7
        env:
        - name: MYSQL_DATABASE
          valueFrom:
            configMapKeyRef:
              name: mysql-config
              key: MYSQL_DATABASE
        ports:
        - containerPort: 3306
```

---


### les Secrets

**Les Secrets se manipulent comme des objets ConfigMaps, mais ils sont chiffrés et faits pour stocker des mots de passe, des clés privées, des certificats, des tokens, ou tout autre élément de config dont la confidentialité doit être préservée.**

Un secret se créé avec l'API Kubernetes, puis c'est au pod de demander à y avoir accès.

---

**Il y a plusieurs façons de donner un accès à un secret, notamment :**
- le secret est un fichier que l'on monte en tant que volume dans un conteneur (pas nécessairement disponible à l'ensemble du pod). Il est possible de ne jamais écrire ce secret sur le disque (volume `tmpfs`).
- le secret est une variable d'environnement du conteneur.

Pour définir qui et quelle app a accès à quel secret, on peut utiliser les fonctionnalités "RBAC" de Kubernetes.

---


#### Exemple de secret pour un certificat SSL et son montage comme fichier dans un pods

**Création du secret en ligne de commande à partir d'un fichier:**

`kubectl create secret generic my-cert --from-file=mycert.pem`

Cela donne par exemple le secret suivant (les données d'un secret sont encodé en base64, un mode de sérialisation qui permet notamment de stocker des données binaires sous forme de texte):

```yaml
apiVersion: v1
data:
  mycert.pem: LS0tLS1CRUdJTiBDR...DQVRFLS0tLS0K
kind: Secret
metadata:
  creationTimestamp: "2023-03-08T16:29:52Z"
  name: my-cert
  namespace: default
  resourceVersion: "5543"
  uid: dd27cd3f-1779-47f4-a821-25d8139b21a4
type: Opaque
```

---


On peut ensuite monter le secret sous forme d'un fichier dans des pods via un volume comme suit :

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - name: mycontainer
        image: myimage
        ports:
        - containerPort: 443
        volumeMounts:
        - name: my-cert
          mountPath: /etc/mycert.pem
          readOnly: true
      volumes:
      - name: my-cert
        secret:
          secretName: my-cert
```



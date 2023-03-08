---
title: Cours - objets de configuration 
draft: false
---

## Les ConfigMaps 

D'après les recommandations de développement [12factor](https://12factor.net), la configuration de nos programmes doit venir de l'environnement.

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

### les Secrets

Les Secrets se manipulent comme des objets ConfigMaps, mais ils sont chiffrés et faits pour stocker des mots de passe, des clés privées, des certificats, des tokens, ou tout autre élément de config dont la confidentialité doit être préservée.
Un secret se créé avec l'API Kubernetes, puis c'est au pod de demander à y avoir accès.

Il y a plusieurs façons de donner un accès à un secret, notamment :
- le secret est un fichier que l'on monte en tant que volume dans un conteneur (pas nécessairement disponible à l'ensemble du pod). Il est possible de ne jamais écrire ce secret sur le disque (volume `tmpfs`).
- le secret est une variable d'environnement du conteneur.

Pour définir qui et quelle app a accès à quel secret, on peut utiliser les fonctionnalités "RBAC" de Kubernetes.

#### Exemple de secret pour un certificat SSL et son montage comme fichier dans un pods

Création du secret en ligne de commande:

`kubectl create secret tls my-tls-secret --cert=mycert.pem --key=mykey.pem`

avec les fichiers suivant:

`mycert.pem`:

```txt
-----BEGIN CERTIFICATE-----
MIIDazCCAlOgAwIBAgIUEvlUurOtSzStpYVhL5+ptGbTVTEwDQYJKoZIhvcNAQEL
BQAwRTELMAkGA1UEBhMCQVUxEzARBgNVBAgMClNvbWUtU3RhdGUxITAfBgNVBAoM
GEludGVybmV0IFdpZGdpdHMgUHR5IEx0ZDAeFw0yMzAzMDgxNjIyMTdaFw0zMzAz
MDUxNjIyMTdaMEUxCzAJBgNVBAYTAkFVMRMwEQYDVQQIDApTb21lLVN0YXRlMSEw
HwYDVQQKDBhJbnRlcm5ldCBXaWRnaXRzIFB0eSBMdGQwggEiMA0GCSqGSIb3DQEB
AQUAA4IBDwAwggEKAoIBAQCf+dzkGldNZhPeCu1r8/mhbrBCHvV0I7xtxkgOz+XA
vn1zd6KmHijdiAYGK7a/QYiBximicBv+FJTcah02LnBuU9gJexAAtfuYoeh2rahh
Ux9mv2MHSRucAnUNzAHZ+p6LwkSgiowSCMAqRRiNCD2oETS4Faf/wGUddFuL7Il2
mLlkvBeXEQmBesZqGP9wDBfXNyZin/qxtBxV6vAev8k+vEcyMC2H1GMlZEdw0wZ9
mr68iBEW5jtCBblTCQQtn6Bt8/0+/1ACj1SsqRLruiBHgYcewOypwYP7dKYj3/86
hk15NkIEBTysMhku8cNvqUsSiOp5DQsM4lEz7IdiqpnRAgMBAAGjUzBRMB0GA1Ud
DgQWBBTNxzBlAjvuNaeohulP1t4mQqkcDjAfBgNVHSMEGDAWgBTNxzBlAjvuNaeo
hulP1t4mQqkcDjAPBgNVHRMBAf8EBTADAQH/MA0GCSqGSIb3DQEBCwUAA4IBAQB2
6jNZdbYjvOGDwK7dHEkdDkSHkL7Sp8qbLjCt4LuTYAXryeDgz/r4ebrSdd8hrdw/
sdKEA4E3T2ZxOWlH6jlVrDfXMlmYLSoHAhAc03Q8WMXNy2fUkJ4aBRu0aLeC8BrS
PGOlEjzDkGlPbD6b9HfqEqG14gvFALo4aD1EqHQTXPLyYE/nwyJXcMOYRVyWLKxV
osabkGtukjTQJZjmleousd8AXakKwnWna3a+bHNs1Tvg1RF5X8qIW8pczK8ZvTUu
VEGwrZg9G+rZoStfHwEiHcUUk0hJLrdD9BPapgjn1At4bavtU6bHlNL8gkEC3vyY
ekskO5+6X20i+iPGQIju
-----END CERTIFICATE-----
```

`mykey.pem`:

```txt
-----BEGIN ENCRYPTED PRIVATE KEY-----
MIIFLTBXBgkqhkiG9w0BBQ0wSjApBgkqhkiG9w0BBQwwHAQIwBRW3dWfnTACAggA
MAwGCCqGSIb3DQIJBQAwHQYJYIZIAWUDBAEqBBC5zW9LtWkowSYRfyeUZEY8BIIE
0IZBufydI18N91vfq46fUDv0kFnVAeBRw3+LHYI5rUSIdI56zkPCvYZPZOlEJnge
WCX3l0UjGOosjF+GMKIK4olLJrItHVMvXsgr4LtEm67O4RggxDWmER5tAIYaR9WU
6W1S+mMQhVEalnNADEBgtvXKXI+YQXyaGQ+O0vYYxbkyFrlfCMAKzp9UD4dEMyCX
tEHQ4IjkeetzpT23dd58tB6/Q+MD7GM7jyxJuadLsuoRYSxUScNKExHqwPzm8QxN
dGJbKwpS1v6LaVnxVkIqaWyPf3txGW/Deq78372V4jEZacJ5qjErBwuoNJcXSMZA
iSQ+WlfyK2uJB4ENcPjToBRjGueEC6AXMimiFC5y2HkBExR02u371ZOmDgmtMjT8
k2wcVMl5EVEfAoSJjcWyRV/LUIXnda1Gqfz6l3WUTq+U8pGAtJUK/Dz27NaamtdZ
lQ25yuYG+/kpjrRrwLxL9C16UcJRi7iWsmtATjdqqAs6VqtXocs5WK4zmVBJqwxN
cwcmXpBHbxbOn0fp7rgd61gxGx5JNJcb3MusUjTI3O299o+8iD7Vkm7cmUTljW7d
VkDcqjPVyU//zKzdjwuFWjRSP5ENVOcB+pSfpRGBgdDXhLzg8D8Ev8OZqzX7kpfA
nbM4UHseE2OOZTxRV17imHo41Ia4tCDEntemu0ay+UAgl8lePIE7mKhGsDgcoa25
J9dstYTseuQC+OL8b+U3RGGgb7pnzdtySeqh/sLtBKZt02nV3hQ/+YOjfSZUTvsp
AFgm+9mRAXZC/VOwBpBO5+SpWzt4BekeiC89f7Br6viVHl5E0sdI65UjrSu5Xm+0
x6z0t+dBMhBaYa0W6yCr0YtELXmq3CbQhe7qNEpufS3Rt+OjKDUcSBECy9ZQtDXj
AFpLBi23w8ui4lRF90eqankTsANYySv04xSMTUmWvRugloyNJjecnpaeX6X0KcSR
F/msuwuFnHPwVFB3Y0N6YGYhNsGClYaMzczUWfPvUzxPzH/rM78OCLwq39f0eT+l
2Alxd8lmTimcejvq9MaBTI+6rtxNKliud+HdGsFlXOAtP7vsE4qLzrq3/G9hZduw
/4M8U5B9uDDxeFGItf60UQX1JZxy5HMJUjOax3hHxgmAcoBTnAc+72NVziYNNTyP
Ll30AMsTSiZlXmMcJ1LyxZqWXSVKM64bhocN7Rc8VWFnUMcOJJeUXN3Id0Yz7GWU
NkN5FWgmFy0eMkqyeA43LdOg7ZrJjtF0FwzOOOvvq34PGD5rrJvh5CRNmNAEpAGz
lVpW+ndrxedemSpPnaRQWs4M8X/W/6yCsHbv3hydzUWpwR37xvxXXjP6GweLj2rJ
zqJbPY2D8QeFzERbSnCsTtpB11gV/ZDIAyBZP8ME8H7EMTDjYyeh9tdNzTnkG9Jj
3MvoxFToNLHiEoNFVuLN/gPydsDE+zimXmytN0ruRcJxN2xRITrzvQAyg4+6uPD1
SZ18CSfUP4vgSAchkNje99mhZlayXmutHzH00SW8V7nX1h4zBeYV4eu7ZDgxAwLG
cKuNQM/TQK9GJAxEk4WOkdeGlcvfiiV4q9FCIAzKT/vLB+rV+Cge2XkExxDGimgn
rOJkGbo0OSUmWQzlbFS5PmyifHLxuz6WC1HPSGPXsO4E
-----END ENCRYPTED PRIVATE KEY-----
```

Cela donne par exemple le secret suivant:

```yaml
apiVersion: v1
data:
  mycert.pem: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURhekNDQWxPZ0F3SUJBZ0lVRXZsVXVyT3RTelN0cFlWaEw1K3B0R2JUVlRFd0RRWUpLb1pJaHZjTkFRRUwKQlFBd1JURUxNQWtHQTFVRUJoTUNRVlV4RXpBUkJnTlZCQWdNQ2xOdmJXVXRVM1JoZEdVeElUQWZCZ05WQkFvTQpHRWx1ZEdWeWJtVjBJRmRwWkdkcGRITWdVSFI1SUV4MFpEQWVGdzB5TXpBek1EZ3hOakl5TVRkYUZ3MHpNekF6Ck1EVXhOakl5TVRkYU1FVXhDekFKQmdOVkJBWVRBa0ZWTVJNd0VRWURWUVFJREFwVGIyMWxMVk4wWVhSbE1TRXcKSHdZRFZRUUtEQmhKYm5SbGNtNWxkQ0JYYVdSbmFYUnpJRkIwZVNCTWRHUXdnZ0VpTUEwR0NTcUdTSWIzRFFFQgpBUVVBQTRJQkR3QXdnZ0VLQW9JQkFRQ2YrZHprR2xkTlpoUGVDdTFyOC9taGJyQkNIdlYwSTd4dHhrZ096K1hBCnZuMXpkNkttSGlqZGlBWUdLN2EvUVlpQnhpbWljQnYrRkpUY2FoMDJMbkJ1VTlnSmV4QUF0ZnVZb2VoMnJhaGgKVXg5bXYyTUhTUnVjQW5VTnpBSForcDZMd2tTZ2lvd1NDTUFxUlJpTkNEMm9FVFM0RmFmL3dHVWRkRnVMN0lsMgptTGxrdkJlWEVRbUJlc1pxR1A5d0RCZlhOeVppbi9xeHRCeFY2dkFldjhrK3ZFY3lNQzJIMUdNbFpFZHcwd1o5Cm1yNjhpQkVXNWp0Q0JibFRDUVF0bjZCdDgvMCsvMUFDajFTc3FSTHJ1aUJIZ1ljZXdPeXB3WVA3ZEtZajMvODYKaGsxNU5rSUVCVHlzTWhrdThjTnZxVXNTaU9wNURRc000bEV6N0lkaXFwblJBZ01CQUFHalV6QlJNQjBHQTFVZApEZ1FXQkJUTnh6QmxBanZ1TmFlb2h1bFAxdDRtUXFrY0RqQWZCZ05WSFNNRUdEQVdnQlROeHpCbEFqdnVOYWVvCmh1bFAxdDRtUXFrY0RqQVBCZ05WSFJNQkFmOEVCVEFEQVFIL01BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQjIKNmpOWmRiWWp2T0dEd0s3ZEhFa2REa1NIa0w3U3A4cWJMakN0NEx1VFlBWHJ5ZURnei9yNGViclNkZDhocmR3LwpzZEtFQTRFM1QyWnhPV2xINmpsVnJEZlhNbG1ZTFNvSEFoQWMwM1E4V01YTnkyZlVrSjRhQlJ1MGFMZUM4QnJTClBHT2xFanpEa0dsUGJENmI5SGZxRXFHMTRndkZBTG80YUQxRXFIUVRYUEx5WUUvbnd5SlhjTU9ZUlZ5V0xLeFYKb3NhYmtHdHVralRRSlpqbWxlb3VzZDhBWGFrS3duV25hM2ErYkhOczFUdmcxUkY1WDhxSVc4cGN6SzhadlRVdQpWRUd3clpnOUcrclpvU3RmSHdFaUhjVVVrMGhKTHJkRDlCUGFwZ2puMUF0NGJhdnRVNmJIbE5MOGdrRUMzdnlZCmVrc2tPNSs2WDIwaStpUEdRSWp1Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
kind: Secret
metadata:
  creationTimestamp: "2023-03-08T16:29:52Z"
  name: my-tls-cert
  namespace: default
  resourceVersion: "5543"
  uid: dd27cd3f-1779-47f4-a821-25d8139b21a4
type: Opaque
```

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
        - name: tls-certs
          mountPath: /etc/tls
          readOnly: true
      volumes:
      - name: tls-certs
        secret:
          secretName: my-tls-secret
```



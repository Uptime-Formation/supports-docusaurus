---
title: "12 - TP 6 - Déployer Wordpress avec Helm et ArgoCD"
draft: false
weight: 2071
---

Helm est un "gestionnaire de paquet" ou vu autrement un "outil de templating avancé" pour k8s qui permet d'installer des applications plsu complexe de façon paramétrable :

- Pas de duplication de code
- Possibilité de créer du code générique et flexible avec pleins de paramètres pour le déploiement.
- Des déploiements avancés avec plusieurs étapes

Inconvénient: Helm ajoute souvent de la complexité non nécessaire car les Charts sur internet sont très paramétrables pour de multiples cas d'usage (plein de code qui n'est utile que dans des situations spécifiques).

Helm ne dispense pas de maîtriser l'administration de son cluster.

### Installer Helm

- Pour installer Helm sur Ubuntu, utilisez : `sudo snap install helm --classic`

#### Autocomplete

`helm completion bash | sudo tee /etc/bash_completion.d/helm` et relancez votre terminal.

### Utiliser un chart Helm pour installer Wordpress

- Cherchez Wordpress sur [https://artifacthub.io/](https://artifacthub.io/).

- Prenez la version de **Bitnami** et ajoutez le dépôt avec la première commande à droite (ajouter le dépôt et déployer une release).

- Installer une **"release"** `wordpress-tp` de cette application (ce chart) avec `helm install wordpress-tp bitnami/wordpress`

- Des instructions sont affichées dans le terminal pour trouver l'IP et afficher le login et password de notre installation. La commande pour récupérer l'IP ne fonctionne que dans les cluster proposant une intégration avec un loadbalancer et fournissant donc des IP externe. Dans minikube (qui ne fournit pas de loadbalancer) il faut à la place lancer `minikube service wordpress-tp` pour y accéder avec le NodePort.

- Notre Wordpress est prêt. Connectez-vous-y avec les identifiants affichés (il faut passer les commandes indiquées pour récupérer le mot de passe stocké dans un secret k8s).

Vous pouvez constater que l'utilisateur est par default `user` ce qui n'est pas très pertinent. Un chart prend de nombreux paramètres de configuration qui sont toujours listés dans le fichier `values.yaml` à la racine du Chart.

On peut écraser certains de ces paramètres dans un nouveau fichier par exemple `myvalues.yaml` et installer la release avec l'option `--values=myvalues.yaml`.

- Désinstallez Wordpress avec `helm uninstall wordpress-tp`

### Utiliser la fonction `template` de Helm pour étudier les ressources d'un Chart

- Visitez le code des charts de votre choix en clonant le répertoire Git des Charts officielles Bitnami et en l'explorant avec VSCode :

```bash
git clone https://github.com/bitnami/charts/
code charts
```

- Regardez en particulier les fichiers `templates` et le fichier de paramètres `values.yaml`.

- Comment modifier l'username et le password wordpress à l'installation ? il faut donner comme paramètres le yaml suivant:

```yaml
wordpressUsername: <votrenom>
wordpressPassword: <easytoguesspasswd>
```

- Nous allons paramétrer plus encore l'installation. Créez un dossier TP5 avec à l'intérieur un fichier `values.yaml` contenant:

```yaml
wordpressUsername: <stagiaire> # replace
wordpressPassword: myunsecurepassword
wordpressBlogName: Kubernetes example blog

replicaCount: 1

service:
  type: ClusterIP

ingress:
  enabled: true
  hostname: wordpress.<stagiaire>.k8s.dopl.uk # replace with your hostname pointing on the cluster ingress loadbalancer IP
  tls: true
  certManager: true
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
    kubernetes.io/ingress.class: nginx
```

- En utilisant ces paramètres, plutôt que d'installer le chart, nous allons faire le rendu (templating) des fichiers ressource générés par le chart: `helm template wordpress-tp bitnami/wordpress --values=values.yaml > wordpress-tp-manifests.yaml`.

On peut maintenant lire dans ce fichier les objets kubernetes déployés par le chart et ainsi apprendre de nouvelles techniques et syntaxes. En le parcourant on peut constater que la plupart des objets abordés pendant cette formation y sont présent plus certains autres.
### ArgoCD pour installer et visualiser en live les ressources de notre chart

Argocd permet d'installer des applications qui peuvent être soit des dossiers de manifestes kubernetes simple, soit des dossiers contenant une `kustomization.yaml` soit des charts Helm. Une application Argocd peut être créée dans l'interface web ou être déclarée elle-même grâce à un fichier manifeste de type:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
```

Ce n'est pas une ressource de base mais bien une `CustomResourceDefinition` car ArgoCD est un opérateur d'applications. Nous allons créer un tel manifeste.

- Ouvrez le fichier `wordpress-chart-argocd-app.yaml` et collez à l'intérieur:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: wordpress
  namespace: argocd
spec:
  destination:
    namespace: default
    server: https://kubernetes.default.svc
  project: default
  source:
    repoURL: https://charts.bitnami.com/bitnami
    chart: wordpress
    targetRevision: 11.0.5
    helm:
      values: |
        wordpressUsername: elie
        wordpressPassword: myunsecurepassword
        wordpressBlogName: Kubernetes example blog

        replicaCount: 1

        service:
          type: ClusterIP

        ingress:
          enabled: true
          hostname: wordpress.elie.k8s.dopl.uk
          pathType: Prefix
          tls: true
          certManager: true
          annotations:
            cert-manager.io/cluster-issuer: letsencrypt-prod
            kubernetes.io/ingress.class: nginx
```

- Appliquez ce fichier avec `kubectl apply -f`.

- Visitez la page `https://argocd.<votrelogin>.k8s.dopl.uk`.

Une application wordpress est apparue

- Visitez la, en particulier les `desired manifests` de quelques resources.
- Synchronisez l'application pour installer le chart avec `Sync`.

En une minute ou deux, l'application est installée et l'ingress avec son certificat devrait être généré.

Vous pouvez visiter le blog à l'adresse: `https://wordpress.<votrelogin>.k8s.dopl.uk`

### Solution

Le dépôt Git contenant la correction de ce TP et des précédents est accessible avec cette commande : `git clone -b all_corrections https://github.com/Uptime-Formation/corrections_tp.git`

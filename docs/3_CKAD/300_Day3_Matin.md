---
title: Jour 3 - Matin
---


# Jour 3 - Matin

## Contrôle du trafic avec Network Policies  

**Les **Network Policies** sont un outil puissant pour sécuriser les communications réseau au sein d’un cluster Kubernetes.** 

Elles permettent de contrôler efficacement le trafic entre les services et de limiter les surfaces d'attaque en restreignant les communications inutiles ou dangereuses.

**Les **Network Policies** dans Kubernetes permettent de contrôler le trafic réseau entrant et sortant des Pods.** 

Elles sont utilisées pour définir les règles de sécurité réseau à l’intérieur d’un cluster, et permettent de restreindre ou d’autoriser des communications entre différents Pods, namespaces, ou réseaux externes. Ces politiques sont essentielles pour sécuriser les communications entre services dans un environnement de production.

---

#### Concepts clés

1. **Namespace** : Les Network Policies sont définies par namespace. Chaque règle s’applique uniquement aux Pods d’un namespace donné.
   
2. **Sélecteurs de Pods (Pod Selectors)** : Les règles s’appliquent aux Pods sélectionnés par une `NetworkPolicy` en fonction de labels. Ces sélecteurs identifient les Pods ciblés pour appliquer des restrictions ou des permissions de trafic.

3. **Ingress et Egress** : 
   - **Ingress** : Contrôle le trafic entrant dans les Pods.
   - **Egress** : Contrôle le trafic sortant des Pods.

4. **Isolation** : Par défaut, tous les Pods peuvent communiquer entre eux dans un cluster. Cependant, dès qu’une **NetworkPolicy** est créée pour un Pod, Kubernetes applique l’isolation réseau et le trafic n’est plus autorisé que selon les règles spécifiées dans la politique.

---

#### Exemple de manifeste YAML de Network Policy

Voici un exemple de `NetworkPolicy` qui autorise uniquement le trafic HTTP entrant sur les Pods portant le label `app: web` depuis les Pods du même namespace portant le label `role: frontend`.

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-http
  namespace: default
spec:
  podSelector:
    matchLabels:
      app: web
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          role: frontend
    ports:
    - protocol: TCP
      port: 80
```

Dans cet exemple :
- **podSelector** : Seules les règles définies s’appliquent aux Pods avec le label `app: web`.
- **policyTypes** : Indique que cette politique concerne le trafic entrant (`Ingress`).
- **from** : Seuls les Pods avec le label `role: frontend` peuvent envoyer des requêtes aux Pods `app: web`.
- **ports** : Seul le port TCP 80 (HTTP) est autorisé.

---

#### Contrôle du trafic sortant (Egress)

Voici un exemple de `NetworkPolicy` qui restreint le trafic sortant à un seul sous-réseau IP externe.

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: restrict-egress
  namespace: default
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
  - Egress
  egress:
  - to:
    - ipBlock:
        cidr: 192.168.1.0/24
    ports:
    - protocol: TCP
      port: 443
```

Dans cet exemple :
- Les Pods avec le label `app: backend` peuvent uniquement envoyer du trafic vers le sous-réseau `192.168.1.0/24` sur le port 443 (HTTPS).

---

#### Points clés

1. **Isolation par défaut** : En l’absence de Network Policies, tout trafic est autorisé. Dès qu’une Policy est appliquée à un Pod, l’isolation réseau s’applique à ce Pod et le trafic doit être explicitement autorisé via des règles.
   
2. **Précision des règles** : Vous pouvez combiner des `PodSelectors`, `NamespaceSelectors` et des plages d’adresses IP (`ipBlock`) pour créer des règles de sécurité très précises.

3. **Support par les CNI (Container Network Interface)** : Les Network Policies ne sont pas prises en charge par tous les plugins réseau. Des solutions comme **Calico**, **Cilium**, ou **Weave** offrent un support complet des Network Policies. Assurez-vous que votre CNI supporte ces fonctionnalités.

---

#### Commandes kubectl utiles

- **Lister les Network Policies dans un namespace** :

```bash
kubectl get networkpolicies -n <namespace>
```

- **Afficher les détails d'une Network Policy** :

```bash
kubectl describe networkpolicy <policy-name> -n <namespace>
```


---

## Les outils de gestions de manifestes : Helm et Kustomize

### Kustomize

**L'outil `kustomize` sert à paramétrer et faire varier la configuration d'une installation Kubernetes en fonction des cas.**

Intégré directement dans `kubectl` depuis quelques années il s'agit de la façon la plus simple et respectueuse de la philosophie déclarative de Kubernetes de le faire.


---

**Par exemple lorsqu'on a besoin de déployer une même application dans 3 environnements de `dev`, `prod` et `staging` il serait dommage de ne pas factoriser le code. On écrit alors une version de base des manifestes kubernetes commune aux différents environnements puis on utilise `kustomize` pour appliquer des patches sur les valeurs.**

Plus généralement cet outil rassemble plein de fonctionnalité pour supporter les variations de manifestes :
- ajout de préfixes ou suffixes aux noms de resources
- mise à jour de l'image et sa version utilisée pour les pods
- génération de secrets et autres configurations
- etc.

Documentation : https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/

---

**Kustomize est très adapté pour une variabilité pas trop importante des installations d'une application, par exemple une entreprise qui voudrait déployer son application dans quelques environnements internes avec un dispositif de Continuous Delivery.** 

Il a l'avantage de garder le code de base lisible et maintenable et d'éviter les manipulations impératives/séquentielles.

- Pour utiliser kustomise on écrit un fichier `kustomization.yaml` à côté des manifestes et patchs et on l'applique avec `kubectl -k chemin_vers_kustomization`.

- Il est aussi très utile de pouvoir visualisé le resultat du patching avant de l'appliquer avec : `kubectl kustomize chemin_vers_kustomization`

Mais lorsqu'on a besoin de faire varier énormément les manifestes selon de nombreux cas, par exemple lorsqu'on distribue une application publiquement et qu'on veut permettre à l'utilisateur de configurer dynamiquement à peut près tous les aspects d'une installation, kustomize n'est pas adapté.

---

### Helm, package manager pour Kubernetes

**Helm permet de déployer des applications / stacks complètes en utilisant un système de templating pour générer dynamiquement les manifestes kubernetes et les appliquer intelligemment.**

C'est en quelque sorte le package manager le plus utilisé par Kubernetes.

- Un package Helm est appelé **Chart**.
- Une installation particulière d'un chart est appelée **Release**.

Helm peut également gérer les dépendances d'une application en installant automatiquement d'autres chart liés et effectuer les mises à jour d'une installation précautionneusement s'il le **Chart** a été prévu pour.

---

**En effet en plus de templater et appliquer les manifestes kubernetes, Helm peut exécuter des hooks, c'est à dire des actions personnalisées avant ou après l'installation, la mise à jour et la suppression d'un paquet.**

Il existe des _stores_ de charts Helm, le plus conséquent d'entre eux est https://artifacthub.io.

Observons un exemple de Chart : https://artifacthub.io/packages/helm/minecraft-server-charts/minecraft

Un des aspects les plus visible côté utilistateur d'un chart est la liste, souvent très étendue, des paramètres d'installation du chart. Il s'agit d'un dictionnaire YAML de paramètres sur plusieurs niveaux. Ils ont presque tous une valeur par defaut qui peut être surchargée à l'installation.

Plutôt que d'installer un chart à l'aveugle il est préférable d'effectuer un templating/dry-run du chart avec un ensemble de paramètre pour étudier les resources kubernetes qui seront créées à son installation: voir dans la suite et le TP. (ou d'utiliser un outil de déploiement et supervision d'applications comme ArgoCD)

### Quelques commandes Helm:

Voici quelques commandes de bases pour Helm :

- `helm repo add bitnami https://charts.bitnami.com/bitnami`: ajouter un repo contenant des charts

- `helm search repo bitnami` : rechercher un chart en particulier

- `helm install my-release my-chart --values=myvalues.yaml` : permet d’installer le chart my-chart avec le nom my-release et les valeurs de variable contenues dans myvalues.yaml (elles écrasent les variables par défaut)

- `helm upgrade my-release my-chart` : permet de mettre à jour notre release avec une nouvelle version.

- `helm plugin install https://github.com/databus23/helm-diff` pour télécharger le plugin helm diff important avant de lancer un upgrade

- Ensuite `helm diff upgrade my-release mychart --values values.yaml`

- `helm list`: Permet de lister les Charts installés sur votre Cluster

Pour lister les resources d'une release helm n'a pas de fonction préconçue :  il faut bricoler un peu:
- `helm get manifest release-name | yq '(.kind + "/" + .metadata.name)'`
- `kubectl get all --all-namespaces -l='app.kubernetes.io/managed-by=Helm,app.kubernetes.io/instance=release-name`
- `kubectl api-resources --verbs=list -o name | xargs -n 1 kubectl get --show-kind -l release=awesome-nginx --ignore-not-found -o name`

- `helm delete my-release`: Permet de désinstaller la release `my-release` de Kubernetes

---


**Helm est un "gestionnaire de paquet" ou vu autrement un "outil de templating avancé" pour k8s qui permet d'installer des applications plus complexe de façon paramétrable :**

- Pas de duplication de code
- Possibilité de créer du code générique et flexible avec pleins de paramètres pour le déploiement.
- Des déploiements avancés avec plusieurs étapes

Inconvénient: Helm ajoute souvent de la complexité non nécessaire car les Charts sur internet sont très paramétrables pour de multiples cas d'usage (plein de code qui n'est utile que dans des situations spécifiques).

Helm ne dispense pas de maîtriser l'administration de son cluster.

## Installer Helm

- Pour installer Helm sur Ubuntu, utilisez : `sudo snap install helm --classic`

#### Autocomplete

`helm completion bash | sudo tee /etc/bash_completion.d/helm` et relancez votre terminal.

## Utiliser un chart Helm pour installer Wordpress

- Cherchez Wordpress sur [https://artifacthub.io/](https://artifacthub.io/).

- Prenez la version de **Bitnami** et ajoutez le dépôt avec la première commande à droite (ajouter le dépôt et déployer une release).

- Installer une **"release"** `wordpress-tp` de cette application (ce chart) avec `helm install wordpress-tp bitnami/wordpress`

- Des instructions sont affichées dans le terminal pour trouver l'IP et afficher le login et password de notre installation. La commande pour récupérer l'IP ne fonctionne que dans les cluster proposant une intégration avec un loadbalancer et fournissant donc des IP externe. Dans minikube (qui ne fournit pas de loadbalancer) il faut à la place lancer `minikube service wordpress-tp` pour y accéder avec le NodePort.

- Notre Wordpress est prêt. Connectez-vous-y avec les identifiants affichés (il faut passer les commandes indiquées pour récupérer le mot de passe stocké dans un secret k8s).

Vous pouvez constater que l'utilisateur est par default `user` ce qui n'est pas très pertinent. Un chart prend de nombreux paramètres de configuration qui sont toujours listés dans le fichier `values.yaml` à la racine du Chart.

On peut écraser certains de ces paramètres dans un nouveau fichier par exemple `myvalues.yaml` et installer la release avec l'option `--values=myvalues.yaml`.

- Désinstallez Wordpress avec `helm uninstall wordpress-tp`

---

### Utiliser la fonction `template` de Helm pour étudier les ressources d'un Chart

- Visitez le code des charts de votre choix en clonant le répertoire Git des Charts officielles Bitnami et en l'explorant avec VSCode :

```bash
git clone https://github.com/bitnami/charts/ --depth 1
code charts
```

- Regardez en particulier les fichiers `templates` et le fichier de paramètres `values.yaml`.

- Comment modifier l'username et le password wordpress à l'installation ? il faut donner comme paramètres le yaml suivant:

```yaml
wordpressUsername: <votrenom>
wordpressPassword: <easytoguesspasswd>
```

- Nous allons paramétrer plus encore l'installation. 
  Créez un dossier avec à l'intérieur un fichier `values.yaml` contenant:

```yaml
wordpressUsername: <stagiaire> # replace
wordpressPassword: myunsecurepassword
wordpressBlogName: Kubernetes example blog

replicaCount: 1

service:
  type: ClusterIP

ingress:
  enabled: true
  hostname: wordpress.<stagiaire>.<labdomain> # replace with your hostname pointing on the cluster ingress loadbalancer IP
  tls: true
  certManager: true
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
    kubernetes.io/ingress.class: nginx
```

- En utilisant ces paramètres, plutôt que d'installer le chart, nous allons faire le rendu (templating) des fichiers ressource générés par le chart: `helm template wordpress-tp bitnami/wordpress --values=values.yaml > wordpress-tp-manifests.yaml`.

On peut maintenant lire dans ce fichier les objets kubernetes déployés par le chart et ainsi apprendre de nouvelles techniques et syntaxes. En le parcourant on peut constater que la plupart des objets abordés pendant cette formation y sont présent plus certains autres.

---

### Surveillance et journalisation

**Dans un environnement Kubernetes, la **surveillance** et la **journalisation** sont essentielles pour assurer le bon fonctionnement des applications, détecter rapidement les problèmes et maintenir une infrastructure fiable. Deux outils populaires pour ces tâches sont **Prometheus** et **Grafana**. Nous allons d'abord présenter brièvement ces deux logiciels et leur mission, puis nous nous concentrerons sur l'installation de leurs opérateurs respectifs.**

---

#### Prometheus

**Prometheus est un système de surveillance et d'alerte open-source conçu pour collecter et stocker des métriques sous forme de séries temporelles.**

- **Mission**: Il permet de surveiller les performances des applications et des infrastructures en collectant des données en temps réel, de définir des alertes basées sur des conditions spécifiques et de fournir des données pour l'analyse et le dépannage.

#### Grafana

**Grafana est une plateforme open-source de visualisation et d'analyse de données, spécialisée dans les graphiques interactifs et les tableaux de bord personnalisables.**

- **Mission**: Il offre une interface riche pour visualiser les métriques collectées par Prometheus (et d'autres sources), permettant aux utilisateurs de créer des tableaux de bord dynamiques pour surveiller l'état de leurs applications et infrastructures.

---

### Installation Prometheus et Grafana

Nous utiliserons le **Helm chart kube-prometheus-stack** (anciennement prometheus-operator) pour installer le Prometheus Operator ainsi que les instances de Prometheus, Alertmanager et Grafana préconfigurées.

   ```bash
   helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
   helm repo update
   helm install prometheus prometheus-community/kube-prometheus-stack

```

Vous devriez voir des Pods avec la commande :

```shell

kubectl --namespace default get pods -l "release=prometheus"

```

---

**Pour accéder à Grafana, utilisez le port-forwarding :**

```bash
kubectl port-forward svc/prometheus-grafana 3000:80
```

Ouvrez votre navigateur et accédez à http://localhost:3000.

Les identifiants par défaut sont :

- **Utilisateur**: `admin`
- **Mot de passe**: récupérable avec la commande :

```bash
kubectl get secret prometheus-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
```

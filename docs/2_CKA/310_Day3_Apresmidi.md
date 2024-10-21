---
title: Jour 3 - Après Midi
---

# Jour 3 - Après Midi

## Custom Resource Definitions (CRDs) dans Kubernetes

**En résumé, les **Custom Resource Definitions** (CRDs) et les opérateurs permettent d'étendre Kubernetes en introduisant des ressources et des logiques métiers spécifiques à vos besoins.** 

Les CRDs offrent une flexibilité pour gérer de nouveaux types d'objets dans Kubernetes, et les opérateurs automatisent la gestion de ces ressources, rendant possible le déploiement et la maintenance d'applications complexes.

En plus des ressources natives comme Pods, Services, et Deployments, les CRDs permettent de définir et de gérer des objets spécifiques à vos applications ou infrastructures directement via l'API Kubernetes.

Les CRDs permettent ainsi de :
- Définir des ressources spécifiques à votre application ou plateforme.
- Gérer ces ressources avec des outils natifs de Kubernetes comme `kubectl`.
- Intégrer des logiques métiers spécifiques via des opérateurs qui surveillent et gèrent l'état de ces ressources.

---

### Comment fonctionnent les CRDs ?

1. **Définition de ressources personnalisées** : Une CRD permet de définir un nouveau type de ressource dans Kubernetes, avec sa propre structure (schema) et comportement.
   
2. **Gestion via l'API Kubernetes** : Une fois la CRD installée, Kubernetes expose une nouvelle API pour gérer ces ressources via `kubectl` ou des appels API.

3. **Contrôleurs et opérateurs** : Les CRDs sont souvent utilisées avec des opérateurs (des contrôleurs avancés) pour automatiser la gestion des ressources personnalisées. Un opérateur est responsable de la création, mise à jour, suppression, et surveillance des objets définis par une CRD.

---

### Exemple simple de CRD

Voici un exemple minimal de CRD qui définit une nouvelle ressource `Database` :

```yaml
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: databases.mycompany.com
spec:
  group: mycompany.com
  versions:
    - name: v1
      served: true
      storage: true
      schema:
        openAPIV3Schema:
          type: object
          properties:
            spec:
              type: object
              properties:
                dbName:
                  type: string
                dbVersion:
                  type: string
  scope: Namespaced
  names:
    plural: databases
    singular: database
    kind: Database
    shortNames:
      - db
```

Cet exemple montre une définition de la ressource `Database` avec deux champs : `dbName` et `dbVersion`. La ressource est déclarée dans le groupe `mycompany.com` et est accessible via l’API `databases`.

Une fois la CRD appliquée, vous pouvez gérer ces objets avec des commandes comme :

```bash
kubectl get databases
kubectl describe database <database-name>
kubectl delete database <database-name>
```

### Installer des CRDs

Pour installer une CRD dans Kubernetes, il suffit de la déployer en utilisant la commande suivante :

```bash
kubectl apply -f <crd-file.yaml>
```

Cela enregistre le type de ressource personnalisé dans le cluster, et Kubernetes expose les nouvelles API correspondantes. Par exemple :

```bash
kubectl apply -f crd-database.yaml
```

---

## Utilisation des opérateurs

Un **Opérateur** est un contrôleur avancé qui surveille l’état des objets CRD et agit en conséquence pour maintenir l’état désiré. Les opérateurs automatisent la gestion des applications complexes en encapsulant la logique métier.

Les opérateurs peuvent être installés via des gestionnaires comme **OperatorHub** ou en les créant manuellement. L'installation d'un opérateur se fait souvent via Helm ou en appliquant directement des fichiers manifestes YAML.



---

<!-- 

### Les Operateurs et les Custom Resources Definitions (CRD)

Kubernetes étant modulaire et ouvert, en particulier son API et ses processus de contrôle il est possible et même encouragé d'étendre son fonctionnement depuis l'intérieur en respectant ses principes natifs de conception:

- Exprimer les objets/resources à manipuler avec des descriptions de haut niveau sous forme de manifestes YAML fournies à l'API
- Gérer ces resources à l'aide de boucles de contrôle/réconciliation qui vont s'assurer automatiquement de maintenir l'état désiré exprimé dans les descriptions.

Un opérateur désigne toute extension de Kubernetes qui respecte ces principes.

Les Custom Resources Definitions (CRDs) sont les nouveaux types de resources ajoutés pour étendre l'API

- On peut lister toutes les resources (custom ou non) dans kubectl avec `kubectl api-resources -o wide`. les CRDs sont aussi affichées dans la dernière section du menu Lens.
- On peut utiliser `kubectl explain` sur ces noms de resources pour découvrir les types qu'on ne connait pas

doc: https://kubernetes.io/docs/concepts/extend-kubernetes/operator/

Quelques exemples d'opérateurs:

- L'application `Certmanager` qui permet de générer et manipuler les certificats x509/TLS comme des resources Kubernetes
- L'opérateur de déploiement et supervision d'application `ArgoCD`
- L'`ingress Traefik` ou le `service mesh Istio` qui proposent des fonctionnalités réseaux avancés exprimées avec des resources custom.
- L'opérateur Prometheus permet d'automatiser le monitoring d'un cluster et ses opérations de maintenance.
- la chart officielle de la suite Elastic (ELK) définit des objets de type `elasticsearch`
- KubeVirt permet de rajouter des objets de type VM pour les piloter depuis Kubernetes
- Azure propose des objets correspondant à ses ressources du cloud Azure, pour pouvoir créer et paramétrer des ressources Azure directement via la logique de Kubernetes.

Les opérateurs sont souvent répertoriés sur le site: https://operatorhub.io/

![](/img/kubernetes/k8s_crd.png)

Avec les opérateurs il est possible d'ajouter des nouvelles fonctionnalités quasi-natives à notre Cluster. Ce mode d'extensibilité est un des points qui fait la force et la relative universalité de Kubernetes.


## Écrire un opérateur

Plus concrêtement un opérateur est:

- un morceau de logique opérationnelle de votre infrastructure (par exemple: la mise à jour votre logiciel de base de donnée stateful comme cassandra ou elasticsearch) ...
- ... implémentée dans kubernetes par un/plusieurs conteneur(s) "controller" ...
- ... controllé grâce à une extension de l'API Kubernetes sous forme de nouveaux type d'objets kubernetes personnalisés (de haut niveau) appelés _CustomResourcesDefinition_ ...
- ... qui manipule d'autre resources Kubernetes.

L'écriture d'opérateurs est un sujet avancé mais très intéressant de Kubernetes.

- Ils peuvent être développés avec un framework Go ou Ansible

Il est important de comprendre que le développement et la maintenance d'un opérateur est une tâche très lourde. Elle est probablement superflue pour la plupart des cas. Écrire un chart fait principalement sens pour une entreprise ou un fournisseur de solution qui voudrait optimiser un morceau de logique opérationnelle crucial et éventuellement vendre cette nouvelle solution a de nombreux clients.

Voir : https://thenewstack.io/kubernetes-when-to-use-and-when-to-avoid-the-operator-pattern/

-->

---

#### Exemple d'installation d'un opérateur via OperatorHub

1. **Accéder à OperatorHub** (sur OpenShift ou via l'interface OperatorHub.io pour d’autres distributions).

2. **Rechercher et installer un opérateur** : Par exemple, pour installer un opérateur Postgres, vous pouvez choisir **Crunchy Postgres Operator** et suivre les étapes d'installation directement dans OperatorHub.

3. **Installer l’opérateur via `kubectl`** : Si vous utilisez un fichier manifeste YAML fourni par l'opérateur, vous pouvez l’appliquer avec `kubectl` :

```bash
kubectl apply -f postgres-operator.yaml
```

4. **Gestion des ressources via l'opérateur** : Une fois l'opérateur installé, il surveille les ressources personnalisées créées (comme `PostgresCluster`) et prend les actions nécessaires pour gérer leur cycle de vie.

---

### Exemples d'opérateurs populaires

- **Prometheus Operator** : Automatisation du déploiement et de la gestion des instances de Prometheus dans Kubernetes.
- **ElasticSearch Operator** : Gestion des clusters ElasticSearch avec support pour les sauvegardes, la mise à l'échelle, et les mises à jour.
- **Cert-Manager** : Automatise la gestion des certificats TLS dans Kubernetes en interagissant avec des autorités de certification (AC).

---

### Exemple de fichier CRD avec opérateur

Voici un exemple pour un opérateur Postgres :

**Custom Resource Definition pour PostgresCluster** :

```yaml
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: postgresclusters.postgres-operator.crunchydata.com
spec:
  group: postgres-operator.crunchydata.com
  versions:
    - name: v1
      served: true
      storage: true
      schema:
        openAPIV3Schema:
          type: object
          properties:
            spec:
              type: object
              properties:
                postgresVersion:
                  type: string
  scope: Namespaced
  names:
    plural: postgresclusters
    singular: postgrescluster
    kind: PostgresCluster
    shortNames:
      - pgcluster
```

Une fois l'opérateur installé, vous pouvez créer un cluster Postgres via la nouvelle ressource `PostgresCluster` :

```yaml
apiVersion: postgres-operator.crunchydata.com/v1
kind: PostgresCluster
metadata:
  name: my-postgres-cluster
spec:
  postgresVersion: "13"
```

---

### Gestion des CRDs et des opérateurs

Pour gérer les CRDs et les opérateurs, Kubernetes fournit des commandes `kubectl` standard ainsi que des interfaces comme OperatorHub. Par exemple :

- **Lister les CRDs installées** :

```bash
kubectl get crds
```

- **Désinstaller une CRD** :

```bash
kubectl delete crd <crd-name>
```

- **Vérifier l'état d'un opérateur** :

```bash
kubectl get pods -n <namespace> -l name=<operator-name>
```

---

## Les outils de gestions de manifestes : Helm et Kustomize

### Kustomize

L'outil `kustomize` sert à paramétrer et faire varier la configuration d'une installation Kubernetes en fonction des cas.

- Intégré directement dans `kubectl` depuis quelques années il s'agit de la façon la plus simple et respectueuse de la philosophie déclarative de Kubernetes de le faire.

Par exemple lorsqu'on a besoin de déployer une même application dans 3 environnements de `dev`, `prod` et `staging` il serait dommage de ne pas factoriser le code. On écrit alors une version de base des manifestes kubernetes commune aux différents environnements puis on utilise `kustomize` pour appliquer des patches sur les valeurs.

Plus généralement cet outil rassemble plein de fonctionnalité pour supporter les variations de manifestes :
- ajout de préfixes ou suffixes aux noms de resources
- mise à jour de l'image et sa version utilisée pour les pods
- génération de secrets et autres configurations
- etc.

Documentation : https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/

Kustomize est très adapté pour une variabilité pas trop importante des installations d'une application, par exemple une entreprise qui voudrait déployer son application dans quelques environnements internes avec un dispositif de Continuous Delivery. Il a l'avantage de garder le code de base lisible et maintenable et d'éviter les manipulations impératives/séquentielles.

- Pour utiliser kustomise on écrit un fichier `kustomization.yaml` à côté des manifestes et patchs et on l'applique avec `kubectl -k chemin_vers_kustomization`.

- Il est aussi très utile de pouvoir visualisé le resultat du patching avant de l'appliquer avec : `kubectl kustomize chemin_vers_kustomization`

Mais lorsqu'on a besoin de faire varier énormément les manifestes selon de nombreux cas, par exemple lorsqu'on distribue une application publiquement et qu'on veut permettre à l'utilisateur de configurer dynamiquement à peut près tous les aspects d'une installation, kustomize n'est pas adapté.

### Helm, package manager pour Kubernetes

Helm permet de déployer des applications / stacks complètes en utilisant un système de templating pour générer dynamiquement les manifestes kubernetes et les appliquer intelligemment.

C'est en quelque sorte le package manager le plus utilisé par Kubernetes.

- Un package Helm est appelé **Chart**.
- Une installation particulière d'un chart est appelée **Release**.

Helm peut également gérer les dépendances d'une application en installant automatiquement d'autres chart liés et effectuer les mises à jour d'une installation précautionneusement s'il le **Chart** a été prévu pour.

En effet en plus de templater et appliquer les manifestes kubernetes, Helm peut exécuter des hooks, c'est à dire des actions personnalisées avant ou après l'installation, la mise à jour et la suppression d'un paquet.

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


Helm est un "gestionnaire de paquet" ou vu autrement un "outil de templating avancé" pour k8s qui permet d'installer des applications plsu complexe de façon paramétrable :

- Pas de duplication de code
- Possibilité de créer du code générique et flexible avec pleins de paramètres pour le déploiement.
- Des déploiements avancés avec plusieurs étapes

Inconvénient: Helm ajoute souvent de la complexité non nécessaire car les Charts sur internet sont très paramétrables pour de multiples cas d'usage (plein de code qui n'est utile que dans des situations spécifiques).

Helm ne dispense pas de maîtriser l'administration de son cluster.

## (facultatif) Installer Helm

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

### Debugging et gestion des pannes dans Kubernetes

Lorsqu'une application ou un cluster Kubernetes rencontre des problèmes, il est essentiel de diagnostiquer rapidement la situation pour minimiser les interruptions de service. Kubernetes offre plusieurs outils et commandes pour le **debugging** et la **gestion des pannes**, permettant d'investiguer et de résoudre les problèmes.

Voici un aperçu des principales techniques pour diagnostiquer et gérer les pannes dans un cluster Kubernetes.

---

## Diagnostiquer les erreurs avec kubectl


**Le **debugging** et la **gestion des pannes** dans Kubernetes nécessitent l’utilisation de divers outils fournis par `kubectl` pour inspecter les Pods, les logs, et l'état des nœuds.** 

Les fonctionnalités avancées, comme l’API debug de Kubernetes, offrent encore plus de flexibilité pour diagnostiquer les erreurs dans un cluster.

Kubernetes fournit plusieurs outils via `kubectl` pour accéder à des informations cruciales pour le debugging. Voici quelques commandes essentielles :

### 1. `kubectl logs`

Cette commande permet d'accéder aux journaux d'un conteneur dans un Pod, ce qui est utile pour diagnostiquer des erreurs d'application ou vérifier le comportement du Pod.

- **Exemple de commande :**

```bash
kubectl logs <pod-name> -n <namespace>
```

- **Options utiles :**
  - `-f` : Affiche les logs en continu (suivre les logs en temps réel).
  - `--previous` : Affiche les logs d'un conteneur mort dans un Pod redémarré.

**Exemple :**

```bash
kubectl logs my-pod -c my-container -n my-namespace
```

Cette commande affiche les logs du conteneur nommé `my-container` dans le Pod `my-pod`.

### 2. `kubectl exec`

La commande `kubectl exec` vous permet d'exécuter des commandes dans un conteneur directement, ce qui est particulièrement utile pour inspecter l'état d'un conteneur ou investiguer une application défaillante.

- **Exemple de commande :**

```bash
kubectl exec -it <pod-name> -n <namespace> -- <command>
```

**Exemple :**

```bash
kubectl exec -it my-pod -n my-namespace -- /bin/bash
```

Cela ouvre un terminal interactif dans le conteneur, où vous pouvez exécuter des commandes Linux pour inspecter le système de fichiers, vérifier les configurations, et investiguer les logs locaux.

### 3. `kubectl port-forward`

La commande `port-forward` permet d'accéder à un service ou à un Pod via un port local, même si ce service ou Pod n'est pas exposé à l'extérieur du cluster. C'est très utile pour tester une application ou un service qui rencontre des problèmes d'accès.

- **Exemple de commande :**

```bash
kubectl port-forward <pod-name> <local-port>:<remote-port> -n <namespace>
```

**Exemple :**

```bash
kubectl port-forward my-pod 8080:80 -n my-namespace
```

Cela redirige le trafic du port local `8080` vers le port `80` du Pod `my-pod`. Vous pouvez alors accéder à l'application du Pod via `localhost:8080`.

### 4. Autres commandes utiles

- **`kubectl describe`** : Donne des détails sur un objet Kubernetes (Pod, Service, etc.) pour diagnostiquer des erreurs liées à la configuration ou aux événements.
  
  ```bash
  kubectl describe pod <pod-name> -n <namespace>
  ```

  Cette commande montre des informations telles que l'état du Pod, les événements récents, et les détails des conteneurs.

- **`kubectl get events`** : Affiche les événements récents dans le cluster, ce qui permet de comprendre les causes des erreurs, comme des problèmes de programmation des Pods, de ressources manquantes, ou des problèmes réseau.

  ```bash
  kubectl get events -n <namespace>
  ```

---

## Utiliser l’API debug de Kubernetes

Kubernetes introduit également une **API de debug** (disponible via `kubectl debug`) qui permet de diagnostiquer plus facilement les Pods en panne ou d’inspecter des conteneurs avec des outils de débogage spéciaux. L'API de debug permet d'exécuter un nouveau Pod avec une configuration de debug ou d'ajouter temporairement des conteneurs de debug à un Pod existant.

### 1. Utiliser `kubectl debug` pour lancer un Pod de debug

La commande `kubectl debug` permet de créer rapidement un Pod de débogage basé sur l’un des Pods existants, mais avec une image contenant des outils supplémentaires pour le diagnostic (comme `busybox` ou `ubuntu`).

- **Exemple de commande :**

```bash
kubectl debug <pod-name> -n <namespace> --image=busybox -- /bin/sh
```

Cela crée un nouveau Pod de débogage utilisant l'image `busybox` avec une session shell interactive, vous permettant d'explorer l'environnement.

### 2. Créer un conteneur de debug dans un Pod existant

Dans certains cas, vous pouvez avoir besoin d’ajouter un conteneur temporaire dans un Pod défaillant pour exécuter des outils de diagnostic qui ne sont pas présents dans l'image du conteneur d'origine.

- **Exemple de commande :**

```bash
kubectl debug <pod-name> -n <namespace> --target=<container-name> --image=ubuntu
```

Cette commande injecte un conteneur de debug basé sur l'image `ubuntu` dans le Pod, où vous pouvez exécuter des outils comme `curl`, `nslookup`, ou `ping` pour diagnostiquer des problèmes réseau.

---

## Scénarios courants de gestion des pannes

### 1. Pods en état **CrashLoopBackOff**

- **Problème** : Le Pod redémarre constamment.
- **Diagnostic** :
  - Vérifiez les logs du conteneur en échec avec `kubectl logs`.
  - Inspectez les événements récents avec `kubectl describe` pour vérifier les erreurs de configuration ou de ressources.

### 2. Pods bloqués en état **Pending**

- **Problème** : Le Pod ne parvient pas à démarrer.
- **Diagnostic** :
  - Utilisez `kubectl describe` pour vérifier si des ressources (comme CPU ou mémoire) sont indisponibles ou si le nœud n'a pas pu programmer le Pod.
  - Vérifiez les quotas de ressources dans le namespace et les limites de capacité du cluster.

### 3. Problèmes de réseau

- **Problème** : Les Pods ou services ne parviennent pas à communiquer.
- **Diagnostic** :
  - Utilisez `kubectl debug` pour lancer des tests réseau depuis le conteneur de debug  (par ex. `ping`, `curl`).
  - Utilisez `kubectl port-forward` pour accéder à un Pod ou un service et vérifier son comportement.

---



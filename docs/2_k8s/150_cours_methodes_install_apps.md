---
title: Cours 6 - Méthodes pour installer des applications Kubernetes
draft: false
---

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

- Il est aussi très utile de pouvoir visualisé le resultat du patching avant de l'appliquer avec : `kubectl kutomize chemin_vers_kustomization`

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

- `kubectl get all --all-namespaces -l='app.kubernetes.io/managed-by=Helm,app.kubernetes.io/instance=release-name` ou `kubectl api-resources --verbs=list -o name | xargs -n 1 kubectl get --show-kind -l release=awesome-nginx --ignore-not-found -o name` => pour lister les resources d'un chart à partir des étiquettes

- `helm delete my-release`: Permet de désinstaller la release `my-release` de Kubernetes

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

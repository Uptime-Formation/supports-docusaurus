---
title: Cours optionnel - Problématiques de securité Kubernetes
draft: false 
# weight: 2100
---

## Modèles de menace et l'environnement dynamique Kubernetes

La première étape pour pouvoir choisir et configurer la sécurité d'un cluster est d'élaborer un modèle de menace en répondant à généralement à la question : quelles sont les menaces qui me concernent et les vecteurs d'attaque probables pour ces menaces ?

Grossièrement les risques : "un attaquant compromet la sécurité d'une application exposée publiquement" et "une partie utilisatrice d'un cluster multitenant occupe toutes les ressources du cluster suite à une fuite mémoire / a accès à des information confidentielles ne la concernant pas" n'appellent pas les mêmes réponses en sécurité.

Notamment, la question de la taille du cluster et de ses usagers compte beaucoup. Il est parfois plus simple d'utiliser de multiples clusters pour mitiger un risque que de vouloir mutualiser dans un seul cluster, ce qui amène souvent le besoin d'une politique plus ou moins proche du "zero trust".

Mais généralement et sans devenir paranoïaque il est important de réaliser à quel point un cluster Kubernetes est un environnement dynamique qui implique de nombreux vecteurs d'attaque potentiels : si un attaquant peut passer d'un conteneur à l'autre par des mouvement latéraux sur le réseau (ce qui est possible par défaut) du cluster il pourra plus facilement trouver un conteneur suffisament unsecure pour éventuellement prendre le contrôle du noeud ou du cluster, ce qui est dramatique à grande échelle.

Face à ce type de menace l'idée de sécuriser simplement l'accès au cluster de l'extérieur n'est pas suffisant. Il faut considérer également la sécurité dynamique interne au cluster.

## Quelques vecteurs d'attaque classiques

Il existe plusieurs types classiques de vecteurs d'attaque qui peuvent être utilisés pour compromettre un cluster Kubernetes :

- Misconfigured authentication and authorization - Si les mécanismes d'authentification et d'autorisation dans Kubernetes ne sont pas correctement configurés, un attaquant pourrait potentiellement accéder au cluster en exploitant des identifiants faibles ou compromis.

- Vulnerable or malicious container images - Si une image de conteneur en cours d'exécution dans un cluster Kubernetes contient une vulnérabilité ou un code malveillant, un attaquant pourrait potentiellement l'utiliser pour prendre le contrôle de l'hôte ou du réseau sous-jacent.

- Unsecured API server - Le serveur API Kubernetes est un composant critique du cluster, et s'il n'est pas correctement sécurisé, un attaquant pourrait potentiellement accéder à des informations sensibles ou même prendre le contrôle de l'ensemble du cluster.

- Insecure network traffic - Si le trafic réseau entre les composants ou les nœuds Kubernetes n'est pas correctement chiffré ou authentifié, un attaquant pourrait potentiellement intercepter ou modifier le trafic pour accéder à des informations sensibles ou exécuter une attaque Man-in-the-Middle (MitM).

- Excessive privileges - Si un utilisateur ou un compte de service dans Kubernetes dispose de privilèges excessifs ou est en mesure d'escalader ses privilèges, un attaquant pourrait potentiellement utiliser cet accès pour prendre le contrôle du cluster.

- Malicious or misconfigured plugins - Si un plugin utilisé par Kubernetes pour le stockage, le réseau ou d'autres services est malveillant ou mal configuré, un attaquant pourrait potentiellement l'utiliser pour accéder au cluster ou exécuter du code malveillant.

- Social engineering - Les attaquants peuvent tenter d'utiliser des tactiques d'ingénierie sociale, telles que le phishing ou le spear-phishing, pour accéder à des identifiants ou des informations sensibles qui peuvent être utilisés pour compromettre le cluster.

Il est important d'être conscient de ces vecteurs d'attaque et de prendre des mesures pour les atténuer :

- mise en place d'authentification et d'autorisation solides
- utilisation d'images de conteneurs sécurisées
- chiffrement du trafic réseau
- configuration minutieuse des plugins et des privilèges. Des audits de sécurité réguliers et une surveillance peuvent également aider à identifier les vulnérabilités potentielles et à atténuer les risques avant qu'ils ne puissent être exploités par des attaquants.

## Sécuriser l'API avec le Role-Based Access Control (RBAC)

L'API est le point d'accès universel au Cluster. Les composants de base du cluster, comme les utilisateurs et même tous les pods du Cluster y ont accès par défaut et peuvent donc contrôler potentiellement n'importe quoi dans le cluster si on en donne le droit. Il est donc impératif de bien limiter l'accès à l'API au cas par cas, pour les utilisateurs humains du cluster mais aussi les pods/composants.

Kubernetes intègre un système de permissions fines pour chaque action sur les ressources et les namespaces. Il fonctionne en liant des ensembles de permissions appelées `Roles` à des identités. Ces identités peuvent être celles d'humains appelés `User`/`Group` ou des comptes de service/automatisation pour vos programmes appelés `ServiceAccount`.

### L'authentification des `User`

On peut authentifier un utilisateur avec notamment:
  - de façon statique à l'aide d'un `fichier token`  ou d'un `certificat X509` a créer par l'administrateur.
  - à l'aide d'une intégration avec l'une ou l'autre solution de gestion d'identité (compatible OpenID, fournie par un cloudprovider comme IAM d'AWS, Active Directory, Keycloak etc). Pour une solution keycloak voir fin du TP : Bootstrapper un cluster multi-noeud avec Ansible.

Exemple de comment générer un certificat à créer un nouvel utilisateur dans minikube: https://docs.bitnami.com/tutorials/configure-rbac-in-your-kubernetes-cluster/

Doc officielle: https://kubernetes.io/docs/reference/access-authn-authz/authentication/

### Le `ServiceAccount` d'un pod

Chaque pod dans le Cluster est lié à sa création avec un `ServiceAccount` soit implicitement au service account par défaut (default) du namespace soit explicitement à un autre `ServiceAccount` adapté. Il peut ensuite utiliser une authentification à l'API grâce au token associé.

Tutoriel pour jouer avec le RBAC et les `ServiceAccounts` : https://dzone.com/articles/using-rbac-with-service-accounts-in-kubernetes

### Roles et ClusterRoles

Une `role` est un objet qui décrit un ensemble d'actions permises sur certaines ressources et s'applique sur **un seul namespace**. Pour prendre un exemple concret, voici la description d'un roles qui authorise la lecture, création et modification de `pods` et de `services` dans le namespace par défaut:

```yaml
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  namespace: default
  name: pod-and-services
rules:
- apiGroups: [""]
  resources: ["pods", "services"]
  verbs: ["create", "delete", "get", "list", "patch", "update", "watch", "proxy"]
```

- Un role est une liste de règles `rules`

Les rules sont décrites à l'aide de verbes qui décrivent des type d'action sur les objects. Les verbes de base :

![](https://i.stack.imgur.com/EhmDC.png)

Il y a aussi le verbe `impersonate` qui permet d'agir en tant qu'autre utilisateur/identité avec la syntaxe `--as=myuser`. Exemple: https://johnharris.io/2019/08/least-privilege-in-kubernetes-using-impersonation/


- Classiquement on crée des `Roles` comme `admin` ou `monitoring` qui désignent un ensemble de permission consistante pour une tâche donnée.

- Notre role exemple est limité au `namespace default`. Pour créer des permissions valable pour tout le cluster on utilise à la place un objet appelé un `ClusterRole` qui fonctionne de la même façon mais indépendamment des namespace.

### Bindings

- Le role **ne fait rien par lui même** : il doit être appliqué à une identité ie un `User`, `Group` ou `ServiceAccount` à l'aide respectivement de `RoleBinding` et `ClusterRoleBinding` comme l'exemple suivant:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  namespace: default
  name: pods-and-services
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: User
  name: alice
- apiGroup: rbac.authorization.k8s.io
  kind: Group
  name: mydevs
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: pod-and-services
```

En plus des rôles que vous pouvez créer pour les utilisateur·ices et processus de votre cluster, il existe déjà dans kubernetes un ensemble de `Roles` et `ClusterRoles` prédéfinis qui sont affichables avec :

`kubectl get clusterroles`

- Le rôle `cluster-admin` fournit un accès complet à l'ensemble du cluster.
- Le rôle `admin` fournit un accès complet à un espace de noms précis.
- Le rôle `edit` permet à un·e utilisateur·ice de modifier des choses dans un espace de noms.
- Le rôle `view` permet l'accès en lecture seule à un espace de noms.

Il y a plein d'autre `roles` et `clusterroles` destinés à différents composants du cluster qu'on peut étudier.

La commande `kubectl auth can-i <verb> <type_de_resource>` permet de déterminer selon le profil utilisé (défini dans votre `kubeconfig`) les permissions actuelles de l'user sur les objets Kubernetes. On peut en plus utiliser l'impersonnation avec can-i (et toutes les commandes kubectl) pour tester les limites d'une d'action avec identité. Exemple:

```bash
kubectl auth can-i delete pod --as=my-limited-serviceaccount
no
```

### Auditer le RBAC...

... Pour trouver les pods avec trop de droits ou qui ont réussi a en avoir plus. Il existe plusieurs solutions la plus populaire est Kubiscan: https://github.com/cyberark/KubiScan

## Sécurité des images et de la runtime de conteneur.

Un vaste sujet : Cf livre Oreilly `Container Security`.

- Utiliser une runtime de conteneur a jour et qui exécute les conteneurs en userspace idéalement.

- Containerd et CRI-O n'ont pas besoin de démon privilégié comme Docker pour fonctionner et sont plus simple. Elles sont donc à conseiller d'un point de vue sécurité.

- Éviter les conteneurs privilégiés sauf cas exceptionnel (exemple `kube-proxy` est privilégié pour éditer les règles iptables) et les isoler le cas échéant.
## Auditer les images

Avoir une analyse statique des images incluses dans son registry (harbor ou quay.io, ou le registry d'un provider par exemple) et qui bloque les déploiements au niveau de la CI/CD si trop de failles critiques.

## Pod Security Admission

Cependant il n'est pas toujours suffisant ou possible d'auditer systématiquement les images en amonts

- a la phase admission de la création d'un pod on peut vérifier que le pod respecte une classe de `PodSecurityStandard` ou autre spécification grace à un plugin.

=> les `PodSecurityPolicies` sont dépréciées et vont bientôt sortir du core de Kubernetes. Elles sont remplacé par ihttps://kubernetes.io/docs/concepts/security/pod-security-admission/ qui fournit les même fonctionnalités en tant qu'extension de Kubernetes.

https://kubernetes.io/docs/concepts/security/pod-security-standards/

Privileged : Unrestricted policy, providing the widest possible level of permissions. This policy allows for known privilege escalations.
Baseline : Minimally restrictive policy which prevents known privilege escalations. Allows the default (minimally specified) Pod configuration.
Restricted : Heavily restricted policy, following current Pod hardening best practices.
## Zero Trust network pour le cluster

Comme évoqué précédemment les mouvements latéraux sur le réseau d'un cloud sont un vecteur privilégié d'attaque ou d'amplification d'une attaque. Pour réduire la surface offerte il est possible notamment de chiffrer les connexions entre les pods.

https://projectcalico.docs.tigera.io/security/adopt-zero-trust
## NetworkPolicies

![](/img/kubernetes/ahmetb_networkpolicies.gif)
*Crédits [Ahmet Alp Balkan](https://medium.com/@ahmetb)*

https://ahmet.im/blog/kubernetes-network-policy/

**Par défaut, les pods ne sont pas isolés au niveau réseau** : ils acceptent le trafic de n'importe quelle source.

Les pods sont isolés dès qu'une NetworkPolicy les sélectionne. Une fois qu'une NetworkPolicy (dans un certain namespace) inclut un pod particulier, ce pod rejettera toutes les connexions qui ne sont pas autorisées par cette NetworkPolicy. Il faut ensuite whitelister les connexions pertinentes.

- Des exemples de Network Policies : [Kubernetes Network Policy Recipes](https://github.com/ahmetb/kubernetes-network-policy-recipes)

## Chiffrement TLS des communications inter-pod

En complément des NetworkPolicies, il est possible de systématiser le chiffrement des communications intra cluster:

- Avec un Service Mesh comme `Istio` ou `Linkerd`...
- ... Combiné ou non avec un plugin de CNI comme `Calico` ou `Cilium`

## Sécurité et Observabilité

Il est important d'avoir une visualisation dynamique adéquate du réseau et des pods/objets d'un cluster pour identifier les dépendances et élaborer une politique de sécurité. Il existe pour cela en plus du monitoring (Prometheus/Grafana, ou service type DataDog etc), des dashboards comme celle de tigera (Calico), hubble (Cillium), Istio ou linkerd qui permette une observabilité avancée du réseau.

De plus, un cluster est un espace dynamique ou le nombre d'évènements est trop important pour être traité facilement par un humain encore moins pour une évaluation continue des menaces. A grande échelle, il faut automatiser la détection d'intrusion et les mitigations associées.

Pour cela il est nécessaire de collecter des informations de façon centralisée et paramétrer des patterns pour les traiter massivement et identifier les comportements suspicieux.
- Les audit logs du cluster pour détecter les appels étranges à l'API
- Les communications interpods
- provenance des requêtes externes (à passer à la moulinette des sources suspicieuses)
- Voire faire du Deep Paquet Inspection sur le traffic
- ...

Un dispositif de SIEM (Security Information and Event Management) permet ce type d'analyse massive et mitigation automatique. Plusieurs solution on premise ou en Saas sont possible : Installation de EFK en mode SIEM, offre du provider comme Azure etc., Offre enterprise de Tigera/Calico etc.

## Overview

![](/img/kubernetes/security_overview.png)

# Bibliographie

- Kubernetes Security and Observability, chez Oreilly (sponsorisé par calico donc un peu sur mesure pour leur solution)

<!-- - Deux modèles fondamentaux :
    - single tenant cluster :
        - la menace est qu'un attaquant peut se connecter au cluster de l'extérieur et gagner des privilèges
        - une application exposée en mode public peut être compromise
        => sécuriser l'accès à l'API
        => sécuriser la runtime de conteneurs
        => Ajouter une pod security admission (successeur des Pod Security Policies) pour éviter qu'un pod compromis puisse compromettre le cluster
        => eviter qu'un pod ait un service account trop permissif
    - multitenant cluster :
        - isoler/protéger les parties/tenants les unes des autres au sein du même cluster
        => RBAC strict
        => Network Policies Strict
        => ResourceQuota incontournables sur tous les namespaces -->
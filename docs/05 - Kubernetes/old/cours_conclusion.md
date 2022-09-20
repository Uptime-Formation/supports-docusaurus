---
title: Conclusion
weight: 2100
draft: true
---

<!-- A supprimer de l'intro si ici -->
## Points forts de Kubernetes

- Open source et très actif.
- Une communauté très visible et présente dans l'évolution de l'informatique.
- Un standard collectif qui permet une certaine interopérabilité dans le cloud.
- Les _pods_ tendent à se rapprocher plus d'une VM du point de vue de l'application.
- Hébergeable de façon quasi-identique dans le cloud, on-premise ou en mixte.
- Kubernetes a un _flat network_ ce qui permet de faire des choses puissante facilement comme le multi-datacenter.
- K8s est pensé pour la _scalabilité_ et le _calcul distribué_.


## Faiblesses de Kubernetes

<!-- TODO à améliorer -->

- Une difficulté à manier tout ce qui est *stateful*, comme des bases de données
  - …même si les Operators et les CRD (Custom Resources Definitions) permettent de combler cette lacune dans la logique *stateless* de k8s


- Beaucoup de points sont laissés à la décision du fournisseur de cloud ou des admins système :

  - Pas de solution de **stockage** par défaut, et parfois difficile de stocker "simplement" sans passer par les fournisseurs de cloud, ou par une solution de stockage décentralisé à part entière (**Ceph, Gluster, Longhorn**...)
    - …même si ces solutions sont souvent bien intégrées à k8s

  - Beaucoup de solutions de **réseau** qui se concurrencent, demandant un comparatif fastidieux
    - …même si plusieurs leaders émergent comme **Calico, Flannel, Weave ou Cilium**

  - Pas de solution de loadbalancing par défaut : soit on se base sur le fournisseur de cloud, soit on configure [*MetalLB*](https://metallb.universe.tf/) -->

  <!-- Pas de solution de **reverse proxy (ingress)** standard
    - …même si l'ingress **Nginx** est très utilisé et plus ou moins officiel et que **Traefik** est optimisé pour k8s -->

## Comparer Kubernetes

### Docker Swarm

- Docker Swarm est la solution d'orchestration et de clustering intégrée avec la CLI et le workflow docker.
- Swarm est plus facile mais moins puissant pour l'automatisation que Kubernetes
- Swarm groupe les containers entre eux par **stack** mais c'est un groupement assez lâche.
- Kubernetes au contraire créé des **pods**, avec une meilleure cohésion qui sont toujours déployés ensembles puis les scale avec des **deployments** et **services**.
  - => Kubernetes à une meilleure fault tolerance que Swarm
  - point vocabulaire : un service Swarm est un seul conteneur répliqué, un service Kubernetes est un pod (groupes de conteneurs) exposé à l'extérieur.
- Kubernetes a plus d'outils intégrés. Il s'agit plus d'un écosystème qui couvre un large panel de cas d'usage.
- Dans un contexte on premise, Swarm est beaucoup plus simple à mettre en œuvre et à maintenir qu'une stack Kubernetes.

### Apache Mesos

Mesos est une autre solution pour exécuter des applications distribuées. En combinant **Mesos** avec son "application framework" **Marathon** on obtient une solution équivalente sur de nombreux points à Kubernetes.

Elle est cependant moins standard :
    - Moins de ressources disponibles pour apprendre, intégrer avec d'autre solution etc.
    - Peu vendu en tant que service par les principaux cloud provider.
    - plutôt pour les gros projets alors que kubernetes peu être intéressant pour les petits projets.
    - Plus chère à mettre en oeuvre.

Comparaison d'architecture : [Mesos vs. Kubernetes](https://www.baeldung.com/mesos-kubernetes-comparison)


---

## Pour approfondir

### Monitoring et logging
Avec Prometheus et la suite Elastic.

### Déploiement continu
- Exemple de workflow de déploiement continu (CD)
  - par exemple avec Gitlab (possiblement auto-hébergé dans K8s)
  - se connecter à un bastion
  - `git pull`
  - puis `kubectl apply`

### Exemple de stack avancée
La Bitnami Kubernetes Production Runtime (BKPR).
- Monitoring avec Prometheus et Grafana
- Logging avec Elasticsearch, Kibana et Fluentd
- HTTPS ingress avec Nginx, ExternalDNS, Cert-Manager et oauth2_proxy
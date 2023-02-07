---
title: 'TP3 - Installer un cluster et déployer avec avec Helm'
draft: true
---

## Installer un cluster lab de 3 noeuds

On peut louer des clusters chez la plupart des fournisseurs de cloud importants:

- Google avec GKE (Google Kubernetes Edition)
- Amazon avec AKS (Amazon Kubernetes Service)
- Azure
- DigitalOcean
- etc.

Les avantages:
- Géré (pas de couts de maintenance)
- des différences entre chaque fournisseurs
- Cher pour les petits clusters (surtout côté loadbalancer)
- Cher et/ou peu flexible pour certains besoins spécifiques
  - stockage réseau spécifique / de grande taille
  - intégration de différents provider
  - 

Il existe de nombreuses façon d'installer un cluster de production de différente taille et complexité:

- kubeadm est l'outil officiel d'installation qui permet l'installation, le redimensionnement et la mise à jour d'un cluster Kubernetes. Il nécessite des opérations manuelles sur chaque serveur du clusteur pour l'automatiser l'installation on peut utiliser par exemple:
  - Kubespray est une solution classique basée sur Ansible et kubeadm pour gérer un cluster de production.
  - Hobby-kube est une solution terraform pour mettre rapidement en place un cluster de production de taille limité en utilisant kubeadm.

K8s est également distribué par différentes entreprise
- Openshift de Redhat: un PAAS complet basé sur la version red hat de K8S.
- RKE une solution proposée par Rancher pour installer un cluster K8S de façon guidée.

Enfin mentionnons K3S une solution rancher très populaire pour créer un cluster K8S simple et léger pour la production en particulier Edge/IoT.

## Installer un cluster avec Hobby-kube et Hetzner cloud

TODO

- Cloner le projet depuis github.com/e-lie
- Utiliser la branche tp3-k8s
- Ajouter les tokens hcloud et digitalocean
- Commenter amazon dns et activer do dns
- Lancer le provisionning
- se connecter au cluster en ssh et tester kubectl
- installer sshuttle pour se connecter au cluster distant sécurisé
- ouvrir le cluster dans Lens

## Helm - le gestionnaire d'application kubernetes standard

Helm est un gestionnaire de paquet K8s qui permet d'installer des paquets sans faire des copier-coller pénibles de yaml :

- pas de duplication de code
- des déploiement avancés avec un processus de mise à jour k8s intégré

Helm ne dispense pas de maîtriser l'administration de son cluster.

- Pour installer Helm sur ubuntu, utilisez : `snap install helm --classic`

- Suivez le [Quickstart] (https://helm.sh/docs/intro/quickstart/) 

## Installer Jenkins grâce à Helm

 TODO mettre la version stable

- Cherchez Jenkins sur [https://hub.kubeapps.com](https://hub.kubeapps.com).
- Prenez la version de **codecentric** et ajoutez le dépot avec la première commande à droite (ajouter le dépot et déployer une release).
- Installer une release jenkins-tp de cette application (ce chart) avec `helm install --template-name jenkins-tp codecentric/jenkins`
- Cherchez le nom du pod jenkins-master
- Affichez les logs du pod avec `kubectl logs` et récupérez la clé d'initialisation qui se trouve entre les triples lignes d'étoiles. Notez là dans un fichier texte (`gedit key.tmp` ?)
- Plutôt que de faire un port-forwarding, nous allons configurer le service k8s de jenkins-master pour être en mode NodePort.
  - Créez un fichier `config_jenkins.yaml` avec à l'intérieur:

```yaml
service:
    master:
        type: "NodePort"
```
- Appliquez cette config à notre release avec `helm upgrade -f config_jenkins.yaml jenkins-tp codecentric/jenkins`.
- Cherchez le port d'exposition du service avec `kubectl get services | grep jenkins`
- Visitez [http://localhost:<node_port>](http://localhost:<node_port>)
- Récupérez le password d'inititalisation précédemment sauvegardé et collez le dans le navigateur
- Notre Jenkins de travail est prêt.

## Facultatif : Transformer notre Application en Chart Helm

TODO

Tranformer l'application du TP2 en chart helm

Ajouter une configmap pour notre application

La base d'un chart

Variabiliser

Tester notre Chart

Les designs pattern de K8S
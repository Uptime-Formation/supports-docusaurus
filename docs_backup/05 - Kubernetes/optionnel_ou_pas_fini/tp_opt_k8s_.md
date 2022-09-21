---
title: TP opt. - Installation d'un 
draft: true
weight: 2100
---



## Liste de prérequis pour un cluster de production
### Infrastructure du cluster

- Exécuter un control plane hautement disponible : Vous pouvez y parvenir en exécutant les composants du control plane sur trois nœuds ou plus. Une autre bonne pratique recommandée est de déployer les composants maîtres Kubernetes et etcd sur deux groupes de nœuds distincts. Cela permet généralement de faciliter les opérations etcd, telles que les mises à niveau et les sauvegardes, et de diminuer le rayon des défaillances du control plane. De plus, pour les grands clusters Kubernetes, cela permet à etcd de bénéficier d'une ressources en l'exécutant sur certains types de nœuds qui répondent à ses besoins d'E/S étendus. Enfin, évitez de déployer des pods sur les nœuds du control plane.

- Exécutez un groupe de workers hautement disponibles : Vous pouvez y parvenir en exécutant un groupe ou plus de nœuds workers avec trois instances ou plus. Si vous exécutez ces groupes de workers en utilisant un fournisseur de cloud, vous devez les déployer dans un groupe d'auto-scaling et dans différentes availability zones.

- Une autre condition pour garantir la haute disponibilité même sous une charge anormalement élevée et/ou pendant les opération de mise à jour est de déployer l'auto-scaler de cluster de Kubernetes, qui permet aux groupes de workers de s'agrandir et se réduire automatiquement en fonction des besoins.

## Installer un serveur K8s de production


![](/img/kubernetes/kubernetes-production-layers.png)


- Récupérer le livre `Kubernetes in Production Best Practices - Build and manage highly available production-ready Kubernetes clusters` de Aly Saleh, Murat Karslioglu chez Packt pour discuter les prérequis de production.

- Déployer un cluster EKS avec Terraform en suivant le chapitre 3 du livre.

- Facultatif : démystifier l'authentification/authorization des utilisateurs avec l'intégration kubernetes RBAC et AWS IAM : https://medium.com/globant/rbac-and-eks-aws-step-by-step-e2f9c38f1aeb

<!--

TODO reprendre les étapes suivantes au propre pour simplifier

- aws configure avec les AWS ID et secret de mon compte

- terraform init && apply dans packtcluster-vpc puis terraform output pour copier les outputs de config du VPC

- collez les outputs dans les vars de packtcluster

- terraform init and apply wait for 9 min

- aws eks --region "eu-west-3" update-kubeconfig --name packtclusters-default -> va maj la kubeconfig

- `terraform output authconfig` à copier dans un fichier authconfig.yaml puis `kubectl apply -n kube-system -f authconfig.yaml` (pour permettre aux noeuds worker AWS de s'authentifier )

## Configurer des namespaces et comptes uilisateurs avec Ansible

```bash
cd terraform/packtcluster
virtualenv $HOME/k8s-ansible-env
source $HOME/k8s-ansible-env/bin/activate
pip install ansible==2.9 openshift pyyaml requests
ansible-playbook -i \
    ../../ansible/inventories/packtclusters/ \
    -e "worker_iam_role_arn=$(terraform output worker_iam_role_arn)" \
    ../../ansible/cluster.yaml
``` -->
---
title: TP opt. - Gestion d'un cluster de production
draft: true
weight: 2100
---





## Installer les couches supérieures d'un cluster K8s de production


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
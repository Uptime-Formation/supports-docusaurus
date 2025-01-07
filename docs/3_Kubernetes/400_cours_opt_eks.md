---
title: Cours optionnel - Le cas de AWS EKS
---

EKS (Elastic Kubernetes Service) est l'offre Kubernetes managée d'amazon AWS.

Elle est l'offre kubernetes managée la plus utilisée (surtout à cause de la force de frappe d'AWS)

Elle s'intègre avec les services amazon AWS (tous les services possibles)

Elle s'intègre avec l'IaC made in AWS (Cloudformation, sécurité AWS : VPC,IAM,Audit, Observabilité AWS)

## EKS vs ECS: deux services d'orchestration de conteneurs

- ECS = un service basé sur docker avec un control plane managé par AWS
- pour les compute resources : EC2 (manuel) ou Fargate (vm managées par AWS)

## Les deux modes compute de EKS chez AWS

- EC2 manual, autoscaling group ou Fargate

![](/img/kubernetes/eks-modes.png)

## Les modes hybrides de EKS

Pour ne pas être trop impacté par le manque d'interopérabilité AWS propose des offres hybrides (+- on premises)

- EKS Outpost : donner acces à amazon a votre datacenter pour les laisser manager virtuellement tout sur vos machines (besoin d'une connexion stable)

- EKS Distro (https://distro.eks.amazonaws.com/): les plugins kubernetes de EKS open sourcés (utilisé par EKS) installable par tout le monde...

- EKS Anywhere : une installation de EKS Distro dans votre datacenter connecté au cloud AWS (connexion internmittente possible)

## Provisionner un cluster EKS simple

D'abord configurer l'aws-cli: `aws configure` avec un une identité admin

- eksctl: `eksctl create cluster -f eks-cluster.yaml`
- terraform (+ansible)
- cloudformation

récupérer la kubeconfig: automatiquement provisionnée dans dossier `.kube`

## Composants de EKS

EKS (Cloud ou Distro) intègre les composants suivants:

- CNI plugins dont Amazon VPC CNI : https://aws.github.io/aws-eks-best-practices/networking/vpc-cni/ 
- CoreDNS
- etcd
- CSI Sidecars dont AWS EFS CSI: https://docs.aws.amazon.com/eks/latest/userguide/efs-csi.html
- aws-iam-authenticator: https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html
- Kubernetes Metrics Server
- Kubernetes build by amazon (kubernetes recompilé a une certaine version)

Toutes les images de conteneurs pour ces composants sont basées sur Amazon Linux 2 et sont disponibles sur l'ECR public gallery (https://gallery.ecr.aws/).

## Architecture de EKS (dans le cloud)

![](/img/kubernetes/EKS-archi2.png)


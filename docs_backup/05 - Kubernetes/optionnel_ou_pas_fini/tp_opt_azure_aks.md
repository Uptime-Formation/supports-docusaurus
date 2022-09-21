---
draft: true
title: TP 5 - Cloud Azure (AKS)
weight: 2172
---

Nous allons déployer une application dans Azure à l'aide de *charts* Helm : https://docs.bitnami.com/kubernetes/get-started-aks/

### Créer un cluster AKS 

#### Configurer l'environnement Azure 


Tout d'abord, il faut se créer un compte Azure. Si c'est la première fois, du crédit gratuit est disponible : https://azure.microsoft.com/fr-fr/free/
Ensuite on peut utiliser le [Cloud Shell Azure](https://shell.azure.com/bash) ou n'importe quel terminal.

```bash
# Install Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Login
az login --allow-no-subscriptions

# Créer le groupe de ressources
az group create --name aks-resource-group --location westeurope
```


Au préalable, installer `kubectl` (pas besoin dans le Cloud Shell) :
```bash
snap install kubectl --classic
```

#### Créer le cluster K8S


```bash
# Créer deux nœuds dans le cluster AKS
az aks create --name aks-cluster --resource-group aks-resource-group --node-count 2 --generate-ssh-keys

# Récupérer la config AKS
az aks get-credentials --name aks-cluster --resource-group aks-resource-group
```

#### Créer le registry pour les images Docker

Pour créer le registry, il faut choisir un nom unique, remplacez `pommedeterrepoirekiwi` par un autre nom.

```bash
# Créer le registry
az acr create --resource-group aks-resource-group  --name pommedeterrepoirekiwi --sku Basic
az acr login --name pommedeterrepoirekiwi

# Créer un compte sur le registry pour K8S
ACR_LOGIN_SERVER=$(az acr show --name pommedeterrepoirekiwi --query loginServer --output tsv)
ACR_REGISTRY_ID=$(az acr show --name pommedeterrepoirekiwi --query id --output tsv)
SP_PASSWD=$(az ad sp create-for-rbac --name k8s-read-registry --role Reader --scopes $ACR_REGISTRY_ID --query password --output tsv)
CLIENT_ID=$(az ad sp show --id http://k8s-read-registry --query appId --output tsv)
kubectl create secret docker-registry read-registry-account \
--docker-server $ACR_LOGIN_SERVER \
--docker-username $CLIENT_ID \
--docker-password $SP_PASSWD \
--docker-email cto@example.org
```

### Pousser une image sur son registry Azure

Pour installer Docker : `curl -sSL https://get.docker.com | sudo sh` 

```bash
# Récupérer puis pousser une image sur son registry Azure
docker pull docker.io/bitnami/wordpress:latest
docker tag docker.io/bitnami/wordpress:latest pommedeterrepoirekiwi.azurecr.io/bitnami/wordpress:latest
docker push pommedeterrepoirekiwi.azurecr.io/bitnami/wordpress:latest
```

### Appliquer une chart Helm

Pour installer Helm : `curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash`

```bash
# Ajout de la chart
helm repo add bitnami https://charts.bitnami.com/bitnami

# Installer la chart
helm install wordpress bitnami/wordpress \
--set serviceType=LoadBalancer \
--set image.registry="pommedeterrepoirekiwi.azurecr.io" \
--set image.pullSecrets={read-registry-account} \
--set image.repository=bitnami/wordpress \
--set image.tag=latest

```

Des messages s'affichent suite à l'application de la chart Helm, suivez les instructions pour accéder au Wordpress.

## Documentation
### Scaling d'application dans Azure

- https://docs.microsoft.com/fr-fr/azure/aks/tutorial-kubernetes-scale

### Stockage dans Azure

- https://docs.microsoft.com/fr-fr/azure/aks/azure-files-dynamic-pv

<!-- https://docs.microsoft.com/fr-fr/azure/aks/azure-files-dynamic-pv
https://docs.microsoft.com/fr-fr/azure/aks/azure-disks-dynamic-pv
https://docs.microsoft.com/fr-fr/azure/aks/concepts-storage -->

### Registry dans Azure

- https://docs.microsoft.com/fr-fr/azure/container-registry/container-registry-quickstart-task-cli

### Terraform avec Azure
Terraform est un outil permettant de décrire des ressources cloud dans un fichier pour utiliser le concept d'infrastructure-as-code avec tous les objets des fournisseurs de Cloud.

- https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster
- https://github.com/terraform-providers/terraform-provider-azurerm/tree/master/examples/kubernetes

- https://registry.terraform.io/modules/Azure/appgw-ingress-k8s-cluster/azurerm/latest
- https://docs.microsoft.com/fr-fr/azure/aks/ingress-basic#create-an-ingress-controller


### Le réseau dans Azure
- Vidéo "K8s Networking in Azure" : https://www.youtube.com/watch?v=JyLtg_SJ1lo&list=PLoWxE_5hnZUZMWrEON3wxMBoIZvweGeiq&index=2
  
- https://docs.microsoft.com/fr-fr/azure/aks/internal-lb
- https://docs.microsoft.com/fr-fr/azure/aks/load-balancer-standard
- https://docs.microsoft.com/fr-fr/azure/aks/http-application-routing
- https://docs.microsoft.com/fr-fr/azure/aks/concepts-network
- https://blog.crossplane.io/azure-secure-connectivity-for-aks-azure-db/
- https://docs.microsoft.com/fr-fr/azure/mysql/concepts-aks


### Pour aller plus loin

- https://docs.microsoft.com/fr-fr/azure/aks/
- https://github.com/microsoft/kubernetes-learning-path

### Les CRD : utiliser des objets Kubernetes pour définir des ressources Azure
https://github.com/Azure/azure-service-operator

## Autres idées d'exercices
- Basique : https://docs.microsoft.com/fr-fr/azure/aks/kubernetes-walkthrough

- Difficile : https://github.com/Microsoft/RockPaperScissorsLizardSpock

---
title: Cours optionnel - Le cas de AWS EKS
---


Pour la surveillance de l'état et de la version du cluster, on peut utiliser la CLI Azure :

```bash
# Vérifier l'état actuel et la version du cluster
az aks show --resource-group monResourceGroup --name monClusterAKS --output table

# Voir les mises à jour disponibles
az aks get-upgrades --resource-group monResourceGroup --name monClusterAKS
```

Azure propose plusieurs approches pour effectuer les mises à jour. La stratégie la plus courante est la mise à jour progressive (rolling upgrade). Avec la cli :

```bash
# Mettre à jour l'ensemble du cluster (plan de contrôle et nœuds)
az aks upgrade \
    --resource-group monResourceGroup \
    --name monClusterAKS \
    --kubernetes-version 1.XX.X

# Mettre à jour uniquement le plan de contrôle
az aks upgrade \
    --resource-group monResourceGroup \
    --name monClusterAKS \
    --kubernetes-version 1.XX.X \
    --control-plane-only
```

La gestion des groupes de nœuds est cruciale pour maintenir la disponibilité des applications pendant les mises à jour. Voici les commandes essentielles :

```bash
# Ajouter un nouveau groupe de nœuds (utile pour les déploiements blue-green)
az aks nodepool add \
    --resource-group monResourceGroup \
    --cluster-name monClusterAKS \
    --name nouveaupool \
    --node-count 3

# Mettre à jour un groupe de nœuds spécifique
az aks nodepool upgrade \
    --resource-group monResourceGroup \
    --cluster-name monClusterAKS \
    --name mongroupenoeuds \
    --kubernetes-version 1.XX.X
```

Pour les fenêtres de maintenance et les mises à jour automatiques, vous pouvez configurer le cluster pour qu'il se mette à jour automatiquement pendant des périodes spécifiques :

```bash
# Configurer les mises à jour automatiques
az aks update \
    --resource-group monResourceGroup \
    --name monClusterAKS \
    --auto-upgrade-channel stable

# Définir la fenêtre de maintenance
az aks update \
    --resource-group monResourceGroup \
    --name monClusterAKS \
    --maintenance-window \
    --weekday Sunday \
    --hour 2
```

Pour surveiller le processus de mise à jour et la santé du cluster, il est important de mettre en place une surveillance appropriée :

```bash
# Activer la surveillance
az aks enable-addons \
    --resource-group monResourceGroup \
    --name monClusterAKS \
    --addons monitoring

# Obtenir l'état de santé du cluster
az aks show \
    --resource-group monResourceGroup \
    --name monClusterAKS \
    --output table
```

Les bonnes pratiques pour la gestion du cycle de vie d'AKS comprennent :

1. Des mises à jour régulières de version pour rester dans la fenêtre des versions supportées
2. L'utilisation d'environnements de préproduction pour tester les mises à jour avant la production
3. La mise en place d'une surveillance et d'alertes appropriées
4. La préparation d'un plan de retour en arrière en cas d'échec des mises à jour
5. L'utilisation efficace des groupes de nœuds pour des mises à jour sans interruption
6. La sauvegarde régulière des configurations du cluster et des données critiques

Cette approche garantit que votre cluster AKS reste sécurisé, stable et à jour tout en minimisant les perturbations potentielles de vos applications. Il est particulièrement important de noter que la gestion des mises à jour doit être planifiée stratégiquement pour maintenir la disponibilité des services tout en assurant la sécurité et la stabilité du cluster.


### Exemple simple de gestion d'un cluster avec Terraform

Je vais vous expliquer comment gérer le cycle de vie d'un cluster AKS avec Terraform. Commençons par la configuration de base d'un cluster, puis nous verrons comment gérer les mises à jour et les groupes de nœuds.

Voici la configuration de base d'un cluster AKS avec Terraform :

```hcl
# Configuration du fournisseur Azure
provider "azurerm" {
  features {}
}

# Création du groupe de ressources
resource "azurerm_resource_group" "aks_rg" {
  name     = "aks-resource-group"
  location = "West Europe"
}

# Création du cluster AKS
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "mon-cluster-aks"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  dns_prefix         = "monclusteraks"

  # Configuration de la version Kubernetes
  kubernetes_version  = "1.25.5"

  # Configuration du plan de contrôle
  automatic_channel_upgrade = "stable"  # Mises à jour automatiques
  
  maintenance_window {
    allowed {
      day   = "Sunday"
      hours = [2, 3]  # Maintenance entre 2h et 4h du matin
    }
  }

  # Configuration du groupe de nœuds par défaut
  default_node_pool {
    name                = "default"
    node_count          = 3
    vm_size            = "Standard_DS2_v2"
    enable_auto_scaling = true
    min_count          = 1
    max_count          = 5
    
    # Configuration des mises à jour automatiques des nœuds
    upgrade_settings {
      max_surge = "33%"  # Maximum de nœuds supplémentaires pendant la mise à jour
    }
  }

  # Identité du cluster
  identity {
    type = "SystemAssigned"
  }

  # Activation de la surveillance
  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.aks.id
  }
}

# Création d'un groupe de nœuds supplémentaire
resource "azurerm_kubernetes_cluster_node_pool" "user" {
  name                  = "user"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size              = "Standard_DS3_v2"
  node_count           = 2
  
  enable_auto_scaling   = true
  min_count            = 1
  max_count            = 3

  # Configuration des mises à jour
  upgrade_settings {
    max_surge = "33%"
  }
}
```

Pour gérer les mises à jour de version, vous pouvez utiliser une variable :

```hcl
variable "kubernetes_version" {
  description = "Version de Kubernetes à utiliser"
  type        = string
  default     = "1.25.5"
}

# Utilisation dans la configuration du cluster
resource "azurerm_kubernetes_cluster" "aks" {
  kubernetes_version = var.kubernetes_version
  # ...
}
```

Pour surveiller l'état du cluster, nous pouvons configurer Log Analytics :

```hcl
# Création d'un espace de travail Log Analytics
resource "azurerm_log_analytics_workspace" "aks" {
  name                = "aks-logs"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  sku                = "PerGB2018"
  retention_in_days   = 30
}

# Configuration des diagnostics
resource "azurerm_monitor_diagnostic_setting" "aks" {
  name                       = "aks-diagnostics"
  target_resource_id        = azurerm_kubernetes_cluster.aks.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.aks.id

  log {
    category = "kube-apiserver"
    enabled  = true
  }

  log {
    category = "kube-controller-manager"
    enabled  = true
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
```

Pour effectuer une mise à jour du cluster, vous pouvez :

1. Modifier la version dans vos variables Terraform
2. Exécuter un plan pour voir les changements prévus :

```bash
terraform plan -var="kubernetes_version=1.26.0"
```
3. Appliquer les changements :
```bash
terraform apply -var="kubernetes_version=1.26.0"
```

Cette approche avec Terraform vous permet de :
- Gérer votre infrastructure comme du code
- Suivre les changements de configuration dans le contrôle de version
- Automatiser les déploiements et mises à jour
- Maintenir la cohérence entre les environnements

Il est important de noter que certains changements, comme les mises à jour de version, peuvent prendre du temps et doivent être planifiés avec soin pour minimiser l'impact sur vos applications.

# Theorie : IAC 


## Objectifs pédagogiques

**Stratégiques**

- Savoir choisir KVM comme outil d'architecture en fonction de critères rationnels.

---
## Infrastructure as Code

**L'infrastructure as code (IaC) est une pratique consistant à décrire l'infrastructure informatique comme du code source, à l'aide d'un langage de programmation.** 

L'objectif est de définir l'infrastructure nécessaire à l'exécution du logiciel d'une manière 
* documentée
* historisée
* mutualisée 

Cela signifie que l'infrastructure (serveurs, réseaux, stockage, etc.) n'est plus gérée et provisionnée plutôt par des processus manuels.

Ce qui permet d'automatiser les changements d'infrastructure, comme par exemple lancer une infrastructure pour des tests.

---

**L'infrastructure as code est une pratique qui permet de gérer l'infrastructure informatique de manière plus automatisée, reproductible, collaborative, agile et rentable.**

Les avantages de l'infrastructure as code sont nombreux :

 **Automatisation**  
  L'infrastructure as code permet d'automatiser la configuration, le déploiement et la gestion de l'infrastructure, ce qui permet de réduire les erreurs humaines et de gagner du temps.

 **Reproductibilité**  
  Les scripts d'infrastructure as code peuvent être versionnés, ce qui permet de reproduire facilement des environnements de développement, de test ou de production.

 **Collaboration**  
  Les scripts d'infrastructure as code peuvent être partagés, modifiés et testés par plusieurs membres de l'équipe, ce qui facilite la collaboration et la gestion des changements.

 **Agilité**  
  L'infrastructure as code permet de provisionner et de déprovisionner rapidement des ressources, ce qui facilite l'adaptation aux changements et aux besoins de l'entreprise.

**Coût**   
  L'infrastructure as code permet de réduire les coûts de maintenance et de gestion de l'infrastructure, car elle permet de minimiser le temps et les ressources nécessaires pour gérer l'infrastructure.

--- 

## Comparaison des familles d'IAC 

**Il existe 5 grandes familles d'outils d'IAC.**

--- 

### Scripts ad hoc  
  C'est la façon la plus basique de faire, en mettant dans des scripts les opérations répétables.  
  Ex: Scripts Bash  
```bash
## Update the apt-get cache
sudo apt-get update

## Install PHP and Apache
sudo apt-get install -y php apache2

## Copy the code from the repository
sudo git clone https://github.com/brikis98/php-app.git /var/www/html/app

## Start Apache
sudo service apache2 start

```

--- 

### Outils de gestion de configuration  
  On utilise des outils de gestion de configuration, ce qui signifie qu'ils sont conçus pour installer et gérer des logiciels sur des serveurs existants.
  Avantages : conventions de code, idempotence, nombreuses cibles 
  ex: Chef, Puppet et Ansible
```ansible
- name: Update the apt-get cache
  apt:
    update_cache: yes

- name: Install PHP
  apt:
    name: php

- name: Install Apache
  apt:
    name: apache2

- name: Copy the code from the repository
  git: repo=https://github.com/brikis98/php-app.git dest=/var/www/html/app

- name: Start Apache
  service: name=apache2 state=started enabled=yes
```
  
--- 

### Outils de modèles de serveur  
  Les outils de création de modèles de serveur sont devenus populaire.  
  Au lieu de lancer un tas de serveurs et de les configurer en exécutant le même code sur chacun d'eux, on crée une image autonome avec le logiciel, les fichiers et tous les autres détails pertinents.
  Un autre outil IaC déploie cette image sur les serveurs, qu'il s'agisse de VMs ou de conteneurs.
  Ex: Docker, Packer
```json
{
  "builders": [{
    "ami_name": "packer-example-",
    "instance_type": "t2.micro",
    "region": "us-east-2",
    "type": "amazon-ebs",
    "source_ami": "ami-0fb653ca2d3203ac1",
    "ssh_username": "ubuntu"
  }],
  "provisioners": [{
    "type": "shell",
    "inline": [
      "sudo apt-get update",
      "sudo apt-get install -y php apache2",
      "sudo git clone https://github.com/brikis98/php-app.git /var/www/html/app"
    ],
    "environment_vars": [
      "DEBIAN_FRONTEND=noninteractive"
    ],
    "pause_before": "60s"
  }]
}

--- 

```
### Outils d'orchestration  
  Les outils d'orchestration se basent sur des modèles de serveur pour assurer la gestion du cycle de vie des services pilotés par les équipe Devops.
  L'orchestrateur va piloter ces instances en : démarrage / arrêt, configuration, démultiplication à la demande, et autres opérations nécessaires à la bonne marche du service. 
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: example-app
spec:
 selector:
    matchLabels:
      app: example-app
  replicas: 3
  strategy:
    rollingUpdate:
      maxSurge: 3
      maxUnavailable: 0
    type: RollingUpdate
  template:
    metadata:
      labels:
        app: example-app
    spec:
      containers:
        - name: example-app
          image: httpd:2.4.39
          ports:
            - containerPort: 80
```

--- 

### Outils de provisionnement  
  Provisioning tools don't define the code that runs on each server, but create server, databases, caches, load balancers, queues, monitoring, subnet configurations, firewall settings, routing rules, Secure Sockets Layer (SSL) certificates, and almost every other aspect of your infrastructure.   
  Ex: Terraform, CloudFormation, OpenStack Heat, and Pulumi

```coffeescript
resource "aws_instance" "app" {
  instance_type     = "t2.micro"
  availability_zone = "us-east-2a"
  ami               = "ami-0fb653ca2d3203ac1"

  user_data = <<-EOF
              #!/bin/bash
              sudo service apache2 start
              EOF
}
```
--- 
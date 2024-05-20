---
title:  Introduction Formation
weight: 1
---

## Introduction

![](../../static/img/docker/docker-lifecycle.png)


## A propos de moi / nous

- Developpeurs 
- Administrateurs Système
- Ingénieurs Devops : Ansible / Docker / Kubernetes / Gitlab CI) / Sécurité 
- Formateurs DevOps, Linux, Python, Sécurité
- Mais aussi graphistes, musiciens, philosophes de la technique, hackers :)

## A propos de vous

- Parcours ?
- Attentes ?
- Cursus DevOps :
  - Est-ce que ça vous plait ?
  - Quels modules avez vous déjà fait ?
  - Répondre aux questions préalables et éventuelles réticences (normales)
  - Anticiper les problèmes de niveaux différents au sein du groupe / faire des paires

---

## Docker is dead ?


![](../../static/img/docker/the-tool-that-realy-runs-your-containers-deep-dive-into-runc-and-oci-specifications.png)


---
## Infrastructure as Code



- on décrit en mode code un état du système. Avantages :
  - pas de dérive de la configuration et du système (immutabilité)
  - on peut connaître de façon fiable l'état des composants du système
  - on peut travailler en collaboration plus facilement (grâce à Git notamment)
  - on peut faire des tests
  - on facilite le déploiement de nouvelles instances

--- 

## Comparaison entre des solutions IAC 

**Il existe 5 grandes familles d'outils d'IAC.**

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

```

--- 

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

## Le mouvement DevOps

Le DevOps est avant tout le nom d'un mouvement de transformation professionnelle et technique de l'informatique.

Ce mouvement se structure autour des solutions **humaines** (organisation de l'entreprise et des équipes) et **techniques** (nouvelles technologies de rupture) apportées pour répondre aux défis que sont:

- L'agrandissement rapide face à la demande des services logiciels et infrastructures les supportant.
- La célérité de déploiement demandée par le développement agile (cycles journaliers de développement).
- Difficultées à organiser des équipes hétérogènes de grande taille et qui s'agrandissent très vite selon le modèle des startups.et


--- 

**Il y a de nombreuses versions de ce que qui caractérise le DevOps mais pour résumer:**

Du côté humain:

- **Application des process de management agile** aux opérations et la gestion des infrastructures (pour les synchroniser avec le développement).
- **Remplacement des procédés d'opérations humaines** complexes et spécifiques par des opérations automatiques et mieux standardisées.
- **Réconciliation de deux cultures divergentes (Dev et Ops)** rapprochant en pratique les deux métiers du développeur et de l'administrateur système.

Du côté technique:

- **L'intégration et le déploiement continus** des logiciels/produits.
- **L'infrastructure as code**: gestion sous forme de code de l'état des infrastructures d'une façon le plus possible déclarative.
- **Les conteneurs** (Docker surtout mais aussi Rkt et LXC/LXD): plus léger que la virtualisation = permet d'isoler chaque service dans son "OS" virtuel sans dupliquer le noyau.
- **Le cloud** (Infra as a service, Plateforme as a Service, Software as a service) permet de fluidifier l'informatique en alignant chaque niveau d'abstraction d'une pile logicielle avec sa structuration économique sous forme de service.


## Aller plus loin

- La DevOps roadmap: [https://github.com/kamranahmedse/developer-roadmap#devops-roadmap](https://github.com/kamranahmedse/developer-roadmap#devops-roadmap)


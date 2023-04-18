---
title: 0 - Introduction
draft: false
sidebar_position: 0
---
---


![](/img/kubernetes/kubernetes_logo.jpg)


---

## Objectifs pédagogiques 
- Avoir une vision globale de la formation
- Comprendre Terraform dans une logique IAC et Devops 

---

## Contenu
* Présentations
* Présentation du IAC
* Présentation du Devops
* Prérequis
* Auto-Évaluation
* Définition des objectifs
* Présentation des outils

---

## Présentations
### A propos de moi 
- Developpeur
- Administrateur Système
- Ingénieur Devops : Ansible / Docker / Kubernetes / Gitlab CI) / Sécurité 
- Formateur DevOps, Linux, Python, Sécurité
- Mais aussi graphiste / musicien / philosophe de la technique / hacker :)

---

### A propos de vous

- Cursus DevOps / IAC :
  - Est-ce que ça vous plait ?
  - Quels modules avez vous déjà fait ?
  - Répondre aux questions préalables et éventuelles réticences (normales)
  - Anticiper les problèmes de niveaux différents au sein du groupe / faire des paires
- La formation :
  - Quelles sont vos attentes ? 
  - Dans quelles conditions allez-vous utiliser les compétences acquises ? 
  - Avez-vous des objectifs opérationnels précis ? 
- L'équipe :
  - Quelle évolution souhaitez-vous apporter au sein de votre équipe avec ces nouvelles compétences ?

---

### Les conditions de la formation

* Horaires et pause 
* Émargement matin et après déjeuner
* Autres ?


--- 

## Infrastructure as Code
 **On décrit en mode code un état du système. Avantages**
  - pas de dérive de la configuration et du système (immutabilité)
  - on peut connaître de façon fiable l'état des composants du système
  - on peut travailler en collaboration plus facilement (grâce à Git notamment)
  - on peut faire des tests
  - on facilite le déploiement de nouvelles instances

---

### Comparaison entre Terraform et d'autres solutions IAC 

**Il existe 5 grandes familles d'outils d'IAC.**

--- 

#### Scripts ad hoc  
  C'est la façon la plus basique de faire, en mettant dans des scripts les opérations répétables.  
  Ex: Scripts Bash  
```bash
### Update the apt-get cache
sudo apt-get update

### Install PHP and Apache
sudo apt-get install -y php apache2

### Copy the code from the repository
sudo git clone https://github.com/brikis98/php-app.git /var/www/html/app

### Start Apache
sudo service apache2 start

```

--- 

#### Outils de gestion de configuration  
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

#### Outils de modèles de serveur  
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
#### Outils d'orchestration  
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

#### Outils de provisionnement  
  Ils ne définissent pas le code exécuté sur chaque serveur mais créent des instances, des bases de données, des load balancers queues, monitoring, subnet configurations, firewall settings, routing rules, certificats Secure Sockets Layer (SSL) et tous les aspects de l'infrastructure en faisant appel à des API.   
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

- Application des process de management agile aux opérations et la gestion des infrastructures (pour les synchroniser avec le développement).
- Remplacement des procédés d'opérations humaines complexes et spécifiques par des opérations automatiques et mieux standardisées.
- Réconciliation de deux cultures divergentes (Dev et Ops) rapprochant en pratique les deux métiers du développeur et de l'administrateur système.

---

Du côté technique:

- L'intégration et le déploiement continus des logiciels/produits.
- L'infrastructure as code: gestion sous forme de code de l'état des infrastructures d'une façon le plus possible déclarative.
- Les conteneurs (Docker surtout mais aussi Rkt et LXC/LXD): plus léger que la virtualisation = permet d'isoler chaque service dans son "OS" virtuel sans dupliquer le noyau.
- Le cloud (Infra as a service, Plateforme as a Service, Software as a service) permet de fluidifier l'informatique en alignant chaque niveau d'abstraction d'une pile logicielle avec sa structuration économique sous forme de service.

---


## Prérequis

- Connaître les bases des commandes système Bash et les concepts Linux associés
- Avoir des notions de réseaux TCP/IP
- Savoir lancer des conteneurs Docker
- Avoir des connaissances en automatisation du delivery applicatif (CI/CD, Jenkins, etc.)


---

## Auto-Évaluation

**Pour bien cerner vos compétences, répondre avec**

* 0 Aucune habitude 
* 1 Déjà pratiqué un peu
* 2 Pratique régulière
* 3 Pratique quotidienne
---

1. **Ligne de commande** : Quelle habitude avez-vous de l'utilisation de programmes en ligne de commande ?
2. **Configuration Linux** : Quelle habitude avez-vous de la configuration et de l'installation de packages Linux ?
3. **OS / Process** : Quelle habitude avez-vous du lancement de process dans Linux ?
4. **Réseau** : Quelle habitude avez-vous de la configuration réseau en général ?
5. **Automatisation** : Quelle habitude avez-vous de l'automatisation (Intégration Continue / Déploiement Continu)
6. **Docker Build** : Quelle habitude avez-vous de la construction d'images Docker ?
7. **Docker Services** : Quelle habitude avez-vous de l'utilisation en production d'images Docker  ?
8. **Docker Tooling** : Quelle habitude avez-vous de l'orchestration et du monitoring de services à base d'images Docker  ?
9. **Infrastructures web** : Quelle habitude avez-vous du lancement de services web avec bases de données / code / cache / reverse proxy / etc. ?
10. **Orchestrateurs** : Quelle habitude avez-vous de l'utilisation d'un orchestrateur de services ?
---

## Définition des objectifs

- Connaître le fonctionnement et l’architecture de Kubernetes
- Installer, configurer et administrer Kubernetes
- Mettre en place les bonnes pratiques associées au développement d’une application
déployée dans Kubernetes

---

## Présentation des outils

* Poste virtuel avec accès en SSH ou en HTTP
* Terminal / Ligne de commande 
* Outils liés à Kubernetes 

---


# Contenu
* Présentations
* Présentation du IAC
* Présentation du Devops
* Prérequis
* Auto-Évaluation
* Définition des objectifs
* Présentation des outils
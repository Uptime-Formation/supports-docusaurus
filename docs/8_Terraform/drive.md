
Todo 

* [ ] 60 Doc Terragrunt : Valider que la formation est conforme du début à la fin 
* [x] 120 Doc : Compararer les 3 ouvrages
* [x] 30 Choix des versions 
  * x ] Terragrunt 	>= 0.40.0
  * [x] Terraform =? 1.3.x	

* [X] 120 Déployer un cluster Openstack pour avoir des API
* [x] 120 Développer le flavour terraform de la recette vnc
* [ ] 30/60 Création des comptes AWS stagiaires 
* [ ] 30/120 Repo Déployer un SASS avec Terragrunt
  * Déployer l'infra en cluster d'une appli avec k8s avec 2 environnements
    * dev : cluster minimal
    * prod : real shit
* [ ] 120 Repo Déployer un cluster k8s 
  * Déployer l'infra en cluster d'une appli avec k8s
* [ ] 90 Repo Déployer en intégrant ansible
  * Déployer le code d'une appli avec une DB en local
* [ ] 90 Repo Déployer avec une image packer 
  * Déployer le code d'une appli dans l'image packer avec une clef SSH
* [ ] 60 Repo Déployer un service web avec load balancer
  1. 1 server avec un site dans un bucket (cf. tf.tutorials )
  2. 2 servers 
  3. ALB
* [x] 90/240 Rédiger la journée 1 
* [30] 240 Rédiger la journée 2
* [ ] 60 Faire la grille d'évaluation

Recette K8S
https://developer.hashicorp.com/terraform/tutorials/kubernetes/eks



Documentation
* Terragrunt 
  * Analyse https://www.nearform.com/blog/terraform-tools-terragrunt-terraspace/
  * Code exemple 
    * Officiel
      * https://github.com/zaremba-tomasz/terragrunt-terraform-comparison
      * https://github.com/gruntwork-io/terragrunt-infrastructure-modules-example
    * https://github.com/gruntwork-io/terragrunt-infrastructure-live-example
  * install https://terragrunt.gruntwork.io/docs/getting-started/install/
* Terraform
  * Doc : https://www.terraform.io/docs 
  * install https://developer.hashicorp.com/terraform/
* Ressources pédagogiques
  * https://github.com/brikis98/terraform-up-and-running-code
  * https://github.com/terraform-in-action
  * https://developer.hashicorp.com/terraform/tutorials






#### Concepts de base de Terraform : provider, resource et data

## 1.04 La CLI de Terraform



## 1.0x Les bénéfices de l'infrastructure as code et comparaison des outils d'IAC  

#### Histoire et enjeux de l'IAC 

#### Les différences entre approches IAC 
  * Mutable / Immutable

#### Compositions de solutions

#### Terraform dans tout ça 

## 1.05 Cycle de vie : créer et détruire les ressources

**_Mise en pratique :_** _Déploiement d'un cluster de serveurs web avec un "load balancer"_

**Challenge** Déployer l'exemple AWS sur openstack :
- serveurs
- load balancer
- cert / domaine

######### Terraform, un langage déclaratif polyvalent
## 1.07 Boucles et "If" expressions dans un langage déclaratif comme Terraform
## 1.10 Fonctions intégrées à Terraform
## 1.12 Les ressources au delà des fournisseurs de cloud: fichiers, modèles (templates) et "null\_resource"
## 1.13 Évaluation et point sur la journée 
**_Mise en pratique :_** _Créer une infrastructure multi-tiers, intégration avec le provider Ansible_




## 2.01 Objectifs du jour 
#### Gérer et refactoriser le code et ressources Terraform

## 2.02 Qu'est-ce que l'état Terraform ?
## 2.03 Stocker et partager l'état dans une équipe
## 2.03 Comment gérer les secrets avec Terraform
## 2.0 Bonnes pratiques d'organisation des fichiers et dossiers d'un projet
## 2.0 Qu'est-ce que l'architecture en modules de Terraform ?
## 2.0 Créer, refactorer et réutiliser du code avec des modules

**_Mise en pratique :_** _Déployer un cluster Kubernetes "à la main" avec kubeadm et Terraform_
https://github.com/hobby-kube/provisioning

######### Problématiques de production

## 2.0 Déploiement "Zero-downtime"
## 2.0 Pièges courants de Terraform, difficultés de refactorisation
## 2.0 Tester le code Terraform
## 2.0 Architecture et critères de vérification pour la production

**_Mise en pratique :_** _Utiliser un cadriciel terraform (gruntwork ou terraspace) pour créer un PAAS (plateforme as a service)_

######### Conclusion - Utiliser Terraform en tant qu'équipe

## 2.0 Adopter Terraform dans une équipe
## 2.0 Cadre de travail pour déployer du code applicatif et d'infrastructure
## 2.0 Révision du code et CI/CD
## 2.0 Le "style Terraform"
## 2.13 Évaluation et point sur la formation 


---

## Comparaison des ouvrages

A Terraform in [A]ction
C [C]ookbook
U Terraform [U]p and Running

Bootstrap::HelloWorld A(:3)
Bootstrap::Providers/Plan A(1)
Bootstrap::LifeCycle A(2)
Bootstrap::Variables A(3)
Configuration C(1.1)
CI/CD A(7)
Dependabot (C2.5)
Deploy vs Conf C(2.3)
Diagrams::General A(:i)
Drift A(2.7)
Filters A(2)
Filters::Case C(1.7)
Filters::Chomp C(1.2)
Filters::Replace C(1.6)
Filters::Regex C(1.5)
Filters::Sort C(1.8)
Filters::Trim C(1.4,1.3)
HCL U(2)
Instances A(4) U(2)
Language::Functional A(3)
Layout U(3)
Loops U(5)
Loops::for_each A(7.4)
Modules A(4) U(4)
Modules::Architecture A(5)
Modules::Creating A(6.3)
Modules::Flat vs Nested A(6)
Modules::Production U(8)
Multicloud A(8) U(7)
NET::Subnets C(1.9)
Provider::Custom (11)
Provisioners A(7.4
Refactoring A(10) U(5)
Registry A(4)
Security A(13)
Secrets U(6)
Serverless A(5)
State::Basics A(1)
State::Backends A(6)
Teamwork U(10)
Testing U(9)
Testing::Linting C(2.4)
Terraform Cloud  C(3) A(12)
tfenv U(8)
tfstate U(3)
tfstate::lock U(3)
tfstate::read-only U(3)
tfvars A(4)
validation
versioning U(8)
VCS C(2.3+)
VPC C(2.2)
Why Terraform U(1)
Workspaces A(6) U(3)
Zero Downtime A(9) U(5)


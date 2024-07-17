---
title: "TP Bonus - Intégration Cloud Terraform" 
draft: false
weight: 53
sidebar_class_name: hidden
---

## Cloner le projet modèle

- Pour simplifier le démarrage, clonez le dépôt de base à l'adresse <https://github.com/Uptime-Formation/exo-ansible-cloud>
- ouvrez le projet avec VSCode.

## Infrastructure dans le cloud avec Terraform et Ansible

### Token DigitalOcean et clé SSH

- Pour louer les machines dans le cloud pour ce TP vous aurez besoin d'un compte DigitalOcean : celui du formateur ici mais vous pouvez facilement utiliser le votre. Il faut récupérer les éléments suivant pour utiliser le compte de cloud du formateur:
  - un token d'API DigitalOcean fourni pour la formation. Cela permet de commander des machines auprès de ce provider.

- Récupérez sur git la paire de clés SSH adaptée : 
```bash
cd
git clone https://github.com/e-lie/id_ssh_shared.git
chmod 600 id_ssh_shared/id_ssh_shared
```

- faites `ssh-add ~/id_ssh_shared/id_ssh_shared` pour déverrouiller la clé, **le mot de passe est `trucmuch42`**

### Si vous utilisez votre propre compte
Si vous utilisez votre propre compte, vous aurez besoin d'un token personnel. Pour en créer, allez dans *API > Personal access tokens* et créez un nouveau token. Copiez bien ce token et collez-le dans un fichier par exemple `~/Bureau/compte_digitalocean.txt` (important : détruisez ce token à la fin du TP par sécurité).

- Copiez votre clé SSH (à créer si nécessaire): `cat ~/.ssh/id_ed25519.pub`
- Aller sur DigitalOcean dans la section `Account` de la sidebar puis `Security` et ajoutez un nouvelle clé SSH. Notez sa fingerprint dans le fichier précédent.

### Installer Terraform et le provider Ansible

Terraform est un outil pour décrire une infrastructure de machines virtuelles et ressources IaaS (infrastructure as a service) et les créer (commander). Il s'intègre en particulier avec du cloud commercial comme AWS ou DigitalOcean, mais peut également créer des machines dans un cluster en interne (on premise) (VMWare par exemple) pour créer un cloud mixte.

Terraform peut s'installer à l'aide d'un dépôt ubuntu/debian. Pour l'installer lancez :

```bash
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt install terraform
```

- Testez l'installation avec `terraform --version`

Pour pouvoir se connecter à nos VPS, Ansible doit connaître les adresses IP et le mode de connexion SSH de chaque VPS. Il a donc besoin d'un inventaire.

Jusqu'ici nous avons créé un inventaire statique, c'est-à-dire un fichier qui contenait la liste des machines. Nous allons maintenant utiliser un inventaire dynamique : un programme qui permet de récupérer dynamiquement la liste des machines et leurs adresses en contactant une API.

- L'inventaire dynamique pour Terraform est [https://github.com/nbering/terraform-inventory/](https://github.com/nbering/terraform-inventory/).

### Terraform avec DigitalOcean

- Le fichier qui décrit les VPS et ressources à créer avec Terraform est `provisioner/terraform/main.tf`. Nous allons commenter ensemble ce fichier.

- La documentation pour utiliser Terraform avec DigitalOcean se trouve ici : <https://www.terraform.io/docs/providers/do/index.html>

Pour que Terraform puisse s'identifier auprès de DigitalOcean nous devons renseigner le token et la fingerprint de clé SSH. Pour cela :

- copiez le fichier `terraform.tfvars.dist` et renommez-le en enlevant le `.dist`
- collez le token récupéré précédemment dans le fichier de variables `terraform.tfvars`
- normalement la clé SSH `id_ssh_shared` est déjà configurée au niveau de DigitalOcean. On doit préciser le fingerprint `05:f7:18:15:4a:77:3c:4c:86:70:85:aa:cb:18:b7:68`. Elle sera donc ajoutée aux VPS que nous allons créer.

- Maintenant que ce fichier est complété nous pouvons lancer la création de nos VPS :
  - faisons `cd provisioner/terraform`
  - `terraform init` permet à Terraform de télécharger les "drivers" nécessaires pour s'interfacer avec notre provider. Cette commande crée un dossier `.terraform`
  - `terraform plan` est facultative et permet de calculer et récapituler les créations et modifications de ressources à partir de la description de `main.tf`
  - `terraform apply` permet de déclencher la création des ressources.

- La création prend environ 1 minute.

Maintenant que nous avons des machines dans le cloud nous devons fournir leurs IP à Ansible pour pouvoir les configurer. Pour cela nous allons utiliser un inventaire dynamique.

### Inventaire dynamique Terraform

Une bonne intégration entre Ansible et Terraform permet de décrire précisément les liens entre resource terraform et hote ansible ainsi que les groupes de machines ansible. Pour cela notre binder propose de dupliquer les ressources dans `main.tf` pour créer explicitement les hotes ansible à partir des données dynamiques de terraform.

- Ouvrons à nouveau le fichier `main.tf` pour étudier le mapping entre les ressources digitalocean et leur équivalent Ansible.

- Pour vérifier le fonctionnement de notre inventaire dynamique, allez à la racine du projet et lancez:

```
source .env
./inventory_terraform.py
```

- La seconde commande appelle l'inventaire dynamique et vous renvoie un résultat en JSON décrivant les groupes, variables et adresses IP des machines créées avec Terraform.

- Complétez le `ansible.cfg` avec le chemin de l'inventaire dynamique : `./inventory_terraform.py`

- Utilisez la commande `ansible-inventory --graph` pour afficher l'arbre des groupes et machines de votre inventaire

- Nous pouvons maintenant tester la connexion avec Ansible directement : `ansible all -m ping`.

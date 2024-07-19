---
title: "TP - Un load balancer pour la haute disponibilité et l'orchestration" 
draft: false
weight: 50
---

## Infrastructure multi-tier avec load balancer

<!-- TODO: s'inspirer aussi de https://github.com/geerlingguy/ansible-for-devops/tree/master/deployments-rolling -->

### Cloner le projet modèle

- Pour simplifier le démarrage, clonez le dépôt de base à l'adresse <https://github.com/Uptime-Formation/exo-ansible-cloud>
- ouvrez le projet avec VSCode.

### Provisionner l'infra

#### Utiliser incus manuellement

- Créer des machines `app1`, `app2` et `app3` ubuntu vierges comme précédemment.
- Créer une machine `balancer1` avec almalinux comme dans le TP initial.
- reporter les ip dans le `inventory.cfg` (décommentez les groupes appservers et balancers)
- Vérifiez que l'inventaire est défini à `inventory.cfg` dans le `ansible.cfg`
- tester la connexion avec ping comme précédemment.

#### Utiliser Terraform pour provisionner l'infra structure dans le cloud Digitalocean

- Créez un compte digitalocean si nécessaire et validez un moyen de paiement et vos coordonnées pour pouvoir créer des VMs. N'oubliez pas de les détruire à la fin du tp soit manuellement dans l'interface de digitalocean soit via terraform destroy. Sinon elles seront facturées.

- Créez un token d'identification digitalocean dans la section API, copiez le
- Ajoutez une clé publique par exemple le contenu d'`id_stagiaire.pub` dans les Settings de digitalocean

Dans le dossier `provisionner/terraform`:

- renommez `variables.tfvars.dist` en `variables.tfvars`
- Reportez dans ce fichier le token et la fingerprint de votre clé ssh ajoutée précédement

- Installez l'outil `terraform` (sur ubuntu on peut utiliser `sudo snap install terraform --classic` ou regarder la documentation d'install)

Toujours dans le dossier `provisionner/terraform`:

- Exécutez `terraform init`
- Exécutez `terraform apply`

Retournez à la racine du projet :

- Déverrouilez bien votre clés ssh (`ssh-add` comme d'habitude)
- Exécutez `source .env` pour définir la variable `ANSIBLE_TF_DIR`
- Vérifiez que l'inventaire est défini à `inventory_terraform.py` dans le `ansible.cfg`
- Testez la connexion avec `ansible all -m ping`

ATTENTION !!!!! : bien détruire les machines à la fin avec `terraform destroy`

### Configurer notre infrastructure (playbook `site.yml`):

- Installez les roles avec `ansible-galaxy install -r roles/requirements.yml -p roles`.

- Lancez le playbook global `site.yml`

- Utilisez la commande `ansible-inventory --graph` ou `ansible-inventory --list --yaml` pour afficher l'arbre des groupes et machines de votre inventaire
- Utilisez-la de même pour récupérer l'IP du `balancer0` (ou `balancer1`) avec : `ansible-inventory --host=balancer0`
- Ajoutez `hello.test` dans `/etc/hosts` en pointant vers l'ip de `balancer0`.

- Chargez la page `hello.test`. Le HAPROXY nous redirige vers l'un des backend applicatif (haute disponibilité).

## Mise à jour "Rolling update" de l'application

On veut désactivez un à un les serveurs applicatifs pour les mettre à jour en haute disponibilité. On va pour cela utiliser le playbook : `playbooks/upgrade_apps.yml`

- Observons ensemble l'organisation du code Ansible de notre projet.
  - Nous avons rajouté à notre infrastructure un loadbalancer installé à l'aide du fichier `balancers.yml`
  - Le playbook `upgrade_apps.yml` permet de mettre à jour l'application en respectant sa haute disponibilité. Il s'agit d'une opération d'orchestration simple en utilisant les 3 (+ 1) serveurs de notre infrastructure.
  - Cette opération utilise en particulier `serial` qui permet de d'exécuter séquentiellement un play sur une fraction des serveurs d'un groupe (ici 1 à la fois parmi les 3).
  - Notez également l'usage de `delegate_to` qui permet d'exécuter une tâche sur une autre machine que le groupe initialement ciblé. Cette directive est au coeur des possibilités d'orchestration Ansible en ce qu'elle permet de contacter un autre serveur (déplacement latéral et non pas *master -> node* ) pour récupérer son état ou effectuer une modification avant de continuer l'exécution et donc de coordonner des opérations.


  - notez également le playbook `manually_exclude_backend.yml` qui permet de sortir un backend applicatif du pool. Il s'utilise avec des *vars prompts* (questionnaire) et/ou des variables en ligne de commande.

- Désactivez le noeud qui vient de vous servir la page en utilisant le playbook `manually_exclude_backend.yml` en remplissant le *prompt*. Vous pouvez le réactiver avec `-e backend_name=<noeud à réactiver> -e backend_state=enabled`.

- Rechargez la page : vous constatez que c'est l'autre backend qui a pris le relai.

- Nous allons maintenant mettre à jour avec le playbook d'upgrade, lancez d'abord dans un terminal la commande : `while true; do curl hello.test; echo; sleep 1; done`

---
title: "TP - Simuler un load balancer" 
draft: false
weight: 50
---

## Infrastructure multi-tier avec load balancer

<!-- TODO: s'inspirer aussi de https://github.com/geerlingguy/ansible-for-devops/tree/master/deployments-rolling -->

### Cloner le projet modèle

- Pour simplifier le démarrage, clonez le dépôt de base à l'adresse <https://github.com/Uptime-Formation/exo-ansible-cloud>
- ouvrez le projet avec VSCode.

Pour configurer notre infrastructure:

- Installez les roles avec `ansible-galaxy install -r roles/requirements.yml -p roles`.

- complétez l'inventaire statique (`inventory.cfg`)
- changer dans `ansible.cfg` l'inventaire en `./inventory.cfg`

- Lancez le playbook global `site.yml`

- Utilisez la commande `ansible-inventory --graph` pour afficher l'arbre des groupes et machines de votre inventaire
- Utilisez-la de même pour récupérer l'IP du `balancer0` (ou `balancer1`) avec : `ansible-inventory --host=balancer0`
- Ajoutez `hello.test` dans `/etc/hosts` en pointant vers l'ip de `balancer0`.

- Chargez la page `hello.test`.

- Observons ensemble l'organisation du code Ansible de notre projet.
  - Nous avons rajouté à notre infrastructure un loadbalancer installé à l'aide du fichier `balancers.yml`
  - Le playbook `upgrade_apps.yml` permet de mettre à jour l'application en respectant sa haute disponibilité. Il s'agit d'une opération d'orchestration simple en utilisant les 3 (+ 1) serveurs de notre infrastructure.
  - Cette opération utilise en particulier `serial` qui permet de d'exécuter séquentiellement un play sur une fraction des serveurs d'un groupe (ici 1 à la fois parmi les 3).
  - Notez également l'usage de `delegate` qui permet d'exécuter une tâche sur une autre machine que le groupe initialement ciblé. Cette directive est au coeur des possibilités d'orchestration Ansible en ce qu'elle permet de contacter un autre serveur (déplacement latéral et non pas *master -> node* ) pour récupérer son état ou effectuer une modification avant de continuer l'exécution et donc de coordonner des opérations.
-
  - notez également le playbook `manually_exclude_backend.yml` qui permet de sortir un backend applicatif du pool. Il s'utilise avec des *vars prompts* (questionnaire) et/ou des variables en ligne de commande.

- Désactivez le noeud qui vient de vous servir la page en utilisant le playbook `manually_exclude_backend.yml` en remplissant le *prompt*. Vous pouvez le réactiver avec `-e backend_name=<noeud à réactiver> -e backend_state=enabled`.

- Rechargez la page : vous constatez que c'est l'autre backend qui a pris le relai.

- Nous allons maintenant mettre à jour avec le playbook d'upgrade, lancez d'abord dans un terminal la commande : `while true; do curl hello.test; echo; sleep 1; done`

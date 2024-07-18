---
title: "TP - Mise en place d'Ansible, commandes Ad Hoc et premier playbook"
draft: false
weight: 11
---


## Jouer avec les groupes et inventaires

Reprenez le projet du TP précédent avec VSCode

Ansible cherche la configuration locale dans le dossier courant. Conséquence: on **lance généralement** toutes les commandes ansible depuis **la racine de notre projet**.


- Ansible implique le cas échéant (login avec clé ssh) de déverrouiller la clé ssh pour se connecter à **chaque** hôte. Lorsqu'on en a plusieurs il est donc nécessaire de la déverrouiller en amont avec l'agent ssh pour ne pas perturber l'exécution des commandes ansible. Pour cela : `ssh-add`.

- Créez un groupe `adhoc_lab` et ajoutez les deux machines `ubu1` et  `almalinux1`.

<details><summary>Réponse</summary>

```ini
[all:vars]
ansible_user=stagiaire

[adhoc_lab]
ubu1 ansible_host=<ip>
almalinux1 ansible_host=<ip>
```

</details>

- Lancez `ping` sur les deux machines.

<details><summary>Réponse</summary>

- `ansible adhoc_lab -m ping`

</details>

- Nous avons jusqu'à présent utilisé une connexion ssh par clé et précisé l'utilisateur de connexion dans le fichier `ansible.cfg`. Cependant on peut aussi utiliser une connexion par mot de passe et préciser l'utilisateur et le mot de passe dans l'inventaire ou en lançant la commande.

En précisant les paramètres de connexion dans le playbook il et aussi possible d'avoir des modes de connexion différents pour chaque machine.

## Installons nginx avec quelques modules

- Modifiez l'inventaire pour créer deux sous-groupes de `adhoc_lab`, `almalinux_hosts` et `ubuntu_hosts` avec deux machines dans chacun. (utilisez pour cela `[adhoc_lab:children]`)

```ini
[all:vars]
ansible_user=stagiaire

[ubuntu_hosts]
ubu1 ansible_host=<ip>

[almalinux_hosts]
almalinux1 ansible_host=<ip>

[adhoc_lab:children]
ubuntu_hosts
almalinux_hosts
```

Dans un inventaire ansible on commence toujours par créer les plus petits sous groupes puis on les rassemble en plus grands groupes.

- Pinguer chacun des 3 groupes avec une commande ad hoc.

Nous allons maintenant installer `nginx` sur nos machines. Il y a plusieurs façons d'installer des logiciels grâce à Ansible: en utilisant le gestionnaire de paquets de la distribution ou un gestionnaire spécifique comme `pip` ou `npm`. Chaque méthode dispose d'un module ansible spécifique.

- Si nous voulions installer nginx avec la même commande sur des machines almalinux et ubuntu à la fois, impossible d'utiliser `apt` car almalinux utilise `dnf`. Pour éviter ce problème on peut utiliser le module `package` qui permet d'uniformiser l'installation (pour les cas simples).

- N'hésitez pas consulter extensivement la documentation des modules avec leur exemple ou d'utiliser la commande de documentation `ansible-doc <module>`
  - utilisez `become` pour devenir root avant d'exécuter la commande (cf élévation de privilège dans le cours2)

## Commandes ad-hoc et premier playbook : Installation de Nginx

### Créer un playbook 

- Créons un playbook : ajoutez un fichier `tp1.yml` avec à l'intérieur:

```yaml
- hosts: ubu1
  
  tasks:
    - name: ping
      ping:
```

- Lancez ce playbook avec la commande `ansible-playbook <nom_playbook>`.

- Adaptons ce playbook rudimentaire pour installer `nginx` en remplaçant la partie `tasks:` par:

```yaml
  tasks:
    - name: Ensure nginx present
      package:
        name: nginx
        state: present
```

- Relancez le playbook : la commande d'installation échoue pourquoi ?

<details><summary>Réponse</summary>

L'élévation de privilège est nécessaire lorsqu'on a besoin d'être `root` pour exécuter une commande ou plus généralement qu'on a besoin d'exécuter une commande avec un utilisateur différent de celui utilisé pour la connexion on peut utiliser:

- Au moment de l'exécution l'argument `--become` en ligne de commande avec `ansible`, `ansible-console` ou `ansible-playbook`.
- La section `become: yes`
  - au début du play (après `hosts`) : toutes les tâches seront executée avec cette élévation par défaut.
  - après n'importe quelle tâche : l'élévation concerne uniquement la tâche cible.

</details>

- Lançons la commande équivalente en "ad-hoc" : `ansible adhoc_lab -m package -a "name=nginx state=present"`. Que se passe t'il ?

<details><summary>Réponse</summary>

La commande renvoie SUCCESS en vert pour la machine ubu1 ce qui signifie que nginx est déjà présent. C'est l'idempotence.

Pour almalinux il y echec car le paquet nginx est introuvable... 

</details>

- Pour résoudre le problème sur les hôtes almalinux, installez `epel-release` sur la  machine almalinux.

<details><summary>Réponse</summary>

`ansible almalinux_hosts --become -m package -a "name=epel-release state=present"`

</details>

- Relancez la commande d'installation de `nginx`. Que remarque-t-on ?

<details><summary>Réponse</summary>

`ansible adhoc_lab -m package -a name=nginx state=present`

La machine almalinux a un retour changed jaune alors que la machine ubuntu a un retour ok vert. C'est encore l'idempotence: ansible nous indique que nginx était déjà présent sur le serveur ubuntu.

</details>

### Vérifier l'état du service Nginx

- Utiliser le module `systemd` et l'option `--check` pour vérifier si le service `nginx` est démarré sur chacune des 2 machines. Normalement vous constatez que le service est déjà démarré (par défaut) sur la machine ubuntu et non démarré sur la machine almalinux.

<details><summary>Réponse</summary>

`ansible adhoc_lab --become --check -m systemd -a "name=nginx state=started"`

</details>

- L'option `--check` sert à vérifier l'état des ressources sur les machines mais sans modifier la configuration`. Relancez la commande précédente pour le vérifier. Normalement le retour de la commande est le même (l'ordre peut varier).

- Lancez la commande ou le playbook avec `state` à `stopped` : le retour est inversé.

- Enlevez le `--check` pour vous assurer que le service est démarré sur chacune des machines.

- Visitez dans un navigateur l'ip d'un des hôtes pour voir la page d'accueil nginx.

## Les variables en Ansible, les Ansible Facts et les templates Jinja2

Nous allons faire que la page d'accueil Nginx affiche des données extraites d'Ansible.


- créons un fichier nommé `nginx_index.j2` avec le contenu suivant :

```jinja2
Nom de l'hôte Ansible : {{ ansible_hostname }}
Système d'exploitation : {{ ansible_distribution }} {{ ansible_distribution_version }}
Architecture CPU : {{ ansible_facts['architecture'] }}
```

Ces variables sont des variables issues de l'étape de collecte de *facts* Ansible (si on ne les collecte pas, la task échouera).


### Afficher le template comme page d'accueil Nginx

- Avec la documentation du module `copy:`, copiez le fichier `nginx_index.j2` à l'emplacement de la configuration Nginx par défaut (c'est `/var/www/html/index.html` pour Ubuntu).
<!-- - Assurez-vous que ce fichier ait bien les bons droits de lecture par l'user `www-data`. -->

- En modifiant le module utilisé de `copy:` à `template:` et en réexécutant le playbook avec l'option `--diff`, observez les changements qu'Ansible fait au fichier.


Pour cela nous allons partir à la découverte des variables fournies par Ansible.

### Les Ansible Facts

Dans Ansible, on peut accéder à la variable `ansible_facts` : ce sont les faits récoltés par Ansible sur l'hôte en cours.

Pour explorer chacune de ces variables vous pouvez utiliser le module `debug` dans un playbook:

```yaml
- name: show vars
  debug:
    msg: "{{ ansible_facts }}"
```

Vous pouvez aussi exporter les "facts" d'un hôte en JSON pour plus de lisibilité :
`ansible all -m setup --tree ./ansible_facts_export`

Puis les lire avec `cat ./ansible_facts_export/votremachine.json | jq` (il faut que jq soit installé, sinon tout ouvrir dans VSCode avec `code ./ansible_facts_export`).

- utilisez `jq` pour extraire et visualiser des informations spécifiques à partir du fichier JSON. Par exemple, pour voir le type de virtualisation détecté :

```bash
cat /tmp/ansible_facts/<nom_hôte_ou_IP>.json | jq '.ansible_facts.ansible_virtualization_type'
```

## Ansible et les commandes unix

Il existe trois façon de lancer des commandes unix avec ansible:

- le module `command` utilise python pour lancez la commande.
  - les pipes et syntaxes bash ne fonctionnent pas.
  - il peut executer seulement les binaires.
  - il est cependant recommandé quand c'est possible car il n'est pas perturbé par l'environnement du shell sur les machine et donc plus prévisible.
  
- le module `shell` utilise un module python qui appelle un shell pour lancer une commande.
  - fonctionne comme le lancement d'une commande shell mais utilise un module python.
  
- le module `raw`.
  - exécute une commande ssh brute.
  - ne nécessite pas python sur l'hote : on peut l'utiliser pour installer python justement.
  - ne dispose pas de l'option `creates` pour simuler de l'idempotence.

- Créez un fichier dans `/tmp` avec `touch` et l'un des modules précédents.

- Relancez la commande. Le retour est toujours `changed` car ces modules ne sont pas idempotents.

- Relancer l'un des modules `shell` ou `command` avec `touch` et l'option `creates` pour rendre l'opération idempotente. Ansible détecte alors que le fichier témoin existe et n'exécute pas la commande.

<details><summary>Réponse</summary>

`ansible adhoc_lab --become -m "command touch /tmp/file" -a "creates=/tmp/file"`

ou

```yaml
- name: "On crée"
  command:
    cmd: "touch /tmp/file"
    creates: "/tmp/file"
```

</details>

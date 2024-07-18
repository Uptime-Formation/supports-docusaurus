---
title: "TP - Préparation du lab Ansible avec des conteneurs Incus"
draft: false
weight: 11
---

## Installation de Ansible

- Installez Ansible au niveau du système avec `pip` en lançant:

`sudo apt install ansible`

<!-- ```
$ sudo apt update
$ sudo apt install software-properties-common
$ sudo apt-add-repository --yes --update ppa:ansible/ansible
$ sudo apt install ansible
``` -->
  
- Affichez la version pour vérifier que c'est bien la dernière stable.

```
ansible --version
```

- Traditionnellement lorsqu'on veut vérifier le bon fonctionnement d'une configuration on utilise `ansible all -m ping`. Que signifie-t-elle ?

<details><summary>Réponse</summary>
Cette commande lance le module ansible `ping` (test de connection ansible) sur le groupe all c'est à dire toutes les machines de notre inventaire. Il s'agit d'une commande ad-hoc ansible.
</details>

- Lancez la commande précédente. Que ce passe-t-il ?

<details><summary>Réponse</summary>

```
ansible all -m ping 
```

Cette commande renvoie une erreur car `all` ne matche aucun hôte.
</details>

- Utilisez en plus l'option `-vvv` pour mettre en mode très verbeux. Ce mode est très efficace pour **débugger** lorsqu'une erreur inconnue se présente. Que se passe-t-il avec l'inventaire ?

<details><summary>Réponse</summary>

`ansible all -m ping -vvv

ansible essaye de trouver un inventaire c'est à dire une liste de machine à contacter et cherche par défaut le fichier `/etc/ansible/hosts`. Comme il ne trouve rien il crée un inventaire implicite contenant uniquement localhost.
</details>

- Testez l'installation avec la commande `ansible` en vous connectant à votre machine `localhost` et en utilisant le module `ping`.

<details><summary>Réponse</summary>

```
ansible localhost -m ping
```

La commande échoue car ssh n'est pas configuré sur l'hote mais la machine est contactée (sortie en rouge). Nous allons dans la suite créer des machines de lab avec ssh installé.
</details>

- Ajoutez la ligne `hotelocal ansible_host=127.0.0.1 ansible_connection=local` dans l'inventaire par défaut (le chemin est indiqué dans). Et pinguer hotelocal.

### Autocomplete
```
python3 -m pip install --user argcomplete
activate-global-python-argcomplete --user
```

## Explorer LXD / Incus

LXD est une technologie de conteneurs actuellement promue par Canonical (ubuntu) qui permet de faire des conteneur linux orientés systèmes plutôt qu'application. Par exemple `systemd` est disponible à l'intérieur des conteneurs contrairement aux conteneurs Docker.
Incus est le successeur de LXD, abandonné par ses devs à cause des choix de Canonical.

<!-- LXD est déjà installé et initialisé sur notre ubuntu (sinon `apt install snapd` + `snap install lxd` + ajouter votre utilisateur courant au group unix `lxd`). -->

<!-- Pour initialiser LXD et générer les images de base nous allons utiliser un script bash à lancer avec `bash /opt/lxd.sh`.

(Pour initialiser à la main on peut utiliser la commande `lxd init` mais utilisez plutôt ici la configuration avec le script précédent) -->

- Affichez la liste des conteneurs avec `incus list`. Aucun conteneur ne tourne.
- Maintenant lançons notre premier conteneur `almalinux` avec `incus launch images:almalinux/8/amd64 almalinux1`.
- Listez à nouveau les conteneurs lxc.
- Ce conteneur est un almalinux minimal et n'a donc pas de serveur SSH pour se connecter. Pour lancez des commandes dans le conteneur on utilise une commande LXC pour s'y connecter `incus exec <non_conteneur> -- <commande>`. Dans notre cas nous voulons lancer bash pour ouvrir un shell dans le conteneur : `incus exec almalinux1 -- bash`.
- Nous pouvons installer des logiciels dans le conteneur comme dans une VM. Pour sortir du conteneur on peut simplement utiliser `exit`.

- Un peu comme avec Docker, LXC utilise des images modèles pour créer des conteneurs. Affichez la liste des images avec `incus image list`. Trois images sont disponibles l'image almalinux vide téléchargée et utilisée pour créer almalinux1 et deux autres images préconfigurée `ubuntu_ansible` et `almalinux_ansible`. Ces images contiennent déjà la configuration nécessaire pour être utilisée avec ansible (SSH + Python + Un utilisateur + une clé SSH).

- Supprimez la machine almalinux1 avec `incus stop almalinux1 && incus delete almalinux1` -->

Nous avons besoin d'images Linux configurées avec SSH, Python et un utilisateur de connexion (disposant idéalement d'une clé ssh configurée pour éviter d'avoir à utiliser un mot de passe de connection)

<details><summary>Configurer manuellement des images prêtes pour Ansible</summary>

### Facultatif : Configurer un conteneur pour Ansible manuellement

Si vous devez refaire les travaux pratiques from scratch (sans la VM de TP actuelle et le script de génération lxd.sh), vous pouvez générer les images LXD pour la suite avec les instructions suivantes:

- Connectez vous dans le conteneur avec la commande `incus exec` précédente. Une fois dans le conteneur  lancez les commandes suivantes:

##### Pour almalinux

```bash
# installer SSH
yum update -y && yum install -y openssh-server sudo

systemctl start sshd

# verifier que python2 ou python3 est installé
python --version || python3 --version

## Attention copiez cette commande bien correctement
# configurer sudo pour être sans password
sed -i 's@\(%wheel.*\)ALL@\1 NOPASSWD: ALL@' /etc/sudoers

# Créer votre utilisateur de connexion
useradd -m -s /bin/bash -G wheel votreprenom

# Définission du mot de passe
passwd votreprenom

exit
```

##### Pour ubuntu

```bash
# installer SSH
apt update && apt install -y openssh-server sudo

# verifier que python2 ou python3 est installé
python --version || python3 --version

## Attention copiez cette commande bien correctement
# configurer sudo pour être sans password
sed -i 's@\(%sudo.*\)ALL@\1 NOPASSWD: ALL@' /etc/sudoers

# Créer votre utilisateur de connexion
useradd -m -s /bin/bash -G sudo votreprenom

# Définission du mot de passe
passwd votreprenom

exit
```

#### Copier la clé ssh à l'intérieur

Maintenant nous devons configurer une identité (ou clé) ssh pour pouvoir nous connecter au serveur de façon plus automatique et sécurisée. Cette clé a déjà été créé pour votre utilisateur stagiaire. Il reste à copier la version publique dans le conteneur.

- On copie notre clé dans le conteneur en se connectant en SSH avec `ssh_copy_id`:

```bash
incus list # permet de trouver l'ip du conteneur
ssh-copy-id -i ~/.ssh/id_ed25519 stagiaire@<ip_conteneur>
ssh stagiaire@<ip_conteneur>
```

### Exporter nos conteneurs en image pour pouvoir les multiplier

LXD permet de gérer aisément des snapshots de nos conteneurs sous forme d'images (archive du systeme de fichier + manifeste).

Nous allons maintenant créer snapshots opérationnels de base qui vont nous permettre de construire notre lab d'infrastructure en local.

```bash
incus stop almalinux1
incus publish --alias almalinux_ansible_ready almalinux1
incus image list
```

On peut ensuite lancer autant de conteneur que nécessaire avec la commande launch:

```bash
incus launch almalinux_ansible_ready almalinux2 almalinux3
```

- Une fois l'image exportée faite supprimez les conteneurs.

```bash
incus delete almalinux1 almalinux2 almalinux3 --force
```

</details>


### Lancer et tester les conteneurs

Créons à partir des images du remotes un conteneur ubuntu et un autre almalinux:

```bash
incus launch ubuntu_ansible ubu1
incus launch almalinux_ansible almalinux1
```

- Pour se connecter en SSH nous allons donc utiliser une clé SSH appelée `id_ed25519` qui devrait être présente dans votre dossier `~/.ssh/`. Vérifiez cela en lançant `ls -l /home/stagiaire/.ssh`.

<!-- - Déverrouillez cette clé ssh avec `ssh-add ~/.ssh/id_ed25519` et le mot de passe `devops101` (le ssh-agent doit être démarré dans le shell pour que cette commande fonctionne si ce n'est pas le cas `eval $(ssh-agent)`). -->

- Essayez de vous connecter à `ubu1` et `almalinux1` en ssh pour vérifier que la clé ssh est bien configurée et vérifiez dans chaque machine que le sudo est configuré sans mot de passe avec `sudo -i`.

### Créer un projet de code Ansible pour tester la connection à nos machines

Lorsqu'on développe avec Ansible il est conseillé de le gérer comme un véritable projet de code :

- versionner le projet avec Git
- Ajouter tous les paramètres nécessaires dans un dossier pour être au plus proche du code. Par exemple utiliser un inventaire `inventory.cfg` ou `hosts` et une configuration locale au projet `ansible.cfg`

Nous allons créer un tel projet de code pour la suite du tp1

- Créez un dossier projet `tp1` sur le Bureau.

<details><summary>Facultatif</summary>

- Initialisez le en dépôt git et configurez git:

```
cd tp1
git config --global user.name "<votre nom>"
git config --global user.email "<votre email>"
git init
```

</details>

- Ouvrez Visual Studio Code.
- Installez l'extension Ansible dans VSCode.
- Ouvrez le dossier du projet avec `Open Folder...`

Un projet Ansible implique généralement une configuration Ansible spécifique décrite dans un fichier `ansible.cfg`

- Ajoutez à la racine du projet un tel fichier `ansible.cfg` avec à l'intérieur:

```ini
[defaults]
inventory = ./inventory.cfg
roles_path = ./roles
host_key_checking = false # nécessaire pour les labs ou on créé et supprime des machines constamment avec des signatures SSH changées.
# stdout_callback = yaml
# bin_ansible_callbacks = True
```

- Créez le fichier d'inventaire spécifié dans `ansible.cfg` et ajoutez à l'intérieur notre nouvelle machine `hote1`.
Il faut pour cela lister les conteneurs lxc lancés.

```
incus list # récupérer l'ip de la machine
```

Générez une clé si elle n'existe pas avec `ssh-keygen`.

On va copier cette clé à distance avec `ssh-copy-id`.

Créez et complétez le fichier `inventory.cfg` d'après ce modèle:

```ini
ubu1 ansible_host=<ip>

[all:vars]
ansible_user=stagiaire
```

- Dans le dossier du projet, essayez de lancer la commande ad-hoc `ping` sur cette machine : `ansible all -m ping`

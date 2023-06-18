# TP: Proxmox KVM

**Vous allez suivre le même processus que durant la demo.**

On va utiliser Proxmox pour installer un système.

---

## Connectez-vous au proxmox avec les authentifiants individuels fournis

**Utiliser votre compte pour vous logger sur proxmox**


Proxmox permet de générer toute une hiérarchie de droits d'utilisateurs.

Pour commencer la création de votre machine virtuelle, cliquez sur "`Create VM`".

---

- Choisir un identifiant pour la machine virtuelle

**Créer une nouvelle machine avec l'ID correspondant au numéro de votre compte** 

```

ex: Compte user-1 = Machine numéro 101

```

**Utilisez le ressource pool correspond à votre identifiant**

```

ex: pool-1

```

--- 

- Choisir une image 
--- 

- Choisir les paramètres de virtualisation  
---  

- Démarrer l'instance KVM

--- 

- Installer le système à partir de l'image de base  

Utilisez l'onglet Console de votre machine pour avoir le feedback écran / clavier / souris.

--- 

**Pour Debian**

* Donner une adresse IP v4 avec le dernier octet correspondant au numéro de votre machine 

```shell

Machine     101 
IP          10.10.10.10${numéro de machine}
Masque      255.255.255.0

```

- Créer un compte root avec un mot de passe suffisamment complexe
- Créer un compte utilisateur avec un mot de passe suffisamment complexe
- Finissez l'installation 
  - avec un serveur SSH  
  - sans installer d'environnement graphique
---

**Pour Alpine**

![](/img/qwerty-keyboard.jpg)
- Installer un clavier en français (clavier QWERTY par défaut)
```shell
$ apk add --update kbd-bkeymaps
$ setup-keymap fr fr 
```

- Ajouter un utilisateur et un serveur ssh 
```shell
$ adduser {utilisateur}
$ apk add openssh
```

- Ajouter du réseau via la ligne de commande 
```shell
$ ip a add  10.10.10.10${numéro de machine}/24 dev eth0
$ ip r set default via 10.10.10.1
```
- OU Ajouter du réseau via le système de fichiers
```shell
$ cat << EOF >> /etc/network/interfaces
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static 
  address  10.10.10.10${numéro de machine}/24
  gateway 10.10.10.1
EOF
$ ifup eth0
$ ping 1.1.1.1
$ echo "nameserver 10.10.10.1" > /etc/resolv.conf
$ getent ahosts google.com
```


--- 
- S'y connecter en SSH

Connectez vous à votre machine sur le port "20${numero de machine}"

```shell

# ex: stagiaire@nicolasp.kvm.rackform.eu -p 20102
$ ssh stagiaire@<USER>.<DOMAIN_FORMATION> -p 20<ID>


```

--- 

- Configurer un service sur l'instance

```shell

$ apt install cockpit

```

--- 
- Valider que le service fonctionne

Problème : Comment joindre le service depuis l'extérieur ? 

```shell

$ curl http://<USER>.<DOMAIN_FORMATION>:9090

```
---

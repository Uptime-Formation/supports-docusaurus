# TP: IHM Proxmox 

---

## Objectifs pédagogiques

**Pratiques**

- Opérer des instances KVM via ses IHM
  - Démarrer un nouvel OS invité (VM)

**Vous allez suivre le même processus que durant la demo.**

On va utiliser Proxmox pour installer des VMs via les comptes utilisateurs individuels fournis pour l'instance commune.

Chaque utilisateur va pouvoir créer sa propre machine dans son propre groupe de ressources

---

## Connectez-vous au proxmox avec les authentifiants individuels fournis

**Utiliser votre compte pour vous logger sur proxmox**


Proxmox permet de générer toute une hiérarchie de droits d'utilisateurs.

Pour commencer la création de votre machine virtuelle, cliquez sur "`Create VM`".

---

## Choisir un identifiant pour la machine virtuelle

**Créer une nouvelle machine avec l'ID correspondant au numéro de votre compte** 

```

ex: Compte user-1 = Machine numéro 101

```

**Utilisez le ressource pool correspond à votre identifiant**

```

ex: pool-1

```

--- 

## Choisir une image
 
**Des images ont été préchargées dans le Proxmox.**

Ce sont des images Debian et Alpine, mais on peut installer toutes sortes d'images ISO.

--- 

## Choisir les paramètres de virtualisation

**Pour le moment vous risquez d'être perdu dans certains réglages.**

À la fin de la formation, en principe vous devriez pouvoir comprendre de quoi ils retournent.

Pour le moment laissez-vous guider et utilisez les réglages par défaut.


---  

## Démarrer l'instance KVM

**Une fois la création terminée, votre VM est démarrable.**

Cliquez sur Démarrer si besoin.

--- 

## Lancer le système à partir d'un disque (boot ISO ou import)  

**Utilisez l'onglet Console de votre machine pour avoir le feedback écran / clavier / souris.**

Vous constatez qu'on y accède via un écran virtuel connecté à sa carte graphique virtuelle.

**Ici on va lancer une image ISO d'installation.**

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

![](../../static/img/qwerty-keyboard.jpg)
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
$ ip r add default via 10.10.10.1
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
```

- Ajouter un resolver DNS
`````shell

$ echo "nameserver 10.10.10.1" > /etc/resolv.conf
$ getent ahosts google.com
```


--- 

## S'y connecter en SSH

**Connectez vous à votre machine sur le port "20${numero de machine}"**

```shell

$ ssh <user@><PROXMOX> -p 22<ID>


```

--- 

## Configurer un service sur l'instance

**Pour une debian**

```shell

$ apt install cockpit

```

**Pour alpine**

```shell
$ setup-apkrepos
$ apk add nginx 
# Changer le numéro de port 80 en 9090
$ vi /etc/nginx/http.d/default.conf
$ echo "auto lo" > /etc/network/interfaces
$ service nginx start
```

--- 
## Valider que le service fonctionne

Problème : Comment joindre le service depuis l'extérieur ? 

```shell

$ curl http://<USER>.<DOMAIN_FORMATION>:9{id}

```
---

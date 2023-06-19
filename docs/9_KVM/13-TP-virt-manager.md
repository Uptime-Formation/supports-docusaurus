# TP : IHM virt-manager 

## Objectifs pédagogiques

**Pratiques**

- Installer KVM et ses IHM
- Opérer des instances KVM via ses IHM
  - Démarrer un nouvel OS invité (VM)
  - Configurer le réseau dans KVM (NAT, libvirt, bridge, etc.)
  - Maîtriser le stockage (pool, volume, chiffrement, virtfs)

---



## Lancez virt-manager


**Virt-Manager est une application fenêtrée pour gérer les machines virtuelles.** 

Localement ou à distance, elle offre la possibilité de 
- contrôler le cycle de vie des machines existantes (bootup / arrêt, pause, suspendre / restaurer)
- fournir de nouvelles machines virtuelles 
- gérer les réseaux virtuels, 
- accéder à la console graphique des machines virtuelles 
- afficher les performances

---

**virt-manager fait partie de la même suite d'outil que virt-builder ou virt-install**
- `virt-install` fournit un moyen facile de provisionner les systèmes d'exploitation dans des machines virtuelles.

- `virt-viewer` est une interface d'interface utilisateur légère pour interagir avec l'affichage graphique du système d'exploitation virtualisé. Il peut afficher VNC ou SPICE, et utilise LibVirt pour rechercher les détails de la connexion graphique.

- `virt-clone` pour cloner les invités inactifs existants. Il copie les images de disque et définit une configuration avec un nouveau nom, UUID et l'adresse MAC pointant vers les disques copiés.

- `virt-xml` pour éditer facilement le domaine LibVirt XML à l'aide des options de ligne de commande de Virgin-stall.

- `virt-bootstrap` offrant un moyen facile de configurer le système de fichiers racine pour les conteneurs basés sur LiBVirt.

--- 
**virt-manager utilise `libvirt` comme de nombreuses autres IHM.**

Le mode de fonctionnement de libvirt et ses IHM sont très importants à comprendre pour comprendre QEMU/KVM.

---

## Installation et exploration de virt-manager

**C'est une solution très légère qui utilise des scripts Python pour piloter les VMs.** 

```shell
$ apt install virt-manager 
$ dpkg -L virt-manager
```

--- 

**Le principe est simple : on peut piloter les machines locales à condition que librvirt soit installé -- et QEMU/KVM pour piloter des VMs.**

La "connexion locale" permet de piloter les machines présentes sur le host où l'application desktop est installée. 

---

**On peut ajouter des connexions vers d'autres hôtes avec différents protocoles.**

virt-manager bénéficie des mêmes API de contreôle que libvirt, lui permettant de piloter

- QEMU-KVM 
- QEMU-KVM (session utilisateur)

mais aussi
- Xen
- Libvirt-LXC
- Virtuozzo

--- 

**La connexion à un hôte distant se fait en utilisant SSH**

Les communications nécessaires aux opérations distantes passeront par ce canal chiffré.

Essayer de créer un compte distant avec un des comptes fournis.

---

**Les détails d'une connexion locale ou distante permettent d'afficher les informations essentielles à l'exécution**

On y accède via le menu ou un clic droit sur l'instance.

Ces informations sont en particulier :

- les graphiques d'utilisation RAM / CPU
- les réseaux 
- les stockages

---

## Création d'une nouvelle VM

**Clique sur le bouton de création d'une nouvelle machine.** 

* Donner un nom à la machine ex: guest1
* Choisir une mise à disposition 
  * via une ISO
  * OU via une URL
    * **Debian** https://deb.debian.org/debian/dists/stable/main/installer-amd64/
    * **Suse** https://download.opensuse.org/pub/opensuse/distribution/leap/42.3/repo/oss/
* Choisir le type de distribution adapté
* Choisir les options par défaut
* Lancer la création de la machine : une nouvelle fenêtre apparaît

--- 

**Quand la création est en cours, vous accédez à l'écran de la VM.**

En utilisant les menus de la fenêtre, vous pouvez observer que vous avez accès :
- à la gestion du cycle de vie de la VM (également avec un clic droit dans l'interface principale)
- aux détails des composants physiques de la VM

--- 

## Mettre en place un nouveau réseau 

**Il est tout à fait possible de créer d’autres réseaux afin par exemple de simuler plusieurs réseaux locaux.** 

Ces réseaux peuvent être totalement isolés ou encore acheminés vers le réseau de l’hôte en mode NAT ou bridge. 

--- 

**Dans l'instance locale, aller dans l’onglet Réseaux virtuels (menu "Détails").**

- créer un nouveau réseau avec le nom mynet0
- choisir la plage d’adresses IP desservie par ce réseau ex: 172.16.122.0/24
  - Q: Connaissez-vous les différents blocs 'RFC1918' ? 
- Activer le serveur DHCP dédié en définissant la plage DHCP de votre choix
- Choisir le réseau virtuel isolé 
- Valider
- Le nouveau réseau apparaît dans la liste des réseaux disponibles

---

**Dans la machine hôte, une nouvelle interface est apparue**

```shell

$ ip link show

```
C'est elle (le bridge) qui porte le réseau fermé que l'on vient de créer.  
# TP : IHM Virsh

## Objectifs pédagogiques

**Théoriques**

- Connaître les IHM permettant de piloter KVM

**Pratiques**

- Opérer des instances KVM via ses IHM
  - Démarrer un nouvel OS invité (VM)
  - Configurer le réseau dans KVM (NAT, libvirt, bridge, etc.)

**Stratégiques**

- Savoir choisir KVM comme outil d'architecture en fonction de critères rationnels.

**Pour récupérer des informations sur les machines virtuelles (VM) sur votre hôte et leurs configurations, utilisez une ou plusieurs des commandes suivantes.**

### Aide 

```shell
# Plus de 260 commandes disponibles dans virsh
$ virsh help

# Dont plus de 100 rien que pour le "domain"
$ virsh help domain  
```

### Liste des VM

Pour obtenir une liste des VM sur votre hébergeur

```shell


$ virsh list --all

```

### Info sur une VM 


```shell

$ virsh dominfo testguest1

```

### Afficher la configuration d'une VM 

```shell

$ virsh dumpxml testguest2

```

### Afficher des informations sur les disques et autres périphériques de bloc d'une VM

```shell

$ virsh domblklist testguest3

```

---

### Obtenir des informations sur les systèmes de fichiers d'une VM et leurs points de montage

```shell

$ virsh domfsinfo testguest3

```
### Obtenir des informations sur les processeurs d'une VM
---

```shell

$ virsh vcpuinfo testguest4

```

---


### Répertorier toutes les interfaces réseau virtuelles sur votre hôte

```shell

$ virsh net-list --all

```

----

### Pour plus d'informations sur une interface spécifique

```shell

$ virsh net-info default

```

---

## Sauvegarder une VM

**Vous pouvez enregistrer une machine virtuelle (VM) et son état actuel sur le disque de l'hôte.**

Ceci est utile, par exemple, lorsque vous devez utiliser les ressources de l'hôte à d'autres fins. La machine virtuelle enregistrée peut ensuite être rapidement restaurée à son état de fonctionnement précédent.

```shell

$ virsh managedsave demo-guest1
$ virsh list --managed-save --all
$ virsh list --with-managed-save --all

```

--- 

## Supprimer une VM

```shell

$ virsh destroy guest1
$ virsh undefine guest1 

```

---

## Créer une VM

Virt

```shell
$  virt-install --install fedora29 --unattended --graphics none 
```
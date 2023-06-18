# Demo: Proxmox  

## Objectifs pédagogiques

**Théoriques**

- Connaître les spécificités de la virtualisation KVM
- Connaître les IHM permettant de piloter KVM


## Proxmox 

![](../../static/img/kvm/kvm-proxmox-logo.png)

**Proxmox Virtual Environnement est une solution de virtualisation libre (licence AGPLv3) basée sur l'hyperviseur Linux KVM, et offre aussi une solution de conteneurs avec LXC.**

Elle est fournie avec un packaging par Proxmox Server Solutions GmbH et propose un support payant.

Documentation : 
  * https://www.proxmox.com/

---
    
## Objectifs pédagogique 

- Opérer des instances KVM via ses IHM

---

## Les opérations 

- Choisir un identifiant pour la machine virtuelle
- Choisir une image 
- Choisir les paramètres de virtualisation  
- Démarrer l'instance KVM  
- Lancer le système à partir d'un disque (boot ISO ou import)  
- S'y connecter en SSH
- Configurer un service sur l'instance
- Valider que le service fonctionne

--- 

## Identification de KVM dans le kernel 

--- 

### Les processeurs

```shell

$ egrep --color 'svm|vmx'  /proc/cpuinfo

# SVM => AMD machines
# VMX => Intel

```  

### Les composants 

```shell

$ lspci

...
00:03.0 Unclassified device [00ff]: Red Hat, Inc. Virtio memory balloon
00:05.0 PCI bridge: Red Hat, Inc. QEMU PCI-PCI bridge
00:12.0 Ethernet controller: Red Hat, Inc. Virtio network device
00:1e.0 PCI bridge: Red Hat, Inc. QEMU PCI-PCI bridge
00:1f.0 PCI bridge: Red Hat, Inc. QEMU PCI-PCI bridge
01:01.0 SCSI storage controller: Red Hat, Inc. Virtio SCSI


```

### Les modules kvm

```shell

$ lsmod | grep ^kvm

```

---

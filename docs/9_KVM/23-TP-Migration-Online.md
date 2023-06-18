# TP: Migration Online 

## Objectifs pédagogiques

## Objectifs pédagogiques

**Pratiques**

- Opérer des instances KVM via ses IHM
  - Démarrer un nouvel OS invité (VM)

**Stratégiques**

- Savoir choisir KVM comme outil d'architecture en fonction de critères rationnels.

**Pour migrer une instance sans stockage partagé, utilisez les étapes suivantes:**

---

## Instance active 

**Assurez-vous que l'invité KVM est en cours d'exécution:**

```shell
kvm1:~# virsh list --all
 Id   Name              State
----------------------------------------------------
 33   kvm_no_sharedfs   running

```
---

## Identification du stockage de l'image

**Trouvez l'emplacement du fichier image:**

```shell
kvm1:~# virsh dumpxml kvm_no_sharedfs | grep "source file"
 <source file='/tmp/kvm_no_sharedfs.img'/>
```
---

## Transfert 

**Transférer le fichier image vers l'hôte de destination:**
```shell

kvm1:~# scp /tmp/kvm_no_sharedfs.img kvm2:/tmp/
kvm_no_sharedfs.img 100% 5120MB 243.8MB/s 00:21
```
---

## Migration
**Migrez l'instance et assurez-vous qu'elle s'exécute sur l'hôte de destination:**
```shell

kvm1:~# virsh migrate --live --persistent --verbose --copy-storage-all kvm_no_sharedfs qemu+ssh://kvm2/system
Migration: [100 %]
kvm1:~# virsh list --all
 Id     Name               State
----------------------------------------------------
 -      kvm_no_sharedfs    shut off

kvm1:~# virsh --connect qemu+ssh://kvm2/system list --all
 Id     Name               State
----------------------------------------------------
 17     kvm_no_sharedfs    running
```

---

## Migration inverse 
Depuis l'hôte de destination, migrez l'instance en arrière, en utilisant le transfert d'image incrémentiel:
```shell

kvm2:~# virsh migrate --live --persistent --verbose --copy-storage-inc kvm_no_sharedfs qemu+ssh://kvm/system
Migration: [100 %]
```

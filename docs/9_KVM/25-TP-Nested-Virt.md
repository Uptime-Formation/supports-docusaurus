
## Objectifs pédagogiques

**Théoriques**

- Connaître les spécificités de la virtualisation KVM

**Pratiques**

- Opérer des instances KVM via ses IHM
  - Démarrer un nouvel OS invité (VM)

**Stratégiques**

- Savoir choisir KVM comme outil d'architecture en fonction de critères rationnels.

# TP Nested Virtualization

Dans une machine virtuelle Proxmox ou autre, on va lancer une autre machine virtuelle.

Changer le type de CPU.

On va utiliser un CPU "physique" pour lancer un KVM dans notre machine virtuelle.

```shell

$ cat /etc/modprobe.d/kvm_amd.conf
options kvm-intel nested=1
options kvm-intel enable_shadow_vmcs=1
options kvm-intel enable_apicv=1
options kvm-intel ept=1

```
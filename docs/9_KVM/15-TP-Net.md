# TP : Réseau routé


## Objectifs pédagogiques

**Pratiques**

- Opérer des instances KVM via ses IHM
  - Configurer le réseau dans KVM (NAT, libvirt, bridge, etc.)

**Stratégiques**

- Savoir choisir KVM comme outil d'architecture en fonction de critères rationnels.
## Réseau par défaut

```shell
$ apt install qemu qemu-kvm libvirt-clients libvirt-daemon-system virtinst bridge-utils virt-manager

$ cat /etc/libvirt/qemu/networks/default.xml

<network>  
  <name>default</name>  
  <uuid>05c663c4-85f9-4886-9483-f38f68d96e36</uuid>  
  <bridge name="virbr0" />  
  <mac address='52:54:00:4:23:D5'/>  
  <forward/>  
  <ip address="192.168.122.1" netmask="255.255.255.0">  
    <dhcp>  
      <range start="192.168.122.2" end="192.168.122.254" />  
    </dhcp>  
  </ip>  
</network>

```

## Création du réseau : fichier de configuration

```shell
cat <<EOF > routed225.xml
<network>
  <name>routed225</name>
  <forward mode='route' dev='br0'/>
  <bridge name='virbr225' stp='on' delay='2'/>
  <ip address='192.168.225.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='192.168.225.141' end='192.168.225.254'/>
      <host name='myclone3' ip='192.168.225.143'/>
    </dhcp>
  </ip>
</network>
EOF
```


---

## Création du réseau

```shell

$ virsh net-define routed225.xml
$ virsh net-start routed225
$ virsh net-autostart routed225

```

---

## 

```shell

$ virt-install \
    --name centos \
    --memory 2048 \
    --vcpus 2 \
    --disk /var/lib/libvirt/images/centosstream-8.qcow2,bus=sata \
    --import \
    --os-variant centos8  \
    --graphics none \
    --network network=routed225,model=virtio,driver.iommu=on

```
---

## 

```shell

$ iptables -t nat -A POSTROUTING -j MASQUERADE

```

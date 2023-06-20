# TP : Réseau routé


## Objectifs pédagogiques

**Pratiques**

- Opérer des instances KVM via ses IHM
  - Configurer le réseau dans KVM (NAT, libvirt, bridge, etc.)

**Stratégiques**

- Savoir choisir KVM comme outil d'architecture en fonction de critères rationnels.

## Réseau par défaut

**Un réseau est crée par défaut lorsque vous installez QEMU**

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

**On va créer un autre réseau qui prendra en charge le routage directement.**

```shell
cat <<EOF > routed225.xml
<network>
  <name>routed225</name>
  <forward mode='route' dev='{INTERFACE:ens2?}'/>
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

**Avec virsh on va charger ce nouveau réseau.**

```shell

$ virsh net-define routed225.xml
$ virsh net-start routed225
$ virsh net-autostart routed225

```

--- 

## Des règles iptables ont été crées 

```shell


$ iptable-save

```
## S'assurer que l'hote est OK pour forwarder les paquets

```shell

$ cat  /proc/sys/net/ipv4/ip_forward 
$ sudo sysctl -w net.ipv4.ip_forward=1
$ iptables -P FORWARD ACCEPT

```

---

## Démarrer une machine dans ce réseau

```shell

$ virt-builder centos-8.0 -o /var/lib/libvirt/images/centosstream-8.qcow2

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

## En cas de problèmes...

**On peut utiliser différentes solutions pour débugger le réseau.**


```shell

# S'assurer que les règles de NAT MASQUERADE sont OK
$ iptables-save
$ iptables -t nat -s 192.168.225.0/24 -A POSTROUTING -j MASQUERADE

# Utiliser tcpdump 
$ apt install tcpdump
$ tcpdump -i any host 1.1.1.1
root@guest: ping 1.1.1.1


```

---
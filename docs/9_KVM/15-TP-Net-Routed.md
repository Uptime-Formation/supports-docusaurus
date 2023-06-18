# TP : Router Network

## Création du réseau : fichier

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

$ virt-install --name centos --memory 2048 --vcpus 2 --disk /var/lib/libvirt/images/centosstream-8.qcow2,bus=sata --import --os-variant centos8  --graphics none --network network=routed225,model=virtio,driver.iommu=on

```
---

## 

```shell

$ iptables -t nat -A POSTROUTING -j MASQUERADE

```
---

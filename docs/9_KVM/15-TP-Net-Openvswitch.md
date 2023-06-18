# TP Réseau : Open vSwitch 


```shell
# Si besoin des dépendances 
$ apt update
$ apt install -y qemu-kvm virtinst libvirt-clients guestfs-tools libvirt-daemon-system
$ apt install -y  openvswitch-switch 
$ systemctl status openvswitch-switch.service
$ lsmod | grep switch
$ ovs-vsctl show

```
---


```shell

$ ovs-vsctl add-br br-ex0
$ ovs-vsctl show
$ ip a add 192.168.122.1/24 dev br-ex0

```
---



```shell 

$ echo "net.ipv4.ip_forward=1" | tee -a /etc/sysctl.conf
$ echo "net.ipv4.conf.all.rp_filter = 2"| tee -a  /etc/sysctl.conf
$ sysctl -p
```
---


```shell

$ virt-builder centosstream-8 --format qcow2 \
  -o /var/lib/libvirt/images/centosstream-8.qcow2 \
  --root-password password:StrongRootPassword
```
---


```shell

$ virt-install \
  --name centosstream-8 \
  --ram 2048 \
  --disk path=/var/lib/libvirt/images/centosstream-8.qcow2 \
  --vcpus 1 \
  --os-type linux \
  --os-variant rhel8.0 \
  --network=bridge:br-ex0,model=virtio,virtualport_type=openvswitch \
  --graphics none \
  --serial pty \
  --console pty \
  --boot hd \
  --import
```
---


```shell
$ ip -br -c a 
$ ip a add 192.168.122.122/24 dev {dev}
$ ping 192.168.122.1
$ ip r add default via 192.168.122.1
$ ping 1.1.1.1
```
---



```shell
$ iptables -t nat -A POSTROUTING -s 192..168.122.0/24 -j MASQUERADE
```
---


```shell

iptables -A FORWARD -i <interface réseau interne> -o <interface réseau externe> -j REJECT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -m state --state NEW -i ! <interface réseau interne> -j ACCEPT
iptables -P INPUT DROP

```
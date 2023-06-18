# TP: Cluster Proxmox

## Objectifs pédagogiques

**Théoriques**

- Connaître les IHM permettant de piloter KVM

**Pratiques**

- Installer KVM et ses IHM

- **Stratégiques**

- Savoir choisir KVM comme outil d'architecture en fonction de critères rationnels.

**Ce TP avancé consiste à monter son propre Proxmox puis de le convertir en cluster.**

---


```shell


apt install -y ansible vim git sudo isc-dhcp-server

ansible-galaxy install lae.proxmox

cat << EOF > /root/proxmox.yml
---
#Playbook hyperviseur
- name: "Playbook hyperviseur Proxmox"
  hosts: localhost
  become: yes
  roles:
    - role: lae.proxmox
      pve_datacenter_cfg:
        keyboard: fr-FR
      pve_groups:
      - name: Admins
        comment: Administrators of this PVE cluster
      - name: Clients
        comment: Groupes Clients
      pve_users:
        - name: root@pam
          email: alban@rackflow.io
#        - name: user1@pam
#          email: blabla0@atomit.fr
#          groups: [ "Admins" ]
#        - name: user2@pve
#          email: blabla1@gmail.com
#          firstname: user2
#          lastname: user2
#          password: "user2"
#          groups: [ "Clients" ]
      pve_acls: # This should generate different ACLs
        - path: /
          roles: [ "Administrator" ]
          groups: [ "Admins" ]
        - path: /vms
          roles: [ "PVEVMUser" ]
          groups: [ "Clients" ]
      pve_storages:
        - name: data
          type: lvmthin
          content: [ "images", "rootdir" ]
          vgname: debian-vg
          thinpool: data-vms
      pve_reboot_on_kernel_update: yes
EOF

echo localhost > ansible.hosts

ansible-playbook -i ansible.hosts proxmox.yml

````

---

## Monter un cluster de proxmox 

La documentation complète est ici :

> https://pve.proxmox.com/wiki/Cluster_Manager

---

## Faire marcher le host comme routeur 

```shell

sed -i -r 's/listen-on \{ 127.0.0.1; \};/listen-on \{ 127.0.0.1; 10.10.10.1;\};/' /etc/bind/named.conf.options

service bind9 restart

cat << EOF > /etc/dhcpd.conf
option domain-name "kvm.rackform.eu";
option domain-name-servers 10.10.10.1;

default-lease-time 600;
max-lease-time 7200;

ddns-update-style none;

subnet 10.10.10.0 netmask 255.255.255.0 {
  range 10.10.10.50 10.10.10.99;
  option routers 10.10.10.1;
}

EOF

cat <<EOF >/etc/default/isc-dhcp-server
INTERFACESv4="vmbr0"
INTERFACESv6=""
EOF

systemctl restart isc-dhcp-server

cat <<EOF > /etc/network/if-up.d/SNAT
#!/bin/sh -e
if iptables -t nat -C PREROUTING -p tcp -m tcp --dport 22100 -j DNAT --to-destination 10.10.10.100:22; then exit; fi
for f in {100..110}; do iptables -t nat -A PREROUTING -p tcp -m tcp --dport 22${f} -j DNAT --to-destination 10.10.10.$f:22; done
EOF

cat <<EOF > /etc/network/if-down.d/SNAT
#!/bin/sh -e
if iptables -t nat -C PREROUTING -p tcp -m tcp --dport 22100 -j DNAT --to-destination 10.10.10.100:22; then exit; fi
for f in {100..110}; do iptables -t nat -A PREROUTING -p tcp -m tcp --dport 9${f} -j DNAT --to-destination 10.10.10.$f:9090; done
EOF

chmod +x /etc/network/if-*.d/SNAT
# qemu-agent
# add comma between 'TAG+="systemd"' and 'ENV{SYSTEMD_WANTS}="qemu-guest-agent.service"' in
# /lib/udev/rules.d/60-qemu-guest-agent.rules.

exit

for N in 2; do
  pveum group add group-$N -comment "Some group"
  pveum pool add pool-$N --comment "User pool"
  pveum user add user-$N@pve -group group-$N -password MyPass-$N
  pveum acl modify /pool/pool-$N -group group-$N -role PVEAdmin
  pveum acl modify /storage/local -group group-$N -role PVEAdmin
  pveum acl modify  /vms/$((100 + $N ))  -group group-$N -role PVEAdmin
done



for N in 1  2 ; do
  pveum user delete user-$N@pve
  pveum group delete group-$N
  pveum pool delete pool-$N
done

```
---
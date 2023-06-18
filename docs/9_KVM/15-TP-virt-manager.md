# TP : Réseau NAT 

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

## Lancez virt-manager




Il est tout à fait possible de créer d’autres réseaux afin par exemple de simuler plusieurs réseaux locaux. Ces réseaux peuvent être totalement isolés ou encore acheminés vers le réseau de l’hôte en mode NAT ou bridge. Dans cet exemple, un second réseau nommé net0 desservant la plage IP 192.168.100/24 va être mis en place. Depuis l’interface virt-manager, après un clic droit sur l’hyperviseur local, choisissez l’option Détails puis l’onglet Réseaux virtuels.


Dans cette fenêtre, cliquez sur le bouton + en bas à gauche. L’écran suivant n’est qu’informatif, cliquez sur Suivant.


La fenêtre qui suit permet de nommer le réseau, ici "net0". Le choix du nom est libre. Poursuivez en cliquant sur Suivant.


L’écran suivant permet de définir la plage d’adresses IP desservie par ce réseau. La valeur par défaut est 192.168.100/24. Comme indiqué, il est souhaitable d’utiliser pour ce réseau des adresses non routables. Comme cette valeur convient, cliquez simplement sur Suivant.


Il est possible d’avoir sur ce réseau un serveur DHCP dédié. L’écran présenté permet de définir l’étendue DHCP et son activation. Ici, la plage va de 192.168.100.128 à 192.168.100.254. Validez ceci par Suivant.


La dernière étape consiste à définir si le réseau est isolé ou en relation avec le réseau de l’hôte. La relation avec l’hôte peut se faire en NAT ou être routée (bridge). Ici, conservons la valeur Réseau virtuel isolé.


L’écran suivant est informatif et récapitule la configuration.


De retour dans l’interface virt-manager, on note la présence d’un second réseau virtuel.


En ouvrant un terminal et via la commande ifconfig, une nouvelle interface (virbr1) est mise en place sur le réseau IP 192.168.100.0/24.
# TP Routed Net 

## Configuration du réseau 

**Pour configurer le réseau il y a plusieurs options**

* Définir une configuration IP statique
* Obtenir une configuration IP dynamique (DHCP)

**Vous devez dans tous les cas identifier le range IP défini pour votre réseau.**

--- 

**Pour chaque option on peut le faire**

* via un fichier de configuration `/etc/network/interfaces`
* via la ligne de commande (`ip`, `resolv.conf`)

--- 

### Configuration IP statique 

**via la ligne de commande** 

```shell

$ ip a add XXX.XXX.XXX.XXX/xx dev XXX
$ ip r add default via XXX.XXX.XXX.XXX
$ echo "nameserve XXX.XXX.XXX.XXX" > /etc/resolv.conf

```
---

**via le fichier interfaces**

```shell

auto lo
iface etho inet loopback

auto eth0
iface eth0 inet static
  address XXX.XXX.XXX.XXX/24
  gateway XXX.XXX.XXX.XXX
  dns-nameservers XXX.XXX.XXX.XXX

```

Puis utiliser la commande 

```

$ ifup xxx

``` 
---


### Configuration IP dynamique


**via la ligne de commande**

```shell
$ apk add dhclient
$ dhclient XXX

```

**via le fichier interfaces et ifup**

```shell

auto lo
iface etho inet loopback

auto eth0
iface eth0 inet dhcp

```

Est-ce que ça marche ? pourquoi ? 

---

**Ajouter le serveur DHCP sur la machine hôte.**

```shell

$ apt install isc-dhcp-server
$ cat << EOF > /etc/dhcp/dhcpd.conf
default-lease-time XXX;
max-lease-time XXX;
ddns-update-style none;
subnet XXX.XXX.XXX.0 netmask XXX.XXX.XXX.0 {
  range XXX.XXX.XXX.1 XXX.XXX.XXX.XXX;
  option routers XXX.XXX.XXX.1;
  option  domain-name-servers XXX.XXX.XXX.1;
}
EOF
$ systemctl restart isc-dhcp-server

```
--- 

**Puis relancez la configuration automatique sur la VM.**

```shell
$ ifdown eth0
$ ifup eth0

```


--- 

## Avancé 

**Peut-on ajouter d'autres interfaces réseau à la VM? Et à la Machine Hôte?**

**Quels sont les opérations à suivre? Quels sont les avantages / inconvénients?**
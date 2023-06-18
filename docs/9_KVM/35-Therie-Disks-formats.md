# Théorie : QEMU et les montages 

## Objectifs pédagogiques

**Théoriques**

- Connaître les spécificités de la virtualisation KVM
- Connaître les contraintes opérationnelles de KVM en production

---

## Verrouillage du fichier image disque

**Par défaut, QEMU essaie de protéger les fichiers image contre les accès simultanés inattendus, tant qu'ils sont pris en charge par le pilote de protocole de bloc et le système d'exploitation hôte.** 

Si plusieurs processus QEMU (y compris les émulateurs et utilitaires QEMU) tentent d'ouvrir la même image avec des modes d'accès en conflit, tous sauf le premier obtiendront une erreur.


---

## Formats de fichier d'image disque

**QEMU prend en charge de nombreux formats de fichiers image pouvant être utilisés avec des machines virtuelles ainsi qu'avec l'un des outils (comme qemu-img).** 

Cela inclut les formats préférés raw et qcow2 ainsi que les formats pris en charge pour la compatibilité avec les anciennes versions de QEMU ou d'autres hyperviseurs.

Documentation:
- https://www.qemu.org/docs/master/system/images.html

---

### raw

**Format d'image disque brut.**

 Ce format a l'avantage d'être simple et facilement exportable vers tous les autres émulateurs.

 Si votre système de fichiers prend en charge les trous (par exemple dans ext2 ou ext3 sous Linux ou NTFS sous Windows), seuls les secteurs écrits réserveront de l'espace.

Utilisez `qemu-img info` pour connaître la taille réelle utilisée par l'image ou ls -ls sous Unix/Linux.

---


### qcow2

**Format d'image QEMU, le format le plus polyvalent.**

Utilisez-le pour avoir des images plus petites (utile si votre système de fichiers ne prend pas en charge les trous, par exemple sous Windows), une compression basée sur zlib et la prise en charge de plusieurs instantanés de VM.

---

### Autres formats 

- **qed** : Ancien format d'image QEMU avec prise en charge des fichiers de sauvegarde et des fichiers image compacts (lorsque votre système de fichiers ou votre support de transport ne prend pas en charge les trous).
- **qcow** : Ancien format d'image QEMU avec prise en charge des fichiers de sauvegarde, des fichiers image compacts, du chiffrement et de la compression.
- **luks** : Format de cryptage LUKS v1, compatible avec Linux dm-crypt/cryptsetup
- **vdi** : Format d'image compatible avec VirtualBox 1.1.
- **vmdk** :Format d'image compatible VMware 3 et 4.
- **vpc** : Format d'image compatible VirtualPC (VHD).
- **VHDX** : Image compatible Hyper-V

Il existe en plus des formats read-only 

- bochs
- cloop
- dmg
- parallels

---

### Montage de périphériques de disques 

**En plus des fichiers d'image disque, QEMU peut accéder directement aux appareils hôtes.**

--- 


#### Linux

**Sur Linux, vous pouvez utiliser directement le nom de fichier du périphérique hôte au lieu d'un nom de fichier d'image disque à condition que vous ayez suffisamment de privilèges pour y accéder.**

* **CDRom**  :Vous pouvez spécifier un périphérique CDROM même si aucun CDROM n'est chargé. Qemu a un code spécifique pour détecter l'insertion ou la suppression de CDROM.
* **Disquette** : Vous pouvez spécifier un périphérique de disquette même si aucune disquette n'est chargée.
* **Disques durs** : Les disques durs peuvent être utilisés. 

> Normalement, vous devez spécifier l'intégralité du disque (/ dev / hdb au lieu de / dev / hdb1) afin que le système d'exploitation invité puisse le voir comme un disque partitionné. Avertissement: à moins que vous ne sachiez ce que vous faites, il est préférable de ne faire que des accès en lecture seule au disque dur, sinon vous pouvez corrompre vos données hôtes (utilisez l'option de ligne de commande -snapshot ou modifiez les autorisations de l'appareil en conséquence).
--- 

#### Windows 

* **CD** : La syntaxe préférée est la lettre d'entraînement (par exemple D :). La syntaxe alternative \\. \ D: est prise en charge.
* **Disques durs** : Les disques durs peuvent être utilisés avec la syntaxe: \\. \ Physical-Driven où n est le numéro de lecteur (0 est le premier disque dur).

> Avertissement: à moins que vous ne sachiez ce que vous faites, il est préférable de ne faire que des accès en lecture seule au disque dur, sinon vous pouvez corrompre vos données d'hôte (utilisez la ligne de commande -Snapshot afin que les modifications soient écrites dans un fichier temporaire).

----

### Autres montages 

#### FAT 

**QEMU peut créer automatiquement une image de disque FAT virtuel à partir d'une arborescence de répertoires. Pour l'utiliser, il suffit de taper :**

```
# Read Only
$ qemu-system-x86_64 linux.img -hdb fat:/my_directory

# Experimental RW
$ qemu-system-x86_64 linux.img -fda fat:floppy:rw:/my_directory

```

--- 
**Des limites avec FAT** 

* Il faut utiliser des noms de fichiers ASCII
* Il ne faut pas utiliser "-snapshot" avec ":rw:"
* Il ne faut pas écrire dans le répertoire FAT sur le système hôte tout en y accédant avec le système invité

---

#### NBD

**QEMU intègre un client / serveur pour NBD, une solution de disque sur réseau peu connue.**

QEMU peut accéder directement au périphérique de bloc exporté à l'aide du protocole Network Block Device.

```shell
$ qemu-system-x86_64 linux.img -hdb nbd://my_nbd_server.mydomain.org:1024/
```

--- 

#### iSCSI

**iSCSI est un protocole populaire utilisé pour accéder aux périphériques SCSI sur un réseau informatique.**



Il existe deux manières différentes d'utiliser les périphériques iSCSI par QEMU.


---

**La première méthode consiste à monter le LUN iSCSI sur l'hôte et à le faire apparaître comme n'importe quel autre périphérique SCSI ordinaire sur l'hôte, puis à accéder à ce périphérique en tant que périphérique /dev/sd depuis QEMU.**

 La façon de procéder diffère selon les systèmes d'exploitation hôtes.

---

**La deuxième méthode consiste à utiliser l'initiateur iSCSI intégré à QEMU.**

Cela fournit un mécanisme qui fonctionne de la même manière quel que soit le système d'exploitation hôte sur lequel vous exécutez QEMU.


---

#### GlusterFS


**GlusterFS est un système de fichiers distribué dans l'espace utilisateur.**

Vous pouvez démarrer à partir de l'image disque GlusterFS avec la commande :

```shell

qemu-system-x86_64 -drive file=gluster[+TYPE]://[HOST}[:PORT]]/VOLUME/PATH
                              [?socket=...][,file.debug=9][,file.logfile=...]

```
---

#### SSH 

**Vous pouvez accéder aux images disque situées sur un serveur ssh distant en utilisant le protocole SSH.**

```shell

$ qemu-system-x86_64 \
  -drive file=ssh://[USER@]SERVER[:PORT]/PATH[?host_key_check=HOST_KEY_CHECK]

```

---

#### NVMe

**Les contrôleurs de stockage NVM Express (NVMe) sont accessibles directement par un pilote d'espace utilisateur dans QEMU.** 

Cela contourne le système de fichiers du noyau hôte et les couches de blocage tout en conservant les fonctionnalités de la couche de blocage QEMU, telles que les tâches de blocage, la limitation des E/S, les formats d'image, etc. 

Les performances d'E/S du disque sont généralement supérieures à celles avec -drive file=/dev/sda en utilisant le pool de threads ou linux-aio.

Le contrôleur sera exclusivement utilisé par le processus QEMU une fois lancé. Pour pouvoir partager le stockage entre plusieurs machines virtuelles et d'autres applications sur l'hôte, veuillez utiliser les protocoles basés sur des fichiers.


---

## Details : NBD 
Si le serveur NBD est situé sur le même hôte, vous pouvez utiliser un socket unix au lieu d'un socket inet :

```shell
$ qemu-system-x86_64 linux.img -hdb nbd+unix://?socket=/tmp/my_socket
```

Dans ce cas, le périphérique bloc doit être exporté à l'aide de qemu-nbd :

```shell
$ qemu-nbd --socket=/tmp/my_socket mon_disk.qcow2
```
L'utilisation de qemu-nbd permet le partage d'un disque entre plusieurs invités :

```shell
$ qemu-nbd --socket=/tmp/mon_socket --share=2 mon_disk.qcow2
```
et ensuite vous pouvez l'utiliser avec deux invités :

```shell
$ qemu-system-x86_64 linux1.img -hdb nbd+unix://?socket=/tmp/my_socket
$ qemu-system-x86_64 linux2.img -hdb nbd+unix://?socket=/tmp/my_socket
```


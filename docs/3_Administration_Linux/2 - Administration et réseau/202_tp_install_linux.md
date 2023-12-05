---
title: TP - Installer Linux et gérer les partitions
---

## 1 - Installer Linux

- 1.1 - Rendez vous sur le site de Linux Mint. Choisissez un environnement graphique et télécharger l'ISO correspondante. (Si vous souhaitez utiliser KDE, il vous faudra aller chercher la version 18.3)
- 1.2 - (Optionnel, mais recommandé pour plus de sécurité) Pendant que l'image télécharge, trouvez le programme `sha256sum.exe` (demander au formateur). Ouvrez une console sous Windows (Menu démarrer > taper 'cmd' pour trouver 'Invite de commande') puis lancez le programme `sha256sum.exe` sur le fichier `.iso` téléchargé précedemment. Comparez la somme de contrôle obtenue avec celle disponible sur le site de Linux Mint.
- 1.3 - Créer une nouvelle machine virtuelle en suivant les instructions :
    - de type Linux, avec comme version "Other Linux (64-bit)" ("Ubuntu (64-bit)" devrait fonctionner également) ;
    - 2048 Mo de RAM semble raisonnable ;
    - créer un disque dur virtuel, de type VDI, dynamiquement alloué, de 20 Go.
- 1.4 - Utilisez l'ISO téléchargée en tant que CD Rom virtuel que vous insérez dans la machine virtuelle. Pour ce faire : dans Configuration, Stockage, cliquer sur le CD rom (vide) puis, sur l'icone de CD rom *toute à droite*, et choisir l'ISO téléchargée.
- 1.5 - Démarrer la machine : Linux Mint est censé se lancer (utiliser le mode de compatibilité sinon)
- 1.6 - Lancer l'installation de Linux Mint
    - choisir sa langue et son clavier
    - accepter l'installation des logiciels tiers
    - lors du choix du type de partitionnement, **cliquer sur "Autre chose"**
    - créer une nouvelle table de partition, puis partitionner à l'aide du "+" l'espace de la manière suivante : 
         - 300 Mo pour `/boot` en ext4
         - 14 Go pour `/` en ext4
         - 5 Go pour `/home` en ext4
         - le reste (~700 Mo) en swap
    - choisissez le fuseau horaire, puis un nom d'utilisateur, de machine, et un mot de passe.
    - lancez l'installation et prenez une pause, buvez un café, ou regardez la vidéo youtube "The UNIX operating system" et laissez Brian Kernighan vous parler de l'élégance des pipes !
- 1.7 - Redémarrez la machine et logguez-vous. Mettez-vous à l'aise et prenez vos marques dans votre nouvel environnement :
    - choisissez un nouveau fond d'écran, naviguez dans les fichiers, testez le menu démarrer, changez le thème de couleur du bureau ou du terminal (Edition > Preferences > Couleurs), personnalisez (ou pas) votre PS1 et vos alias ...
    - testez le copier-coller dans la console. Vous pouvez utiliser clic droit puis "Copier" et "Coller", ou bien Ctrl+Shift+C et Ctrl+Shift+V, ou bien sélectionner du texte et utiliser le clic du milieu de la souris.
    - tapez quelques commandes et tentez de maîtriser des raccourcis comme Ctrl+R, Ctrl+A/E, Ctrl+U/K
    - (éventuellement, testez et configurer un éditeur de texte graphique comme `xed`, `atom`, ...)
- 1.8 - Vérifiez avec `df -h`, `lsblk -f` et `mount` que le partitionnement et les points de montage correspondent à ce que vous avez fait.
- 1.9 - Au bureau, un collègue vous informe que vous aurez besoin d'une partition de type NTFS sur votre disque, pour pouvoir communiquer avec un OS de type Microsoft. Vous décidez alors d'ajuster le partitionnement de votre disque. Or, pour redimensionner une partition, celle-ci ne dois pas être en cours d'utilisation. Nous allons donc éteindre la machine et redémarrer sur le Live CD, dont les utilitaires vont nous permettre de redimensionner et créer une nouvelle partition.
    - Relancez votre machine, de nouveau avec l'ISO dans le lecteur CD virtuel
    - Depuis la live CD, lancez le programme "Gparted" depuis le "Menu Démarrer"
    - Redimensionnez la partition correspondant à `/home/` pour la réduire de 1 Go
    - Créez une nouvelle partition de type ntfs prenant le 1 Go désormais libre
    - Validez les changements, et redémarrez le système
- De retour sur votre bureau, :
    - Vérifier qu'une nouvelle partition ntfs est effectivement présente via `lsblk -f`
    - Créez un dossier `windows` dans `/media/` puis montez manuellement la nouvelle partition sur `/media/windows`. (Vérifiez le résultat avec `lsblk` et `df -h`)
- 1.10 - Rendez ce montage automatique en modifiant `/etc/fstab` et en redémarrant le système. (Vérifiez le résultat avec `lsblk` et `df -h`)

### Exercices avancés

- Inspectez l'arbre des processus avec `ps -ef --forest` et identifiez le serveur graphique `Xorg`. Que se passe-t-il si vous tentez de killer ce processus ?
- De retour dans la machine virtuelle, arrangez-vous pour affichez GRUB pendant le démarrage puis appuyez sur "e" pour modifier les instructions de démarrage. À la fin de la commande "linux", ajoutez `init=/bin/bash` puis poursuivez le démarrage. Que se passe-t-il ?
- Si vous avez une clef USB, trouvez de quoi flasher l'ISO depuis Windows (par exemple, Etcher ou Unetbootin) puis tentez de démarrer votre machine physique sur la live USB (n'installez pas Linux Mint sur la machine physique !!)

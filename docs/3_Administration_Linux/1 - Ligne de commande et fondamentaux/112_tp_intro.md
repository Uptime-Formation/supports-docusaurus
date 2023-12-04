---
title: TP - Linux démarrage
---

<!-- ## 0. Création de la machine

- Installer Virtualbox, puis créer une nouvelle machine virtuelle
   - choisissez comme type Linux / Other-Linux (64 bit)
   - 2048 Mo de RAM devraient suffir
   - au moment de spécifier le disque dur virtuel, utiliser l'image de disque provenant de OSboxes.org -->

<!-- ## 1. Démarrer et se logguer

- Démarrer la machine et *observer* son démarrage
- L'user par défaut est `padawan` et le mot de passe `ilovelinux`.
- Une fois loggué, confirmez que la disposition du clavier est Francais/Azerty. (Si nécessaire, la changer en allant dans le "Menu démarrer" > Keyboads, puis '+' pour ajouter la disposition de clavier. Enfin, supprimez la disposition Qwerty avec le '-'.)
- Pour que l'écran de la machine virtuelle (VM) s'adapte automatiquement et joliment à la taille de l'écran, il vous faut utiliser le menu "Périphériques" (tout en haut de l'écran), puis, en bas du menu, "Insérer le CD des add-ons invités". Ensuite, accepter d'executer le CD dans Linux Mint. Un terminal s'ouvre automatiquement pour installer des logiciels. Une fois terminé, redémarrer la machine, et l'écran devrait s'adapter automatiquement à la taille de la fenêtre. -->

## 2. Premier contact avec la ligne de commande commandes

- Changer le mot de passe en tapant `passwd` puis *Entrée* et suivre les instructions
- Taper `pwd` puis *Entrée* et observer
- Taper `ls` puis *Entrée* et observer
- Taper `cd /var` puis *Entrée* et observer
- Taper `pwd` puis *Entrée* et observer
- Taper `ls` puis *Entrée* et observer
- Taper `ls -l` puis *Entrée* et observer
- Taper `echo 'Je suis dans la matrice'` puis *Entrée* et observer

## 3. La ligne de commande

- **3.1** - Rendez-vous dans `/usr/bin` et listez le contenu du dossier
- **3.2** - Y'a-t-il des fichiers cachés dans votre répertoire personnel ?
- **3.3** - Quand a été modifié le fichier `/etc/shadow` ?
- **3.4** - Identifiez à quoi sert l'option `-h` de la commande `ls` via son `man`.
- **3.5** - Cherchez une option de `ls` qui permet de trier les fichiers par date de modification
- **3.6** - Identifiez ce que fait la commande `sleep` via son `man`.
- **3.7** - Lancer `sleep 30` et arrêter l'execution de la commande avant qu'elle ne se termine.
- **3.8** - Pour vous entraîner à utiliser [Tab] et ↑, tentez le plus rapidement possible et en utilisant le moins de touches possible de lister successivement le contenu des dossiers `/usr`, `/usr/share`, `/usr/share/man` et `/usr/share/man/man1`.
- 3.9 - Se renseigner sur ce que font `date` et `cal`
- 3.10 - Afficher le calendrier pour l'année 2022, puis juste le mois de Février 2022
- **3.11** - Se renseigner sur ce que fait la commande `free`, et interpreter la sortie de `free -h`
- **3.12** - Se renseigner sur ce que fait la commande `ping` et interpreter la sortie de `ping 8.8.8.8`
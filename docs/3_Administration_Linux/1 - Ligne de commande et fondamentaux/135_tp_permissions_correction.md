---
title: TP - Correction - Permissions
---


Votre nom d'utilisateur sera remplacé par `padawan` dans la suite

- 6.1 : Faire `touch xwing.conf` puis `ls -l xwing.conf` pour analyser les proprietaires et permissions actuelles. Changer le proprietaire/groupe si necessaire avec `chown padawan:padawan xwing.conf`. Reverifier les modifications avec `ls -l xwing.conf`. Faire `chmod o-r xwing.conf` di nécessaire.
- 6.2 : `touch private`, puis `chmod ugo-rwx private` par exemple (on peut aussi le faire en plusieurs étapes)
- 6.3 : `chmod u+r private`, puis `chmod ug+w private`, puis `chmod +x private`
- 6.4 : `chmod ugo-rwx private` (ou `chmod 000 private`)
- 6.5 : `chmod 731 private` (car `rwx-wx--x` s'écrit 731 en octal)
- 6.6 : `chmod go-rx /home/<padawan>` (`padawan` changer pour votre utilisateur courant)
- 6.7 : `chmod -R o-rwx ~/documents` par exemple
- 6.8 : en tant que root : `mkdir /home/r2d2`, puis en tant que root : `chown r2d2 /home/r2d2` puis `chmod go-rx /home/r2d2` devrait suffir (eventuellement enlever le `w` aussi)
- 6.9 : `touch /home/r2d2/droid.conf` puis par exemple `cd /home/r2d2` et `chown r2d2:droid ./droid.conf`
- 6.10 : (en étant dans `/home/r2d2/`) `touch beep.wav boop.wav blop.wav` puis `chown r2d2 *.wav` et, par exemple, `chmod go-x *.wav` et `chmod u+x *.wav`
- 6.11 : `mkdir secrets` puis `touch secrets/nsa.pdf` (eventuellement mettre du texte dans `secrets/nsa.pdf`). Ensuite : `chmod -r secrets/` desactive le listage des fichiers dans `secrets/` ... pourtant, il est possible de faire `cat secrets/nsa.pdf` !
- 6.12 : Si l'on essaye de faire un `chown` en tant que `padawan`, le système refusera ! (On ne peut pas donner ses fichiers à quelqu'un d'autre)
- 6.13 : (pour que cela fonctionne, il faut installer le paquet `acl` avec `apt install acl`) `setfacl -m g:droid:r-x /home/padawan` puis faire `ls -l` sur le dossier et constater le `+` à la fin des permissions. On peut regarder le détails des ACL avec `getfacl /home/padawan`
- 6.14 : `setfacl -m u:<padawan>:r-x /home/r2d2`

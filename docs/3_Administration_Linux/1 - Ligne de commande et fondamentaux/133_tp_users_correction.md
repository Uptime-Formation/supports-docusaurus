---
title: TP - Correction - Users et groupes
---


- **5.3** - Dans votre deuxième terminal (en `root`)
    - créez un utilisateur `r2d2` avec `useradd` plutôt que `adduser` : `useradd r2d2` suffit ici puisqu'on va le configurer après.
    - définissez un mot de passe pour l'utilisateur `r2d2` à l'aide de la commande `passwd`: `passwd r2d2`
    - créez un groupe `droid`: `groupadd droid` 
    - ajoutez `r2d2` au groupe `droid`: `usermod -aG droid r2d2`
    - constatez que les infos de `r2d2` et du groupe `droid` sont bien dans `/etc/passwd`, `/etc/shadow` et `/etc/group`.

```
/etc/passwd
...
...
r2d2:x:1001:1001::/home/r2d2:/bin/sh
```

```
/etc/group
...
...
r2d2:x:1001:
```


- **5.4** - Ouvrir un troisième terminal. Dedans, ouvrir un sous-shell en tant que `r2d2` à l'aide des commandes `sudo` et/ou `su`.

- l'invite de commande obtenue est différente de celle de `r2d2` et `root`. Pourquoi ? (On pourra comparer le résultat de la commande `echo $SHELL`) : `sudo -u r2d2 -i` *
    
=> le shell par défaut est `/bin/sh` car on ne l'a pas précisé à la création de l'user.

=> Il y a aussi un warning présent car le home par défaut est configuré à `/home/r2d2` alors que ce dossier n'existe pas.

=> Pour éviter tout cela on pourrait utiliser `useradd -m -s /bin/bash r2d2` => l'utilisateur serait créé avec son home (copié depuis le modèle `/etc/skel`) et son shell configuré à bash.

- comment peut-on procéder pour changer le shell par défaut de `r2d2` ? (Indice: regarder `/etc/passwd`, ou bien la commande `chsh`) : `chsh -s /bin/bash r2d2`
- regardez le résultat des commandes `whoami`, `id` et `groups` et comparez à ce que vous obtenez pour ces commandes dans le premier terminal (en tant que votre utilisateur initial)

- **5.5** - Inspectez le contenu de `/etc/sudoers`: Ajoutez `r2d2` au groupe `sudo` avec `usermod -aG sudo r2d2`
    - en lisant les commentaires du fichier, chercher comment faire pour donner le droit à `r2d2` d'utiliser `sudo`
    - (après avoir fait la manip, n'oubliez pas de relancer le terminal/shell dans lequel vous êtes pour propager le changement!)
    - depuis un shell en tant que `r2d2`, validez que vous êtes en mesure de faire des commandes avec `sudo` (Par exemple: `sudo ls -la /root/`).
- **5.6** - Constatez que les commandes executées avec `sudo` sont logguées dans le ficher `/var/log/auth.log` (on pourra utiliser `tail` pour afficher seulement les dernières lignes du fichier) : `sudo tail -f /var/log/auth.log` puis dans un autre terminal lancer une commande avec `sudo`
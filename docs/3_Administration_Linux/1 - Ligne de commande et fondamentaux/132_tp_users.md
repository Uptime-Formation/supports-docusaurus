---
title: TP - Users et groupes
---


- **5.1** - Ouvrir un premier terminal en tant que qu'utilisateur (`<votreprenom>`, `<stagiaireN>`, `padawan`)
- **5.2** - Ouvrir un deuxième terminal. Dedans, ouvrir un sous-shell en `root` à l'aide des commandes `sudo` et/ou `su`.
- **5.3** - Dans votre deuxième terminal (en `root`)
    - créez un utilisateur `r2d2` avec `useradd` plutôt que `adduser`
    - définissez un mot de passe pour l'utilisateur `r2d2` à l'aide de la commande `passwd`
    - créez un groupe `droid`
    - ajoutez `r2d2` au groupe `droid`
    - constatez que les infos de `r2d2` et du groupe `droid` sont bien dans `/etc/passwd`, `/etc/shadow` et `/etc/group`
- **5.4** - Ouvrir un troisième terminal. Dedans, ouvrir un sous-shell en tant que `r2d2` à l'aide des commandes `sudo` et/ou `su`.
    - l'invite de commande obtenue est différente de celle de `r2d2` et `root`. Pourquoi ? (On pourra comparer le résultat de la commande `echo $SHELL`)
    - comment peut-on procéder pour changer le shell par défaut de `r2d2` ? (Indice: regarder `/etc/passwd`, ou bien la commande `chsh`)
    - regardez le résultat des commandes `whoami`, `id` et `groups` et comparez à ce que vous obtenez pour ces commandes dans le premier terminal (en tant que votre utilisateur initial)
- **5.5** - Inspectez le contenu de `/etc/sudoers`:
    - en lisant les commentaires du fichier, chercher comment faire pour donner le droit à `r2d2` d'utiliser `sudo`
    - (après avoir fait la manip, n'oubliez pas de relancer le terminal/shell dans lequel vous êtes pour propager le changement!)
    - depuis un shell en tant que `r2d2`, validez que vous êtes en mesure de faire des commandes avec `sudo` (Par exemple: `sudo ls -la /root/`).
- 5.6 - Constatez que les commandes executées avec `sudo` sont logguées dans le ficher `/var/log/auth.log` (on pourra utiliser `tail` pour afficher seulement les dernières lignes du fichier)
---
title: TP - Pipes et boîte à outils
---

- **10.1** - Si ce n'est pas deja le cas, ajoutez un alias pour activer automatiquement `--color=auto` chaque fois que la commande `grep` est utilisée. Essayez quelques manipulations avec `grep` pour confirmer que les occurences trouvées sont bien mises en valeur.
- **10.2** - Lister les lignes de `/etc/passwd` qui correspondent aux utilisateurs ayant `/bin/bash` comme shell
- **10.3** - Même chose, mais cette fois en affichant uniquement le nom des utilisateurs
- **10.4** - Lister les utilisateurs (uniquement leur nom !) qui ont comme shell `nologin`
- **10.5** - Lister les utilisateurs (uniquement leur nom) qui ont un mot de passe non vide (rappel : historiquement les passwords se trouvaient dans `/etc/passwd`, mais ce n'est plus le cas de nos jours !)
- **10.6** - Écrivez un alias `estcequecestleweekend` qui vérifie si on est Samedi ou Dimanche en utilisant `date`
- 10.7 - Sachant que pour grep, `^`et `$` désignent un début et une fin de ligne, pouvez-vous affichez le contenu de `/etc/login.defs`
    - sans les commentaires (ce sont les lignes commençant par #)
    - puis sans les commentaires ni les lignes vides ? (Indice : une ligne vide est une ligne qui se commnence puis se termine tout de suite)
- 10.8 - Écrire **une seule ligne de commande** qui affichera (uniquement) "Oui" ou "Non" suivant si par exemple le paquet `vim` est installé. Pour tester si un paquet est installé, on pourra se baser sur `dpkg --list` ou bien sur `dpkg-query --status <nom_du_paquet>` (Testez et validez le comportement avec d'autres paquets)
- **10.9** - À l'aide des pages de man de `grep`, trouvez un moyen de lister toutes les occurences du mot `daemon` dans tous les fichiers à l'intérieur de `/etc/` (recursivement)
- **10.10** - À l'aide de `ps`, `sort` et `uniq` générer un bilan du nombre de processus actuellement en cours par utilisateur
- **10.11** - À l'aide de `sort` et `uniq`, analysez le fichier `loginattempts.log` (demander au formateur comment l'obtenir), et produisez un résumé du nombre de tentative de connections par ip
- 10.12 - (Avancé) Construisez une ligne de commande qui récupère les adresses des images présentes dans le code du site `www.wikimedia.org`. Vous aurez possiblement besoin de `curl`, `grep`, `tr`, `awk` et `sed`.

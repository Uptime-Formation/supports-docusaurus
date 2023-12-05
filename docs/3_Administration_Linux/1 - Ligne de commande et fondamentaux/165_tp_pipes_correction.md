---
title: TP - Correction - Pipes et boîte à outils
sidebar_class_name: hidden
---



- 10.1 : utiliser `alias grep` pour verifier que l'alias existe, sinon ajouter `alias grep="grep --color=auto"` au `.bashrc` et le recharger.
- 10.2 : `cat /etc/passwd | grep "/bin/bash"`
- 10.3 : `cat /etc/passwd | grep "/bin/bash" | tr ':' ' ' | awk '{print $1}'` (on peut aussi utiliser `awk -F:`, ou la commande `cut`)
- 10.4 : `cat /etc/passwd | grep "nologin$" | tr ':' ' ' | awk '{print $1}'`
- 10.5 : Les utilisateurs n'ayant pas de mot de passe sont typiquement caractérisés par un `:x:` sur la ligne (ou eventuellement un `:!:`) dans `/etc/shadow`. On utilise alors un grep 'inversé' (`-v`) pour obtenir les lignes des utilisateurs qui ont vraiment un mot de passe. On utilise aussi un "ou" dans grep (avec `\|`) pour ignorer à la fois les lignes contenant `:!:` et `:x:`.

```bash
sudo cat /etc/shadow | grep -v ":\!:\|:x:" | awk -F: '{print $1}'
```

- 10.6 :

```bash
alias esquecestleweekend='date | grep "^Sat \|^Sun " >/dev/null && echo "Cest le weekend" && echo "Cest le weekend" || echo "Arg il faut encore taffer!"
```

- 10.7 : Les lignes vides correspondent à `^$` (début de ligne suivi de fin de ligne) donc : `cat /etc/login.defs | grep -v "^$"` Pour enlever également les commentaires, on utilise un "ou" dans grep (`\|`), ce qui donne : `cat /etc/login.defs | grep -v "^$\|^#"`
- 10.8 : `dpkg-query --status vim | grep -q 'Status: install ok installed' && echo Oui || echo Non`
- 10.9 : `grep -nr "daemon" /etc/`
- 10.10 : `ps -ef | grep -v "UID" | awk '{print $1}' | sort | uniq -c`
- 10.11 : `cat loginattempts.log  | awk '{print $9}' | sort | uniq -c | sort -n`
- 10.12 : Il s'agit d'un exercice un peu avancé avec plusieurs solutions possibles (qui ne sont pas trop robuste, mais peuvent dépanner). En voici une qui envoie les adresses des images dans un fichier `img.list` :

```bash
curl yoloswag.team           \
 | grep "img src"            \
 | sed 's/img src/\n[img]/g' \
 | grep "\[img\]"            \
 | tr '<>"' ' '              \
 | awk '{print $2}'          \
 > img.list
```

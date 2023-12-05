---
title: TP - Correction - Environnement du shell
sidebar_class_name: hidden
---


- 8.1 : Un exemple de personnalisation de PS1 est :

```bash
PS1="[\033[01;32m\u on \h\033[0m:\033[01;34m\w\033[0m] \n> "
```

- 8.2 : Ajouter la ligne précédente en bas de `~/.bashrc` à l'aide de nano puis recharger avec `source ~/.bashrc`
- 8.3 : Même chose que 8.2 mais en rajoutant une ligne comme :

```bash
echo "May the source be with you
```
- 8.4 : Ouvrir `/root/.bashrc` avec nano (et possiblement sudo) puis rajouter une ligne pour modifier le PS1, comme :

```bash
PS1="[\033[01;31m\u on \h\033[0m:\033[01;34m\w\033[0m] \n> "
```

(noter la couleur '31' = rouge)

- 8.5 : Taper `ll` pour tester si la commande existe. Si elle n'existe pas, rajouter `alias ll='ls -l'` dans le bashrc puis le recharger avec `source`. Pour s'assurer que `ls` utiliser `--color=auto` par défaut, taper `alias ls`.
- 8.6 : Taper `alias suls='sudo ls -la'` (par exemple) et `alias sucat='sudo cat'`. Tester en tant que padawan de taper `suls /root` et `sucat /etc/shadow` (ou d'autres dossiers / fichiers accessibles uniquement par root).
- 8.7 : `alias r2d2="sudo su r2d2"` puis tester de taper `r2d2`.
- 8.8 : Se renseigner sur Internet ;P (question un peu 'extra')
- 8.9 : `alias ls="echo 'G pas envie'"`

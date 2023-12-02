---
title: Cours - l'environnement du shell et ses variables
---



## 8. Personnaliser son environnement

## 8. Personnaliser son environnement

### Variables d'envionnement

Lorsque vous êtes dans un shell, il existe des *variables d'environnement* qui définissent certains comportements.

Par exemple, la variable 'HOME' contient `/home/padawan` et corresponds à l'endroit où `cd` retourne par défaut (si pas de dossier donné en argument)

Autre exemples :

```
SHELL : /bin/bash (généralement)
LANG, LC_ALL, ... : langue utilisée par les messages
USER, USERNAME : nom d'utilisateur
```


## 8. Personnaliser son environnement

### Changer une variable d'envionnement

Exemple :

```
HOME=/usr/cache/
```

### Afficher une variable

```
$ echo $HOME
/usr/cache/
```


## 8. Personnaliser son environnement

### Lister les variables d'envionnement

`env` permet de lister les variables d'environnement

```
$ env
LC_ALL=en_US.UTF-8
HOME=/home/alex
LC_MONETARY=fr_FR.UTF-8
TERM=rxvt-unicode-256color
[...]
```


## 8. Personnaliser son environnement

### Personnaliser l'invite de commande

- La variable `PS1` décrit l'apparence de l'invite de commande !
- Généralement, `PS1` vaut : `\u@\h:\w$`
- `\u` corresponds au nom d'utilisateur
- `\h` corresponds au nom de la machine (host)
- `\w` corresponds au repertoire de travail (working directory)
- `\n` corresponds ... à un retour à la ligne !

`PS2` corresponds à l'invite de commande de deuxième niveau !


## 8. Personnaliser son environnement

### Ecrire du texte en couleur

(Syntaxe absolument abominable :'( !)

```
echo -e "\033[31mCeci est en rouge\033[0m"
echo -e "\033[32mCeci est en vert\033[0m"
echo -e "\033[33mCeci est en jaune\033[0m"
echo -e "\033[7mCeci est surligné\033[0m"
echo -e "\033[31;1;7;6mCeci est surligné rouge gras surligné clignotant\033[0m"
```

Couleurs : 30 à 38
Effets : 0 à 7


## 8. Personnaliser son environnement

### PS1 en couleur ...

```
PS1="\[\033[31;1;7;6m\]\u\[\033[0m\]@\h:\w$ "
```

N.B. : pour les couleurs dans le PS1, ne pas oublier d'ajouter des `\[` et `\]` autour des machines pour les couleurs ... sinon le terminal buggera à moitié...


## 8. Personnaliser son environnement

### Définir des aliases

Un alias est un nom "custom" pour une commande et des options

```
alias ll='ls -l'
alias rm='rm -i'
alias ls='ls --color=auto'
```

On peut connaître les alias existants avec juste `alias`

(Mauvaise blague : définir `alias cd='rm -r'` !)


## 8. Personnaliser son environnement

### Les fichiers de profil

- Le fichier `~/.bashrc` est lu à chaque lancement de shell
- Il permet de définir des commandes à lancer à ce moment
- Par exemple, des alias à définir ou des variables à changer...
- Pour appliquer les modifications, il faut faire `source ~/.bashrc`

Autres fichiers de profils : `~/.profile` et `/etc/bash_profile`

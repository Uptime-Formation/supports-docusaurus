---
title: TP - Le système de ficher
---


- **4.1** - En utilisant `mkdir` et `touch`, créez dans votre répertoire personnel l'arborescence suivante :

```bash
~/
├── Documents/
    ├── formation_linux/
    │   ├── slides_1_les_bases.html
    │   └── exo_1_les_bases.pdf
    └── mon_pokedex/
        ├── index.html
        ├── all_pokemons.txt
        ├── mon_equipe_de_pokemons.csv
        └── assets/
            ├── css/
            │   └── pokedex.css
            ├── fonts/
            │   └── pokefont.ttf
            └── img/
                ├── logo.png
                ├── pikachu.jpg
                └── carapuce.jpg
```

- **4.2** - Téléchargez la liste de tous les pokémons connus (`all_pokemons.txt`) depuis le serveur du formateur à l'aide de `wget`.
- **4.3** - À l'aide de `nano`, remplissez `mon_pokedex/mon_equipe_de_pokemons.csv` avec quelque chose comme:

```
Pokemon;Niveau
bulbizarre;17
rattata;8
roucoups;15
```

Vérifiez que le contenu a bien été pris en compte en l'affichant avec `cat`.

- **4.4** - Aller dans `~/Documents/mon_pokedex/assets/` puis, **en utilisant uniquement des chemins relatifs** et en vous aidant de la touche [Tab], déplacez-vous successivement vers :
    - `~/Documents/mon_pokedex/assets/img`
    - `~/Documents/formation_linux`
    - `~/.local/` (ou `~/.config/` si `~/.local/` n'existe pas)
    - `~/Documents/mon_pokedex/assets/fonts`
    - `/usr/share/doc/`
    - `~/`
- **4.5** - Créez un fichier `dracaufeu.jpg` dans `~/Documents/formation_linux` ... Vous réalisez ensuite que vous auriez voulu mettre ce fichier dans `~/Documents/mon_pokedex/assets/img` ! Utilisez alors la commande `mv` pour déplacer le fichier vers le bon dossier.
- **4.6** - Renommez le dossier `mon_pokedex/` en `ma_collection_de_pokemons/`
- **4.7** - Supprimez le fichier `carapuce.jpg` dans `~/Documents/ma_collection_de_pokemons/assets/img` **en restant là où vous êtes actuellement, i.e. sans utiliser `cd`**
- **4.8** - Créez un dossier `~/sauvegardes` et dedans, créer un dossier `collection_bkp` qui sera une copie récursive de `~/Documents/ma_collection_de_pokemons`
- **4.9** - Supprimez tout le dossier `~/sauvegardes` récursivement

- **4.10** - Depuis là où vous êtes (i.e. sans utiliser `cd` !):
    - affichez le contenu de `/etc/os-release` : devinez-vous à quoi correspondent ces informations ?
    - affichez le contenu de `/etc/hostname` : à quoi correspond cette information ?
    - affichez le contenu de `/etc/timezone` : à quoi correspond cette information ?
    - affichez le contenu de `/etc/default/locale` : à quoi correspond cette information ?

- **4.11** - Regardez le contenu de `/etc/nanorc` :
    - à quoi correspond ce fichier ?
    - en utilisant `less`, cherchez toutes les occurences du mot `set`.
    - même chose mais cette fois en ouvrant le fichier avec `nano` (il existe un raccourci clavier pour chercher un mot dans `nano`)
- **4.12** - Utilisez une commande pour compter le nombre de ligne du fichier `/etc/nanorc`
- **4.13** - Copiez le fichier `/etc/nanorc` dans `~/.nanorc`. Éditez ensuite cette copie pour décommenter la ligne `# set linenumbers` (c'est à dire enlever le `#` devant la ligne pour activer l'option `linenumbers`). Qu'avons-nous fait avec cette manipulation ? Pourquoi avoir copié le fichier dans notre répertoire personnel pour faire cela ?
- 4.14 - (Avancé) Créez (puis supprimez) un fichier qui s'appelle littérallement `*.py`
- 4.15 - (Avancé) Créez (puis supprimez) un fichier qui s'appelle littérallement `-f`
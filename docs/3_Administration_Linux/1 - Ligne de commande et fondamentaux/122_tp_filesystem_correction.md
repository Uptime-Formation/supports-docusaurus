---
title: TP Correction - Le système de ficher
---

### 4. système de fichiers

Une remarque d'efficacité:

- `mkdir -p ~/Documents/mon_pokedex/assets/img` permet de créer plusieurs dossiers (tout le chemin) d'un coup

- **4.10** - Depuis là où vous êtes (i.e. sans utiliser `cd` !):
    - affichez le contenu de `/etc/os-release` : devinez-vous à quoi correspondent ces informations ?

=> informations sur le système d'exploitation (version du noyau Linux, distribution et sa version, architecture du processeur)

    - affichez le contenu de `/etc/hostname` : à quoi correspond cette information ?

=> configuration du nom de la machine

    - affichez le contenu de `/etc/timezone` : à quoi correspond cette information ?

=> configuration du fuseau horaire système

    - affichez le contenu de `/etc/default/locale` : à quoi correspond cette information ?

=> configuration de la conf de langue du système pour les applications (plus ici: https://wiki.archlinux.org/title/Locale_(Fran%C3%A7ais))

- `nanorc` est la configuration du logiciel `nano` (finir un nom de conf par rc => courant comme `.bashrc` par exemple ). C'est un exemple classique de fichier de configuration:
    - présent dans une version modèle dans `/etc` => `/etc/nanorc`
    - en créant la version utilisateur de cette conf `.nanorc` dans votre home, le nano lancé en tant que votre utilisateur utilisera en priorité cette dernière. Plutôt que de modifier la conf système ce qui peut être problématique et que parfois on a pas le droit de faire, on copie le modèle système dans son home et on le modifie.
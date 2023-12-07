---
title: TP - Le gestionnaire de paquet et les archives
# sidebar_class_name: hidden
---

### Gestionnaire de paquet

- 2.1 Suite à l'installation de votre système, vous voulez vous assurer qu'il est à jour.
   - Lancez la commande `apt update`. Quels dépôts sont contactés pendant cette opération ?
   - À l'aide de `apt list --upgradable`, identifiez si `firefox`, `libreoffice`, `linux-firmware` et `apt` peuvent être mis à jour - et identifiez l'ancienne version et la nouvelle version.
   - Lancez la mise à jour avec `apt full-upgrade`. Pendant le déroulement de la mise à jour, identifiez les trois parties clefs du déroulement : liste des tâches et validation par l'utilisateur, téléchargement des paquets, et installation/configuration.
- 2.2 - Cherchez avec `apt search` si le programme `sl` est disponible. (Utiliser `grep` pour vous simplifiez la tâche). À quoi sert ce programme ? Quelles sont ses dépendances ? (Vous pourrez vous aider de `apt show`). Finalement, installez ce programme en prêtant attention aux autres paquets qui seront installés en même temps.
- 2.3 - Même chose pour le programme `lolcat`
- 2.4 - Même chose pour le programme `nyancat` - mais cette fois, trouvez un moyen de télécharger le `.deb` directement depuis le site de debian qui référence les paquets, puis installez ce `.deb` avec `dpkg -i`. (Pour ce faire, taper par exemple `nyancat package debian` dans un moteur de recherche. Une fois arrivé sur la bonne page, vous trouverez une section 'Download' en bas. Parmis les architectures proposées, prendre `amd64`.)

- 2.5 - Parfois, il est nécessaire d'ajouter un nouveau dépôt pour installer un programme (parce qu'il n'est pas disponible, ou bien parce qu'il n'est pas entièrement à jour dans la distribution utilisée). Ici, nous prendrons l'exemple de `mongodb` (un logiciel pour gérer des bases NoSQL) dont la version 7 n'est disponible que via un dépôt précis maintenu par les auteurs de mongodb.
    - Regarder avec `apt search` et `apt show` (et `grep` !) si le paquet `mongodb` est disponible et quelle est la version installable.
    - Suivez les instruction officielles d'installation ici: https://www.mongodb.com/docs/manual/tutorial/install-mongodb-on-debian/#install-mongodb-community-edition
    - Ajouter un nouveau fichier `mongodb.list` dans `/etc/apt/sources.list.d` avec une unique ligne : `deb [ signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] http://repo.mongodb.org/apt/debian bullseye/mongodb-org/7.0 main`
    - Faire `apt update`. Que se passe-t-il ? Quels serveurs votre machine a-t-elle essayer de contacter ? Pourquoi cela produit-il une erreur ?
    - Ajoutez la clef d'authentification des paquets avec :
    - `sudo apt install -y gnupg curl`
    - `curl -fsSL https://pgp.mongodb.com/server-7.0.asc | sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg --dearmor`
    <!-- - Ajoutez la clef d'authentification des paquets avec `wget -qO - https://www.mongodb.org/static/pgp/server-5.0.asc | sudo apt-key add -`. -->
    - Refaire `apt update`. Est-ce que ça fonctionne ?
    - Regarder avec `apt search` et `apt show` (et `grep` !) si le paquet `mongodb-org` est disponible et quelle est la version installable.
    - Installer le paquet. Depuis où a-t-il été téléchargé ?
    - Désinstallez ce paquet (en purgeant les données / fichiers) et supprimez le `mongodb.list` puis refaites un `apt update` pour remettre à plat la liste des paquets disponibles.

- 2.6 - Regardez le contenu de `/var/cache/apt/archives`. À quoi ces fichiers correspondent-ils ? Trouvez deux méthodes pour nettoyer ces fichiers, l'une "brutale" avec `rm`, et l'autre "propre" avec `apt`.

- 2.7 - Identifiez l'utilité de la commande `apt moo`

### Gestion des archives

- 2.8 - Créez une archive (non-compressée !) de votre répertoire personnel avec `tar`.
- 2.9 - En utilisant `gzip`, produisez une version compressée de l'archive de la question précédente
- 2.10 - Recommencez mais en produisant une version compressée directement
- 2.11 - En fouillant dans les options de `tar`, trouvez un moyen de lister le contenu de l'archive
- 2.12 - Créez un dossier `test_extract` dans `/tmp/`, déplacez l'archive dans ce dossier puis décompressez-là dedans.
- 2.13 - (Avancé) En reprenant le `.deb` du programme `nyancat` de la question 1.14, utilisez `ar` et `tar` pour décompresser le `.deb` jusqu'à trouver le fichier de controle debian, ainsi que l'executable contenu dans le paquet.
- 2.14 - (Avancé) Trouvez un ou des fichiers `.gz` dans `/var/log` (ou ailleurs ?) et cherchez comment combiner `cat` et `gzip` pour lire le contenu de ce fichier sans créer de nouveau fichier.

### Exercices avancés

- Utilisez `aptitude why` pour trouver la raison pour laquelle le paquet `libxcomposite1` est installé
- Utilisez `apt-rdepends` pour afficher la liste des dépendances de `libreoffice`.
- Investiguez les options de `apt-rdepends` et du programme `dot` pour générer un rendu en PNG du graphe de dépendance de `firefox`.
- Trouvez où télécharger le `.deb` du paquet `nyancat` depuis `ftp.debian.org`
- (Très avancé) Renseignez-vous sur `equivs` et créez un package virtuel `lolstuff` qui dépend de `sl`, `lolcat` et `nyancat`
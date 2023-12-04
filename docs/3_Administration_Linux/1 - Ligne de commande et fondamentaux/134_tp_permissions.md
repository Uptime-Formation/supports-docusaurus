---
title: TP - Permissions
---


- **6.1** - Créez un fichier `xwing.conf` que seul vous et votre groupe pouvez lire
- **6.2** - Créez un fichier `private` et supprimer toutes les permissions dessus
- **6.3** - Ajoutez successivement à `private` le droit de lecture au propriétaire, le droit d'écriture au groupe et au proprietaire, et les droits d'execution pour tout le monde.
- **6.4** - Resupprimez toutes les permissions de `private`
- **6.5** - Remettez les mêmes permissions qu'avant mais avec une seule commande en utilisant la notation octale
- 6.6 - Modifier les permissions de votre répertoire personnel pour que seul vous ayez le droit d'écriture et de traverse (x) dessus
- **6.7** - Interdisez à tous les "autres" utilisateurs de fouiller et modifier les fichier dans `~/documents`, avec une seule commande qui aura un effet récursif
- **6.8** - Créez un répertoire personnel pour `r2d2`. Définir `r2d2` comme proprietaire de son dossier personnel + s'assurer que les permissions lui permettent (à lui et à lui seul) de lire, ecrire et entrer dans son repertoire.
- 6.9 - Créez un fichier `droid.conf` dans son dossier personnel, le définir comme propriétaire, et définir le groupe comme 'droid'.
- 6.10 - Créez des fichier `beep.wav`, `boop.wav` et `blop.wav` que seul `r2d2` peut executer.
- 6.11 - Êtes-vous capable de créer un dossier qui contient des fichiers qu'il est possible de lire, mais pas de lister ?
- 6.12 - En tant qu'utilisateur `padawan`, arrivez-vous à donner un de vos fichier à `r2d2` ?
- 6.13 - (Avancé) Utilisez `setfacl` pour autoriser le groupe `droid` à lister et rentrer dans votre home. Confirmez l'effet attendu, d'une part avec `ls -l` et `getfacl`, et d'autre part depuis un shell en étant connecté en tant que `r2d2`
- 6.14 - (Avancé) Même chose, mais cette fois-ci donnez le droit de list et rentrer dans `/home/r2d2` à l'user(!) `padawan`.
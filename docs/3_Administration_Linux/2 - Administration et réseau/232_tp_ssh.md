---
title: TP - Connection SSH
---

<!-- ## Notions de cryptographie

- 4.0 - Installer `gpg` si le programme n'est pas déjà présent
- 4.1 - Générer une clef GPG avec `gpg --full-generate-key`. Lors de la création, on peut garder toutes les options par défaut. Pour le nom et email, vous pouvez utilisez de "fausses" informations comme `votreprenom@formationlinux`.
- 4.2 - Récupérer la clef GPG du formateur puis l'importer avec `gpg --import <chemin_vers_la_clef>`. S'assurer que la clef a bien été importée avec `gpg --list-keys`.
- 4.3 - Écrire un court message pour le formateur dans un fichier (par exemple, 'Je fais du chiffrement !') puis chiffrer ce fichier avec 
```bash
gpg --recipient leformateur@example.com --encrypt --armor <fichier>
```
Affichez ensuite le contenu de `<fichier>.asc` : il s'agit du message chiffré à destination du formateur !
- 4.4 - Affichez votre clef publique avec 
```bash
gpg --armor --export votreprenom@formationlinux
```
**Il vous faudra la fournir au formateur pour qu'il puisse vous répondre en chiffré !**
- 4.5 - Envoyez depuis `yopmail.com`, un mail au formateur contenant le message chiffré **et votre clef publique**.
- 4.6 - Attendre une réponse, et tenter de la déchiffrer avec `gpg --decrypt`. -->

## Se connecter et gérer un serveur avec SSH

- 5.1 - Pingez votre serveur, connectez-vous dessus en root (si possible en vérifiant la fingerprint du serveur) et **changer le mot de passe** ! (Choisir un mot de passe un minimum robuste : il sera mis à l'épreuve !!!). Dans une autre console, constater qu'il y a maintenant une entrée correspondant à votre serveur dans `~/.ssh/known_hosts`.
- 5.2 - **Sur votre serveur**, familiarisez-vous avec le système : 
    - de quelle distribution s'agit-il ? (`lsb_release -a` ou regarder `/etc/os-release`)
    - quelle est la configuration en terme de CPU, de RAM, et d'espace disque ? (`cat /proc/cpuinfo`, `free -h` et `df -h`)
    - quelle est son adresse IP locale et globale ?
- 5.3 - **Sur votre serveur** : donnez un nom à votre machine avec `hostnamectl set-hostname <un_nom>`. (Attention, ce nom est purement cosmétique et interne à la machine. Il ne s'agit pas d'un vrai nom de domaine résolvable et accessible par n'importe qui sur internet, à la différence de celui qui sera configuré à la question 5.8)

- 5.4 - **Sur votre serveur** : créez un utilisateur destiné à être utilisé plutôt que de se connecter en root. 
    - Créez-lui un répertoire personnel et donnez-lui les permissions dessus. 
    - Définissez-lui un mot de passe. 
    - Assurez-vous qu'il a le droit d'utiliser `sudo`.
    <!-- - Ajoutez-le au groupe `ssh`. -->

- 5.5 - **Depuis votre machine de bureau (VM Mint / Xubuntu)** : connectez-vous en ssh sur votre serveur avec le nouvel utilisateur. Personnalisez (ou pas) le PS1, les alias, et votre .bashrc en général. Créez quelques fichiers de test pour confirmer que vous avez le droit d'écrire dans votre home.
- 5.6 - **Depuis votre machine de bureau (VM Mint / Xubuntu)** : ajoutons maintenant une vrai clef SSH : 
    - générez une clef SSH pour votre utilisateur avec `ssh-keygen -t rsa -b 4096 -C "un_commentaire"`;
    - identifiez le fichier correspondant à la clef publique créé (generalement `~/.ssh/un_nom.pub`) ;
    - utilisez `ssh-copy-id -i clef_publique user@machine` pour copiez et activer la clef sur votre serveur ;
    - (notez que sur le serveur, il y a maintenant une ligne dans `~/.ssh/authorized_keys`)
    - tentez de vous connecter à votre utilisateur en utilisant désormais la clef (`ssh -i clef_privee user@machine`)
- 5.7 - **Depuis votre machine de bureau (VM Mint / Xubuntu)**, configurez `~/.ssh/config` avec ce modèle de fichier. Vous devriez ensuite être en mesure de pouvoir vous connecter à votre machine simplement en tapant `ssh nom_de_votre_machine`
```bash
Host nom_de_votre_machine
    User votre_utilisateur
    Hostname ip_de_votre_machine
    IdentityFile chemin_vers_clef_privee
```
- 5.8 - Définissons maintenant un vrai nom de domaine "public" pour votre serveur, de sorte qu'il soit contactable facilement par n'importe quel être humain connecté à Internet :
    - aller sur `netlib.re` et se connecter avec les identifiants fourni par le formateur ;
    - créer un *nouveau* nom de domaine (en `.netlib.re` ou `.codelib.re`). (Ignorez les nom déjà créé, ce sont ceux de vos camarades !) ;
    - une fois créé, cliquer sur le bouton 'Details' puis (en bas) ajouter un nouvel enregistrement de type 'A' avec comme nom '@' et comme valeur l'IP globale(!) de votre serveur ;
    - de retour dans une console, tentez de résoudre et pinger le nom de domaine à l'aide de `host` et `ping` ;
    - modifiez votre `~/.ssh/config` pour remplacer l'ip de la machine par son domaine, puis tentez de vous reconnecter en SSH.
- 5.9 - Depuis votre machine de bureau (Mint), récupérez sur internet quelques images de chat ou de poney et mettez-les dans un dossier. Utilisez `scp` pour envoyer ce dossier sur le serveur.

### Exercices avancés

- Installez MobaXterm sous Windows et essayez de vous connecter à votre serveur avec cet outil.

- Utilisez `sshfs` pour monter le home de votre utilisateur dans un dossier de votre répertoire personnel.

- Utilisez `ssh -D` pour créer un tunnel avec votre serveur, et configurez Firefox pour utiliser ce tunnel pour se connecter à Internet. Confirmez que les changements fonctionnent en vérifiant quelle semble être votre IP globale depuis Firefox.

resource en anglais: https://www.baeldung.com/linux/ssh-tunneling-and-proxying
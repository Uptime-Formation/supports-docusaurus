---
title: Cours - Déployer une app PHP MYSQL et le déboguage
---

<!-- ![](/img/linux/admin/previously.jpg)

![](/img/linux/admin/sudoreported.png) -->

## Recap'

- Installer une distribution
- Le gestionnaire de paquet
- Notions de réseau
- Notion de chiffrement
- Administrer à distance avec SSH
- Gérer des services
- Notions de sécurité
- Installer un serveur web

### (tentative de représentation)


![](/img/linux/admin/1.png)


![](/img/linux/admin/2.png)


![](/img/linux/admin/3.png)


![](/img/linux/admin/4.png)


![](/img/linux/admin/5.png)


![](/img/linux/admin/6.png)


![](/img/linux/admin/7.png)





- Jusqu'ici : des pages statiques !

![](/img/linux/admin/7.png)



Comment créer des pages "dynamiques", par exemple :
- espaces utilisateurs (mur facebook, compte amazon)
- compte genéré via des données variables (cours de bourse, ...)
- ... ou stockées dans des bases de donnée (liste d'élèves d'une université...) 
- ...



## Historiquement : methode 'CGI' avec par ex. PHP

- CGI: Common Gateway Interface
- Le serveur web déclenche un "script CGI" pour traiter la requête et générer la réponse
- Pas très performant (lancement d'un script à chaque requête, en Perl, PHP, Python, ...)
- ... mais depuis optimisé dans la variante FastCGI
    - c.f. "PHP-FPM" pour "PHP FastCGI Process Manager"


![](/img/linux/admin/nextcloud.png)



## Methode générale / versatile / "moderne"

- Reverse-proxy (c.f. instruction `proxy_pass` dans nginx)
- Le serveur web transmet la requête à un autre programme / daemon qui écoute généralement sur `127.0.0.1:<port>`
- Dans le cas d'un reverse proxy, il y a une séparation claire entre le serveur web et l'applicatif (a la différence du CGI où il se peut que ce soit un script lancé à chaque requête)


![](/img/linux/admin/proxypass.png)



## 502 Bad Gateway / 504 Gateway Timeout

- Erreurs courantes lorsqu'on debug une installation avec du CGI / Reverse proxy
- La "gateway" désigne le process avec lequel Nginx communique
    - bad gateway = nginx n'arrive pas du tout à communiquer avec le process
    - gateway timeout = le process a mis trop longtemps à traiter la requête




## Bases de données / MySQL

- MySQL est classiquement utilisé pour gérer des bases de données
- Les données sont structurées de façon cohérente pour être accédées de manière efficace
- Interface avec PHP qui peut venir piocher dyaniquement des données
- PHP / L'app met ensuite en forme ces données pour générer la page

- N.B. : MariaDB est un fork du MySQL originel
- Un autre moteur SQL très connu est PosgreSQL




## LAMP

Une pile logicielle historique et classique pour construire et déployer une app web dynamique

- Linux
- Apache (... plutot que Nginx dans notre cas)
- Mysql
- PHP



## Nextcloud

![](/img/linux/admin/nextcloud-logo.jpg)



## Nextcloud

- Un logiciel libre, auto-hébergeable
- Stockage et synchronisation de fichiers sur un serveur
   - (similaire à Google Drive, Dropbox, )
- Basé sur PHP / MySQL

- Et aussi : calendrier, contacts, et pleins de modules variés


## Nextcloud

![](/img/linux/admin/nextcloud-interface.png)



## Nextcloud : procédure d'installation

- Télécharger (et décompresser) les sources
- (Configurer PHP)
- Créer une base de donnée MySQL
- Configurer Nginx
- Configurer l'application
- Tester et valider


# Investiguer et réparer des problèmes


## Méthode générale

- Comprendre que le deboggage fait partie du job !
- Être attentif, méthodique
- Chercher et consulter les logs...
   - ... et lire les messages attentivement !
- Comparer les messages à ce que l'on vient de faire, identifier à quel niveau se situe le problème ...
- Chercher des infos sur Internet ...
  - avec des mots clefs approprié


## Méthode générale

Malheureusement ...

- Logs pas forcément trouvable (ou alors messages abscons)
- Demande un peu d'expérience pour savoir quoi / où chercher ...


## Sources d'information

Savoir lire des posts sur Stack Overflow et ses dérivés :
- Stack Overflow (développement / programmation)
- Super User (administration système géneraliste / amateur)
- Server Fault (contexte pro., e.g. maintenance de serveur)
---
slug: /
title: Accueil
sidebar_position: 0
---

# Bienvenue sur le site des supports de formation

Utilisez le menu de gauche pour parcourir les cours et TP.


## Plateforme Guacamole

- Accédez à Guacamole à l'adresse fournie par le formateur, par exemple `guacamole.k8s.dopl.uk` ou `guacamole.uptime-formation.fr`.

- Accédez à votre VM via l'interface Guacamole avec le login fourni par le formateur (traditionnellement votre prenom en minuscule et sans accent et un mot de passe générique indiqué à l'oral)

- Pour accéder au copier-coller de Guacamole, il faut appuyer simultanément sur **`Ctrl+Alt+Shift`** et utiliser la zone de texte qui s'affiche (réappuyer sur `Ctrl+Alt+Shift` pour revenir à la VM).

- Cependant comme ce copier-coller est capricieux, il est conseillé d'ouvrir cette page de doc dans le navigateur à l'intérieur de guacamole et de suivre à partir de la machine distance.

## Imprimer le site internet

- Est-ce vraiment nécessaire ? Normalement non car le site (un snapshot unique pour la formation) va rester en ligne pendant des années.

- Pour le moment le site de support doit être imprimé page par page avec la fonction d'impression pdf du navigateur

## Problèmes avec le snap firefox

```sh
$ sudo add-apt-repository ppa:mozillateam/ppa


$ echo '
Package: *
Pin: release o=LP-PPA-mozillateam
Pin-Priority: 1001

Package: firefox
Pin: version 1:1snap1-0ubuntu2
Pin-Priority: -1
' | sudo tee /etc/apt/preferences.d/mozilla-firefox


$ sudo snap remove firefox


$ sudo apt install firefox

```

---
title: "Labs : Comment ça marche"
sidebar_position: 1

---

# Labs 

**Notre solution répond à une problématique courante dans la formation.**

La mise en place de nouveaux outils sur des postes souvent sécurisés fait perdre un temps précieux en début de formation.  

Notre envie était de simplifier ça, en fournissant des labs accessibles par navigateur. Tout simplement.

**C'est pourquoi nous mettons à disposition de chaque stagiaire un environnement de travail préconfiguré pour la formation.**

Chaque environnement est un Serveur Privé Virtuel accessible en SSH et via une interface VNC.

Chaque environnement est fourni le temps de la formation, et les stagiaires sont libres d'utiliser leur environnement à leur souhait.

## Accès individuel

**La machine est ajoutée dans le DNS avec un nom individuel.** 

Ce nom de domain contient le prénom de la personne et le titre de la session. 

Par exemple: `sacha.brx2022.uptime-formation.fr`

**Une machine supplémentaire est fournie pour servir de serveur VNC**

Nous utilisons la solution Apache Guacamole qui fait du VNC dans le navigateur. 

**Chaque stagiaire reçoit par email avant la formation des identifiants**

Ces identifiants sont :
* son prénom
* un mot de passe

Avec ces identifiants, les stagiaires accèdent à leur machine:
* **en SSH**
  * accès par le nom de domaine individuel ex: `sacha.brx2022.uptime-formation.fr`
  * login : prénom de la personne. ex: `sacha`
  * mdp : fourni dans le mail 
  * accès : `ssh sacha@sacha.brx2022.uptime-formation.fr`

* **au serveur VNC** 
  * accès par le nom de domaine commun ex: `vnc.brx2022.uptime-formation.fr`
  * login : prénom de la personne. ex: `sacha`
  * mdp : fourni dans le mail 
  * accès: `https:vnc.brx2022.uptime-formation.fr` puis saisie des identifiants.


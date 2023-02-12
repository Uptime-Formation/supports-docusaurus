---
title: "Pourquoi Docker : Les pratiques de déploiement"
pre: "<b>1.05 </b>"
weight: 6
---

## Objectifs Pédagogiques
  - Connaître l'histoire des pratiques devops
  - Comprendre les pratiques d'Infrastructure As Code et d'automatisation

## Une petite histoire de l'automatisation du déploiement 

**On va voir les problèmes de déploiement qui ont amené aux solutions Docker via l'évolution de la question éternelle.**


```
(Dev) - Comment je déploie mon code sur le serveur de prod ? 
(Ops) - Comme tu veux, mais pas le vendredi.
```
**À travers quelques exemples et quelques périodes**


* FTP (avant 2000)
* SSH + GIT (2009)
* Provisioning & IAC (2010)
* Capistrano (2012)
* Devops (2014)
* 12 factors app / Heroku (2015)
* docker (2016)
* k8s (2018)

Ces dates et ces expériences sont liées à mon expérience. 

Par exemple Capistrano est né en 2006, mais ce n'est pas arrivé tout de  suite. 

Idem, le Devops est né en 2008, mais n'est pas devenu reconnu de suite.  

### Les contraintes du déploiement et les solutions actuelles

Les applications, en particulier pour le web, ont des contraintes à gérer
- versions du code 
  > J'ai codé une nouvelle fonctionnalité, comment j'intègre ça en prod ?
- différents environnements (dev, prod) 
  > J'ai testé sur la dev, on le passe en prod ?
- fichiers de configuration par environnement
  > Qui connaît le mot de passe de la DB de prod ?
- dépendances internes (ex: librairies, modules)  
  > Comment j'intègre en prod la librairie qui lit des fichiers Excel ? 
- dépendances externes (ex: bases de données)
  > J'ai ajouté un redis pour stocker du cache, comment on déploie ça en prod ?
- options de lancement du process (options, variables)
  > Tu savais pas que l'appli crash sans l'option `-XX:+UseZGC` ? 
- processus de mise à jour (sauvegarde, retour en arrière) 
  > La nouvelle version de la DB marche pas avec l'ancienne version du code, on fait quoi ?

On va voir comment, aujourd'hui, on a progressé dans la résolution de ces problèmes : 

- Les différents environnements utilisent les mêmes images  
- Chaque image docker correspond à un état du code dans git
- Les options de configuration par environnement sont dans l'image docker
- Les dépendances internes sont dans l'image docker
- Les options de lancement du code sont dans l'image docker
- La mise à jour est gérée par un orchestrateur
- Les dépendances externes sont manifestées auprès d'un orchestrateur
- Les backups sont automatisés par l'orchestrateur
- Les changements importants de la base de donnée sont découplés du code



## Comment on en est arrivé là / une histoire des pratiques devops

### FTP (avant 2000)

On utilise une application bureau pour mettre à jour le code en fonction des modifications faites sur le poste, fichier par fichier.

* Tous les désavantages qu'on peut imaginer  

 

### SSH + GIT (2009)

On stocke les versions du code dans GIT et on se connecte sur le serveur de prod pour faire un pull.

* au moins on peut revenir en arrière sur le code

### Provisioning & IAC (2010)

On peut déployer de nouvelles machines avec les logiciels et le code. 

* On a une reproductibilité des environnements d'exécution

### Capistrano (2012)

Un gestionnaire de mise à jour capable d'orchestrer les mises à jour avec des backups et des versions.

* Automatisation mais pas de reproductibilité simple 


### 12 factors app / Heroku  (2015)

12 contraintes concernant le déploiement qui visent à les micro services et la croissance. 

* Règles / bonnes pratiques concernant le code, les dépendances, la configuration, et autres 

### docker (2016)

Un système qui formalise la construction opérant les applications, leur distribution et 

* Uniformisation du code dans les différents environnements et portabilité

### k8s (2018)

Une architecture modulaire complexe pour exécuter les applications dans des environnements sécurisés

* Le déploiement devient un objet en soi, au coeur de toute un système complexe mais qui permet de gérer tous ces problèmes.



##  L'Infrastructure As Code = formalisation des conditions "optimales" de fonctionnement des processus

"Optimales" car à un moment T, en fonction d'un contexte humain, technique, professionnel.

Par exemple le monitoring, les logs et les graphs sont un enjeu permanent.

Au départ, on a des pratiques informelles tant chez les devs que chez les adminsys. 

**Progressivement, on essaie de formaliser l'applicatif pour maximiser** 

- la capacité de développer
- la capacité de tester 
- la sécurité de l'application
- la capacité d'évolution et de changement 
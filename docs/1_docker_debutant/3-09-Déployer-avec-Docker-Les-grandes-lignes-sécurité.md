---
title: 3.09 Déployer avec Docker Les grandes lignes sécurité
pre: "<b>3.09 </b>"
weight: 37
---

## Objectifs pédagogiques
  - Connaître les méthodes de conteneurisation
  - Connaître les bonnes pratiques
 
---

### Exemple : bloquer le système hôte depuis un simple conteneur

```shell
$ :(){ : | :& }; :
``` 

Ceci est une _fork bomb_. Dans un conteneur **non privilégié**, on bloque tout Docker, voire tout le système sous-jacent, en l'empêchant de créer de nouveaux processus.


Pour éviter cela il faudrait limiter la création de processus via une option kernel.

Ex: `docker run -it --ulimit nproc=3 --name fork-bomb bash`

**L'isolation des conteneurs n'est donc ni magique, ni automatique, ni absolue !**
Correctement paramétrée, elle est tout de même assez **robuste, mature et testée**.


# Retour sur les technologies de virtualisation

On compare souvent les conteneurs aux machines virtuelles. 

Mais ce sont de grosses simplifications parce qu'on en a un usage similaire : isoler des process.


![](../assets/images/vm_vs_containers.png)

- **VM** : une abstraction complète pour simuler des machines

  - un processeur, mémoire, appels systèmes, carte réseau, carte graphique, etc.

- **conteneur** : un découpage dans Linux pour séparer des ressources (accès à des dossiers spécifiques sur le disque, accès réseau).

**Les deux technologies peuvent utiliser un système de quotas pour l'accès aux ressources matérielles (accès en lecture/écriture sur le disque, sollicitation de la carte réseau, du processeur).**

---

# Docker Origins : genèse du concept de **conteneur**

Les conteneurs mettent en œuvre un vieux concept d'isolation des processus permis par la philosophie Unix du "tout est fichier".


### `chroot` ou pivot_root

Implémenté principalement par le programme `chroot` [*change root* : changer de racine], présent dans les systèmes UNIX depuis longtemps (1979 !) :

  > "Comme tout est fichier, changer la racine d'un processus, c'est comme le faire changer de système".

### Les _cgroups_ pour la comptabilité et limitation des ressources consommées


  - usage de la mémoire
  - du disque
  - du réseau
  - des appels système
  - du processeur (CPU)

---

### Les _namespaces_ (espaces de noms)

Ils  cloisonnent 
- mount : masque les montages 
- pid : repart de 1 le compteur de process id
- network : réinitialise la couche réseau 
- Inter-process Communication : empêche le partage de mémoire entre process de namespaces différents 
- UTS : change le hostname
- User ID : modifie les identifiants réels de l'utilisateur (ex: 100000 => 0 soit root dans le conteneur) 
- Control group : les cgroups sont un "arbre" dont l'enfant peut voir uniquement sa partie
- Time Namespace : avoir un temps différent du parent

---

## Les capabilities 

C'est une division des autorisations de l'utilisateur root.

> Analogie: Le roi.  
> Il a tous les droits.  
> Mais il délègue uniquement une partie de sont pouvoir à ses représentants (juges, magistrats, etc.)  
> Le user root est roi, mais il va supprimer certains droits à certains process selon les besoins.

L'utilisateur root (ou tout ID avec UID de 0) bénéficie d'un traitement spécial lors de l'exécution de processus. 

Le noyau et les applications sont généralement programmés pour ignorer la restriction de certaines activités lorsqu'ils voient cet ID utilisateur. 

En d'autres termes, cet utilisateur est autorisé à faire (presque) n'importe quoi.

**Les capabilities Linux fournissent un sous-ensemble des privilèges racine disponibles à un processus.** 

Cela divise efficacement les privilèges root en unités plus petites et distinctes. Chacune de ces unités peut alors être indépendamment attribuée à des processus. De cette façon, l'ensemble complet des privilèges est réduit et diminue les risques d'exploitation.


---

## Bonnes pratiques 

* Un conteneur privilégié est _root_ sur la machine !
* Toujours utiliser des user non root
* Monter au maximum en read only (un fichier binaire pirate est visible au milieu d'images)

--- 

## Renforcer la sécurité
- Mettre des règles  des _cgroups_ corrects : `ulimit -a`

- Activer les _user namespaces_ ne sont pas utilisés !
  - exemple de faille : <https://medium.com/@mccode/processes-in-containers-should-not-run-as-root-2feae3f0df3b>
  - exemple de durcissement conseillé : <https://docs.docker.com/engine/security/userns-remap/>
- le benchmark Docker CIS : <https://github.com/docker/docker-bench-security/>

- La sécurité de Docker c'est aussi celle de la chaîne de dépendance, des images, des packages installés dans celles-ci : on fait confiance à trop de petites briques dont on ne vérifie pas la provenance ou la mise à jour

  - [Clair](https://github.com/quay/clair) : l'analyse statique d'images Docker

- [docker-socket-proxy](https://github.com/Tecnativa/docker-socket-proxy) : protéger la _socket_ Docker quand on a besoin de la partager à des conteneurs comme Traefik ou Portainer


# Théorie : Virt vs. Cont

## Objectifs pédagogiques

**Théoriques**

- Connaître les spécificités de la virtualisation KVM

**Pratiques**

- Lancer des commandes Docker

**Stratégiques**

- Savoir choisir KVM comme outil d'architecture en fonction de critères rationnels.

---


# Retour sur les technologies de virtualisation

On compare souvent les conteneurs aux machines virtuelles. 

Mais ce sont de grosses simplifications parce qu'on en a un usage similaire : isoler des process.


![](../../static../../static/img/vm_vs_containers.png)

- **VM** : une abstraction complète pour simuler des machines

  - un processeur, mémoire, appels systèmes, carte réseau, carte graphique, etc.

- **conteneur** : un découpage dans Linux pour séparer des ressources (accès à des dossiers spécifiques sur le disque, accès réseau).

**Les deux technologies peuvent utiliser un système de quotas pour l'accès aux ressources matérielles (accès en lecture/écriture sur le disque, sollicitation de la carte réseau, du processeur).**

---

## Micro TP : lancer un conteneur docker 

**On va lancer une instance docker dans une VM et observer son statut vis à vis du système parent.**

### Host 

- Installer le docker daemon et la ligne de commande dans une VM
- Lancer un conteneur nginx avec 
```shell
$ docker run -d nginx 
```
- Lancer depuis la VM 
```shell
$ ps fauxw | grep nginx 
```
- Lancer depuis le hôte KVM
```shell
$ ps fauxw | grep nginx 
```
---

**Que se passe-t-il ?**

Quel est la différence de visibilité entre le processus d'un conteneur et celui d'une VM ?

--- 

## Les avantages des conteneurs 

- **Légèreté** : Pas besoin de virtualiser tout un système (coûts, empreinte carbone)
- **Infrastructure as Code** : La création d'images custom est simplifiée
- **Orchestrateurs** : Capacité d'opérer des systèmes complexes intégralement  (du FS au load balancers TLS)

---

## Micro TP : créer une image Docker 

- Créer un fichier Dockerfile avec le contenu suivant
```Dockerfile
# Filename : Dockerfile 
# our base image
FROM ubuntu

WORKDIR /srv

RUN apt update && apt install -y python3  

# run the application
CMD ["sh", "-c", "echo Hello World"]
```
- Lancer la commande depuis le dossier contenant le fichier
```shell
$ docker built -t myimage .
```
- Démarrer l'image produite 
```shell
$ docker run myimage 
```
--- 

## Les techniques de conteneurs 

Les conteneurs mettent en œuvre plusieurs méthodes certaines anciennes et d'autres nouvelles.


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




# Evaluation - formation Docker-Kubernetes du 16 décembre 2022

## Questionnaire pour tester l'acquisition des concepts importants de la formation :

- Le questionaire est à choix multiples (les questions peuvent avoir plusieurs réponses justes, voire que des réponse justes, mais jamais que des réponses erronées).
- Les sources externes sont autorisées.
- Certaines questions impliquent de coller dans le formulaire un code kubernetes.

### 1 - Les principaux atouts de Kubernetes sont :

La sécurité simplifiée pour les applications
La déclarativité de sa configuration
La diversité des cas d'usage qu'il supporte
La puissance expressive et la simplicité de son langage de configuration natif
La versatilité des configurations d'installation et la standardisation qu'il propose

## 2 - Qu'est qu'un Ingress ?

Un reverse proxy HTTP configurable nativement dans kubernetes pour exposer à l'exterieur des applications web
Un firewall natif Kubernetes qui permet de créer des règles de communication réseau à l'intérieur du cluster
Un point de communication réseau incontournable à créer pour chaque pod du cluster

## 3 - Qu'est ce qu'une CRD (Custom Resource Definition) ?

Une resource dédiée à limiter l'access à l'API Kubernetes via un mechanisme RBAC
Un nouveau type de resource Kubernetes qui permet d'étendre les fonctionnalité du cluster
Un nouveau module ajouté à l'API du cluster par un opérateur Kubernetes

## 4 - Docker et Kubernetes promeuvent l'immutabilité des infrastructures. Cela implique concrêtement :

Que les images de conteneurs permettent de créer et recréer autant de conteneurs que nécessaire dans un état souhaité
Qu'on ne peut pas écrire sur le disque d'un conteneur
Que les conteneurs qui tournent en production ne devraient pas être modifiés après lancement
Que les conteneurs doivent pouvoir être supprimés sans risque
Que des volumes de persistences sont automatiquement créés pour chaque pod d'un cluster

## 5 - Où peut-on se renseigner généralement à propos de la configuration d'une image docker tierce ?

Via le Docker Hub et le README des images
Via le code Kubernetes du déploiement ou du pod
Via le code du Dockerfile

## 6 - La haute disponibilité d'une application dans Kubernetes implique:

D'utiliser un système de CI/CD correctement configurer pour le déploiement cloud
D'augmenter le nombre de réplicats au delà de 1
De disposer d'un cluster sur plusieurs zones géographiques
De disposer d'une configuration d'autoscaling
De disposer d'un cluster avec plusieurs noeuds `worker`
De disposer d'un cluster avec plusieurs noeuds `master`
De créer plusieurs pods à la main
De créer un Ingress pour faire rentrer le traffic dans le cluster

## 7 - Déploiement Kubernetes :

Proposez ici un code kubernetes permettant
- de déployer le conteneur `nginx` 
- le rendre accessible à l'extérieur d'une façon ou d'une autre

## 8 - Comment lancer un conteneur (Docker ou compatible OCI) dans un cluster Kubernetes ?

Grâce à la commande `docker run ...`
En déployant un service de type NodePort
En créant une resource pod à la main
Avec une resource Deployment
Avec un autre controlleur comme Statefulset ou Job...
Avec une resource Ingress
Grâce à la commande `kubectl create deployment ...`

## 9 - Pour construire une image Docker :

On doit écrire un Dockerfile
On peut utiliser un pipeline de CI/CD
On peut utiliser utiliser d'autre outils que Docker comme kaniko ou buildpack
Il faut généralement utiliser une image existante comme base
On doit partir du code d'une nouvelle application à dockeriser

## 10 - Pour créer un cluster Kubernetes

On peut louer un service managé dans le cloud
On peut utiliser une solution automatique d'installation en une seule commande
On peut installer et configurer à la main chaque composant du cluster
On peut simplement lancer un conteneur préconfiguré pour obtenir un cluster de développement

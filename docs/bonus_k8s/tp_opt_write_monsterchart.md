---
title: TP optionnel - Écrire un chart pour notre application monsterstack
draft: false
weight: 2090
---

- Récupérez la correction du dernier TP sur le déploiement de la monsterstack avec la commande: `git clone -b tp_monsterstack_final https://github.com/Uptime-Formation/corrections_tp.git tp_monsterchart`.

- Ouvrez le dans VSCode

- Pour démarrer le développement d'un chart on peut utiliser une commande helm d'initialisation qui va générer un chart d'exemple : `helm create monsterchart`
git clone -b tp_monsterstack_final https://github.com/Uptime-Formation/corrections_tp.git tp_monsterchart
Observons un peu le contenu de notre Chart d'exemple :

- Un dossier `templates` avec tous les fichiers resources à trou qui seront templatés par helm et quelques snippet utilitaires de templating dans _helpers.tpl
- Le fichier `values.yaml` avec les valeurs par défaut pour l'installation, qu'on va pouvoir surcharger pour installer le chart
- Un fichier NOTES.txt contenant le texte d'aide qui s'affichera pour l'utilisateur à la fin de l'installation
- Un fichier `Chart.yaml` contenant des informations/paramètres caractérisant le chart lui même comme son nom, sa version et la version nde l'application installée correspondante.

Ce chart d'exemple est déjà installable en l'état et créé un déploiement de nginx, un service et un ingress pour pouvoir afficher la page d'accueil de Nginx.

Nous avons un soucis pour étudier ce chart : la syntaxe lourdement chargée de templating est assez illisible en l'état. Étudier le déploiement concret implique de réaliser le templating pour visualiser résultat final. Deux méthodes plutôt sont possibles :

- `helm template releasename --values=valuefile.yaml ./chart_folder > result.yaml`
- `helm install releasename --dry-run --debug --values=valuefile.yaml ./chart_folder > debug-chart.yaml` 

La seconde a l'avantage d'afficher des informations de debug comme les informations de la release et la liste des valeurs calculées pour le templating.

- Utilisez la deuxième commande pour faire une évaluation de ce qui serait installé avec le chart par défaut

## Une version statique de notre chart

Nous allons dans un premier temps remplacer les templates (à trou) par les fichiers statiques de notre déploiement du TP précédent, puis nous ajouterons quelques paramètres.

- Dupliquez le dossier `templates` en  `templates_backup` puis supprimez les fichiers template yaml et le dossiers test du dossier templates
- Ajoutez vos fichiers d'installation copiés depuis `k8s-deploy-dev`.
- Testez le templating avec la commande utilisée précédemment.

Ce chart statique a plusieurs soucis mais notamment il ne permet par d'être installé plusieurs fois. Nous allons corriger quelques aspects en le variabilisant.

## Ajouter des paramètres simples

Nous allons paramétrer à minima nos templates pour pouvoir modifier: 

- les images utilisées pour l'installation des services
- le nom des resources pour éviter les conflits
- la configuration du ingress

Pour ce faire:

- Déplacez le fichier `values.yaml` existant dans le dossier `templates_backup`.
- Ajoutez à un nouveau fichier `values.yaml` avec le code suivant : 

```yaml
frontend:
  image:
    name: frontend
    tag: latest
  service:
    port: 5000
imagebackend:
  image:
    name: amouat/dnmonster
    tag: "1.0"
redis:
  image:
    name: redis
    tag: latest
```

- Remplacez ensuite dans nos trois fichiers template la valeur image du conteneur par ces valeurs dynamique avec un emplacement de variable de la forme `{{ .Values.imagebackend.image.name }}:{{ .Values.imagebackend.image.tag }}`


Passons maintenant à la gestion dynamique du nom pour pouvoir installer notre chart plusieurs fois. Pour cela nous allons utiliser le helper `monsterchart.fullname` disponible dans le chart d'exemple.

- Observez et commentons ce helper qui génère automatiquement un nom compatible pour notre release
- Observez dans le chart d'exemple (`templates_backup`) comment est utilisé ce helper par exemple dans le template du déploiement.
- Remplacez pour les 3 services (redis, frontend et imagebackend) toutes les occurences de `<nomservice>` dans le nom des ressources et les labels `partie: ` en ajoutant `-{{ include "monsterchart.fullname" . }}` comme suffixe.
- Testez avec la commande d'installation dry run précédente.

Enfin nous allons ajouter la gestion dynamique du ingress en copiant celle du chart d'exemple.
- Supprimez le template `monsterstack-ingress.yaml`
- Copiez le template `ingress.yaml` du backup
- Copiez la section `ingress` depuis le `values.yaml` déplacé dans `templates_backup` vers le `values.yaml` principal et complétez la avec le nom de domaine de votre choix et activez le ingress avec `enabled: true`:
- Modifiez le template ingress pour qu'il pointe vers la bonne ressource service à savoir `frontend-{{ include "monsterchart.fullname" . }}` (il y a deux valeurs à modifier service: name: et serviceName: plus bas.`)
- Dans le même fichier, modifiez enfin la variable port pour l'adapter à notre cas `{{- $svcPort := .Values.service.port -}}` => `{{- $svcPort := .Values.frontend.service.port -}}`

- Testez le résultat et s'il vous semble bon, essayez de déployer votre chart pour de vrai (sans dry-run) et avec `tecpi/monstericon` du dockerhub comme image frontend.
- Vous pouvez essayer d'installer une autre release pour confirmer que tout fonctionne.

### Idées d'amélioration

<!-- TODO 
tester et ajouter la question:
- De même trouvez dans l'exemple de wordpress comment ajouter un paramètre de réplication et répartir les réplicats sur plusieurs noeuds du cluster. Testons cette configuration sur un cluster multinoeud loué. lien vers le dépot scalelaab.
-->

- Paramétrer les labels comme dans le chart exemple. 
- Fixer le bug de connexion à redis et imagebackend en ajoutant un parametrage par variable d'environnement du nom de domaine des services dans app.py.
- Ensuite, s'inspirant du dump du chart wordpress, utilisez une configmap pour générer la variable d'environnement du domaine de chaque service.
- Utiliser pour l'installation de redis une dépendance à un autre chart comme par exemple ce lui de Bitnami (voir sur https://artifacthub.io) et la documentation ici : https://helm.sh/docs/helm/helm_dependency/
- Essayer de packager et héberger le chart comme expliqué ici : https://docs.bitnami.com/tutorials/create-your-first-helm-chart/

### Solution

Le dépôt Git de la correction de ce TP est accessible ici : `git clone -b tp_monsterchart https://github.com/Uptime-Formation/corrections_tp.git`

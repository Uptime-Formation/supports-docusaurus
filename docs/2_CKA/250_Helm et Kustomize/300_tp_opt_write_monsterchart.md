---
title: TP optionnel - Écrire un chart pour notre application monsterstack
draft: false
# weight: 2090
---

- Récupérez la correction du dernier TP sur le déploiement de la monsterstack avec la commande: `git clone -b tp_monsterstack_correction_configmap https://github.com/Uptime-Formation/corrections_tp.git tp_monsterchart`.

- Ouvrez le dans VSCode

Pour démarrer le développement d'un chart on peut utiliser une commande helm d'initialisation qui va générer un chart d'exemple :

- aller sur le Bureau: `cd ~/Desktop/tp_monsterchart`
- puis créer le chart: `helm create monsterchart`

Observons un peu le contenu de notre Chart d'exemple :

- Un dossier `templates` avec tous les fichiers resources à trou qui seront templatés par helm et quelques snippet utilitaires de templating dans _helpers.tpl
- Le fichier `values.yaml` avec les valeurs par défaut pour l'installation, qu'on va pouvoir surcharger pour installer le chart
- Un fichier NOTES.txt contenant le texte d'aide qui s'affichera pour l'utilisateur à la fin de l'installation
- Un fichier `Chart.yaml` contenant des informations/paramètres caractérisant le chart lui même comme son nom, sa version et la version nde l'application installée correspondante.

Ce chart d'exemple est déjà installable en l'état et créé un déploiement de nginx, un service et un ingress pour pouvoir afficher la page d'accueil de Nginx.

Nous avons un soucis pour étudier ce chart : la syntaxe lourdement chargée de templating est assez illisible en l'état. Étudier le déploiement concret implique de réaliser le templating pour visualiser le résultat final. Deux méthodes plutôt sont possibles :

- `helm template <releasename> --values=valuefile.yaml ./<chart_folder> > result.yaml`
- `helm install <releasename> --dry-run --debug --values=valuefile.yaml ./chart_folder > debug-chart.yaml` 

La seconde a l'avantage d'afficher des informations de debug comme les informations de la release et la liste des valeurs calculées pour le templating.

- Utilisez la deuxième commande pour faire une évaluation de ce qui serait installé avec le chart par défaut

## Une version statique de notre chart

Nous allons dans un premier temps remplacer les templates (à trou) par les fichiers statiques de notre déploiement du TP précédent, puis nous ajouterons quelques paramètres.

- Dupliquez le dossier `templates` en  `templates_backup` puis supprimez les fichiers template yaml et le dossiers test du dossier templates
- Ajoutez vos fichiers d'installation copiés depuis `k8s-deploy-dev`.
- Testez le templating avec la commande utilisée précédemment.

Ce chart statique a plusieurs soucis mais notamment il ne permet par d'être installé plusieurs fois. Nous allons corriger quelques aspects en le variabilisant.

## Utiliser skaffold pour développer

Skaffold est un outils pour développer de façon dynamique dans un cluster (voir TP afférant avec monsterstack)

- Créez le fichier de config skaffold suivant: 

```yaml
apiVersion: skaffold/v2beta5
kind: Config
build:
  artifacts: []
    # - image: docker.io/<votre_login_dockerhub>/frontend
deploy:
  helm:
    releases:
      - name: monsterchart
        chartPath: ./monsterchart
        # artifactOverrides:
        #   imageKey: docker.io/<votre_login_dockerhub>/frontend
        imageStrategy:
          fqn: {}
```

- Assurez vous d'être connecté au docker hub (avec `docker login`).

- Lancez `skaffold dev` va déployer le chart automatiquement à chaque modification des fichiers template (désactiver l'auto-save de vscode peut aider ainsi que SaveAll pour éviter les inconsistance pendant l'edition)

## Ajouter des paramètres simples

Nous allons paramétrer à minima nos templates pour pouvoir modifier: 

- les images utilisées pour l'installation des services
- le nom des resources pour éviter les conflits
- la configuration du ingress
- le type de service avec un defaut à `NodePort`

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
    type: ClusterIP
imagebackend:
  image:
    name: amouat/dnmonster
    tag: "1.0"
redis:
  image:
    name: redis
    tag: latest
```

- Remplacez ensuite dans nos trois fichiers template la valeur image du conteneur par ces valeurs dynamiques avec un emplacement de variable de la forme `{{ .Values.imagebackend.image.name }}:{{ .Values.imagebackend.image.tag }}`


Passons maintenant à la gestion dynamique du nom pour pouvoir installer notre chart plusieurs fois. Pour cela nous allons utiliser le helper `monsterchart.fullname` disponible dans le chart d'exemple.

- Observez et commentons le helper qui génère automatiquement un nom compatible pour notre release
- Observez dans le chart d'exemple (`templates_backup`) comment est utilisé ce helper par exemple dans le template du déploiement ?
- Remplacez pour les 3 services (redis, frontend et imagebackend) toutes les occurences de `<nomservice>` dans le nom des ressources et les labels en ajoutant `-{{ include "monsterchart.fullname" . }}` comme suffixe.
- Testez avec la commande d'installation dry run précédente.

Enfin nous allons ajouter la gestion dynamique du ingress en copiant celle du chart d'exemple.
- Supprimez le template `monsterstack-ingress.yaml`
- Copiez le template `ingress.yaml` du backup
- Copiez la section `ingress` depuis le `values.yaml` déplacé dans `templates_backup` vers le `values.yaml` principal et complétez la avec le nom de domaine de votre choix et activez le ingress avec `enabled: true`:
- Modifiez le template ingress pour qu'il pointe vers la bonne ressource service à savoir `frontend-{{ include "monsterchart.fullname" . }}` (il y a deux valeurs à modifier service: name: et serviceName: plus bas.`)
- Dans le même fichier, modifiez enfin la variable port pour l'adapter à notre cas `{{- $svcPort := .Values.service.port -}}` => `{{- $svcPort := .Values.frontend.service.port -}}`

- Testez le résultat et s'il vous semble bon, essayez de déployer votre chart pour de vrai (sans dry-run) et avec `tecpi/monstericon` du dockerhub comme image frontend.
- Vous pouvez essayer d'installer une autre release pour confirmer que cela fonctionne.

### Fixer le nom de domaine pour matcher le nom du service

- Modifier la configmap définissant les deux noms de domaine en incorporant le fullname: `<domain>-{{ include "monsterchart.fullname" . }}`

### Utiliser un Chart redis

- Utiliser pour l'installation de redis une dépendance à un autre chart comme par exemple ce lui de Bitnami (voir sur https://artifacthub.io) et la documentation ici : https://helm.sh/docs/helm/helm_dependency/


- Ajoutez à `Chart.yaml`

```yaml
dependencies:
  - name: redis
    condition: redis.enabled
    version: "19.0.1"
    repository: "https://charts.bitnami.com/bitnami"
```

- Ajouter à `values.yaml`:

```yaml
redis:
  enabled: true
  auth:
    enable: false
```

- supprimez les autres paramètres de redis dans `values.yaml` et les fichier de template pour redis

- lancez `helm dependency build` dans le docker `monsterchart`.

- templatez le résultat :  comment s'appelle le service redis master ?

- Modifiez la configmap du frontend pour que le domaine rédis soit : ` "{{ .Release.name }}-redis-master"`

### Templater notre chart pour l'utiliser en mode GitOps

Si une instance d'argoCD a été installé dans un TP précédent:

- Utilisez `helm template` pour exporter le chart sous forme d'un seul manifeste yaml
- Uploadez le sur github ou gitlab (en mode public pour simplifier l'exemple)
- Créez un projet `argoCD`, idéalement dans votre propre `appProject` pour déployer l'application "en prod"

### Solution

Le dépôt Git de la correction de ce TP est accessible ici : `git clone -b tp_monsterchart https://github.com/Uptime-Formation/corrections_tp.git`

---
title: TP - Installation simple et découverte de Prometheus
# sidebar_class_name: hidden
---

Dans ce TP nous allons explorer comment installer, configurer et utiliser une instance simple de Prometheus. Vous allez télécharger et exécuter Prometheus localement, le configurer pour collecter des données sur lui-même et sur une application exemple, puis travailler avec des requêtes, des règles et des graphiques pour utiliser les séries temporelles collectées.

## Création d'un projet VSCod(ium)

Nous allons jongler entre code de configuration et redémarrage de service et modification de code applicatif. Pour gérer cela il est pratique d'utiliser un IDE comme VSCodium (et d'activer l'autosave dans les settings)

- Créez un dossier tp1 par exemple sur le bureau et ouvrez le avec VSCod(ium)

## Téléchargement et exécution de Prometheus

[Téléchargez la dernière version](https://prometheus.io/download) de Prometheus pour votre plate-forme, puis extrayez la :

```bash
tar xvfz prometheus-*.tar.gz
cd prometheus-*
```

Avant de démarrer Prometheus, configurons-le.

## Configuration de Prometheus pour se surveiller lui-même

Prometheus collecte des métriques à partir de *cibles* en récupérant des métriques à partir de points d'accès (endpoints) HTTP. Étant donné que Prometheus expose également ses données de la même manière à propos de lui-même, il peut également récupérer et surveiller sa propre santé.

Bien qu'un serveur Prometheus qui collecte uniquement des données à propos de lui-même ne soit pas très utile, il constitue un bon exemple de départ. Enregistrez la configuration de base de Prometheus suivante dans un fichier nommé `prometheus.yml` :

```yaml
global:
  scrape_interval:     15s # Par défaut, récupère les cibles toutes les 15 secondes.

  # Attachez ces étiquettes à toute série temporelle ou alerte lors de la communication avec
  # des systèmes externes (fédération, stockage distant, Alertmanager).
  external_labels:
    monitor: 'codelab-monitor'

# Une configuration de récupération contenant exactement une cible à récupérer :
# Ici, c'est Prometheus lui-même.
scrape_configs:
  # Le nom du job est ajouté en tant qu'étiquette `job=<job_name>` à toutes les séries temporelles récupérées à partir de cette configuration.
  - job_name: 'prometheus'

    # Remplacez la valeur par défaut globale et récupérez les cibles de ce job toutes les 5 secondes.
    scrape_interval: 5s

    static_configs:
      - targets: ['localhost:9090']
```

Pour une spécification complète des options de configuration, consultez la [documentation de configuration](https://prometheus.io/docs/prometheus/latest/getting_started/../configuration/configuration/).

## Démarrage de Prometheus

Pour démarrer Prometheus avec le fichier de configuration que vous venez de créer, accédez au répertoire contenant le binaire Prometheus et exécutez :

```bash
# Démarrez Prometheus.
# Par défaut, Prometheus stocke sa base de données dans ./data (indicateur --storage.tsdb.path).
./prometheus --config.file=prometheus.yml
```

Prometheus devrait démarrer. Vous devriez également pouvoir accéder à une page de statut à son sujet à l'adresse [localhost:9090](http://localhost:9090). Attendez quelques secondes que Prometheus collecté quelques données à son sujet à partir de son propre point d'accès HTTP.

Vous pouvez également vérifier que Prometheus sert des métriques à propos de lui-même en accédant à son point d'accès de métriques : [localhost:9090/metrics](http://localhost:9090/metrics)


Source: documentation officielle sous licence CC by SA
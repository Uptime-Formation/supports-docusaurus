---
title: Cours - Alertes
sidebar_class_name: hidden
---

Les alertes sont l'un des éléments constitutifs de la surveillance, permettant d'informer un être humain en cas de problème.

Prometheus vous offre la possibilité de définir des conditions sous forme d'expressions PromQL qui sont continuellement évaluées, et toute série temporelle résultante devient une alerte.

Prometheus n'est pas responsable de l'envoi de *notifications* telles que des e-mails, des messages de chat ou des pages. Cette responsabilité incombe au composant *Alertmanager*.

Prometheus est l'endroit où vous définissez la logique pour déterminer ce qui doit ou ne doit pas déclencher une alerte. Une fois qu'une alerte est *fired* dans Prometheus, elle est envoyée à Alertmanager

Alertmanager peut recevoir des alertes de nombreux serveurs Prometheus et regroupe ensuite les alertes pour envoyer des notifications "régulées".

Cette architecture offre une flexibilité et la possibilité d'obtenir une seule notification basée sur des alertes provenant de différents serveurs Prometheus.

Par exemple, si vous avez un problème de propagation des données vers tous vos datacenters, vous pouvez configurer le regroupement des alertes de manière à recevoir une seule notification au lieu d'être submergé par une notification pour chaque datacenter.

## Alerting Rules

Les règles d'alerte sont similaires aux recording rules : vous placez et groupez les règles d'alerte dans la même section du `prometheus.yml`, et vous pouvez les combiner comme bon vous semble.

Voici un exemple de règle d'alerte :
```yaml
groups:
 - name: node_rules
   rules:
    - record: job:up:avg
      expr: avg without(instance, group)(up{job="node"})
    - alert: PlusieursServeursArretes
      expr: job:up:avg{job="node"} < 0.5
```

Cela définit une alerte avec le nom `'PlusieursServeursArretes` qui se déclenchera si plus de la moitié de vos serveurs (node_exporters) sont inactifs. Vous pouvez reconnaître qu'il s'agit d'une règle d'alerte car elle comporte un champ `alert` plutôt qu'un champ `record`.

Dans cet exemple, nous veillons à utiliser `without` plutôt que `by` pour préserver toutes les autres étiquettes des séries temporelles, qui seront ensuite transmises à l'Alertmanager => avoir les détails de l'objet tels que le job, l'environnement ou le cluster est utile lorsque vous générez la notification.

Alors que pour les recording rules il faut éviter de filtrer les expressions, car les séries temporelles apparaissant et disparaissant sont difficiles à gérer, pour les règles d'alerte, le filtrage est essentiel :

- si l'évaluation de votre expression aboutit à un instant vector vide, aucune alerte ne se déclenchera. En revanche, si des de multiples sampes sont renvoyés, chacun d'entre eux deviendra une alerte.

```yml
- alert: UnServeurDown
  expr: up{job="node"} == 0
```

Par exemple cette règle d'alerte comme celle-ci s'applique automatiquement à chaque instance dans le job `node` que la découverte de service renvoie, et si vous aviez une centaine d'instances hors service, vous obtiendriez une centaine d'alertes déclenchées. Si lors du cycle d'évaluation suivant certaines de ces instances sont de nouveau opérationnelles, ces alertes sont considérées comme *résolues*.

### Identifier les alertes

Une alerte est identifiée d'un cycle d'évaluation à l'autre par ses étiquettes et n'inclut pas l'étiquette du nom de la métrique `__name__`, mais inclut une étiquette `alertname` avec le nom de l'alerte.

En plus d'envoyer des alertes à l'Alertmanager, vos règles d'alerte alimenteront également deux métriques : `ALERTS` et `ALERTS_FOR_STATE`. En plus de toutes les étiquettes de votre alerte, une étiquette `alertstate` est également ajoutée à `ALERTS`. L'étiquette `alertstate` aura la valeur `firing` pour les alertes en cours et `pending` pour les alertes en attente (voir la suite).

Les alertes résolues n'ont pas de samples ajoutés à `ALERTS`. Bien que vous puissiez utiliser `ALERTS` dans vos règles d'alerte comme vous le feriez avec n'importe quelle autre métrique, nous vous conseillons la prudence car cela pourrait indiquer que vous compliquez trop votre configuration.

La valeur de `ALERT_FOR_STATE` est le timestamp Unix lorsque l'alerte a commencé. Cette métrique est utilisée en interne par Prometheus pour restaurer l'état des alertes après un redémarrage.

### Définir un une plage horaire pour les alertes

Alertmanager ne prend pas en charge le routage basé sur l'heure : pour que les notifications ne soient envoyées qu'à certaines heures de la journée, vous pouvez utiliser les fonctions `minute`, `hour`, `day_of_week`, `day_of_month`, `day_of_year`, `days_in_month`, `month` et `year` décrites dans la doc officielle,

Par exemple :

```yml
- alert: PlusieursServeursArretes
  expr: >
    (
        avg without(instance, group)(up{job="node"}) < 0.5
      and on()
        hour() >= 9 < 17
    )
```

Cette alerte ne se déclenchera que de 9 heures à 17 heures UTC. Il est courant d'utiliser `and` pour combiner les conditions d'alerte. Ici, nous avons utilisé `on()` car il n'y avait pas d'étiquettes partagées entre les deux côtés du `and`, ce qui n'est généralement pas le cas.

### Champ `for`

Le monitoring Prometheus implique souvent des "race conditions" et délais : un scrape peut expirer en raison d'une perte de paquet réseau, une évaluation de règle peut être légèrement retardée, et les systèmes que vous surveillez peuvent connaître une brève interruption de connectivité.

=> Pour ne pas être réveillé en pleine nuit pour chaque anomalie et économiser l'énergie pour les problèmes réels on utilise le champ `for` des règles d'alerte :

```yaml
groups:
- name: node_rules
  rules:
  - record: job:up:avg
    expr: avg without(instance, group)(up{job="node"})
  - alert: PlusieursServeursArretes
    expr: avg without(instance, group)(up{job="node"}) < 0.5
    for: 5m
```

Le champ `for` signifie qu'une alerte donnée doit être active pendant au moins cette durée avant de se déclencher. Tant que la condition `for` n'est pas satisfaite, une alerte est considérée comme `en attente`. Une alerte en attente mais non encore déclenchée n'est pas envoyée à l'Alertmanager.

Après avoir créé cette alerte et stoppé le node_exporter pour la déclencher...

... le Allons voir *http://localhost:9090/alerts* et cliquons sur le nom de l'alerte.

Prometheus n'a aucune notion de détection de clignotement pour les alertes : il faut choisir les seuils d'alerte de manière à ce que le problème soit suffisamment grave pour nécessiter l'intervention d'un être humain (même si le problème s'atténue par la suite).

Un `for` d'au moins 5 minutes est un minimum raisonnable pour toutes vos alertes. Cela éliminera les faux positifs pour la plupart des anomalies, y compris les fluctuations brèves. On pourrait craindre que cela empêche de réagir immédiatement à un problème, mais il faut probablement 5 minutes pour se réveiller démarrer l'ordinateur et commencer le débogage. Il même souvent au moins 20 à 30 minutes pour avoir une idée précise de la situation.

### Étiquettes (labels) pour les alertes

Tout comme pour les recording rules, vous pouvez spécifier des `labels` pour une règle d'alerte. L'utilisation de `labels` avec les règles d'enregistrement est assez rare, mais c'est une pratique courante avec les règles d'alerte.

Par exemple, vous pouvez avoir une étiquette `severity` indiquant si une alerte est destinée à alerter quelqu'un, voire à le réveiller, ou s'il s'agit d'un ticket pouvant être traité de manière moins urgente.

Voici un exemple :

```yaml
- record: job:up:avg
    expr: avg without(instance, group)(up{job="node"})
- alert: UnServeurArrete
  expr: up{job="node"} == 0
  for: 1h
  labels:
    severity: ticket
- alert: PlusieursServeursArretes
  expr: job:up:avg{job="node"} < 0.5
  for: 5m
  labels:
    severity: page
```

Cela signifie qu'une machine isolée en panne ne nécessite pas une intervention immédiate, mais si la moitié de vos machines sont hors service, cela nécessite une enquête urgente.
Voici le texte traduit en français, au format Markdown, en supprimant les liens, les éléments de syntaxe ePub, en ajoutant l'équivalent anglais des mots techniques entre parenthèses et en supprimant les notes de bas de page :

La balise `severity` ici n'a aucune signification sémantique particulière ; c'est simplement une étiquette ajoutée à l'alerte qui sera disponible pour votre usage lorsque vous configurerez l'Alertmanager. Lorsque vous ajoutez des alertes dans Prometheus, vous devriez configurer les choses de manière à ce que vous n'ayez besoin d'ajouter qu'une étiquette `severity` pour que l'alerte soit dirigée correctement, et que vous n'ayez que rarement à ajuster votre configuration d'Alertmanager.

En plus de l'étiquette `severity`, si un Prometheus peut envoyer des alertes à différentes équipes, il n'est pas inhabituel d'avoir une étiquette `team` ou `service`.

S'il n'y a qu'un seul Prometheus qui envoie des alertes à une seule équipe, vous utiliseriez des étiquettes externes (comme discuté dans la section "External Labels"). Il ne devrait normalement pas être nécessaire de mentionner des étiquettes comme `env` ou `region` dans les règles d'alerte ; elles devraient déjà être sur l'alerte en raison d'être des étiquettes de cible qui se retrouvent dans la sortie de l'expression d'alerte, ou elles seront ajoutées ultérieurement par `external_labels`.

Parce que toutes les étiquettes d'une alerte, à la fois de l'expression et des `labels`, définissent l'identité d'une alerte, il est important qu'elles ne varient pas d'un cycle d'évaluation à l'autre. Mis à part le fait que de telles alertes ne satisferaient jamais le champ `for`, elles encombreraient la base de données de séries temporelles de Prometheus, de l'Alertmanager et de vous-même.

Prometheus ne permet pas à une alerte d'avoir plusieurs seuils, mais vous pouvez définir plusieurs alertes avec différents seuils et étiquettes :

```yml
- alert: FDsNearLimit
  expr: >
    process_open_fds > process_max_fds * .95
  for: 5m
  labels:
    severity: page
- alert: FDsNearLimit
  expr: >
    process_open_fds > process_max_fds * .8
  for: 5m
  labels:
    severity: ticket
```

Notez que si vous dépassez les 95 % de la limite des descripteurs de fichiers, ces deux alertes se déclencheront. Essayer de faire en sorte qu'une seule d'entre elles se déclenche serait dangereux, car si la valeur oscille autour de 95 %, aucune alerte ne se déclenchera jamais.

De plus, une alerte qui se déclenche devrait être une situation où vous avez déjà décidé qu'il vaut la peine de demander à un être humain de jeter un œil à un problème. Si vous pensez que cela peut être perçu comme du spam, vous devriez essayer d'ajuster les alertes elles-mêmes et envisager s'il est nécessaire de les avoir en premier lieu, plutôt que d'essayer de mettre le génie de nouveau dans la bouteille lorsque l'alerte se déclenche déjà.




Vous pouvez également utiliser des annotations avec des valeurs statiques, telles que des liens vers des tableaux de bord utiles ou de la documentation.

```markdown
- alert: 'UnServeurDown
  for: 5m
  expr: up{job="prometheus"} == 0
  labels:
    severity: page
  annotations:
    summary: 'L'instance {{$labels.instance}} de {{$labels.job}} est hors ligne.'
    dashboard: http://some.grafana:3000/dashboard/db/prometheus
```

Eviter de fournir toutes les informations de débogage possibles. Vous devriez considérer les annotations d'alerte et les notifications principalement comme un panneau indicateur pour vous orienter dans la bonne direction pour le débogage initial. Vous pouvez obtenir des informations bien plus détaillées et à jour dans une dashboard que dans quelques lignes d'une notification d'alerte.

La *Notification templates*  sont une autre couche de templating effectuée cette fois dans l'Alertmanager pour rédiger les messages et tikets de notifications

### Quelqu'un doit avoir la responsabilité de vos alertes : évitez les emails et notifications "floues"

Il est courant d'envoyer les alertes par email à une équipe ou dans un chat collectif. Le problème c'est que ces modes de notification risques d'empêcher le traitement conséquent des alertes car il ne donne pas de responsabilité à une personne de traiter l'alerte de façon réaliste.

Les alertes vont alors s'accumuler dans une boite mail ou un canal de chat rendant encore plus difficile et rébarbatif pour quelqu'un de s'en saisir.

Dans les exemples précédents est privilégié les `severity` `pager` ou `ticket` : les alertes pouvant être traitées dans un délai pas trop court seront assignées à une personne avec la responsabilité de s'en charger dans les prochaines heures ouvrées et les alertes urgentes devraient directement être envoyée à une personne s'occupant de veille.

Cette pratique impose également de limiter la quantité d'alertes au nécessaire et de bien les configurer pour éviter les faux positifs. Les personnes en charge des alertes seront ainsi également impliquées dans leur régulation.

<!-- 
Brian a délibérément omis d'inclure une sévérité de `email` ou de `chat` dans les exemples. Pour expliquer pourquoi, laissez-le vous raconter une histoire :

J'ai déjà fait partie d'une équipe qui devait créer une liste de diffusion d'équipe tous les quelques mois. Il y avait une liste de diffusion pour les alertes par e-mail, mais les alertes envoyées là-bas n'obtenaient pas toujours l'attention souhaitée, car il y en avait simplement trop, et la responsabilité était diffuse, c'est-à-dire que ce n'était en réalité le travail de personne de s'en occuper. Certaines alertes étaient considérées comme importantes, mais pas assez importantes pour déranger l'ingénieur de garde. Par conséquent, ces alertes étaient envoyées à la liste de diffusion principale de l'équipe, dans l'espoir que quelqu'un y jetterait un coup d'œil. Avance rapide un peu, et la même chose est arrivée à la liste de diffusion de l'équipe, qui recevait maintenant régulièrement des alertes automatisées. À un moment donné, la situation s'est tellement détériorée qu'une nouvelle liste de diffusion d'équipe a été créée, et cette histoire s'est répétée, au point où cette équipe avait trois listes d'alertes par e-mail.

Sur la base de cette expérience et de celle des autres, je déconseille fortement les alertes par e-mail et les alertes attribuées à une équipe. Au lieu de cela, je préconise que les notifications d'alerte soient dirigées vers un système de billetterie de quelque forme que ce soit, où elles seront attribuées à une personne spécifique dont la tâche est de s'en occuper. J'ai également vu que cela fonctionnait bien d'envoyer un e-mail quotidien aux membres de l'équipe de garde, répertoriant toutes les alertes actuellement actives.

Après une panne, c'est la faute de tout le monde de ne pas avoir regardé les alertes par e-mail, mais ce n'est toujours la responsabilité de personne. Le point clé est qu'il doit y avoir une responsabilité et non pas seulement l'utilisation de l'e-mail comme journalisation.

La même chose s'applique aux messages de chat pour les alertes, avec des systèmes de messagerie tels qu'IRC, Slack et Telegram. Avoir vos alertes dupliquées dans votre système de messagerie est pratique, et les alertes sont rares. La duplication des non-pages présente les mêmes problèmes que les alertes par e-mail, et est pire car elle a tendance à être plus distrayante. Vous ne pouvez pas filtrer les messages de chat dans un dossier que vous ignorez comme vous le faites avec les e-mails. -->


## Choisir ses alertes : monitoring des symptomes pour les systèmes complexes

Dans le monitoring de style Nagios, il serait normal d'alerter sur des problèmes tels qu'une charge élevée (high load average), une utilisation élevée du CPU (high CPU usage) ou un processus qui ne fonctionne pas.

=> Ces éléments sont tous des *causes* potentielles de problèmes, mais ils n'indiquent pas nécessairement un problème nécessitant une intervention urgente d'un être humain.

À mesure que les systèmes deviennent de plus en plus complexes et dynamiques, avoir des alertes pour chaque chose qui pourrait mal tourner n'est pas réalisable. Même si c'est possible, le nombre de faux positifs serait tellement élevé que cela épuiserait les équipes et détournerait des vrais problèmes noyés dans le bruit.

Une meilleure approche consiste à alerter plutôt sur les *symptômes* : les utilisateurs ne se soucient pas de savoir si la charge moyenne est élevée ; ils se soucient de la lenteur du chargement de leurs pages et medias. En ayant des alertes sur des métriques telles que la latence et les échecs rencontrés par les utilisateurs, vous identifierez des problèmes qui comptent vraiment, plutôt que des éléments qui pourraient éventuellement indiquer un problème.

Par exemple, des tâches planifiées nocturnes (cronjobs) peuvent provoquer une augmentation de l'utilisation du CPU, mais avec peu d'utilisateurs à ce moment de la journée, vous n'aurez probablement aucun problème à les servir. Inversement, la perte intermittente de paquets peut être difficile à détecter directement, mais elle sera assez clairement exposée par des métriques de latence.

Vous devriez également avoir des alertes pour **détecter les problèmes d'utilisation des ressources, tels que l'épuisement de quota ou d'espace disque**, ainsi que des alertes pour **vérifier que votre surveillance fonctionne correctement**.

L'objectif à atteindre est que chaque notification à la personne de garde, et chaque ticket d'alerte soumis, nécessite une action humaine intelligente. Si une alerte ne nécessite pas d'intelligence pour être résolue, alors elle est un candidat idéal pour l'automatisation.

- Comme un incident non trivial pris en charge par la personne de veille peut prendre quelques heures à résoudre, vous devriez en avoir moins de deux incidents par jour.

- Pour les alertes non urgentes envoyées à votre système de gestion des tickets, vous n'avez pas besoin d'être aussi strict, mais vous ne voulez pas non plus avoir plus d'alertes que de personnes pour les traiter.

- Si résoudre une alerte semble un travail un peu absurde cela indique qu'elle n'aurait pas dû être déclenchée en premier lieu il faut alors envisager d'augmenter le seuil de l'alerte pour la rendre moins sensible, ou éventuellement la supprimer.

<!-- 
Pour une discussion approfondie sur la manière d'aborder l'alerting et la gestion des systèmes, nous vous recommandons de lire ["Ma philosophie sur l'alerting"](https://oreil.ly/WYPVf) de Rob Ewaschuk. Rob a également écrit le chapitre 6 de *Site Reliability Engineering* (Betsy Beyer et al., éditeurs, O'Reilly), qui contient également des conseils généraux sur la gestion des systèmes. -->


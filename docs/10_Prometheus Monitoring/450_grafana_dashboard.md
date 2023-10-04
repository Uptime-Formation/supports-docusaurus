
# Dashboarding avec Grafana

Lorsque vous recevez une alerte ou souhaitez vérifier les performances actuelles de vos systèmes, les tableaux de bord seront votre premier point de contact. Le navigateur d'expression que vous avez vu jusqu'à présent convient pour la création ad hoc de graphiques et lorsque vous devez déboguer votre PromQL, mais il n'est pas conçu pour être utilisé comme un tableau de bord.

Que voulons-nous dire par tableau de bord ? Un ensemble de graphiques, de tableaux et d'autres visualisations de vos systèmes. Vous pourriez avoir un tableau de bord pour le trafic global, les services qui reçoivent combien de trafic et avec quelle latence. Pour chacun de ces services, vous auriez probablement un tableau de bord de sa latence, erreurs, taux de requêtes, nombre d'instances, utilisation du CPU, utilisation de la mémoire et métriques spécifiques au service. En creusant davantage, vous pourriez avoir un tableau de bord pour des sous-systèmes particuliers ou chaque service, ou un tableau de bord de "garbage collection" utilisable avec n'importe quelle application Java.

Grafana est un outil populaire avec lequel vous pouvez construire de tels tableaux de bord pour de nombreux systèmes de surveillance et non de surveillance, y compris Graphite, InfluxDB, Jaeger, Elasticsearch et PostgreSQL. C'est l'outil recommandé pour créer des tableaux de bord lors de l'utilisation de Prometheus, et il améliore continuellement son support pour Prometheus.

## Simple Docker - Installation

Vous pouvez télécharger Grafana depuis le site web de Grafana. Le site comprend des instructions d'installation, mais si vous utilisez Docker, par exemple, vous utiliseriez :

- `docker run -d --name=grafana -p 3000:3000 grafana/grafana:9.1.6`

Notez que cela n'utilise pas un montage de volume, donc il stockera tout l'état à l'intérieur du conteneur.

Nous utilisons ici Grafana 9.1.6. Vous pouvez utiliser une version plus récente, mais soyez conscient que ce que vous verrez différera légèrement.

Une fois Grafana en marche, vous devriez pouvoir y accéder dans votre navigateur à `http://localhost:3000/`, et vous verrez un écran de connexion comme celui de la Figure 6-1.

Connectez-vous avec le nom d'utilisateur par défaut admin et le mot de passe par défaut, qui est également admin. Il vous sera demandé de changer votre mot de passe, ce que nous vous recommandons de faire.

## Data Source

Grafana se connecte à Prometheus via des sources de données pour récupérer les informations utilisées pour les graphiques. Une variété de types de sources de données sont pris en charge nativement, y compris InfluxDB, PostgreSQL et, bien sûr, Prometheus. Vous pouvez avoir plusieurs sources de données du même type, et généralement, vous en auriez une par Prometheus en cours d'exécution. Un tableau de bord Grafana peut avoir des graphiques provenant de diverses sources, et vous pouvez même mélanger les sources dans un panneau de séries chronologiques.

Les versions plus récentes de Grafana facilitent l'ajout de votre première source de données. Cliquez sur "Ajoutez votre première source de données" et ajoutez une source de données avec un Nom de Prometheus, un Type de Prometheus, et une URL de http://localhost:9090 (ou toute autre URL sur laquelle votre Prometheus du Chapitre 2 écoute).

Laissez tous les autres paramètres à leurs valeurs par défaut et cliquez enfin sur "Save & Test" en bas du formulaire. Selon la taille de votre écran, vous devrez peut-être faire défiler pour voir les boutons. Si cela fonctionne, vous recevrez un message indiquant que la source de données fonctionne. Si ce n'est pas le cas, vérifiez que Prometheus est effectivement en cours d'exécution et qu'il est accessible depuis Grafana.

Retournez à http://localhost:3000/ dans votre navigateur, et cette fois cliquez sur "Créez votre premier tableau de bord".

De là, vous pouvez cliquer sur “Ajouter un nouveau panneau” et sélectionner le premier panneau que vous souhaitez ajouter. Les panneaux sont des zones rectangulaires contenant un graphique, un tableau ou d'autres informations visuelles. Vous pouvez ajouter de nouveaux panneaux au-delà du premier avec le bouton “Ajouter un panneau”, qui est le bouton de la rangée supérieure avec le signe plus orange. Les panneaux sont organisés au sein d'un système de grille et peuvent être réarrangés par glisser-déposer.

Après avoir apporté des modifications à un tableau de bord ou à des panneaux, si vous voulez qu'ils soient mémorisés, vous devez explicitement les enregistrer. Vous pouvez le faire avec le bouton d'enregistrement en haut de la page ou avec le raccourci clavier Ctrl-S.

Vous pouvez accéder aux paramètres du tableau de bord, comme son nom, en utilisant l'icône d'engrenage en haut. Depuis le menu des paramètres, vous pouvez également dupliquer des tableaux de bord en utilisant "Save As", ce qui est pratique lorsque vous souhaitez expérimenter avec un tableau de bord.

Il n'est pas rare de finir avec plusieurs tableaux de bord par service que vous exécutez. Il est facile pour les tableaux de bord de se surcharger progressivement avec trop de graphiques, ce qui vous rend difficile l'interprétation de ce qui se passe réellement. Pour atténuer cela, vous devriez essayer d'éviter les tableaux de bord qui servent plus d'une équipe ou d'un but, et leur donner à la place un tableau de bord à chacun.

Plus un tableau de bord est de haut niveau, moins il devrait avoir de rangées et de panneaux. Un aperçu global devrait tenir sur un seul écran et être compréhensible à distance. Les tableaux de bord couramment utilisés pour les appels peuvent avoir une rangée ou deux de plus que cela, tandis qu'un tableau de bord pour le réglage de performance en profondeur par des experts pourrait s'étendre sur plusieurs écrans.

## Stat pannel

Le stat pannel affiche des valeurs uniques d'une time serie. Il peut également montrer une valeur de label Prometheus.

Nous commencerons cet exemple en ajoutant une time serie.

Cliquez sur Appliquer (la flèche retour en haut à droite) pour revenir du panneau de séries chronologiques à la vue du tableau de bord. Cliquez sur le bouton "Ajouter un panneau" et sélectionnez "Panneau Statistique" dans le menu déroulant sur la droite. Pour l'expression de requête dans l'onglet Métriques, utilisez `prometheus_tsdb_head_series`, qui est (en gros) le nombre de différentes time series que Prometheus ingère. Par défaut, le stat pannel calculera la dernière valeur de la série chronologique sur la plage de temps du tableau de bord. Le texte par défaut peut être un peu petit, alors changez la Taille de la Police à 200%. Sous les options du panneau, changez le Titre à "time series Prometheus". Sous Threshold, cliquez sur l'image de la corbeille à côté du seuil prédéfini à 80 pour supprimer le seuil.

Afficher des valeurs d'étiquettes est pratique pour les versions logicielles sur vos graphiques. Ajoutez un autre stat pannel; cette fois, vous utiliserez l'expression de requête `node_uname_info`, qui contient la même information que la commande `uname -a`. Définissez "Format as" sur Tableau, et sous "value options", définissez les Champs sur "release". Sous "pannel options", le Titre devrait être Version du Noyau. Cliquez sur "Retour au tableau de bord" et réarrangez les panneaux en utilisant le glisser-déposer.

Le stat pannel offre d'autres fonctionnalités, notamment différentes couleurs en fonction de la valeur de la série chronologique, et l'affichage de courbes fines derrière la valeur.

## Table Pannel

Bien que le Stat pannel puisse afficher plusieurs time series, chaque time serie unique prend beaucoup d'espace. Le panneau Table vous permet d'afficher plusieurs "time series" de manière plus concise et offre des fonctionnalités avancées telles que la pagination. Les Table pannels ont tendance à nécessiter plus de configuration que les autres panneaux, et tout le texte peut être difficile à lire sur vos tableaux de bord.

Ajoutez un nouveau panneau, cette fois un Table pannel. Comme précédemment, cliquez sur “Add panel” puis sur “Add a new panel”. Sélectionnez Table dans le menu déroulant à droite. Utilisez l'expression de requête `rate(node_network_receive_bytes_total[1m])` dans l'onglet Metrics, et changez le Type de Range à Instant. Changez le Format en Table.

Il y a plus de colonnes que nécessaire ici. Allez dans l'onglet Transform et cliquez sur “Organize fields”. Sélectionnez les champs que vous souhaitez masquer en cliquant sur l'icône de l'œil.

Dans la barre latérale, sous “Standard options”, définissez l'unité sur “bytes/sec (IEC)” sous “data rate”. Enfin, dans “Panel options”, définissez le titre à Network Traffic Received.

## Panneau State Timeline

Lors de la visualisation de métriques représentant un état, comme les métriques "up", le panneau "State Timeline" est très utile. Il montre comment un état discret évolue dans le temps.

Utilisons-le pour afficher nos métriques `up`.

Ajoutons un panneau "State Timeline". Comme avant, cliquez sur “Add panel” puis sur “Add a new panel”. Sélectionnez “State Timeline” dans le menu déroulant à droite. Utilisez l'expression de requête `up` dans l'onglet "Metrics". Réglez la légende sur custom: `{{job}} / {{instance}}`.

Dans la barre latérale, sous “Standard options”, définissez “Color scheme” sur “Single Color”. Sous “Value mappings”, cliquez sur “Add value mappings” et ajoutez deux mappages de valeurs : Value 1 pour afficher le texte UP, avec une couleur verte, et Value 2 pour afficher DOWN, avec une couleur rouge.


Bien sûr, voici la traduction en gardant les termes techniques en anglais :

---

## Variables de Modèle (Template Variables)

Tous les exemples de tableaux de bord que nous vous avons montrés jusqu'à présent s'appliquaient à un seul Prometheus et un seul Node Exporter. C'est suffisant pour une démonstration des bases, mais pas idéal lorsque vous avez des centaines ou même des dizaines de machines à surveiller. La bonne nouvelle est que vous n'avez pas à créer un tableau de bord pour chaque machine individuelle. Vous pouvez utiliser la fonction de modélisation (templating) de Grafana.

Vous n'avez une surveillance que pour une seule machine, donc pour cet exemple, nous utiliserons un modèle basé sur les périphériques réseau, car vous devriez en avoir au moins deux.

Pour commencer, créez un nouveau tableau de bord en survolant l'icône des quatre carrés dans la barre latérale, puis en cliquant sur "+New dashboard", comme vous pouvez le voir sur la Figure 6-16.

Cliquez sur l'icône engrenage en haut puis sur "Variables". Cliquez sur "+Add variable" pour ajouter une variable de modèle. Le nom devrait être "Device", et la "Data source" est Prometheus avec un rafraîchissement sur "On time range change". La requête que vous utiliserez est `label_values(node_network_receive_bytes_total, device)`. Cliquez sur "Update" pour ajouter la variable.

Lorsque vous cliquez sur la flèche pour revenir au tableau de bord, une liste déroulante pour la variable sera désormais disponible.

Vous devez maintenant utiliser la variable. Cliquez sur le X pour fermer la section "Templating", puis cliquez sur les trois points et ajoutez un nouveau panneau "Time series". Configurez l'expression de la requête pour qu'elle soit `rate(node_network_receive_bytes_total​{device="$Device"}[$__rate_interval])`, et $Device sera remplacé par la valeur de la variable de modèle. Si vous utilisez l'option "Multi-value", vous utiliseriez `device=~"$Device"` car la variable serait une expression régulière dans ce cas. Les regex doivent également être utilisés si la valeur est complexe, car Grafana essaierait de les échapper de toute façon. Réglez le format de la légende sur "Custom" puis `{{device}}`, le titre sur "Bytes Received" et l'unité sur "bytes/sec" sous "data rate".

Comme vous l'avez vu, nous utilisons $__rate_interval dans notre expression PromQL. C'est une fonctionnalité de Grafana qui sélectionne le meilleur intervalle en fonction de l'intervalle d'extraction défini dans la configuration de la source de données et d'autres paramètres tels que le pas utilisé dans le panneau. Si vous regardez 24 heures de données, la valeur de $__rate_interval serait plus grande que si vous ne regardez que la dernière heure.

Cliquez sur "Apply" et cliquez sur le titre du panneau, puis cette fois cliquez sur "More" puis sur "Duplicate". Cela créera une copie du panneau existant. Modifiez les paramètres de ce nouveau panneau pour utiliser l'expression rate(node_network_transmit_bytes_total​{device=~"$Device"})[$__rate_interval], et définissez le titre sur "Bytes Transmitted". Le tableau de bord aura maintenant des panneaux pour les octets envoyés dans les deux sens, et vous pouvez regarder chaque périphérique réseau en le sélectionnant dans la liste déroulante.

Dans la réalité, vous baseriez probablement le modèle sur l'étiquette d'instance et afficheriez toutes les métriques liées au réseau pour une seule machine à la fois. Vous pourriez même avoir plusieurs variables pour un seul tableau de bord. Voici comment pourrait fonctionner un tableau de bord générique pour la collecte des ordures Java : une variable pour le travail, une pour l'instance et une pour sélectionner quelle source de données Prometheus utiliser.

Vous avez peut-être remarqué que lorsque vous changez la valeur de la variable, les paramètres de l'URL changent, et de même si vous utilisez les contrôles de temps. Cela vous permet de partager des liens de tableau de bord ou d'avoir vos alertes liées à un tableau de bord avec juste les bonnes valeurs de variable, comme le montre "Notification templates". Il y a une icône "Share dashboard" en haut de la page que vous pouvez utiliser pour créer les URL et prendre des instantanés des données du tableau de bord. Les instantanés sont parfaits pour les post-mortems et les rapports de panne, lorsque vous voulez préserver l'aspect du tableau de bord.



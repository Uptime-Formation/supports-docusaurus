---
title: "cours istio traffic routing fr"
sidebar_class_name: hidden
---

## Gestion du trafic

Les règles de routage de trafic d'Istio vous permettent de contrôler facilement le flux de trafic et les appels API entre les services. Istio simplifie la configuration des propriétés au niveau des services et facilite la mise en place de tâches importantes comme les tests A/B, les déploiements canary, et les déploiements progressifs avec des répartitions de trafic (load balancing) basées sur des pourcentages.

Il propose des fonctionnalités de fiabilité prêtes à l'emploi qui rendent votre application plus résiliente face aux pannes des services dépendants ou du réseau.

Le modèle de gestion du trafic d'Istio repose sur les "Envoy proxies" qui sont déployés avec à côté de vos (micro)services. Tout le trafic que vos (micro)services dans le mesh envoient et reçoivent (trafic du plan de données/data plane) est proxyfié via Envoy, ce qui facilite la direction et le contrôle du trafic au sein de votre mesh sans avoir à modifier vos services.


### Introduction à la gestion du trafic Istio

Pour diriger le trafic à l'intérieur de votre mesh, Istio a besoin de connaître l'emplacement de tous vos endpoints et à quels services ils appartiennent. Pour remplir son propre registre de services, Istio se connecte à un système de découverte de services. Dans un cluster Kubernetes, Istio détecte automatiquement les services et les points de terminaison dans ce cluster.

En utilisant ce registre de services, les Envoy proxies peuvent ensuite diriger le trafic vers les services pertinents. La plupart des applications basées sur des microservices ont plusieurs instances de chaque charge de travail de service pour gérer le trafic, souvent appelées un pool d'équilibrage de charge. Par défaut, les Envoy proxies répartissent le trafic sur le pool de load balancing de chaque service en utilisant un modèle de "least requests", où chaque requête est routée vers l'hôte ayant le moins de requêtes actives à partir d'une sélection aléatoire de deux hôtes du pool ; ainsi, l'hôte le plus chargé ne recevra plus de requêtes tant qu'il ne sera pas aussi peu chargé que les autres hôtes.

Vous pourriez souhaiter un contrôle plus précis sur ce qui se passe avec le trafic de votre mesh comme :
- vouloir diriger un pourcentage particulier de trafic vers une nouvelle version d'un service dans le cadre d'un test A/B
- appliquer une politique d'équilibrage de charge différente au trafic pour un sous-ensemble particulier d'instances de service
- vouloir appliquer des règles spéciales au trafic entrant ou sortant de votre mesh, ou ajouter une dépendance externe de votre mesh au registre de services

Comme pour les autres configurations d'Istio, l'API est spécifiée à l'aide de CRDs Kubernetes. Ces ressources sont :

- Virtual services
- Destination rules
- Gateways
- Service entries
- Sidecars


### Virtual services

Les Virtual services, ainsi que les destination rules, sont les éléments clés de la fonctionnalité de routage de trafic d'Istio. Un virtual service vous permet de configurer comment les requêtes sont routées vers un service à l'intérieur d'un mesh de services Istio, en s'appuyant sur la connectivité de base et la découverte fournies par Istio et votre plateforme. Chaque `virtual service` se compose d'un ensemble de règles de routage qui sont évaluées dans l'ordre, permettant à Istio d'associer chaque requête donnée au virtual service à une destination réelle spécifique dans le mesh. Votre mesh peut nécessiter plusieurs virtual services ou aucun, selon votre cas d'utilisation.

#### Pourquoi utiliser des virtual services ?

Les virtual services jouent un rôle clé en rendant la gestion du trafic dans Istio flexible et puissante. Ils le font en découplant fortement l’endroit où les clients envoient leurs requêtes des workloads de destination qui les implémentent réellement. Les virtual services offrent également une façon riche de spécifier différentes règles de routage du trafic pour envoyer du trafic à ces workloads.

Pourquoi est-ce si utile ? Sans les virtual services, Envoy distribue le trafic en utilisant l'équilibrage de charge par "moins de requêtes" entre toutes les instances de service, comme décrit dans l'introduction. Vous pouvez améliorer ce comportement en utilisant ce que vous savez sur les workloads. Par exemple, certains peuvent représenter une version différente. Cela peut être utile dans les tests A/B, où vous pourriez vouloir configurer des routes de trafic basées sur des pourcentages entre différentes versions de service, ou diriger le trafic de vos utilisateurs internes vers un ensemble particulier d'instances.

Avec un virtual service, vous pouvez spécifier le comportement du trafic pour un ou plusieurs noms d'hôtes. Vous utilisez des règles de routage dans le virtual service pour indiquer à Envoy comment envoyer le trafic du virtual service vers les destinations appropriées. Les destinations des routes peuvent être différentes versions du même service ou des services totalement différents.

Un cas d'utilisation typique est d'envoyer du trafic vers différentes versions d'un service, spécifiées comme des sous-ensembles de services. Les clients envoient des requêtes à l'hôte du virtual service comme s'il s'agissait d'une entité unique, et Envoy achemine ensuite le trafic vers les différentes versions en fonction des règles du virtual service : par exemple, « 20 % des appels vont vers la nouvelle version » ou « les appels de ces utilisateurs vont vers la version 2 ». Cela vous permet, par exemple, de créer un déploiement canari où vous augmentez progressivement le pourcentage de trafic envoyé à une nouvelle version de service. Le routage du trafic est complètement séparé du déploiement des instances, ce qui signifie que le nombre d'instances implémentant la nouvelle version de service peut augmenter ou diminuer en fonction de la charge de trafic sans avoir à se référer au routage du trafic. En revanche, les plateformes d'orchestration de conteneurs comme Kubernetes ne supportent la distribution du trafic qu'en fonction de la montée en charge des instances, ce qui devient rapidement complexe. Vous pouvez en savoir plus sur la manière dont les virtual services aident avec les déploiements canari dans Canary Deployments using Istio.

Les virtual services vous permettent également de :

- Adresser plusieurs services applicatifs via un seul virtual service. Si votre mesh utilise Kubernetes, par exemple, vous pouvez configurer un virtual service pour gérer tous les services dans un namespace spécifique. Mapper un seul virtual service à plusieurs services « réels » est particulièrement utile pour transformer une application monolithique en un service composite construit à partir de microservices distincts sans que les consommateurs du service aient besoin de s’adapter à cette transition. Vos règles de routage peuvent spécifier « les appels à ces URI de monolith.com vont vers le microservice A », etc. Vous pouvez voir comment cela fonctionne dans l’un de nos exemples ci-dessous.
- Configurer des règles de trafic en combinaison avec des gateways pour contrôler le trafic entrant et sortant.

Dans certains cas, vous devez également configurer des destination rules pour utiliser ces fonctionnalités, car c’est là que vous spécifiez vos sous-ensembles de services. Spécifier des sous-ensembles de services et d’autres politiques spécifiques à la destination dans un objet séparé vous permet de les réutiliser proprement entre les virtual services. Vous pouvez en savoir plus sur les destination rules dans la section suivante.

#### Exemple de virtual service

Le virtual service suivant achemine les requêtes vers différentes versions d’un service en fonction de si la requête provient d’un utilisateur particulier.

```yaml
apiVersion: networking.istio.io/v1
kind: VirtualService
metadata:
  name: reviews
spec:
  hosts:
  - reviews
  http:
  - match:
    - headers:
        end-user:
          exact: jason
    route:
    - destination:
        host: reviews
        subset: v2
  - route:
    - destination:
        host: reviews
        subset: v3
```

##### Le champ hosts

Le champ hosts liste les hôtes du virtual service, autrement dit, la ou les destinations accessibles par l’utilisateur auxquelles ces règles de routage s’appliquent. C’est l’adresse ou les adresses que le client utilise lorsqu’il envoie des requêtes au service.

```yaml
hosts:
- reviews
```

Le nom d'hôte du virtual service peut être une adresse IP, un nom DNS ou, selon la plateforme, un nom court (comme le nom court d’un service Kubernetes) qui se résout, de manière implicite ou explicite, en un nom de domaine pleinement qualifié (FQDN). Vous pouvez également utiliser des préfixes wildcard ("*"), vous permettant de créer un ensemble unique de règles de routage pour tous les services correspondants. Les hôtes du virtual service n'ont pas besoin de faire partie du registre de services d'Istio ; ils sont simplement des destinations virtuelles. Cela vous permet de modéliser le trafic pour des hôtes virtuels qui n'ont pas d'entrées routables à l'intérieur du mesh.

##### Règles de routage

La section http contient les règles de routage du virtual service, décrivant les conditions de correspondance et les actions pour le routage du trafic HTTP/1.1, HTTP2 et gRPC envoyé vers les destinations spécifiées dans le champ hosts (vous pouvez également utiliser des sections tcp et tls pour configurer des règles de routage pour le trafic TCP et TLS non terminé). Une règle de routage consiste en la destination vers laquelle vous souhaitez que le trafic soit dirigé et zéro ou plus de conditions de correspondance, selon votre cas d'utilisation.
Condition de correspondance

La première règle de routage dans l'exemple a une condition et commence donc par le champ match. Dans ce cas, vous voulez que ce routage s'applique à toutes les requêtes provenant de l'utilisateur « jason », vous utilisez donc les champs headers, end-user et exact pour sélectionner les requêtes appropriées.

```yaml
- match:
   - headers:
       end-user:
         exact: jason
```

Destination

Le champ destination de la section route spécifie la destination réelle du trafic qui correspond à cette condition. Contrairement aux hôtes du virtual service, l'hôte de destination doit être une destination réelle qui existe dans le registre de services d'Istio ou Envoy ne saura pas où envoyer le trafic. Cela peut être un service dans le mesh avec des proxies ou un service externe ajouté via une service entry. Dans ce cas, nous exécutons sur Kubernetes et le nom de l'hôte est un nom de service Kubernetes :

```yaml
route:
- destination:
    host: reviews
    subset: v2
```

Notez que dans cet exemple, ainsi que dans les autres exemples de cette page, nous utilisons un nom court Kubernetes pour les hôtes de destination pour simplifier. Lorsque cette règle est évaluée, Istio ajoute un suffixe de domaine basé sur le namespace du virtual service qui contient la règle de routage afin d’obtenir le nom complet de l’hôte. Utiliser des noms courts dans nos exemples signifie également que vous pouvez les copier et les essayer dans n’importe quel namespace que vous souhaitez. L’utilisation de noms courts comme celui-ci ne fonctionne que si les hôtes de destination et le virtual service se trouvent réellement dans le même namespace Kubernetes. Parce que l'utilisation du nom court Kubernetes peut entraîner des erreurs de configuration, nous recommandons de spécifier des noms d'hôtes complets dans les environnements de production.

La section destination spécifie également quel sous-ensemble de ce service Kubernetes vous souhaitez que les requêtes correspondant aux conditions de cette règle atteignent, dans ce cas le sous-ensemble nommé v2. Vous verrez comment définir un sous-ensemble de service dans la section sur les **destination rules** ci-dessous.

##### Priorité des règles de routage

Les règles de routage sont évaluées dans l’ordre séquentiel de haut en bas, la première règle dans la définition du virtual service ayant la priorité la plus élevée. Dans ce cas, vous souhaitez que tout ce qui ne correspond pas à la première règle de routage soit dirigé vers une destination par défaut, spécifiée dans la deuxième règle. C’est pourquoi la deuxième règle n’a aucune condition de correspondance et redirige simplement le trafic vers le sous-ensemble v3.

```yaml
- route:
  - destination:
      host: reviews
      subset: v3
```

Nous recommandons de fournir une règle par défaut sans condition ou basée sur des pourcentages (décrite ci-dessous) comme dernière règle dans chaque virtual service afin de garantir que le trafic vers le virtual service ait toujours au moins une route correspondante.

#### Plus d'informations sur les règles de routage

Comme vous l’avez vu plus haut, les règles de routage sont un outil puissant pour rediriger certains sous-ensembles de trafic vers des destinations spécifiques. Vous pouvez définir des conditions de correspondance sur les ports de trafic, les champs d'en-tête, les URIs, et plus encore. Par exemple, ce virtual service permet aux utilisateurs d’envoyer du trafic vers deux services distincts, `ratings` et `reviews`, comme s'ils faisaient partie d’un plus grand virtual service à l’adresse `http://bookinfo.com/`. Les règles du virtual service correspondent au trafic en fonction des URIs de requête et dirigent les requêtes vers le service approprié.

```yaml
apiVersion: networking.istio.io/v1
kind: VirtualService
metadata:
  name: bookinfo
spec:
  hosts:
    - bookinfo.com
  http:
  - match:
    - uri:
        prefix: /reviews
    route:
    - destination:
        host: reviews
  - match:
    - uri:
        prefix: /ratings
    route:
    - destination:
        host: ratings
```

Pour certaines conditions de correspondance, vous pouvez choisir de les sélectionner en fonction de la valeur exacte, d’un préfixe ou d’une expression régulière (regex).

Vous pouvez ajouter plusieurs conditions de correspondance au même bloc pour combiner vos conditions avec un « ET » logique, ou ajouter plusieurs blocs de correspondance à la même règle pour les combiner avec un « OU » logique. Vous pouvez également avoir plusieurs règles de routage pour un même virtual service. Cela vous permet de rendre vos conditions de routage aussi complexes ou simples que vous le souhaitez au sein d’un seul virtual service. Une liste complète des champs de conditions de correspondance et leurs valeurs possibles est disponible dans la référence **HTTPMatchRequest**.

En plus d’utiliser des conditions de correspondance, vous pouvez distribuer le trafic par pourcentage de « poids ». Cela est utile pour les tests A/B et les déploiements canari.

```yaml
spec:
  hosts:
  - reviews
  http:
  - route:
    - destination:
        host: reviews
        subset: v1
      weight: 75
    - destination:
        host: reviews
        subset: v2
      weight: 25
```

Vous pouvez également utiliser des règles de routage pour effectuer certaines actions sur le trafic, par exemple :

- Ajouter ou supprimer des en-têtes.
- Réécrire l’URL.
- Définir une politique de réessai pour les appels vers cette destination.

Pour en savoir plus sur les actions disponibles, consultez la référence **HTTPRoute**.

### **Destination Rules**

En complément des virtual services, les destination rules sont un élément clé des fonctionnalités de routage du trafic dans Istio. Vous pouvez considérer les virtual services comme la manière de router votre trafic vers une destination donnée, et les destination rules comme la façon de configurer ce qui se passe pour le trafic vers cette destination. Les destination rules sont appliquées après l’évaluation des règles de routage des virtual services, elles s'appliquent donc à la destination "réelle" du trafic.

En particulier, vous utilisez les destination rules pour spécifier des sous-ensembles de services nommés, tels que le regroupement de toutes les instances d’un service donné par version. Vous pouvez ensuite utiliser ces sous-ensembles de services dans les règles de routage des virtual services pour contrôler le trafic vers différentes instances de vos services.

Les destination rules vous permettent également de personnaliser les politiques de trafic d’Envoy lors de l’appel du service de destination entier ou d’un sous-ensemble spécifique de services, comme votre modèle préféré d’équilibrage de charge, le mode de sécurité TLS ou les paramètres de disjoncteurs (circuit breakers). Vous pouvez voir une liste complète des options de destination rules dans la référence **Destination Rule**.

#### Options d'équilibrage de charge

Par défaut, Istio utilise une politique d’équilibrage de charge basée sur le « moins de requêtes », où les requêtes sont réparties parmi les instances avec le moins de requêtes. Istio prend également en charge les modèles suivants, que vous pouvez spécifier dans les destination rules pour les requêtes vers un service ou sous-ensemble de service particulier.

- **Aléatoire** : Les requêtes sont redirigées de manière aléatoire vers les instances dans le pool.
- **Pondéré** : Les requêtes sont redirigées vers les instances dans le pool selon un pourcentage spécifique.
- **Round-robin** : Les requêtes sont envoyées à chaque instance dans l'ordre séquentiel.

Consultez la documentation d’Envoy sur l’équilibrage de charge pour plus d'informations sur chaque option.

#### Exemple de destination rule

L'exemple de destination rule suivant configure trois sous-ensembles différents pour le service de destination `my-svc`, avec différentes politiques d’équilibrage de charge :

```yaml
apiVersion: networking.istio.io/v1
kind: DestinationRule
metadata:
  name: my-destination-rule
spec:
  host: my-svc
  trafficPolicy:
    loadBalancer:
      simple: RANDOM
  subsets:
  - name: v1
    labels:
      version: v1
  - name: v2
    labels:
      version: v2
    trafficPolicy:
      loadBalancer:
        simple: ROUND_ROBIN
  - name: v3
    labels:
      version: v3
```

Chaque sous-ensemble est défini en fonction d'une ou plusieurs **labels** (étiquettes), qui, dans Kubernetes, sont des paires clé/valeur attachées à des objets tels que des Pods. Ces labels sont appliquées dans le déploiement du service Kubernetes en tant que métadonnées pour identifier différentes versions.

En plus de définir des sous-ensembles, cette destination rule a à la fois une politique de trafic par défaut pour tous les sous-ensembles de cette destination et une politique spécifique à un sous-ensemble qui la remplace pour cet ensemble particulier. La politique par défaut, définie au-dessus du champ `subsets`, définit un simple équilibrage de charge aléatoire pour les sous-ensembles v1 et v3. Dans la politique v2, un équilibrage de charge round-robin est spécifié dans le champ correspondant à ce sous-ensemble.

### Gateways

Vous utilisez un gateway pour gérer le trafic entrant et sortant de votre mesh, vous permettant de spécifier quel trafic vous souhaitez faire entrer ou sortir du mesh. Les configurations de gateway sont appliquées aux proxys Envoy autonomes qui fonctionnent en périphérie du mesh, plutôt qu’aux proxys Envoy sidecar exécutés aux côtés de vos workloads de service.

Contrairement à d'autres mécanismes de contrôle du trafic entrant dans vos systèmes, tels que les API Kubernetes Ingress, les gateways d'Istio vous permettent d’utiliser toute la puissance et la flexibilité du routage de trafic d'Istio. Vous pouvez le faire parce que la ressource **Gateway** d'Istio vous permet de configurer uniquement les propriétés de routage de charge des couches 4 à 6, comme les ports à exposer, les paramètres TLS, etc. Ensuite, au lieu d'ajouter le routage du trafic au niveau de l'application (L7) à la même ressource API, vous associez un virtual service Istio ordinaire au gateway. Cela vous permet de gérer le trafic des gateways comme tout autre trafic de plan de données dans un mesh Istio.

Les gateways sont principalement utilisés pour gérer le trafic entrant, mais vous pouvez également configurer des **egress gateways**. Un **egress gateway** vous permet de configurer un

 nœud de sortie dédié pour le trafic quittant le mesh, vous permettant de limiter quels services peuvent ou doivent accéder aux réseaux externes, ou d’activer le contrôle sécurisé du trafic sortant pour ajouter de la sécurité à votre mesh, par exemple. Vous pouvez également utiliser un gateway pour configurer un proxy purement interne.

Istio fournit quelques déploiements de proxy gateway préconfigurés (`istio-ingressgateway` et `istio-egressgateway`) que vous pouvez utiliser - les deux sont déployés si vous utilisez notre installation de démonstration, tandis que seul le gateway d'entrée est déployé avec notre profil par défaut. Vous pouvez appliquer vos propres configurations de gateway à ces déploiements ou déployer et configurer vos propres proxys de gateway.























L'exemple suivant montre une configuration possible de **gateway** pour le trafic HTTPS entrant :

```yaml
apiVersion: networking.istio.io/v1
kind: Gateway
metadata:
  name: ext-host-gwy
spec:
  selector:
    app: my-gateway-controller
  servers:
  - port:
      number: 443
      name: https
      protocol: HTTPS
    hosts:
    - ext-host.example.com
    tls:
      mode: SIMPLE
      credentialName: ext-host-cert
```

Cette configuration de gateway permet d'accepter le trafic HTTPS provenant de `ext-host.example.com` sur le port 443, mais ne spécifie pas de routage pour ce trafic.

Pour spécifier le routage et que le gateway fonctionne comme prévu, vous devez également l'associer à un virtual service. Vous le faites en utilisant le champ `gateways` du virtual service, comme dans l'exemple suivant :

```yaml
apiVersion: networking.istio.io/v1
kind: VirtualService
metadata:
  name: virtual-svc
spec:
  hosts:
  - ext-host.example.com
  gateways:
  - ext-host-gwy
```

Vous pouvez ensuite configurer le virtual service avec des règles de routage pour le trafic externe.

### **Service Entries**

Une **service entry** vous permet d'ajouter une entrée dans le registre de services qu'Istio maintient en interne. Une fois que vous avez ajouté l’entrée de service, les proxys Envoy peuvent envoyer du trafic vers ce service comme s'il faisait partie de votre mesh. Configurer des service entries vous permet de gérer le trafic pour des services externes au mesh, incluant les tâches suivantes :

- Rediriger et acheminer le trafic vers des destinations externes, comme des API web ou des services dans une infrastructure héritée.
- Définir des politiques de réessai, de délai d'expiration et d'injection de fautes pour des destinations externes.
- Intégrer un service mesh sur une machine virtuelle (VM) en ajoutant des VM à votre mesh.

Vous n'avez pas besoin d’ajouter une service entry pour chaque service externe que vous souhaitez utiliser avec vos services du mesh. Par défaut, Istio configure les proxys Envoy pour passer les requêtes à des services inconnus. Cependant, vous ne pouvez pas utiliser les fonctionnalités d'Istio pour contrôler le trafic vers des destinations non enregistrées dans le mesh.

#### Exemple de service entry

L’exemple suivant de **service entry** ajoute la dépendance externe `ext-svc.example.com` au registre de services d'Istio :

```yaml
apiVersion: networking.istio.io/v1
kind: ServiceEntry
metadata:
  name: svc-entry
spec:
  hosts:
  - ext-svc.example.com
  ports:
  - number: 443
    name: https
    protocol: HTTPS
  location: MESH_EXTERNAL
  resolution: DNS
```

Vous spécifiez la ressource externe via le champ `hosts`. Vous pouvez la qualifier entièrement ou utiliser un nom de domaine préfixé avec un caractère générique.

Vous pouvez configurer des virtual services et des destination rules pour contrôler le trafic vers une service entry de manière plus granulaire, comme pour tout autre service dans le mesh. Par exemple, la destination rule suivante ajuste le délai d'attente pour les connexions TCP aux requêtes adressées au service externe `ext-svc.example.com` configuré avec la service entry :

```yaml
apiVersion: networking.istio.io/v1
kind: DestinationRule
metadata:
  name: ext-res-dr
spec:
  host: ext-svc.example.com
  trafficPolicy:
    connectionPool:
      tcp:
        connectTimeout: 1s
```

Consultez la référence des **Service Entries** pour plus d’options de configuration.

### **Sidecars**

Par défaut, Istio configure chaque proxy Envoy pour accepter le trafic sur tous les ports de la charge de travail associée, et pour atteindre toutes les charges de travail dans le mesh lorsqu'il relaie le trafic. Vous pouvez utiliser une configuration de **sidecar** pour :

- Affiner l’ensemble des ports et des protocoles qu’un proxy Envoy accepte.
- Limiter l’ensemble des services que le proxy Envoy peut atteindre.

Cette limitation peut être utile dans de grandes applications, où chaque proxy configuré pour atteindre tous les autres services du mesh peut affecter les performances du mesh en raison d'une utilisation élevée de la mémoire.

Vous pouvez spécifier que vous souhaitez qu’une configuration de sidecar s’applique à toutes les charges de travail d’un namespace particulier, ou choisir des charges de travail spécifiques en utilisant un `workloadSelector`. Par exemple, la configuration de sidecar suivante configure tous les services dans le namespace `bookinfo` pour n'atteindre que les services du même namespace et le plan de contrôle d'Istio (nécessaire pour les fonctionnalités de sortie et de télémétrie d'Istio) :

```yaml
apiVersion: networking.istio.io/v1
kind: Sidecar
metadata:
  name: default
  namespace: bookinfo
spec:
  egress:
  - hosts:
    - "./*"
    - "istio-system/*"
```

Consultez la référence des **Sidecars** pour plus de détails.

### **Résilience réseau et tests**

En plus de faciliter la gestion du trafic dans votre mesh, Istio offre des fonctionnalités de récupération en cas de panne et d’injection de fautes que vous pouvez configurer dynamiquement à l’exécution. L'utilisation de ces fonctionnalités permet à vos applications de fonctionner de manière fiable, en assurant que le service mesh tolère les nœuds défaillants et empêche que des pannes locales se propagent à d'autres nœuds.

#### Délai d'expiration (Timeouts)

Un délai d'expiration (timeout) est la durée pendant laquelle un proxy Envoy attend la réponse d’un service donné, garantissant que les services ne restent pas bloqués indéfiniment en attente de réponses et que les appels réussissent ou échouent dans un laps de temps prévisible. Par défaut, le délai d'attente d’Envoy pour les requêtes HTTP est désactivé dans Istio.

Pour certaines applications, le délai d’attente par défaut d'Istio peut ne pas être approprié. Par exemple, un délai trop long peut entraîner une latence excessive due à l'attente de réponses de services en échec, tandis qu'un délai trop court peut provoquer l’échec d'appels alors qu'une opération entre plusieurs services est encore en cours. Pour trouver et utiliser les paramètres de délai d'attente optimaux, Istio permet de régler facilement les délais d’attente dynamiquement pour chaque service à l'aide des virtual services, sans avoir à modifier le code du service. Voici un virtual service qui spécifie un délai d'attente de 10 secondes pour les appels au sous-ensemble `v1` du service `ratings` :

```yaml
apiVersion: networking.istio.io/v1
kind: VirtualService
metadata:
  name: ratings
spec:
  hosts:
  - ratings
  http:
  - route:
    - destination:
        host: ratings
        subset: v1
    timeout: 10s
```

#### Réessais (Retries)

Le paramètre de réessai spécifie le nombre maximum de fois qu’un proxy Envoy tente de se connecter à un service si l'appel initial échoue. Les réessais peuvent améliorer la disponibilité et les performances d’une application en s'assurant que les appels ne tombent pas en échec de manière définitive à cause de problèmes temporaires, comme un service temporairement surchargé ou un problème réseau. L’intervalle entre les réessais (25 ms ou plus) est variable et déterminé automatiquement par Istio, empêchant ainsi le service appelé d’être submergé de requêtes. Le comportement par défaut pour les requêtes HTTP est de réessayer deux fois avant de renvoyer l’erreur.

Comme pour les délais d’attente, le comportement de réessai par défaut d'Istio peut ne pas correspondre aux besoins de votre application en termes de latence (trop de réessais peuvent ralentir les services en échec) ou de disponibilité. De plus, vous pouvez affiner encore plus le comportement des réessais en ajoutant des délais d'attente pour chaque tentative de réessai, spécifiant ainsi le temps que vous voulez attendre pour chaque tentative de connexion. L'exemple suivant configure un maximum de 3 réessais avec un délai d'attente de 2 secondes pour chaque tentative après un échec initial.

```yaml
apiVersion: networking.istio.io/v1
kind: VirtualService
metadata:
  name: ratings
spec:
  hosts:
  - ratings
  http:
  - route:
    - destination:
        host: ratings
        subset: v1
    retries:
      attempts: 3
      perTryTimeout: 2s
```

#### Disjoncteurs (Circuit breakers)

Les disjoncteurs sont un autre mécanisme utile qu'Istio fournit pour créer des applications basées sur des microservices résilients. Dans un disjoncteur, vous définissez des limites pour les appels à des hôtes individuels dans un service, telles que le nombre de connexions simultanées ou le nombre d’échecs des appels vers cet hôte. Une fois que cette limite est atteinte, le disjoncteur se déclenche et empêche toute nouvelle connexion à cet hôte. L’utilisation d’un modèle de disjoncteur permet un échec rapide au lieu que les clients continuent de tenter
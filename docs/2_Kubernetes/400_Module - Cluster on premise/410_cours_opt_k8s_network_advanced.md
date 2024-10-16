---
title: Cours optionnel - Réseau Kubernetes avancé 
draft: false
# weight: 2100
---

## Le réseau Pod-to-Pod et les CNI plugins

La base du réseau Kubernetes consiste dans les communication entre les pods car tout est pod dans un cluster (même les éléments réseau comme les ingress et souvent le kube-proxy)

Sous Linux les conteneurs (quelle que soit la runtime choisie, Docker, containerd etc) tirent partie d'une fonctionnalité du noyau appelée `Network namespace` c'est à dire des espaces réseau isolés du réseau principal du serveur grâce à une forme de virtualisation. On peut s'en rendre compte en créant soit même des interfaces vituelle dans un namespace (cf https://linuxhint.com/use-linux-network-namespace/).

Les pods sont composés de plusieurs conteneurs qui partagent le même namespace réseau. Au moment de la création d'un pod, le premier conteneur créé est appelé `pause`, il est vide mais sert de support à la création de l'interface réseau virtuelle pour le pod. Les conteneurs démarrés ensuite récupèrent cette interface commune. On peut constater la création de ce conteneur en utilisant la cli docker ou ctr.

Dans Kubernetes cette interface virtuelle de chaque pod est créée et routée automatiquement par le plugin CNI (Container Network Interface, une norme standard qui permet à toutes les runtime de conteneurs et tous les plugins d'être compatibles.).

Ce plugin doit être présent dans le cluster pour pouvoir automatiser la communication entre les pods. À l'installation (manuelle) du cluster on configure donc un CIDR pour les pods généralement un /16, et un plugin CNI.

Il existe de nombreux plugin CNI du plus simple au plus sophistiqué pour pouvoir répondre à des edge cases (notamment la communication interne/externe du cluster) des problématiques de performance, sécurité, observabilité. Voir plus loin.

On peut même implémenter un plugin simple en bash a des fins pédagogiques : https://www.altoros.com/blog/kubernetes-networking-writing-your-own-simple-cni-plug-in-with-bash/.

Une fois cette configuration mise en place les pods sont capables de communiquer avec tous les autres pods du cluster sans NAT (à leur niveau), c'est à dire sans modification de l'adresse IP au cours de la communication.

On donc peut tester la base du fonctionnement d'un plugin CNI installé en essayant de pinguer depuis un pod l'IP d'un autre pod sur un autre noeud.

https://projectcalico.docs.tigera.io/about/about-k8s-networking

![](/img/kubernetes/pod_network.png)

<!-- ## Traffic réseau "North-South-East-West"

- Lorsque vous avez un cluster Kubernetes avec vos services en cours d'exécution, comment l'utilisateur final extérieur ou un service extérieur entrent-t-ils en contact avec votre service ?. C'est ce que l'on appelle le trafic nord, c'est-à-dire une requête extérieure qui arrive sur votre cluster. Pour gérer ce trafic entrant, vous pouvez mettre en place un loadbalancer. Un loadbalancer kubernetes (LB) donne une seule adresse IP externe qui transmettra tout votre trafic entrant à votre service.

- Le trafic sud désigne les requêtes qui quittent votre cluster (vous retournez peut-être une réponse à une requête, ou vous devez appeler une API externe). Bien qu'il existe un type de ressource d'entrée (Ingress) fourni par l'API Kubernetes, il n'y a pas de type de ressource de sortie. C'est là que quelque chose comme la ressource Egress d'Istio est utile.

Le trafic est-ouest désigne la communication de vos services entre eux. D'une manière générale, il s'agit du trafic au sein d'un datacenter de serveur à serveur. -->

## Une chaine video géniale pour aller en profondeur dans le réseau k8s

Pleins de schémas. Des principes fondamentaux et une comparaison des différents plugin CNI

- https://www.youtube.com/@TheLearningChannel-Tech/videos

## Communication inter-services avec le kube-proxy

Une fois que l'on a mis en place un moyen de communication inter-pod la communication est-ouest de notre cluster n'est pas encore opérationnelle. En effet Kubernetes étant un environnement dynamique avec des pods créés et détruit automatiquement par des Deployment ou autre controller, gérer les IP des pods manuellement est en réalité impraticable. Pour cela nous avons besoin de la gestion automatique d'une ip virtuelle associée fournissant le loadbalancing proposé par les resources de type Service.

Cette gestion d'IP virtuelle est réalisée traditionnellement par le composant Kubernetes appelé `kube-proxy`. Le kube-proxy est généralement installé dans le cluster en temps que pod privilégié sur chaque noeud (mais peut également être un service systemd) et manipule `iptable`. On peut s'en rendre compte par exemple avec la commande `sudo iptables-save | grep KUBE | grep "kubernetes-dashboard" # ou autre nom de service`.

Ainsi, `kube-proxy` créé dynamiquement des règles `iptable` qui indiquent que tout paquet venant du CIDR des pods et à destination de l'IP virtuelle du service (en réalité l'IP de l'objet endpoint) doit être redirigé aléatoirement vers l'un des pods de backend d'un groupe désignés comme nous l'avons vu grace à un selecteur de labels.

kube-proxy peut également être configuré pour utiliser à la place de iptable la fonctionnalité d'IP virtuelle du noyau Linux appelé IPVS. Cela amène surtout de meilleures performances dans le cas d'un grand nombre de services (<500).

Enfin depuis quelques temps la gestion du traffic inter-node avec kube-proxy peut être remplacée par une implémentation eBPF dans le noyau linux par exemple grâce à Calico ou Cilium.

Video: [Kubernetes Services networking](https://www.youtube.com/watch?v=NFApeJRXos4&list=PLoWxE_5hnZUZMWrEON3wxMBoIZvweGeiq&index=4)

# Découverte de service avec kube-DNS

Les services viennent avec un nom de domaine local au namespace et local grâce à au composant `kube-dns`. Ce composant peut depuis longtemps être remplacé par coreDNS plus performant et modulaire (recommandé).

On peut tester le bon fonctionnement du composant DNS avec `nslookup` depuis par exemple un pods du conteneur `dnsutils`.

Deux types de services moins connus :

- service de type `headless` avec `ClusterIP=None` -> une requête vers le nom de domaine du service renvoie la liste des IP des pods backend. On peut ensuite implémenter soit même d'une manière ou d'une autre la connexion/loadbalancing vers ces backend.

- service `ExternalName`: utilise CoreDNS pour mapper le nom de domaine du service à un enregistrement `CNAME` renvoyant vers un autre service par exemple à l'extérieur du Cluster. Aucun proxy d’aucune sorte n’est utilisé.

### Fournir des services LoadBalancer on premise avec `MetalLB`

Dans un cluster managé provenant d'un fournisseur de cloud, la création d'un objet Service Lodbalancer entraine le provisionning d'une nouvelle machine de loadbalancing à l'extérieur du cluster avec une IPv4 publique grâce à l'offre d'IaaS du provideur (impliquant des frais supplémentaires).

Cette intégration n'existe pas par défaut dans les clusters de dev comme minikube ou les cluster on premise (le service restera pending et fonctionnera comme un NodePort). Le projet [*MetalLB*](https://metallb.universe.tf/) cherche à y remédier en vous permettant d'installer un loadbalancer directement dans votre cluster en utilisant une connexion IP classique ou BGP pour la haute disponibilité.

## Le mesh networking et les *service meshes*

Un **service mesh** est un type d'outil réseau pour connecter un ensemble de pods, généralement les parties d'une application microservices de façon encore plus intégrée que ne le permet Kubernetes.

En effet opérer une application composée de nombreux services fortement couplés discutant sur le réseau implique des besoins particuliers en terme de routage des requêtes, sécurité et monitoring qui nécessite l'installation d'outils fortement dynamique autour des nos conteneurs.

Un exemple de service mesh est `https://istio.io` qui, en ajoutant dynamiquement un conteneur "sidecar" à chacun des pods à supervisés, ajoute à notre application microservice un ensemble de fonctionnalités d'intégration très puissant.

Un autre service mesh populaire et plus simple/léger qu'Istio, Linkerd : https://linkerd.io/

## Les network policies : des firewalls dans le cluster

Voir cours sur la sécurité

## Comparaison des plugins CNI

https://platform9.com/blog/the-ultimate-guide-to-using-calico-flannel-weave-and-cilium

### Flannel

Flannel est le plugin le plus ancien et simple pour kubernetes. Il implémente la communication Pod-to-Pod créant un réseau overlay par dessus un backend linux standard comme VXLAN. Il ne s'occupe pas de la communication inter-service.

Son principal avantage est d'être plus simple à implémenter et maintenir que Calico ou Cillium et plus compatible (pas besoin d'un noyau eBPF par exemple). Idéal pour les petits clusters peu critiques.

Il ne dispose pas d'implémentation des Network Policies à moins d'être complémenté par Calico (Cannal)

![](/img/kubernetes/flannel_archi.png)

### Calico

Calico développé par l'entreprise Tigera est le plugin CNI le plus populaire pour les clusters à grande échelle avec des configurations avancées et des performances exemplaires.

Il peut implémente la communication inter-Pod avec un réseau overlay ou en routant le traffic entre les noeuds à l'aide d'un routeur virtuel utilisant BGP (protocole inter-routeur structurant internet) : https://projectcalico.docs.tigera.io/networking/determine-best-networking

Calico est assez modulaire et très configurable. Il peut: 
- venir complémenter flannel avec des network policies (Canal) : https://ubuntu.com/kubernetes/docs/cni-canal
- s'intégrer avec Istio pour proposer de network policies au niveau application (HTTP ou gRPC etc) https://projectcalico.docs.tigera.io/security/tutorials/app-layer-policy/enforce-policy-istio
- S'intégrer avec metallb pour fournir des LoadBalancer in cluster résilient avec BGP
- Ou encore depuis peu fournir un dataplane complet basé sur eBPF (des hooks surs et programmables pour étendre le noyau le noyau linux et en particulier sa gestion des paquets réseau): https://www.tigera.io/blog/introducing-the-calico-ebpf-dataplane/. Dans cette configuration il prend complètement en charge la communication inter-Services.

Calico est extrêment fin sur les network policies mais peut aussi gérer le traffic en dehors de kubernetes et notamment s'occuper de règles de firewall pour des VM. Toutes ces règles sont alors configurées par exemple avec des CRD kubernetes ou via la dashboard Tigera (offre Saas) : https://www.tigera.io/features/microsegmentation/

Calico dispose de plus de nombreuses offres managées de différents vendeurs. Il s'intègre en particulier avec l'offre de Tigera et stack complète d'observabilité et sécurité réseau. Cf cours sur la sécurité.

![](/img/kubernetes/calico_archi.png)

### Cilium

Solution plus récente mais très en vogue, Cilium implémente depuis le départ un dataplane eBPF qui lui permet d'associer une configuration simple avec des fonctionnalités puissantes qui concurrencent Calico:
- remplace kube-proxy avec sa communication inter-services eBPF ()
- fournit une observabilité réseau puissante via une récolte de métrique et son dashboard Hubble (Open source ce qui est un avantage par rapport à Tigera)
- fournit des Network Policies standard et avancées au niveau transport (OSI 3-4) et application (OSI 7) qui sont DNS-aware
- fournit en option un chiffrement du traffic
- Permet de créer facilement un multi-cluster

![](/img/kubernetes/cilium_archi.png)

### Comparaison Cilium et Calico

Cilium et Calico on a peu prêt le même périmetre de fonctionnalités puissantes et performances exemplaires mais :
- Calico est un peu plus modulaire et peut s'installer de plusieurs façons... ce qui peut être un avantage mais peut aussi amener de la complexité.
- Cilium est plus open source côté dashboard et intégration SIEM car non adossé à une offre SaaS
- Calico est capable d'étendre sa gestion de sécurité réseau au delà du cluster à d'autres machines avec l'agent calico installé ce qui peut être très puissant.


## Ressources sur le réseau

- Documentation officielle : <https://kubernetes.io/fr/docs/concepts/services-networking/service/>

- [An introduction to service meshes - DigitalOcean](ttps://www.digitalocean.com/community/tutorials/an-introduction-to-service-meshes)

- [Kubernetes NodePort vs LoadBalancer vs Ingress? When should I use what?](https://medium.com/google-cloud/kubernetes-nodeport-vs-loadbalancer-vs-ingress-when-should-i-use-what-922f010849e0)

- [Determine best networking option - Project Calico](https://docs.projectcalico.org/networking/determine-best-networking)

- [Doc officielle sur les solutions de networking](https://kubernetes.io/docs/concepts/cluster-administration/networking/)




<!-- 
Pas confondre ingress et egress comme NetworkPolicy et Ingress resource -->


<!-- - MetalLB is simply a way to use LoadBalancer when not captive from big Google Microsoft or Amazon cloud (no official K8s solution) : https://metallb.universe.tf/  -->

<!-- 
## Network Plugins
Network plugins in Kubernetes come in a few flavors:

* CNI plugins: adhere to the Container Network Interface (CNI) specification, designed for interoperability.
* Kubenet plugin: implements basic cbr0 using the bridge and host-local CNI plugins

---

- **Network policies** : Faire un petit tableau avec Cilium / Calico / Kubenet etc et ce qu'ils font et si CNI ou non
- Dire que pas confondre avec **services meshes** Istio / Pilot etc.
- Ni avec **ingress controllers** !!! https://medium.com/flant-com/comparing-ingress-controllers-for-kubernetes-9b397483b46b


- Service Topology enables a service to route traffic based upon the Node topology of the cluster : https://kubernetes.io/docs/concepts/services-networking/service-topology/


- Rappel layer 2/3 layer 4 layer 7 ?

---
 -->

<!--
Pitch MetalLB :
Kubernetes does not offer an implementation of network load-balancers (Services of type LoadBalancer) for bare metal clusters. The implementations of Network LB that Kubernetes does ship with are all glue code that calls out to various IaaS platforms (GCP, AWS, Azure…). If you’re not running on a supported IaaS platform (GCP, AWS, Azure…), LoadBalancers will remain in the “pending” state indefinitely when created.

Bare metal cluster operators are left with two lesser tools to bring user traffic into their clusters, “NodePort” and “externalIPs” services. Both of these options have significant downsides for production use, which makes bare metal clusters second class citizens in the Kubernetes ecosystem.

MetalLB aims to redress this imbalance by offering a Network LB implementation that integrates with standard network equipment, so that external services on bare metal clusters also “just work” as much as possible.


-->

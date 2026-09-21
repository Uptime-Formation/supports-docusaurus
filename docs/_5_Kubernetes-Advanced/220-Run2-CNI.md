---
title: Run2 - CNI
weight: 220
---

## Quickstart : Déploiement de Cilium sur Kubernetes

Ce quickstart vous permet d'installer rapidement Cilium sur un cluster Kubernetes en utilisant les commandes essentielles pour l'installation et la validation. 

Pour plus de détails, visitez [la documentation officielle de Cilium](https://docs.cilium.io/en/stable/gettingstarted/k8s-install-default/).

---

### Étape 1 : Installer le CLI de Cilium

* **Télécharger et installer la dernière version du CLI de Cilium**
```sh
CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
CLI_ARCH=amd64
if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi
curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
sha256sum --check cilium-linux-${CLI_ARCH}.tar.gz.sha256sum
sudo tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin
rm cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
```

---

### Étape 2 : Déployer Cilium

* **Installer Cilium dans le cluster Kubernetes**

Cilium utilise votre kubeconfig actuelle pour se connecter à un cluster sur lequel vous devez avoir les droits d'admin.

```sh
cilium install --version 1.15.6
```

---

### Étape 3 : Valider l'installation

* **Vérifier que Cilium est correctement installé**
```sh
cilium status --wait
```

* **Tester la connectivité du réseau**
```sh
cilium connectivity test
```

---

## Container Network Interface : c'est quoi ? 


**La spécification CNI (Container Network Interface) vise à standardiser la configuration des réseaux de conteneurs.**

En définissant ces composants principaux, la spécification CNI garantit que différents environnements d'exécution de conteneurs et plugins réseau peuvent interagir de manière cohérente, permettant l'automatisation et la standardisation de la configuration réseau.

Pour la convention complète c'est ici : https://www.cni.dev/docs/spec/

Il y a [plusieurs solutions d'orchestration qui s'appuient sur CNI]( https://www.cni.dev/docs/#container-runtimes), pas seulement Kubernetes.


---

**La CNI propose une interface commune entre les runtimes de conteneurs et les plugins réseau.**

- **Format de configuration du réseau**

> Définit comment les administrateurs définissent les configurations réseau.

- **Protocole de requête**

> Décrit comment les environnements d'exécution de conteneurs envoient des demandes de configuration ou de nettoyage de réseau aux plugins réseau.

- **Processus d'exécution des plugins**

> Détaille comment les plugins exécutent la configuration ou le nettoyage du réseau en fonction de la configuration fournie.

- **Délégation de plugins**

> Permet aux plugins de déléguer des fonctionnalités spécifiques à d'autres plugins.

- **Retour des résultats**

> Définit le format des données pour retourner les résultats à l'environnement d'exécution après l'exécution du plugin.



---

**Les points majeurs de CNI**

1. CNI est une solution de mise en réseau conteneurisée basée sur des plugins.
2. Les plugins CNI sont des fichiers exécutables.
3. La responsabilité d'un plugin CNI est unique.
4. Les plugins CNI sont invoqués de manière enchaînée.
5. La spécification CNI définit un espace de noms réseau Linux pour un conteneur.
6. Les définitions de réseau dans CNI sont stockées au format JSON.
7. Les définitions de réseau sont transmises aux plugins via des flux d'entrée STDIN, ce qui signifie que les fichiers de configuration réseau ne sont pas stockés sur l'hôte, et d'autres paramètres de configuration sont transmis aux plugins via des variables d'environnement.

---

**Les plugins CNI sont chaînés.**

Pour une liste complète des core plugins c'est ici : https://www.cni.dev/plugins/current/

Pour une liste complète des plugins Third-Party c'est là : https://www.cni.dev/docs/#3rd-party-plugins

---

**Que font les plugins third party**

**Les plugins réseau tiers, tels que Calico, Flannel, Weave, et Cilium, permettent de gérer la connectivité réseau entre les pods et les services.** 

Ils peuvent offrir des fonctionnalités avancées comme :
- la sécurité du réseau, 
- le routage, 
- la gestion des politiques réseau.

---

## CNI et Network Policies

**Parmi les plugins CNI tiers couramment utilisés dans Kubernetes, **Flannel** et **Weave** sont des exemples qui ne fournissent pas nativement de fonctionnalités de Network Policies.**

Flannel se concentre principalement sur la connectivité de base entre les pods, tandis que Weave fournit des fonctionnalités de réseau overlay et une certaine sécurité de base, mais sans implémenter des Network Policies avancées comme celles supportées par des solutions telles que Calico ou Cilium.

Pour combler cette lacune, les utilisateurs doivent souvent combiner ces plugins avec des outils supplémentaires ou choisir des solutions CNI plus complètes qui intègrent des Network Policies.

---

### Flannel

**Rôle :**

- Fournit une solution simple de mise en réseau pour les conteneurs, principalement axée sur la connectivité de couche 3 (IP).

**Fonctionnalités :**

- Backend de réseau : Flannel supporte plusieurs backends pour la distribution du trafic réseau, y compris vxlan, host-gw, udp, et autres.
- Simplicité : Conçu pour être facile à déployer et à configurer, idéal pour les clusters Kubernetes de petite à moyenne taille.
- Routage : Utilise des sous-réseaux pour chaque nœud et encapsule le trafic entre les nœuds, selon le backend choisi.

---
   
### Calico

**Rôle** 

- Fournit des fonctionnalités avancées de mise en réseau et de sécurité pour les conteneurs.
- Offre une politique réseau riche qui permet de contrôler le trafic entre les pods en fonction de divers critères.
- Supporte le routage BGP (Border Gateway Protocol) pour une mise en réseau de grande échelle.

**Fonctionnalités** 

- Politiques de réseau : Calico permet de définir des politiques de réseau basées sur des étiquettes de pods, des espaces de noms et d'autres critères.
- Sécurité : Offre des fonctionnalités de pare-feu et de sécurité réseau, y compris l'application des politiques de sécurité au niveau des hôtes.
- Routage : Utilise BGP pour distribuer les routes réseau, facilitant ainsi la mise en réseau entre plusieurs clusters.

---


### Cilium

**Rôle :**

- Fournit une mise en réseau avancée pour les conteneurs, en mettant l'accent sur la sécurité et l'observabilité.

**Fonctionnalités :**

- eBPF (Extended Berkeley Packet Filter) : Utilise eBPF pour une performance élevée et une visibilité fine du trafic réseau.
- Politiques de sécurité : Permet de définir des politiques de sécurité réseau granulaires, y compris des règles basées sur les services, les applications et les utilisateurs.
- Observabilité : Offre des outils avancés pour la surveillance et le traçage du trafic réseau, aidant à diagnostiquer et à résoudre les problèmes de réseau.
- Intégration avec Service Mesh : Peut s'intégrer avec des solutions de service mesh comme Istio pour offrir des fonctionnalités réseau supplémentaires.

--- 

### Différences Clés

**Complexité et Facilité d'Utilisation :**

- **Flannel** : Plus simple et plus facile à configurer, idéal pour les déploiements moins complexes.
- **Calico** : Plus complexe à configurer en raison de ses fonctionnalités avancées, mais offre une grande flexibilité et des capacités de mise en réseau puissantes.
- **Cilium** : Complexe à cause de l'utilisation d'eBPF et des fonctionnalités de sécurité avancées, mais offre une grande visibilité et sécurité.

**Fonctionnalités de Sécurité :**

- **Flannel** : Moins axé sur la sécurité, principalement conçu pour la connectivité réseau de base.
- **Calico** : Politiques de sécurité détaillées et support de BGP pour une sécurité et une mise en réseau robustes.
- **Cilium** : Sécurité granulaire avec eBPF, permet une application fine des politiques de sécurité.

**Performance et Scalabilité :**

- **Flannel** : Peut rencontrer des limitations de performance avec des backends comme udp, mais reste performant avec vxlan.
- **Calico** : Très performant et scalable grâce au routage BGP.
- **Cilium** : Très performant grâce à l'utilisation d'eBPF, offrant également une meilleure observabilité et sécurité.

---

## Les technologies propres derrière les plugins tiers CNI 



| Technologie       | Spécificités                                                                 | Généralisation de son usage dans les plugins CNI                            |
|-------------------|------------------------------------------------------------------------------|---------------------------------------------------------------------------|
| Routage UDP       | Envoie des paquets de données sans connexion préalable via le protocole UDP | Utilisé dans certains plugins comme Flannel pour les réseaux overlay simples.  |
| Routage host-gw   | Utilise les tables de routage des hôtes pour diriger le trafic entre les pods sur différents nœuds | Implémenté dans des solutions comme Flannel en mode host-gw pour la simplicité et performance.  |
| Routage BGP       | Utilise le protocole Border Gateway Protocol pour échanger les routes IP entre les routeurs | Couramment utilisé par Calico pour le routage réseau hautement scalable et performant.  |
| VXLAN             | Crée des réseaux overlay à l'aide de tunnels encapsulés dans des paquets UDP | Utilisé par Flannel, Weave et d'autres pour créer des réseaux overlay extensibles.  |
| Réseau avec eBPF  | Utilise eBPF pour traiter le trafic réseau dans le kernel Linux de manière très efficace | Utilisé par Cilium pour la performance avancée et la sécurité des réseaux.  |
| IPIP              | Encapsulation de paquets IP dans d'autres paquets IP pour le transport sur le réseau | Utilisé par Calico en mode IPIP pour les réseaux overlay.  |
| GRE               | Generic Routing Encapsulation pour encapsuler une grande variété de protocoles de couche réseau | Moins courant, mais utilisé par certains pour des réseaux overlay spécifiques.  |
| SR-IOV            | Single Root I/O Virtualization pour fournir des réseaux à haute performance directement au niveau du matériel | Utilisé par des plugins comme SR-IOV CNI pour des besoins de performance maximale.  |
| MACVLAN           | Associe plusieurs adresses MAC à une interface réseau pour créer des interfaces virtuelles | Utilisé pour donner des adresses MAC distinctes aux pods, trouvé dans des plugins comme Multus.  |
| IPVS              | IP Virtual Server pour la répartition de charge et le routage basé sur la couche 4 | Utilisé par kube-proxy en mode IPVS pour une meilleure performance de la répartition de charge.  |
---

## Les outils utilisateurs des CNI

- **Kubeskoop** Une [solution](https://github.com/alibaba/kubeskoop) dédiée au réseau et orientée CNI
- **Hubble** https://github.com/cilium/hubble dépendant du CNI Cilium
- **Calico Cloud** Solution en SAAS qui fournit une [interface intéressante](https://docs.tigera.io/calico-cloud/tutorials/calico-cloud-features/tour).
- **Prometheus AWS CNI Metrics** Réservé au [CNI AWS](https://github.com/aws/amazon-vpc-cni-k8s) 
- **Hubble** https://github.com/cilium/hubble dépendant de Cilium

--- 


**En l'absence de bonnes solutions généralistes, on en revient aux outils classiques du stack Linux** 

``` 
$ kubectl debug mypod -it --image=nicolaka/netshoot

# Avec le plugin kubectl
kubectl netshoot debug my-existing-pod
kubectl netshoot run tmp-shell --host-network

```
---

**Il existe aussi des solutions pour utilisateurs avancés** 

- Kokotap : copier le trafic réseau d'un pod vers un autre pour analyse https://github.com/redhat-nfvpe/kokotap
 

--- 


## TP : Installation de Cilium comme Plugin CNI dans Kubernetes

Ce TP vous guidera à travers l'installation et la configuration de Cilium comme plugin CNI (Container Network Interface) dans un cluster Kubernetes.

#### Prérequis

- Un cluster Kubernetes fonctionnel (vous pouvez utiliser Minikube, Kind, ou un cluster géré sur le cloud comme GKE, EKS, ou AKS).
- kubectl installé et configuré pour accéder à votre cluster Kubernetes.
- Helm installé pour gérer les packages Kubernetes.

#### Étape 1 : Préparation du Cluster

1. **Vérifiez l'état du cluster :**
   ```bash
   kubectl get nodes
   ```
   Assurez-vous que tous les nœuds sont en état `Ready`.

2. **Désactivez le plugin CNI existant (si nécessaire) :**
   Si vous utilisez un cluster avec un plugin CNI déjà installé, vous devrez peut-être le désactiver avant d'installer Cilium.

#### Étape 2 : Installation de Helm

Si Helm n'est pas déjà installé, suivez ces étapes pour l'installer :

1. **Téléchargez et installez Helm :**
   ```bash
   curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
   ```

2. **Vérifiez l'installation de Helm :**
   ```bash
   helm version
   ```

#### Étape 3 : Ajouter le Répertoire Helm de Cilium

1. **Ajoutez le répertoire de Cilium :**
   ```bash
   helm repo add cilium https://helm.cilium.io/
   ```

2. **Mettez à jour les répertoires Helm :**
   ```bash
   helm repo update
   ```

#### Étape 4 : Installer Cilium

1. **Créez le namespace cilium :**
   ```bash
   kubectl create namespace cilium
   ```

2. **Installez Cilium avec Helm :**
   ```bash
   helm install cilium cilium/cilium --namespace cilium
   ```

3. **Vérifiez l'installation :**
   ```bash
   kubectl get pods -n cilium
   ```
   Tous les pods Cilium devraient être en état `Running`.

#### Étape 5 : Configuration Avancée (Optionnelle)

Vous pouvez configurer des options avancées pour Cilium via des valeurs Helm personnalisées. Par exemple, pour activer Hubble (observabilité et monitoring), vous pouvez utiliser un fichier de valeurs personnalisé.

1. **Créez un fichier de valeurs personnalisé (cilium-values.yaml) :**
   ```yaml
   global:
     hubble:
       enabled: true
       ui:
         enabled: true
   ```

2. **Appliquez les valeurs personnalisées lors de l'installation :**
   ```bash
   helm install cilium cilium/cilium --namespace cilium --values cilium-values.yaml
   ```

#### Étape 6 : Vérification et Test

1. **Vérifiez les logs des pods Cilium :**
   ```bash
   kubectl logs -n cilium -l k8s-app=cilium
   ```

2. **Déployez une application de test :**
   Déployons une simple application pour vérifier le bon fonctionnement de Cilium.
   ```bash
   kubectl create deployment nginx --image=nginx
   kubectl expose deployment nginx --port=80 --type=NodePort
   ```

3. **Accédez à l'application de test :**
   Récupérez l'URL de l'application :
   ```bash
   minikube service nginx --url
   ```
   Pour les clusters autres que Minikube, utilisez l'adresse IP et le port exposé.

#### Étape 7 : Utilisation de Hubble (Optionnelle)

Si vous avez activé Hubble, vous pouvez l'utiliser pour visualiser le trafic réseau dans votre cluster.

1. **Port-Forward Hubble UI :**
   ```bash
   kubectl port-forward -n cilium svc/hubble-ui 12000:80
   ```

2. **Accédez à Hubble UI :**
   Ouvrez votre navigateur et allez à `http://localhost:12000` pour visualiser le trafic réseau.

#### Conclusion

Vous avez maintenant installé et configuré Cilium comme plugin CNI dans votre cluster Kubernetes. Vous pouvez utiliser Cilium pour des fonctionnalités avancées de réseau et de sécurité, y compris la surveillance du trafic avec Hubble.

N'hésitez pas à explorer davantage les capacités de Cilium en consultant la documentation officielle : [Documentation Cilium](https://docs.cilium.io/).

### Points à explorer après le TP

- Configuration de la sécurité réseau avec Cilium Network Policies.
- Intégration de Cilium avec d'autres outils de monitoring et observabilité.
- Utilisation de Cilium pour le load balancing et le DNS service discovery.
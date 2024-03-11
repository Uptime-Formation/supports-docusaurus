---
title: Les concepts de base Kubernetes
draft: false
# sidebar_position: 8
---

## Les concepts de base Kubernetes


## L'API et les Objets Kubernetes

Utiliser Kubernetes consiste à déclarer des objets grâce à l’API Kubernetes pour décrire l’état souhaité d'un cluster : quelles applications ou autres processus exécuter, quelles images elles utilisent, le nombre de replicas, les ressources réseau et disque que vous mettez à disposition, etc.

On définit des objets généralement via l’interface en ligne de commande et `kubectl` de deux façons :

- en lançant une commande `kubectl run <conteneur> ...`, `kubectl expose ...`
- en décrivant un objet dans un fichier YAML ou JSON et en le passant au client `kubectl apply -f monpod.yaml`

Vous pouvez également écrire des programmes qui utilisent directement l’API Kubernetes pour interagir avec le cluster et définir ou modifier l’état souhaité. **Kubernetes est complètement automatisable !**

### La commande `apply`

Kubernetes encourage le principe de l'infrastructure-as-code : il est recommandé d'utiliser une description YAML et versionnée des objets et configurations Kubernetes plutôt que la CLI.

Pour cela la commande de base est `kubectl apply -f object.yaml`.

La commande inverse `kubectl delete -f object.yaml` permet de détruire un objet précédement appliqué dans le cluster à partir de sa description.

Lorsqu'on vient d'appliquer une description on peut l'afficher dans le terminal avec `kubectl apply -f myobj.yaml view-last-applied`

## Parenthèse : Le YAML

Kubernetes décrit ses ressources en YAML. A quoi ça ressemble, YAML ?

```yaml
- marché:
    lieu: Marché de la Place
    jour: jeudi
    horaire:
      unité: "heure"
      min: 12
      max: 20
    fruits:
      - nom: pomme
        couleur: "verte"
        pesticide: avec

      - nom: poires
        couleur: jaune
        pesticide: sans
    légumes:
      - courgettes
      - salade
      - potiron
```

---
## Syntaxe

- Alignement ! (**2 espaces** !!)
- des listes (tirets)
- des ditionnaires composés d'un ensemble de paires **clé: valeur** (dans n'importe quel ordre !)
- Un peu comme du JSON, avec cette grosse différence que le JSON se fiche de l'alignement et met des accolades et des points-virgules
- **les extensions Kubernetes et YAML dans VSCode vous aident à repérer des erreurs**

### Syntaxe de base d'une description YAML Kubernetes

Les description YAML permettent de décrire de façon lisible et manipulable de nombreuses caractéristiques des ressources Kubernetes (un peu comme un *Compose file* par rapport à la CLI Docker).

#### Exemple

Création d'un service simple :

```yaml
kind: Service
apiVersion: v1
metadata:
  labels:
    k8s-app: kubernetes-dashboard
  name: kubernetes-dashboard
  namespace: kubernetes-dashboard
spec:
  ports:
    - port: 443
      targetPort: 8443
  selector:
    k8s-app: kubernetes-dashboard
  type: NodePort
```

Organisation de la syntaxe :

- Les resources k8s sont de dictionnaires !

- Toutes les descriptions doivent commencer par spécifier le module d'API et sa version à partir de laquelle notre objet peut être créé et manipulé.
- Il faut ensuite préciser le type d'objet avec `kind`

S'ensuit deux sections présentes dans toutes  description Kubernetes:

- La section `metadata` est identique pour chaque type de resource et contient en particulier le nom, les étiquetes diverses, et éventuellement le namespace de la ressource. Le nom dans `metadata:\n name: value` est également obligatoire.

- La section `spec` qui précise tous les paramètres désirés spécifiques à la resource en question.

Les paramètres de la spec sont pour beaucoup facultatifs et prennent leur valeur par défaut s'ils ne sont pas écrit explicitement.

On peut aller observer les paramètres en ligne de commande avec la commande `kubectl explain` exemple:

```bash
kubectl explain pod
kubectl explain pod.spec.containers
kubectl explain deploy --recursive
```

### Description de plusieurs ressources

- On peut mettre plusieurs ressources à la suite dans un fichier k8s : cela permet de décrire une installation complexe en un seul fichier

  - par exemple le dashboard Kubernetes [https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml](https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml)

- L'ordre n'importe pas car les ressources sont décrites déclarativement c'est-à-dire que:

  - Les dépendances entre les ressources sont déclarées
  - Le control plane de Kubernetes se charge de planifier l'ordre correct de création en fonction des dépendances (pods avant le déploiement, rôle avec l'utilisateur lié au rôle)
  - On préfère cependant les mettre dans un ordre logique pour que les humains puissent les lire.

- On peut sauter des lignes dans le YAML et rendre plus lisible les descriptions
- On sépare les différents objets par `---`

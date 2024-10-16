---
title: TP optionnel - Kubernetes the (not so) hard way avec Ansible
---

<!-- Comme nous l'avons évoqué dans le cours précédent, pour installer Kubernetes soi-même (et dans sa version la plus "vanilla"), on utilise généralement `kubeadm` qui est une sorte d'opérateur d'installation et mise à jour des différents composants de Kubernetes ou on peut installer les composants à la main en suivant un tutoriel `Kubernetes the hard way` (ce qui est principalement utile a des fins d'apprentissage).

## Kubeadm : l'opérateur de cluster -->

## `Kubernetes the hard way` avec Ansible

![](/img/kubernetes/schemas-perso/k8s-archi.jpg)


La version la plus manuelle de l'installation de Kubernetes a été documentée à des fins d'apprentissage par Kelsey Hightower qui l'a nommé `Kubernetes the hard way`. On peut la retrouver à l'adresse https://github.com/kelseyhightower/kubernetes-the-hard-way/tree/master/docs.

La principale limite de cette méthode d'installation est le nombre très important de manipulations sur plusieurs serveurs et donc le temps d'installation conséquent, peu reproductible et qui favorise les erreurs. Pour remédier à cela, l'installation manuelle a été notamment reprise par `githubixx/RW` de tauceti.blog et intégré dans une série de tutoriels adossés à des roles Ansible qui documentent cette installation manuelle et sont d'après l'auteur utilisable en production à une échelle moyenne : https://www.tauceti.blog/posts/kubernetes-the-not-so-hard-way-with-ansible-the-basics/

Nous allons suivre étape par étapes cette installation manuelle Ansible pour observer et commenter concrêtement les différents composants et étapes d'installation de Kubernetes.

- Commencez par cloner le projet de base avec `git clone -b k8s_hard_way_ansible_correction https://github.com/e-lie/k8s_notsohardway_correction.git`

- Installer Terraform et Ansible avec `bash /opt/terraform.sh` et `sudo apt remove ansible && bash /opt/ansible.sh`

Nous allons maintenant ouvrir le projet et suivre le README pour créer l'infrastructure dans le cloud avec terraform puis exécuter les différents playbooks pour installer étape par étape cluster.

Chaque étape sera l'occasion de commenter le code Ansible et explorer notre cluster au cours de son installation.

### Créer les serveurs en IaC avec Terraform

- compléter le subdomain dans `terraform/variables.tf`
- compléter les tokens infra et DNS en copiant `terraform/secrets.auto.tfvars.dist` sans le .dist puis en complétant avec les tokens formateur. 

=> pour éviter les conflits, besoin de faire autant de projet hcloud que de stagiaires et envoyer un fichier avec un token cloud par personne par exemple dans le dépot git

Observons et expliquons ensemble le code.

- `./cloud_init setup_terraform`

### Setup Ansible

L'inventaire Ansible Terraform

- `source env_file`
- `ssh-add ~/.ssh/id_stagiaire`
- `ansible all -K -m ping`
- `ansible-inventory --host controller-0`

### Installation d'un réseau privé `wireguard`

Chapitre du tutorial : https://www.tauceti.blog/posts/kubernetes-the-not-so-hard-way-with-ansible-wireguard/

- role: `githubixx.ansible_role_wireguard` à appliquer avec `ansible-playbook -K --tags=role-wireguard k8s.yaml`

- variables de configuration dans `terraform/ansible_hosts` et `group_vars/vpn.yml`
### Setup PKI infrastructure

Chapitre du tutorial : https://www.tauceti.blog/posts/kubernetes-the-not-so-hard-way-with-ansible-certificate-authority/

- role: `githubixx.cfssl`, `ansible-playbook -K --tags=role-cfssl k8s.yaml`
- role: `githubixx.kubernetes-ca`, `ansible-playbook -K --tags=role-kubernetes-ca k8s.yaml`

- variables de configuration dans `group_vars/k8s_ca.yml`

- Génération des kubeconfigs des composants : `ansible-playbook -K playbooks/all_kubeconfs.yml` variables dans `group_vars/all.yml`

### Installation de `etcd` sur les controllers

Chapitre : https://www.tauceti.blog/posts/kubernetes-the-not-so-hard-way-with-ansible-etcd/

- variables dans `group_var/all.yml`

- role: `githubixx.etcd`, `ansible-playbook --tags=role-etcd k8s.yaml`

test de etcd avec 

```bash
    ansible -m shell -e "etcd_conf_dir=/etc/etcd" \
        -a 'ETCDCTL_API=3 etcdctl endpoint health \
            --endpoints=https://{{ ansible_wgk8slaab.ipv4.address }}:2379 \
            --cacert={{ etcd_conf_dir }}/ca-etcd.pem \
            --cert={{ etcd_conf_dir }}/cert-etcd-server.pem \
            --key={{ etcd_conf_dir }}/cert-etcd-server-key.pem' \
        k8s_etcd
```

### Installation des composants du control plane sur les controllers

Chapitre: https://www.tauceti.blog/posts/kubernetes-the-not-so-hard-way-with-ansible-control-plane/

- role `githubixx.kubernetes-controller` appliquer avec `ansible-playbook --tags=role-kubernetes-controller k8s.yml`

- variables dans `all.yml`

test des composants avec :

```bash
    kubectl cluster-info
    echo "test scheduler "
    curl -k https://10.8.0.101:10257/healthz
    echo "\ntest controller manager "
    curl -k https://10.8.0.102:10259/healthz
```

### Installation de `containerd`,  `kubelet` et `kube-proxy` sur les workers

Chapitre : https://www.tauceti.blog/posts/kubernetes-the-not-so-hard-way-with-ansible-worker-2020/
alternative plus ancienne avec Docker et Flannel CNI : https://www.tauceti.blog/posts/kubernetes-the-not-so-hard-way-with-ansible-worker/

variables dans `k8s_worker`

role : `githubixx.containerd` appliquer avec `ansible-playbook --tags=role-containerd k8s.yml`

Puis role `githubixx.kubernetes-worker` appliquer avec `ansible-playbook --tags=role-kubernetes-worker k8s.yml`

Tester avec `kubectl get nodes` les nodes sont notready car il manque le plugin CNI
### Installation du CNI `cilium`

Même chapitre

role : `githubixx.cilium_kubernetes` appliquer avec `ansible-playbook --tags=role-cilium-kubernetes -K -e cilium_install=true k8s.yml`

### Installation de CoreDNS

Même chapitre

playbook : `githubixx_playbooks/coredns.yml` appliquer avec `ansible-playbook -K`

Faire un déploiement de test `kubectl -n default apply -f https://k8s.io/examples/application/deployment.yaml`
- `kubectl -n default get all -o wide`
- `ansible -m get_url -a "url=http://10.200.1.23 dest=/tmp/test.html" k8s_worker`

### Mise à jour de l'infra

La mise à jour des différents composant est discutée dans les posts de blogs tauceti mais pour une vue générale on peut se référer à la documentation officielle : https://kubernetes.io/docs/tasks/administer-cluster/cluster-upgrade/
### Correction par un script

Pour installer toute l'infrastructure en une seule commande : `bash deploy_all.sh`
## Détruire l'infra

- `./cloud_init destroy_infra`

## Cluster de 4 noeuds terraform/kubeadm avec metallb, rook, argoCD

- `git clone -b kubadm_tf_prod_cluster https://github.com/e-lie/provisioning.git `

- compléter le subdomain avec votre prenom ou autre dans `variables.tf`
- compléter les tokens infra et DNS dans en copiant `env_secrets.dist` en `env_secret` et complétant avec les token formateur.

- `./cloud_init setup_terraform`. Si il y a une errur concernant le `remote exec` rexecutez `ssh-add ~/.ssh/id_stagiaire` et relancez l'installation.

- Modifiez la ligne `export KUBE1_DOMAIN=kube1.k8slab.dopl.uk` du fichier `get_k8s_admin_config.sh` en remplaçant k8slab par votre sous domaine et exécutez ce script avec `bash`.

- Testez la bonne installation du cluster avec `kubectl cluster-info` et `kubectl get nodes`. Vous pouvez également ajouter la kubeconfig `hobby-kube-connection.yaml` à Lens.

### Installer un storage provisionner (CSI plugin)

Deux options dans ce TP: rook ceph ou le plugin local storage de rancher

#### Option rook

- Utilisez le quickstart (https://rook.io/docs/rook/v1.9/quickstart.html) et les manifestes présents dans le dossier `k8s-boostrap/rook1_9_2`.

On peut ensuite debugger avec un pod rook toolbox.
#### Option localstorage

kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.22/deploy/local-path-storage.yaml

### Installer metallb

Autre élément indispensable d'un cluster on premise, être capable de faire rentrer le traffic depuis l'extérieur. Par défault les services de type `LoadBalancer` ne fonctionnerons pas et resterons des `NodePort`. Il est alors possible de provisionner manuellement des loadbalancer externes vers le bon nodeport. Mais cette méthode est peu efficace et provoque vite des erreurs liées à des conflits de ports et problèmes de mise à jour manuelle.

La solution adapté est probablement d'installer la solution générique `metallb` qui peut fournir des loadbalancer internes au cluster.

- Compléter `k8s-bootstrap/metallb-values.yaml` avec les liste des ips des noeuds récupérées avec `ping kube1-3.<subdomain>.dopl.uk`
- Installer `metallb` avec le chart helm grâce à la commande : 

```bash
helm upgrade --install metallb metallb \
  --repo https://metallb.github.io/metallb \
  --namespace metallb-system --create-namespace \
  --version 0.12.1 --values=k8s-bootstrap/metallb-values.yaml
```

- Par défaut nous l'avons installé en mode IP : les agents speakers vont répondre aux requêtes ARP pour assigner les IP que nous avons fournies aux noeuds et rediriger le traffic vers le bon service endpoint.
### Installer le `Ingress Nginx`

Installons le Ingress Nginx pour exposer des services HTTP et immédiatement vérifier que les services `LoadBalancer` fonctionnent:

```bash
helm upgrade --install ingress-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --namespace ingress-nginx --create-namespace \
  --version 4.1.0
```

- Si metallb est bien configuré, le service qui expose le ingress controller devrait se voir attribuer une IP externe. On peut le vérifier avec la commande: `kubectl get svc -n ingress-nginx -o wide`.

### Installer l'opérateur `CertManager`

voir le début du TP `CI/CD avec Gitlab et ArgoCD`
### Installer ArgoCD pour superviser les applications

voir le début du TP `CI/CD avec Gitlab et ArgoCD`

### Installer du monitoring

voir TP monitoring et série de tutorial dans ce TP pour plus avancé

### Installer le gestionnaire d'identité keycloak et la connection openID à Kubernetes

- https://github.com/int128/kubelogin
- https://www.keycloak.org/getting-started/getting-started-kube

- https://www.talkingquickly.co.uk/installing-keycloak-kubernetes-helm
- https://www.talkingquickly.co.uk/setting-up-oidc-login-kubernetes-kubectl-with-keycloak

### Installer Rancher ?


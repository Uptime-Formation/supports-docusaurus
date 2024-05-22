---
title: "TP: lancer des conteneurs plus sécurisés (cgroup, capabilities, rootless)"
---

## Limiter les resources avec les cgroups

... Pour éviter que le conteneur compromis puisse consommer toutes les resources et provoquer un déni de service plus global

Essayez de lancer un conteneur nginx avec quelque uns des paramètres suivants:

- `--memory=<memory size>` — maximum amount of memory (for example 512m)
- `--restart=on-failure:<number_of_restarts>` — number of restarts
- `--cpus=<number>` — maximum CPU resources available to a container
- `--ulimit nofile=<number>` — maximum number of file descriptors
- `--ulimit nproc=<number>` — maximum number of processes

## Scanner une image pour les vulnérabilités avec `trivy`

- Installez `trivy` par exemple avec le script kubernetes.sh si dispo sur la machine (`bash /opt/kubernetes.sh`) puis relancez le terminal

- Lancez `trivy image registry` puis `trivy image microblog` des tp précédents. Commentons


## Limiter les `capabilities` accordées à l'utilisateur

Traduction simplifiée de la doc: https://docs.docker.com/engine/security/#linux-kernel-capabilities

Par défaut, Docker démarre les conteneurs avec un ensemble restreint de `capabilities`. Qu'est-ce que cela signifie ?

Les capabilities transforment la dichotomie binaire "root/non-root" en un système de contrôle d'accès finement réglé. Les processus (comme les serveurs web) qui ont juste besoin de se lier à un port inférieur à 1024 n'ont pas besoin de s'exécuter en tant que root : ils peuvent simplement se voir accorder la capability `net_bind_service` à la place. Et il existe de nombreuses autres capabilities, couvrant presque tous les domaines spécifiques où les privilèges root sont habituellement nécessaires.

Les serveurs typiques exécutent plusieurs processus en tant que root par exemple le démon SSH, le démon cron, les modules du noyau, etc. Mais un conteneur n'a pas besoin de faire tout ça ces tâches sont gérées par l'infrastructure docker autour du conteneur :

- L'accès SSH est généralement géré par un seul serveur s'exécutant sur l'hôte Docker
- cron, lorsqu'il est nécessaire, devrait s'exécuter en tant que processus utilisateur, dédié et adapté à l'application qui a besoin de son service de planification, plutôt que comme une installation globale à la plateforme
- La gestion du réseau se fait à l'extérieur des conteneurs, ce qui signifie qu'un conteneur ne devrait jamais avoir besoin d'exécuter les commandes ifconfig, route ou ip

Cela signifie que dans la plupart des cas, les conteneurs n'ont pas besoin de "vrais" privilèges root du tout. Et par conséquent, les conteneurs peuvent fonctionner avec un ensemble réduit de capabilities ; ce qui signifie que "root" dans un conteneur a beaucoup moins de privilèges que le vrai "root". Par exemple, il est possible de :

- Interdire toutes les opérations "mount"
- Interdire l'accès aux sockets bruts (pour empêcher le spoofing de paquets)
- Interdire l'accès à certaines opérations sur le système de fichiers, comme la création de nouveaux nœuds de périphérique, le changement de propriétaire de fichiers ou la modification d'attributs (y compris le flag immutable)
- Interdire le chargement de modules

Ainsi même si un intrus parvient à devenir root dans un conteneur, il est beaucoup plus difficile de causer des dommages sérieux ou de s'escalader jusqu'à l'hôte.
Cela réduit considérablement les vecteurs d'attaque des utilisateurs malveillants. Par défaut, Docker désactive toutes les capabilities sauf celles nécessaires:

- https://github.com/moby/moby/blob/master/oci/caps/defaults.go#L6-L19
- explication des capabilities : https://www.baeldung.com/linux/set-modify-capability-permissions#possible-system-capabilities

Lancer un conteneur `registry2` avec toutes les capabilities désactivées (si l'application fonctionne sans, ce n'est jamais une mauvaise) : `docker run -d --name registry2 -p 5001:5000 --cap-drop=all registry:2` : normalement ici aucune n'est nécessaire.

pour remettre tout désactiver et remettre par exemple juste le droit de chown : `docker run -d --name registry3 -p 5001:5000 --cap-drop=all --cap-add CHOWN registry:2`

## Le mode Rootless de docker

Le mode rootless permet d'exécuter le démon Docker et les conteneurs en tant qu'utilisateur non-root afin de réduire les vulnérabilités potentielles dans le daemon Docker et l'environnement d'exécution des conteneurs.

Le mode rootless ne nécessite pas de privilèges root, même lors de l'installation du démon Docker.

Un autre façon de le dire :

- un conteneur rootful (classique) est lancé par l'utilisateur root et a potentiellement accès aux fonctionnalités que root possède en cas de faille dans la runtime (mis à part la réduction des `capabilities` effectuée automatiquement par Docker si le conteneur n'est pas lancé avec `--priviledged`). Ça n'est pas la même chose que de dire que le processus lancé dans le conteneur est lancé et root !

- Lorsque docker est lancé en mode `rootless` (c'est à dire que le daemon est lancé par un utilisateur) tous les conteneurs sont créés comme enfants d'un user namespace dans lequel sont recréé des "sous utilisateurs" y compris un "faux" user root et d'autre user namespaces (pour chaque conteneur). Donc on peut être root dans conteneur rootless sans risque.

### Installer et lancer docker en mode rootless (sur ubuntu 22.04)

La documentation afférente est ici : https://docs.docker.com/engine/security/rootless/

- `sudo apt-get install -y dbus-user-session uidmap systemd-container docker-ce-rootless-extras`
- `cat /etc/subuid` devrait afficher qqch comme `<votreuser>:100000:65536`
- Dans le terminal ou vous allez lancer l'installation executez (en remplaçant `<votreuser>`): `sudo machinectl shell <votreuser>@`
- Désactivez le daemon docker lancé en root avec : `sudo systemctl disable --now docker.service docker.socket`
- supprimez la socket docker normale `sudo rm /var/run/docker.sock`
- Lancez l'installation de docker rootless : `dockerd-rootless-setuptool.sh install`

La dernière commande devrait afficher pas mal de lignes de sortie avec parmis elles `Installed docker.service successfully`

- Lancez le service docker en tant qu'utilisateur : `systemctl --user start docker`

- ensuite pour pouvoir utiliser la cli docker en se connectant au bon socket il faut exporter la variable d'environnement pointant vers lui: `export DOCKER_HOST=unix:///run/user/1000/docker.sock`

Testez l'installation avec `docker ps` puis `docker run -d -p 8888:80 nginx` et visitez `localhost:8888`

### Limitations connues (traduction de la documentation)

Limitations connues
- Seuls les pilotes de stockage suivants sont pris en charge :
  - overlay2 (uniquement si exécuté avec le noyau 5.11 ou ultérieur, ou avec un noyau d'Ubuntu)
  - fuse-overlayfs (uniquement si exécuté avec le noyau 4.18 ou ultérieur, et que fuse-overlayfs est installé)
  - btrfs (uniquement si exécuté avec le noyau 4.18 ou ultérieur, ou si ~/.local/share/docker est monté avec l'option de montage user_subvol_rm_allowed)
  - vfs

- La limitation des ressources Cgroup est prise en charge uniquement lorsqu'il est exécuté avec cgroup v2 et systemd
- Les fonctionnalités suivantes ne sont pas prises en charge :
  - AppArmor
  - Checkpoint
  - Réseau overlay (swarm)
  - Exposition des ports SCTP

- Pour utiliser la commande ping, voir Routage des paquets ping dans la doc docker rootless.
- Pour exposer des ports TCP/UDP privilégiés (< 1024), voir Exposition des ports privilégiés dans la documentation.
- L'adresse IP affichée dans docker inspect est nommée dans le namespace réseau de RootlessKit. Cela signifie que l'adresse IP n'est pas accessible depuis l'hôte sans `nsenter` dans le namespace réseau.
- Le réseau hôte (docker run --net=host) est également namespacé dans RootlessKit.
- Les montages NFS en tant que "data-root" de Docker ne sont pas pris en charge. Cette limitation n'est pas spécifique au mode rootless.

Voir aussi "éviter certains pièges de docker rootless" : https://joeeey.com/blog/rootless-docker-avoiding-common-caveats/


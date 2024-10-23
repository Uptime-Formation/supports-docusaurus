---
title: Docker Avancé - Les instances 
weight: 6
---

## Les instances

![](/img/docker/docker-daemon-architecture.jpg)

---

## Le cycle de vie des instances Docker

![](../../static/img/docker/docker-lifecycle.png)

--- 

## Debugger Docker

Les instances Docker sont des processus standards lancés dans un host. 

**On dispose des moyens classiques pour suivre son activité :** 

- Logs
- Strace

**On peut également bénéficier des outils spécifiques aux conteneurs** 

- Modifier la manière de lancer le container (ex: donner les droits root)
- Exec dans le même espace de conteneurisation

**Comment faire quand on utilise des images distroless i.e. sans Shell ?** 

- Disposer d'une image non-distroless
- Utiliser l'API debug de l'orchestrateur k8s

--- 

## Les volumes Docker

![](../../static/img/docker/docker-volumes.png)

**Rappel : à quoi servent les volumes dans les environnements de conteneurs ?**

Les instances Docker sont... des processus standards lancés dans un host. 

On peut monter des volumes selon les méthodes usuelles de Linux : 

- mount bind
- mount tmpfs
- mount spécifiques Docker (ex: /var/lib/docker/xxx)


### Plugins de volumes

On peut utiliser d'autres systèmes de stockage en installant de nouveau plugins de driver de volume. Par exemple, le plugin `vieux/sshfs` permet de piloter un volume distant via SSH.

Exemples:

- SSHFS (utilisation d'un dossier distant via SSH)
- NFS (protocole NFS)
- BeeGFS (système de fichier distribué générique)
- Amazon EBS (vendor specific)
- etc.

```shell
# Installation du plugin SSHFS
$ docker plugin install vieux/sshfs

# Création du volume
$ docker volume create -d vieux/sshfs -o sshcmd=<sshcmd> -o allow_other sshvolume

# Montage du volume
$ docker run -p 8080:8080 -v sshvolume:/path/to/folder --name test someimage
```

---

## Les réseaux Docker

**Les réseaux Docker sont automatisés : DNS, IP Address Management, et plus.**

La solution basique est de faire un bridge local.

![](../../static/img/docker/docker-network.png)

**La solution Docker Swarm utilise un réseau spécial nommé overlay.**

![](../../static/img/docker/docker-swarm-overlay.png)

**La solution Kubernetes apporte des composants qui permettent de résoudre plus habilement les problèmes réseaux.**


![](../../static/img/docker/k8s-net-simple.png)

---

**On accède aux réseaux dans Docker avec la ligne de commande et le verbe `network`**

Ex: `docker network ls`

--- 

## TP : Lancer deux instances Docker avec un volume et un réseau nommés partagés

Objectif : vous devez lancer deux instances Docker 
- avec une image alpine
- nommées container_1 et container_2 
- dans le même réseau `test` 
- avec le même volume `test` monté sur /data

Vous devriez pouvoir afficher et modifier le contenu d'un même fichier. 

Vous devriez également pouvoir faire un ping de la machine 1 vers la machine 2.

<details><summary>Correction</summary>

```yml

docker network create test
docker volume create test
docker run -d --rm -v test:/data --network test --name container_1 alpine:latest sh -c "while true; do read /dev/null; done"
docker run -d --rm -v test:/data --network test --name container_2 alpine:latest sh -c "while true; do read /dev/null; done"
docker exec -it container_1 sh
    / # echo container_1 > /data/info
docker exec -it container_2 sh
    / # cat /data/info 
    / # ping container_1

```


</details>
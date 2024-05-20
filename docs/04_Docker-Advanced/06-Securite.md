---
title: Docker Avancé - Securite 
weight: 6
---


## Sécurité / durcissement

- **un conteneur privilégié est _root_ sur la machine !**
  - et l'usage des capabilities Linux dès que possible pour éviter d'utiliser `--privileged`
  - on peut utiliser [`bane`](https://github.com/genuinetools/bane), un générateur de profil AppArmor pour Docker
  - dans l'écrasante majorité des cas, on peut se concentrer sur les *capabilities* (pour des conteneurs non privilégiés) pour avoir un cluster Docker déjà très sécurisé.
  - SELinux peut s'activer sur les systèmes RedHat : plusieurs règles liées à la conteneurisation sont ajoutées au système hôte pour rendre plus difficile une exploitation via un conteneur. Cela s'active dans les options du daemon Docker : <https://www.arhea.net/posts/2020-04-28-selinux-for-containers/>
  - les profils *seccomp* ont une logique similaire : ils désactivent certains appels kernel (syscall) pour rendre plus difficile une exploitation (voir https://docs.docker.com/engine/security/seccomp/). En général on utilise un profil par défaut.

- des _cgroups_ corrects par défaut dans la config Docker : `ulimit -a` et `docker stats`

- par défaut les _user namespaces_ ne sont pas utilisés !
  - exemple de faille : <https://medium.com/@mccode/processes-in-containers-should-not-run-as-root-2feae3f0df3b>
  - exemple de durcissement conseillé : <https://docs.docker.com/engine/security/userns-remap/>

- le benchmark Docker CIS : <https://github.com/docker/docker-bench-security/>

- La sécurité de Docker c'est aussi celle de la chaîne de dépendance, des images, des packages installés dans celles-ci : on fait confiance à trop de petites briques dont on ne vérifie pas la provenance ou la mise à jour

  - Docker Scout, Clair ou Trivy : l'analyse statique d'images Docker grâce aux bases de données de CVEs

  - [Watchtower](https://github.com/containrrr/watchtower) : un conteneur ayant pour mission de périodiquement recréer les conteneurs pour qu'ils utilisent la dernière image Docker

- [docker-socket-proxy](https://github.com/Tecnativa/docker-socket-proxy) : protéger la _socket_ Docker quand on a besoin de la partager à des conteneurs comme Traefik ou Portainer



- intégration des événements suspects à un SIEM avec Falco :
https://github.com/falcosecurity/falco

## Les registries privés
Un registry avancé, par exemple avec [Harbor](https://goharbor.io/docs/2.10.0/install-config/demo-server/), permet d'activer le scanning d'images, de gérer les droits d'usage d'images, et de potentiellement restreindre les images utilisables dans des contextes d'organisation sécurisés.

---
title:  Securite 
weight: 6
---


## Sécurité / durcissement

---

### La sécurité Docker... un vaste débat

**Docker a toujours eu la réputation d'être une solution peu sécurisable.**

Et c'est normal car c'est une solution qui s'appuie sur des fondamentaux complexes, dans un cadre exposé et avec une vision self-service et agile qui n'arrange rien.

La page sécurité de Docker donne de bons indices sur la complexité des actions à mener pour sécuriser une instance Docker.

> https://docs.docker.com/engine/security/

---

**La sécurité dans Docker s'appuie sur plusieurs couches de protection pour isoler les conteneurs et sécuriser l'environnement d'exécution.**

![](../../static/img/docker/docker_security_layers.png)

---

### Sécurité des images et contrôle des dépendances (image SHA-pinning)

**Le pinning par SHA permet de verifier l'intégrité des images et éviter les attaques de type "supply chain" :**

```dockerfile
# MAUVAIS - utilisation de tags flottants
FROM nginx:latest

# BON - utilisation de SHA spécifique
FROM nginx@sha256:abc123def456...

# MEILLEUR - utilisation à la fois du tag et du SHA
FROM nginx:1.21@sha256:abc123def456...
```

**Intégration de Clair pour l'analyse de vulnérabilités :**

```yaml
version: '3.8'
services:
  clair:
    image: quay.io/clair/clair:latest
    restart: unless-stopped
    depends_on:
      - postgres
    environment:
      - CLAIR_DATABASE=postgresql://clair:password@postgres:5432/clair?sslmode=disable
    ports:
      - "6060:6060"

  clair-scanner:
    image: objectiflibre/clair-scanner:latest
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    command: >
      sh -c "
        clair-scanner --ip host --report /reports/report.json \
        --clair http://clair:6060 myapp:latest
      "
```

**Déploiement d'un registre privé isolé avec Harbor :**

```yaml
version: '3.8'
services:
  harbor-core:
    image: goharbor/harbor-core:latest
    environment:
      - CORE_SECRET=secret
      - REGISTRY_CREDENTIAL_USERNAME=admin
      - REGISTRY_CREDENTIAL_PASSWORD=password
    depends_on:
      - harbor-db
      - harbor-redis

  harbor-registry:
    image: goharbor/registry-photon:latest
    environment:
      - REGISTRY_HTTP_SECRET=secret
    volumes:
      - registry_data:/storage

  harbor-db:
    image: goharbor/harbor-db:latest
    environment:
      - POSTGRES_PASSWORD=password
    volumes:
      - db_data:/var/lib/postgresql/data

volumes:
  registry_data:
  db_data:
```

---


## Outils de posture Docker Bench et CIS pour renforcement de la sécurité

![](../../static/img/docker/docker-security-cis-benchmark.png)

**Docker Bench Security automatise les vérifications du CIS Benchmark :**

```shell
# Exécution de Docker Bench Security
$ git clone https://github.com/docker/docker-bench-security.git
$ cd docker-bench-security
$ sudo ./docker-bench-security.sh

# Exécution via conteneur
$ docker run -it --net host --pid host --userns host --cap-add audit_control \
    -v /var/lib:/var/lib \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /etc:/etc \
    docker/docker-bench-security

# Vérifications spécifiques
$ ./docker-bench-security.sh -c check_2_1
```

**Exemple de sortie des vérifications :**
```
[INFO] 2.1  - Restrict network traffic between containers
[PASS] 2.1  - Ensure network traffic is restricted between containers on the default bridge
[WARN] 2.2  - Ensure the logging level is set to 'info'
[FAIL] 2.3  - Ensure Docker is allowed to make changes to iptables
```

**Configuration CIS recommandée dans `/etc/docker/daemon.json` :**

```json
{
  "userns-remap": "default",
  "log-level": "info",
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "live-restore": true,
  "userland-proxy": false,
  "no-new-privileges": true
}
```

---

**Configuration via Docker Compose :**

```yaml
version: '3.8'
services:
  webapp:
    image: nginx:latest
    deploy:
      resources:
        limits:
          cpus: '1.0'
          memory: 512M
        reservations:
          cpus: '0.5'
          memory: 256M
    ulimits:
      nproc: 65535
      nofile:
        soft: 20000
        hard: 40000
```

**Types de ressources contrôlables :**
- Mémoire RAM et swap
- CPU shares et quotas
- I/O disque (BPS, IOPS)
- Network bandwidth
- PIDs maximum

---

### Sécurité des images et contrôle des dépendances

![](https://docs.docker.com/engine/security/trust/images/trust_components.png)

**La sécurisation de la supply chain des images est fondamentale.** L'utilisation de SHAs pour épingler les images garantit leur intégrité, mais des outils supplémentaires sont nécessaires pour analyser leur contenu.

- **Image SHA-pinning** : S'assurer de tirer (pull) des images par leur digest cryptographique (`image@sha256:abc123...`) plutôt que par un tag mutable comme `latest`. Ceci garantit que l'image exécutée est exactement celle qui a été testée .
- **Analyse des vulnérabilités avec Clair** : Des outils comme Clair peuvent être intégrés pour scanner automatiquement les images des registres pour les vulnérabilités connues (CVEs) .
- **Registre privé avec Harbor** : Harbour fournit un registre d'images conteneurisé avec des fonctionnalités de sécurité comme l'analyse des vulnérabilités, la signature d'images et le contrôle d'accès basé sur les rôles, permettant de centraliser et de sécuriser la gestion des artefacts.

---

**La fonction **Docker Enterprise Hardened Images** fournit des images de base conçues pour être conformes au benchmark CIS Docker.** 

La mise à disposition de ces images réduit les efforts de durcissement initial .

---

### Les user namespaces pour l'isolation

**Les user namespaces remappent les UID/GID à l'intérieur du conteneur vers des utilisateurs non privilégiés sur l'hôte.** Cela signifie qu'un processus s'exécutant en tant que `root` (UID 0) à l'intérieur du conteneur est mappé à un UID normal non privilégié sur le système hôte, limitant considérablement les dommages potentiels en cas d'évasion du conteneur .

**La configuration se fait via le fichier `/etc/docker/daemon.json` :**
```json
{
  "userns-remap": "default"
}
```

---

**La fonction **Enhanced Container Isolation (ECI)** de Docker Enterprise va bien plus loin.** 

Elle applique systématiquement les user namespaces à *tous* les conteneurs, même ceux lancés avec le flag `--privileged` . ECI utilise le runtime Sysbox, qui :
- Applique des mappages d'UID exclusifs pour chaque conteneur.
- Bloque le partage des namespaces de l'hôte (comme `--pid=host` ou `--network=host`).
- Émule des parties des systèmes de fichiers `/proc` et `/sys` pour cacher les informations sensibles de l'hôte .
- Rend les conteneurs privilégiés sûrs en les empêchant de modifier les paramètres noyau globaux de la machine hôte .

---

### Outils de posture Docker Bench et CIS

**Le CIS Docker Benchmark** est un ensemble de recommandations de configuration sécurisée développé par le Center for Internet Security, couvrant l'hôte, le daemon, les images et le runtime .

**Docker Bench for Security** est un script open-source qui automatise la vérification de ces bonnes pratiques .

```bash
# Cloner et exécuter le script
$ git clone https://github.com/docker/docker-bench-security.git
$ cd docker-bench-security
$ sudo sh docker-bench-security.sh
```

**Fonctionnement et cas d'usage  :**
- **Évaluation de la conformité** : Produit des rapports clairs (PASS, WARN, INFO) liés aux contrôles CIS.
- **Intégration CI/CD** : Peut être exécuté dans des pipelines pour bloquer les déploiements non conformes.
- **Surveillance continue** : Détecte la dérive de configuration dans les environnements de production.

---

### Limiter les ressources avec les cgroups

**Les cgroups (control groups)** sont une fonctionnalité du noyau Linux que Docker utilise pour limiter, accounted for et isoler l'utilisation des ressources .

**Gestion de la mémoire  :**
- `-m` ou `--memory` : Limite la mémoire maximale (ex: `512m`, `2g`).
- `--memory-swap` : Limite la mémoire totale (RAM + swap). Pour désactiver le swap, fixez `--memory-swap` égal à `--memory`.
- `--memory-reservation` : Définit une limite logicielle, moins stricte, activée en cas de contention mémoire.

**Gestion du CPU  :**
- `--cpus` : Limite le nombre de CPU (ex: `1.5`).
- `--cpuset-cpus` : Contraindre le conteneur à des CPU spécifiques (ex: `0-3` ou `1,3`).

**Exemple pratique :**
```bash
# Lancer un conteneur avec des limites strictes
$ docker run -d \
  --name my-app \
  --memory="1g" \
  --memory-swap="1g" \
  --cpus="2" \
  --cpuset-cpus="0,1" \
  nginx:latest

# Surveiller l'utilisation des ressources
$ docker stats my-app
```

---

### Capabilities, seccomp et Linux Security Modules

**Approche de sécurité en couches pour le runtime.**

**Capabilities Linux** : Docker, par défaut, exécute les conteneurs avec une liste restreinte de privilèges (capabilities), suivant une approche de type "allow-list" . Il est possible de retirer des capabilities encore plus spécifiques ou, avec une extrême prudence, d'en ajouter.

```bash
# Lancer un conteneur en supprimant toutes les capabilities, puis en ajoutant une seule nécessaire
$ docker run -it --rm --cap-drop=ALL --cap-add=NET_BIND_SERVICE alpine
```

**Seccomp (Secure Computing Mode)** : Docker utilise un profil seccomp par défaut qui restreint les appels système disponibles pour un conteneur. Ce profil est personnalisable via un profil JSON pour verrouiller encore plus l'environnement .

**Linux Security Modules (LSM)** :
- **AppArmor** : Docker génère et charge automatiquement un profil AppArmor par défaut pour chaque conteneur. Des profils personnalisés peuvent être utilisés pour un contrôle granulaire des actions des processus (lecture, écriture, exécution, etc.) .
- **SELinux** : Si l'hôte utilise SELinux (comme RHEL, CentOS), les étiquettes (labels) peuvent être appliquées aux conteneurs pour contrôler l'accès .

---

## Conclusion


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

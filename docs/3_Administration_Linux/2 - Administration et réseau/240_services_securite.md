---
title: Cours - Services et sécurité basique d'un serveur
---

### Objectifs

- Parler de la gestion des services
- Tout en appliquant ça à certaines pratiques "de base" de sécurité d'un serveur

### `sshd`

- Un service ou "daemon" qui écoute sur le port 22
- Il gère les connexions SSH ...
- comme d'autres services : il passe sa vie toujours éveillé et prêt à répondre
- Comme beaucoup d'autre programmes : sa configuration est dans `/etc/` et ses logs dans `/var/log/`

En particulier :
- `/etc/ssh/sshd_config` : configuration du daemon
- `/var/log/daemon.log` : un fichier de log utilisé par plusieurs daemons
- `/var/log/auth.log` : logs d'authentification

### `/etc/ssh/sshd_config`

```text
Port 22
HostKey /etc/ssh/ssh_host_ecdsa_key
PermitRootLogin yes
AllowGroups root ssh
```

### Bonnes pratiques en terme de ssh

- (plus ou moins subjectif !..)
- Changer le port 22 en quelque chose d'autre (2222, 2323, 2200, ...)
- Desactiver le login root en ssh
- Utiliser exclusivement des clefs

### Gérer un service avec `systemd`

```bash
$ systemctl status  <nom_du_service> # Obtenir des informations sur le status du service
```

```bash
$ systemctl start   <nom_du_service> # Démarrer le service
$ systemctl reload  <nom_du_service> # Recharger la configuration
$ systemctl restart <nom_du_service> # Redémarrer le service
$ systemctl stop    <nom_du_service> # Stopper le service
```

```bash
$ systemctl enable  <nom_du_service> # Lancer le service au démarrage de la machine
$ systemctl disable <nom_du_service> # Ne pas lancer le service au démarrage
```


```bash
systemctl status ssh
● ssh.service - OpenBSD Secure Shell server
   Loaded: loaded (/lib/systemd/system/ssh.service; enabled; vendor preset: enabled)
   Active: active (running) since Wed 2018-10-10 17:43:11 UTC; 3h 17min ago
 Main PID: 788 (sshd)
   CGroup: /system.slice/ssh.service
           └─788 /usr/sbin/sshd -D

Oct 10 20:39:34 scw-5e2fca sshd[5063]: input_userauth_request: invalid user user [preauth]
Oct 10 20:39:34 scw-5e2fca sshd[5063]: pam_unix(sshd:auth): check pass; user unknown
Oct 10 20:39:34 scw-5e2fca sshd[5063]: pam_unix(sshd:auth): authentication failure; logname= uid=0 euid=0 tty=ssh ruser= r
Oct 10 20:39:37 scw-5e2fca sshd[5063]: Failed password for invalid user user from 5.101.40.101 port 33879 ssh2
Oct 10 20:39:37 scw-5e2fca sshd[5063]: Connection closed by 5.101.40.101 port 33879 [preauth]
```


### Investiguer des logs

- Fouiller `/var/log` ... par exemple : `/var/log/auth.log`

```text
Oct 10 20:50:35 scw-5e2fca sshd[5157]: Invalid user user from 5.101.40.101 port 34418
Oct 10 20:50:35 scw-5e2fca sshd[5157]: input_userauth_request: invalid user user [preauth]
Oct 10 20:50:35 scw-5e2fca sshd[5157]: pam_unix(sshd:auth): check pass; user unknown
Oct 10 20:50:35 scw-5e2fca sshd[5157]: pam_unix(sshd:auth): authentication failure; logname= uid=0 euid=0 tty=ssh ruser= rhost=5.101.40.101
Oct 10 20:50:38 scw-5e2fca sshd[5157]: Failed password for invalid user user from 5.101.40.101 port 34418 ssh2
Oct 10 20:50:38 scw-5e2fca sshd[5157]: Connection closed by 5.101.40.101 port 34418 [preauth]
Oct 10 21:01:37 scw-5e2fca sshd[5174]: Invalid user user from 5.101.40.101 port 35162
Oct 10 21:01:37 scw-5e2fca sshd[5174]: input_userauth_request: invalid user user [preauth]
Oct 10 21:01:37 scw-5e2fca sshd[5174]: pam_unix(sshd:auth): check pass; user unknown
Oct 10 21:01:37 scw-5e2fca sshd[5174]: pam_unix(sshd:auth): authentication failure; logname= uid=0 euid=0 tty=ssh ruser= rhost=5.101.40.101
Oct 10 21:01:39 scw-5e2fca sshd[5174]: Failed password for invalid user user from 5.101.40.101 port 35162 ssh2
Oct 10 21:01:39 scw-5e2fca sshd[5174]: Connection closed by 5.101.40.101 port 35162 [preauth]
```

#### Qu'est-ce que c'est un service systemd?

Config:

```
/etc/systemd/system/sshd.service
```

(Ou bien aussi: `systemctl cat sshd`)

`systemctl` est un outil pour lancer le service / daemon, en tant que fils de `init`

#### Qu'est-ce que c'est systemd

- Une suite d'outils pour manipuler pleins d'aspects du système
- ... en particulier, tout le système d'`init` et les services (`systemctl`), alternative à `SysVinit`
- Mais aussi:
    - `localectl` (gestion des traduction / localisation)
    - `hostnamectl` (nom de la machine, etc.)
    - `systemd-resolve` (un service qui gère la résolution DNS)
    - les points de montage
    - les tâches programmées (cron -> timer)

- Systemd est une sorte de "framework pour assembler la base d'un système Linux"
- Il au coeur des Linux modernes malgré une certaine impopularité. Approfondir systemd est certainement important pour un admin.
- Systemd est plein de fonctionnalités peu connues pour répondre à différents usecases et c'est un sujet vaste.
- Il est modulaire et remplace certaines partie usages linux traditionnels.
- Certaines distributions implémente seulement certaines parties de systemd
  - Debian/ubuntu/ArchLinux ne l'utilise pas entièrement
  - Fedora (et aussi Red Hat) utilise tout ou largement systemd

Quelques liens (en anglais):

- https://www.digitalocean.com/community/tutorials/understanding-systemd-units-and-unit-files
- https://opensource.com/article/20/5/systemd-startup

### Investiguer des logs via systemd

The systemd way : `journalctl -u <nom_du_service>`

Par exemple : `journalctl -u ssh`


### Protéger contre le brute-force : `fail2ban`

- Fail2ban analyse automatiquement les logs
- Cherche / détecte des activités suspectes connues
    - Par exemple : une IP qui essaye des mots de passe
- Déclenche une action ... comme bannir l'IP pour un certain temps
    - (Basé sur `iptables` qui permet de définir des règles réseau)
- Les "jails" sont configurées via `/etc/fail2ban/jail.conf`
- Fail2ban loggue ses actions dans `/var/log/fail2ban.log`

### `fail2ban` : exemple de la jail SSH

- Analyse `/var/log/auth.log`
- Cherche des lignes comme `Failed password for user from W.X.Y.Z`

```text
## Global settings
bantime  = 600
findtime = 600
maxretry = 5

[sshd]
port    = ssh
logpath = /var/log/auth.log
```

### `fail2ban` : le log de fail2ban

```text
2018-10-10 20:50:35 INFO    [sshd] Found 5.101.40.101
2018-10-10 20:50:35 INFO    [sshd] Found 5.101.40.101
2018-10-10 20:50:38 INFO    [sshd] Found 5.101.40.101
2018-10-10 20:50:39 NOTICE  [sshd] Ban 5.101.40.101
2018-10-10 21:00:40 NOTICE  [sshd] Unban 5.101.40.101
2018-10-10 21:01:37 INFO    [sshd] Found 5.101.40.101
2018-10-10 21:01:37 INFO    [sshd] Found 5.101.40.101
2018-10-10 21:01:39 INFO    [sshd] Found 5.101.40.101
2018-10-10 21:01:40 NOTICE  [sshd] Ban 5.101.40.101
2018-10-10 21:11:41 NOTICE  [sshd] Unban 5.101.40.101
```

### `fail2ban` : exemple de la jail recidive

- Analyse `/var/log/fail2ban.log` (!!)
- Cherche des lignes comme `Ban W.X.Y.Z`

```text
## Global settings
bantime  = 600
findtime = 600
maxretry = 5

[recidive]
logpath  = /var/log/fail2ban.log
banaction = %(banaction_allports)s
bantime  = 604800  ; 1 week
findtime = 86400   ; 1 day
```

### Sécurité : modèle de menace

- De qui cherche-t-on à se protéger ?
   - Des acteurs gouvernementaux ? (NSA, Russie, Chine, ...)
   - Des attaques ciblées ? (DDOS, ransomware, espionnage economique)
   - Des attaques automatiques ? (bots)
   - De pannes systèmes ? (c.f. backups, résilience)
   - Des utilisateurs d'un site ? (injections, abus, ...)
   - Des collègues ?
   - ...

- Que cherche-t-on à protéger ?
   - Le front-end ?
   - L'accès aux serveurs ?
   - Des informations sur la vie de l'entreprise ?
   - Les infos personelles des utilisateurs ?
   - L'intégrité et la résilience d'un système ?
   - Sa vie privée ? (historique de navigation, geolocalisation)
   - ...


### Sécurité basique d'une machine (bureau, serveur)

1. Maintenir son système à jour
2. Minimiser la surface d'attaque
  - logiciels / apps installées
  - ports ouverts
  - permissions des utilisateurs et fichiers
  - accès physique
  - ...
3. Utiliser des mots de passe robustes (ou idéalement des clefs)
4. Utiliser des protocoles sécurisés
5. Faire des sauvegardes (3-2-1)
6. Faire auditer les systèmes + veille sur les CVE


![](/img/linux/admin/xkcd_password.jpg)


![](/img/linux/admin/xkcd_security.png)


### Exemple de risque de sécurité subtil

Si on lance cette commande :

```bash
commande_complexe --argument --password "super_secret"
```

Le mot de passe `super_secret` sera visible par d'autres utilisateurs dans `ps -ef` ...!
---
title: "Pourquoi Docker : Les Dockerfiles"
pre: "<b>1.07 </b>"
weight: 8
---
## Objectifs pédagogiques
  - Savoir comparer un Dockerfile à d'autres solutions d'IAC (Ansible, puppet)
  - Analyser les avantages et inconvénients de cette solution

## Analogie

On va voir que Docker, c'est un peu comme servir des plats surgelés - qui peuvent être par ailleurs de bonne qualité selon leur prix.

On va opposer ça avec la "cuisine maison", qui nécessite 
* de faire les courses, 
* d'avoir des recettes
* d'y passer du temps
* d'avoir du matériel

Et qui peut être bonne ou mauvaise selon la qualité des cuisines, des ingrédients, etc.

## Les pratiques d'Infrastructure As Code 

**On a vu que les pratiques de déploiement ont avancé dans le sens de la formalisation et de l'automatisation.**

L'objectif de l'IAC est de définir dans du code des actions manuelles.

Une fois automatisées, ces opérations peuvent être reproduites.

## Les outils d'IAC

Quelques noms : 

- Terraform : ça fait les courses 
- Ansible : ça lance la cuisson d'un plat
- Puppet : ça surveille des cuisines industrielles

### **Terraform** 

Est utilisé pour déployer de nouvelles ressources dans le cloud et les configurer. 

> Ex: Tous les soirs on détruit l'infrastructure de dev et tous les matins on la reconstruit avec le volume data voulu chez AWS.

```shell
resource "aws_ebs_volume" "my_data" {
  availability_zone = "${module.my_host.availability_zone}" # ensure the volume is created in the same AZ the docker host
  type              = "gp2"                                 # i.e. "Amazon EBS General Purpose SSD"
  size              = 25                                    # in GiB; if you change this in-place, you need to SSH over and run e.g. $ sudo resize2fs /dev/xvdh
}
```

### **Ansible**

Est utilisé pour configurer des serveurs en fonction de leurs rôles.

> Ex: Toutes les nouvelles VMs Apache ont le package voulu et il est actif. 

```shell
---
  - name: Playbook
    hosts: webservers
    become: yes
    become_user: root
    tasks:
      - name: ensure apache is at the latest version
        yum:
          name: httpd
          state: latest
      - name: ensure apache is running
        service:
          name: httpd
          state: started
```

### **Puppet** 

Est utilisé pour maintenir sur le long terme une flotte de machines.

> Ex: Le nouvel utilisateur est déployé sur les 1200 machines du parc.

```shell
    # Ensure user
    user { "tech":
        ensure => present,
        system => false,
        shell  => '/bin/bash',
        groups => ["tech", "wheel"],
        home   => "/home/tech",
    }   

```

### Les outils d'IAC sont exécutés sur des systèmes actifs

Ils vont créer de nouvelles ressources, les configurer, gérer leur cycle de vie.

* Déploiement de nouvelles machines
* Installation de packages
* Génération de fichiers de configuration
* Lancement de process

**C'est ça la "cuisine maison".** 

Elle implique beaucoup de connaissances, ce qui rend le déploiement de nouvelles applications parfois difficile.

Et selon la manière dont on aura plus ou moins bien conçu sa cuisine et formé les cuistots...

On aura de bons résultats et une bonne capacité d'évolution.

## Docker, un plat surgelé ? 


**C'est le Dockerfile qui rapproche Docker des outils d'IAC.**

```dockerfile
FROM node:18-alpine
MAINTAINER support@mytechcompany.io
LABEL "author"="Blue Team"
WORKDIR /app
COPY . .
RUN yarn install --production
RUN adduser -D nodejs
USER nodejs
ARG CUSTOMER_API="v1"
ENTRYPOINT ["node"]
CMD ["src/index.js"]
EXPOSE 3000
VOLUME /data
HEALTHCHECK --interval=60s --timeout=5s \
  CMD curl -f http://localhost:3000/heathz || exit 1
```

C'est un fichier qui définit les conditions nécessaires pour que le process de votre application se lance correctement.

Ça inclut : 
- les packages 
- les utilisateurs
- les fichiers de configuration
- le code applicatif 
- le lancement du process
- les besoins en stockage 
- les ports réseaux 
- la surveillance de l'application

**L'image Docker est «prête à consommer».**

Avantage : Une image Docker contient toutes ces informations et rend l'application simple à lancer pour un utilisateur.

Désavantage : Vous ne savez pas ce que l'image contient, comment elle fonctionne, ce qu'elle exécute. En cas de problème, ça peut devenir très compliqué.



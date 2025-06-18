---
title: "Pourquoi Docker : Les Dockerfiles"
weight: 8
---
## Objectifs pédagogiques
  - Savoir comparer un Dockerfile à d'autres solutions d'IAC (Ansible, puppet)
  - Analyser les avantages et inconvénients de cette solution

---

## Analogie

**On va voir que Docker, c'est un peu comme servir des plats surgelés - qui peuvent être par ailleurs de bonne qualité selon leur prix.**

On va opposer ça avec la "cuisine maison", qui nécessite 
* de faire les courses, 
* d'avoir des recettes
* d'y passer du temps
* d'avoir du matériel

Et qui peut être bonne ou mauvaise selon la qualité des cuisines, des ingrédients, etc.

---

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

---

**L'image Docker est «prête à consommer».**

Avantage : Une image Docker contient toutes ces informations et rend l'application simple à lancer pour un utilisateur.

Désavantage : Vous ne savez pas ce que l'image contient, comment elle fonctionne, ce qu'elle exécute. En cas de problème, ça peut devenir très compliqué.


--- 

## Docker une solution de packaging

**La réussite de Docker tient à celle de sa solution d'IAC, qui a permis aux développeurs de fournir leur application sous forme de package simple à exploiter.**

Auparavant la création d'images système était réservée aux administrateurs chevronnés.

En fournissant une solution d'IAC simple et efficace, Docker a permis de réduire la complexité qui sépare les développeurs de la production.


# Théorie : Avantages de la virtualisation

## Objectifs pédagogiques

**Stratégiques**

- Savoir choisir KVM comme outil d'architecture en fonction de critères rationnels.

---
## Amélioration de la sécurité 

**L'un des principaux avantages de l'utilisation d'un hyperviseur est qu'il peut améliorer la sécurité des machines virtuelles et du système hôte.** 

L'hyperviseur peut isoler les machines virtuelles les unes des autres et du système hôte, empêchant l'accès non autorisé, la fuite de données ou l'infection malveillante.

De plus, une approche granulaire des applications (une application par VM) permet :

- de réduire le périmètre d'exposition en cas de piratage de l'applicatif
- de maîtriser la consommation des ressources (réduction des dénis de service)

---
## Réduction des dépenses informatiques

**Lorsque vous virtualisez un environnement, un serveur physique unique se transforme en de nombreuses machines virtuelles.** 

Ces machines virtuelles peuvent avoir des systèmes d'exploitation différents et exécuter différentes applications tout en étant hébergés sur le serveur physique unique.

La consolidation des applications dans des environnements virtualisés est une approche plus rentable, car vous serez en mesure de consommer moins de clients physiques, vous aidant à dépenser beaucoup moins d'argent pour les serveurs et à réaliser des économies de coûts à votre organisation.

---

## Réduction des temps d'arrêt et amélioration de la résilience des situations de reprise après sinistre

**Lorsqu'une catastrophe affecte un serveur physique, quelqu'un est responsable de le remplacer ou de la réparer - cela pourrait prendre des heures voire des jours.** 

Avec un environnement virtualisé, il est facile de provisionner et de déployer, vous permettant de reproduire ou de cloner la machine virtuelle qui a été affectée. 

Le processus de récupération ne prendrait que quelques minutes - opposés aux heures qu'il faudrait pour provisionner et mettre en place un nouveau serveur physique - améliorer de manière significative la résilience de l'environnement et améliorer la continuité des activités.

---

## Capacité d'adaptation 

**En cas de fluctuation des charges utiles, vous aurez plus de facilité à adapter votre infrastructure.** 

En cas de forte demande, il est plus simple de déployer des clones de VM pour répondre à la montée en charge.

En cas de réduction, on peut regrouper des machines sur un nombre réduit d'hôtes physiques et éteindre ceux qui sont inutiles.

---

## Mise en capacité DevOps

**Étant donné que l'environnement virtualisé est segmenté en machines virtuelles, les développeurs peuvent rapidement faire tourner une machine virtuelle sans impact sur un environnement de production.** 

Ceci est idéal pour les environnements de Dev / Test, car le développeur peut rapidement cloner la machine virtuelle et exécuter un test sur l'environnement.

Par exemple, si un nouveau correctif logiciel a été publié, quelqu'un peut cloner la machine virtuelle et appliquer la dernière mise à jour logicielle, tester l'environnement, puis la tirer dans son application de production. 


---

## Réduction de l'empreinte carbone

**Lorsque vous êtes en mesure de réduire le nombre de serveurs physiques que vous utilisez, cela entraînera une réduction de la quantité d'énergie consommée.** 

La densification de l'infrastructure signifie une meilleure capacité d'optimisation de la charge utile.

* Moins d'alimentations électriques
* Meilleur usage des CPU/RAM sur les machines 
* Moins de ports réseaux => moins d'équipements réseaux
---

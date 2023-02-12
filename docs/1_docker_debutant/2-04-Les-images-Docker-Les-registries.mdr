---
title: Les images Docker Les registries
pre: "<b>2.04 </b>"
weight: 17
---
## Objectifs pédagogiques
  - Comprendre le fonctionnement des registries
  - Savoir installer un registry local
  - Savoir utiliser la commande push


# Publier des images vers un registry privé

- Généralement les images spécifiques produites par une entreprise n'ont pas vocation à finir dans un dépôt public.

- On peut installer des **registries privés**.

- On utilise alors `docker login <adresse_repo>` pour se logger au registry et le nom du registry dans les `tags` de l'image.

- Exemples de registries :
  - **Gitlab** fournit un registry très intéressant car intégré dans leur workflow DevOps.
  <-- - **Docker Trusted Registry (DTR)** fait partie de **Docker Enterprise** et pratique des tests de sécurité sur les images. -->

---

## Docker Hub

- Avec `docker login`, `docker tag` et `docker push`, poussez l'image `microblog` sur le Docker Hub. Créez un compte sur le Docker Hub le cas échéant.

{{% expand "Solution :" %}}

```bash
docker login
docker tag microblog:latest <your-docker-registry-account>/microblog:latest
docker push <your-docker-registry-account>/microblog:latest
```

{{% /expand %}}


## _Facultatif :_ un Registry privé

- En récupérant [la commande indiquée dans la doc officielle](https://docs.docker.com/registry/deploying/), créez votre propre registry.
- Puis trouvez comment y pousser une image dessus.
- Enfin, supprimez votre image en local et récupérez-la depuis votre registry.

{{% expand "Solution :" %}}

```bash
# Créer le registry
docker run -d -p 5000:5000 --restart=always --name registry registry:2

# Y pousser une image
docker tag ubuntu:16.04 localhost:5000/my-ubuntu
docker push localhost:5000/my-ubuntu

# Supprimer l'image en local
docker image remove ubuntu:16.04
docker image remove localhost:5000/my-ubuntu

# Récupérer l'image depuis le registry
docker pull localhost:5000/my-ubuntu
```

{{% /expand %}}
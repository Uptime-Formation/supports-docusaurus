---
title: "Dockerfile : démarrer un process avec des arguments"
pre: "<b>1.11 </b>"
weight: 12
---
## Objectifs pédagogiques
  - Savoir lancer un process dans un container Docker
  - Savoir utiliser les commandes CMD, ENTRYPOINT



## Instruction `CMD`

- Généralement à la fin du `Dockerfile` : elle permet de préciser la commande par défaut lancée à la création d'une instance du conteneur avec `docker run`. on l'utilise avec une liste de paramètres

```Dockerfile
CMD ["echo 'Conteneur démarré'"]
```

## Instruction `ENTRYPOINT`

- Précise le programme de base avec lequel sera lancé la commande

```Dockerfile
ENTRYPOINT ["/usr/bin/python3"]
```

## `CMD` et `ENTRYPOINT`

* Ne surtout pas confondre avec `RUN` qui exécute une commande Bash uniquement pendant la construction de l'image.

L'instruction `CMD` a trois formes :
* `CMD ["executable","param1","param2"]` (*exec form*, forme à préférer)
* `CMD ["param1","param2"]` (combinée à une instruction `ENTRYPOINT`)
* `CMD command param1 param2` (*shell form*)


Si l'on souhaite que notre container lance le même exécutable à chaque fois, alors on peut opter pour l'usage d'`ENTRYPOINT` en combination avec `CMD`.
le contenu du dossier courant sur l'hôte dans un dossier `/microblog` à l’intérieur du conteneur.
Nous n'avons pas copié les requirements en même temps pour pouvoir tirer partie des fonctionnalités de cache de Docker, et ne pas avoir à retélécharger les dépendances de l'application à chaque fois que l'on modifie le contenu de l'app.

Puis, dans la 2e ligne, le dossier courant dans le conteneur est déplacé à `/`.

- Reconstruisez votre image. **Observons que le build recommence à partir de l'instruction modifiée. Les layers précédents avaient été mis en cache par le Docker Engine.**
- Si tout se passe bien, poursuivez.

  <-- - `RUN pip3 install flask` -->

- Enfin, ajoutons la section de démarrage à la fin du Dockerfile, c'est un script appelé `boot.sh` :

```Dockerfile
CMD ["./boot.sh"]
```

- Reconstruisez l'image et lancez un conteneur basé sur l'image en ouvrant le port `5000` avec la commande : `docker run -p 5000:5000 microblog`

- Naviguez dans le navigateur à l’adresse `localhost:5000` pour admirer le prototype microblog.

- Lancez un deuxième container cette fois avec : `docker run -d -p 5001:5000 microblog`

- Une deuxième instance de l’app est maintenant en fonctionnement et accessible à l’adresse `localhost:5001`


## _Facultatif :_ Faire parler la vache

Créons un nouveau Dockerfile qui permet de faire dire des choses à une vache grâce à la commande `cowsay`.
Le but est de faire fonctionner notre programme dans un conteneur à partir de commandes de type :

- `docker run --rm cowsay Coucou !`
- `docker run --rm cowsay -f stegosaurus Yo!`
- `docker run --rm cowsay -f elephant-in-snake Un éléphant dans un boa.`

- Doit-on utiliser la commande `ENTRYPOINT` ou la commande `CMD` ? Se référer au [manuel de référence sur les Dockerfiles](https://docs.docker.com/engine/reference/builder/) si besoin.
- Pour information, `cowsay` s'installe dans `/usr/games/cowsay`.
- La liste des options (incontournables) de `cowsay` se trouve ici : <https://debian-facile.org/doc:jeux:cowsay>

{{% expand "Solution :" %}}

```Dockerfile
FROM ubuntu
RUN apt-get update && apt-get install -y cowsay
ENTRYPOINT ["/usr/games/cowsay"]
# les crochets sont nécessaires, car ce n'est pas tout à fait la même instruction qui est exécutée sans
```

{{% /expand %}}

- L'instruction `ENTRYPOINT` et la gestion des entrées-sorties des programmes dans les Dockerfiles peut être un peu capricieuse et il faut parfois avoir de bonnes notions de Bash et de Linux pour comprendre (et bien lire la documentation Docker).
- On utilise parfois des conteneurs juste pour qu'ils s'exécutent une fois (pour récupérer le résultat dans la console, ou générer des fichiers). On utilise alors l'option `--rm` pour les supprimer dès qu'ils s'arrêtent.

# Pour vérifier l'état de Docker

- Les commandes de base pour connaître l'état de Docker sont :

```bash
docker info  # affiche plein d'information sur l'engine avec lequel vous êtes en contact
docker ps    # affiche les conteneurs en train de tourner
docker ps -a # affiche  également les conteneurs arrêtés
```

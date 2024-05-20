---
title: "Cours Dockerfile : la commande par défaut d'un conteneur"
---

<!-- ## Objectifs pédagogiques

  - Savoir lancer un process dans un container Docker
  - Savoir utiliser les commandes CMD, ENTRYPOINT
   -->
<!-- --- -->

La combinaison des deux directives du Dockerfile `CMD` et `ENTRYPOINT` débouche sur le programme qui sera effectivement executé au lancement du conteneur ainsi que les arguments utilisés.

### Instruction `CMD`

```dockerfile
CMD ["executable","param1","param2"] (exec form, this is the preferred form)
CMD ["param1","param2"] (as default parameters to ENTRYPOINT)
CMD command param1 param2 (shell form)
```

Généralement à la fin du `Dockerfile`, `CMD` permet de préciser **la commande par défaut** lancée à la création d'une instance du conteneur avec `docker run`. on l'utilise avec une liste de paramètres

```Dockerfile
CMD ["echo 'Conteneur démarré'"]
```

<!-- --- -->

### Instruction `ENTRYPOINT`

```dockerfile
ENTRYPOINT ["executable", "param1", "param2"]
ENTRYPOINT command param1 param2
```

`ENTRYPOINT` précise le programme de base (d'entrée) avec lequel sera lancé le conteneur... il ne sera pas écrasé par la commande éventuellement fournie au lancement.

```Dockerfile
FROM python:3.9
ENTRYPOINT ["/usr/bin/python3", "-c"]
```

Ensuite on peut faire : `docker run python_entrypoint 'print("hello")'`


### Combinaisons de ENTRYP0INT et CMD - Comment s'y retrouver ?!

En général il y a 9 combinaisons possibles des deux commandes => les résultats sont compliqués et peu intuitifs: https://docs.docker.com/engine/reference/builder/#understand-how-cmd-and-entrypoint-interact

En réalité on utilise que 3 situations en général

#### Cas 1 - la plupart du temps ENTRYPOINT n'est pas utile et on utilise uniquement CMD

Quand il n'y a que `CMD` dans le Dockerfile :
- soit on fait `docker run` sans donner de commande et c'est le `CMD` du Dockerfile qui prime
- soit on donne une commande et elle écrase le `CMD` du Dockerfile

La plupart des cas de commandes docker run que nous avons vu jusqu'ici rentrent dans cette catégorie

<!-- --- -->

#### Cas 2 - ENTRYPOINT type ["/usr/bin/python3"]

On utilise ce cas quand on veut créer un conteneur "outil" basé sur un programme "prompt" de base. Exemple donné plus haut:

```Dockerfile
FROM python:3.9
ENTRYPOINT ["/usr/bin/python3", "-c"]
```

Ensuite on peut faire : `docker run python_entrypoint 'print("hello")` dans ce cas :
- `print("hello")`, la commande est ajoutée comme argument de l'entrypoint `/usr/bin/python3 -c`
- nous avons un conteneur "outil" qui permet lancer un bout de code python directement.
- si on ne précise pas de commande avec Docker run c'est juste `/usr/bin/python3` sans argument qui est exécuté.

Vois aussi cowsay plus bas comme outils pour décorer du texte avec Docker. On pourrait imaginer d'autres outils par exemple utiliser `/usr/bin/nslookup` pour faire des check dns directement sans entrer dans un conteneur. etc

<!-- --- -->

#### Cas 3 - ENTRYPOINT type ["/usr/bin/python3"] + une CMD

```Dockerfile
FROM python:3.9
ENTRYPOINT ["/usr/bin/python3", "-c"]
CMD ['print("je peux executer du python directement")']
```

Dans ce cas :
- si on ne donne pas de commande à `docker run` le conteneur execute `/usr/bin/python3 -c 'print("je peux executer du python directement")'`
- si on donne une commande à `docker run` elle remplace la partie `CMD` mais pas l'entrypoint. Par exemple `docker run python_entrypoint -c 1+1` affiche `2` (car [`-c`,`print(... directement)`] de la CMD on été remplacés par les nouveaux arguments)

=> on a une sorte d'"outil" rapide comme le cas 2 mais il a une valeur par défaut pour ses arguments qu'on peut surcharger

<!-- --- -->

## _Exercice facultatif :_ Faire parler la vache

Créons un nouveau Dockerfile qui permet de faire dire des choses à une vache grâce à la commande `cowsay`.

Le but est de faire fonctionner notre programme dans un conteneur à partir de commandes de type :

- `docker run --rm cowsay Coucou !`
- `docker run --rm cowsay -f stegosaurus Yo!`
- `docker run --rm cowsay -f elephant-in-snake Un éléphant dans un boa.`

- Doit-on utiliser la commande `ENTRYPOINT` ou la commande `CMD` ? Se référer au [manuel de référence sur les Dockerfiles](https://docs.docker.com/engine/reference/builder/) si besoin.
- Pour information, `cowsay` s'installe dans `/usr/games/cowsay`.
- La liste des options (incontournables) de `cowsay` se trouve ici : <https://debian-facile.org/doc:jeux:cowsay>


### Correction :

```Dockerfile
FROM ubuntu
RUN apt-get update && apt-get install -y cowsay
ENTRYPOINT ["/usr/games/cowsay"]
```


**L'instruction `ENTRYPOINT` et la gestion des entrées-sorties des programmes dans les Dockerfiles peut être un peu capricieuse et il faut parfois avoir de bonnes notions de Bash et de Linux pour comprendre (et bien lire la documentation Docker).**

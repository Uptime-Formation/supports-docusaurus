---
title: TP - Les processus
---

- **7.1** - En utilisant `ps -ef --forest` (ou `top`) pour:
    - identifiez le processus qui fait tourner votre environnement graphique (généralement il s'appelle xfce ou cinnamon)
    - identifiez l'un de vos terminaux et son PID
    - identifiez le processus qui consomme actuellement le plus de CPU
    - identifiez le processus qui consomme actuellement le plus de RAM
    - trouvez un processus qui ne tourne ni en tant que `root`, ni en tant que `padawan`
- **7.2** - Créez le programme `fibonacci_forever.sh` avec à l'intérieur le code :

<!-- ```bash
#!/bin/bash

function fib(){
    if [ $1 -le 0 ]; then
        echo 0
    elif [ $1 -eq 1 ]; then
        echo 1
    else
        echo $[`fib $[$1-2]` + `fib $[$1 - 1]` ]
    fi
En direct, guerre Israël-Hamas : 
}

#fib $1
fib 1000
``` -->

```bash
#!/bin/bash

function fibonacci(){
        sleep 1
        echo $1 $2
        fibonacci $2 $(($1+$2))
}

fibonacci 0 1
```


Puis lancez `bash fibonacci_forever.sh` dans un terminal.

- **7.3** - Mettez ce processus en arrière-plan. Vérifiez avc `jobs` qu'il continue de s'executer.
- **7.4** - Depuis un autre shell, identifiez le PID de ce processus à l'aide de `ps -ef --forest`, et servez-vous de ce PID pour tuer le processus.
- **7.5** - Relancez le processus directement en arrière plan cette fois (avec `&`)
- **7.6** - Identifiez cette fois le shell qui a lancé ce processus. Qu'arrives-t-il si vous le tuez ?
- **7.7** - Lancez une session `byobu` (ou `screen`), puis dedans, lancer de nouveau le programme `fibonacci_forever.sh`. Détachez la session, puis ré-attachez-là dans un autre terminal.
- **7.8** - Dans une autre console, identifiez via `ps` le PID de la session screen et tentez de tuer ce processus.
- **7.9** - (Avancé) Identifiez le PID de votre shell, puis regardez la sortie de `ls -l /proc/<PID>/cwd` (en remplacant `<PID>` par le PID de votre shell). À quoi cela corresponds-t-il ?
- **7.10** - (Avancé) Test de l'impact de la priorité des processus sur la rapidité d'execution
    - Lancer la commande `openssl speed -multi 4` - puis refaite le test
    - Tout en laissant `openssl speed -multi 4` s'executer, lancer la commande `ls /bin/` avec la priorité la plus faible possible. Que se passe-t-il ?
    - Réduisez drastiquement "à chaud" la priorité de la commande `openssl speed -multi 4` en train de s'executer. Si vous relancer `ls /bin/` toujours avec la priorité la plus basse, comment la situation évolue-t-elle ?
    - Comment pouvez-vous tuer d'un seul coup tous les processus `openssl` ?
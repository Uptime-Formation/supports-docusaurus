---
title: TP - Correction - Redirections et assemblage de commandes
sidebar_class_name: hidden
---


- 9.1 : `echo "Hello" > hello.txt`, puis faire `cat hello.txt` pour confirmer le résultat attendu
- 9.2 : `echo "World!" >> hello.txt`, puis faire `cat hello.txt` pour confirmer le résultat attendu
- 9.3 : `ls /usr/bin/ > files.tmplist` puis `less files.tmplist`
- 9.4 : `bash fibonacci_forever.sh > suite_de_fibonacci`, puis `Ctrl+C` après quelques secondes, puis `cat suite_de_fibonacci` pour confirmer le résultat attendu
- 9.4 : écrire `2+2`, `6\*7`, `10/3` (sur plusieurs lignes) dans un fichier `calcul`, puis faire `bc < calcul`
- 9.5 : `bc <<< "6*7"`
- 9.6 : `mkdir -p ~/formation_linux/calculs; echo '6*7' > ~/formation_linux/calculs/formule; bc < ~/formation_linux/calculs/formule > ~/formation_linux/calculs/reponse`
- 9.7 : `curl -L fr.wikipedia.org > wikipedia.html >/dev/null 2>&1 || echo "ça n'a pas marché !"`
- 9.8 :

```bash
mkdir /tmp/chat/
touch /tmp/chat/chat
chmod +w /tmp/chat/chat
tail -f /tmp/chat/chat &
```

puis faire `echo "beep boop" >> /tmp/chat/chat` depuis d'autres terminaux (attention, il y a deux chevrons !).

Il est possible de créer l'alias `say` qui parle dans le chat avec :

```bash
alias say="echo [$USER] >> /tmp/chat/chat"
```
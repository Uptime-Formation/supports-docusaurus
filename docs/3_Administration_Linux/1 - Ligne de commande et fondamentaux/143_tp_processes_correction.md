---
title: TP - Correction - Les processus
sidebar_class_name: hidden
---

- 7.1 - Il faut lancer `ps -ef --forest` et lire attentivement la sortie pour trouver `cinnamon-session`/`xfce4-session` et un processus nommé `bash` (et/ou `gnome-terminal-server` qui devrait être le parent des processus `bash`). Trouver le processus qui consomme le plus de CPU et de RAM se fait avec `top` (utiliser `shift+M` pour trier par utilisation de la RAM). Dans `ps -ef --forest`, il est possible aussi de trouver des processus qui tourne en tant que des utilisateurs système, tel que `systemd-*`.
- 7.2 - En utilisant l'url du programme, faire `wget https://url/du/programme` pour le récupérer dans votre machine. Puis lancer `bash fibonnaci_forever.sh`.
- 7.3 - En ayant `bash fibonnaci_forever.sh` qui tourne, faire `Ctrl+Z` puis `bg` pour mettre le programme en arrière plan. Confirmer avec `jobs` qu'il tourne bien en arrière plan. Notez que la sortie de la commande continue de s'afficher dans le terminal (bien que le programme n'a pas la main dessus)
- 7.4 - Après avoir trouvé le PID avec `ps -ef --forest`, faire `kill PID`.
- 7.5 - `bash fibonnaci_forever.sh &` (notez le `&` à la fin de la commande)
- 7.6 - Si l'on tue le shell (c'est-à-dire le processus `bash` qui a lancé la commande `bash fibonnaci_forever.sh`), alors cela tue complètement la fenêtre de terminal plutôt que juste l'execution de `fibonnaci_forever.sh`.
- 7.7 - Lancez `screen` et dedans, `bash fibonnaci_forever.sh`. Faites `Ctrl+A` puis `D` pour détacher la session. Eventuellement `screen -list` pour lister les sessions screen. Depuis un autre terminal, faites `screen -r` et constatez que vous récupérez bien le shell ou vous aviez lancé `fibonnaci_forever.sh`.
- 7.8 - Après avoir trouvé le PID avec `ps -ef --forest`, faire `kill PID`.

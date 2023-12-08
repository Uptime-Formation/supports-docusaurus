---
title: TP - Déployer un site web simple avec nginx
---

- 7.1 - Installer `nginx` puis vérifier que le service tourne bien avec `systemctl status nginx`. On pourra aussi utiliser `ps -ef --forest` pour constater qu'un processus nginx tourne bien, ainsi que `netstat -tulpn` pour constater qu'il écoute bien sur le port 80.
- 7.2 - Tester d'accéder à votre serveur depuis un navigateur web. Que se passe-t-il ? En déduire qu'il faut taper `ufw allow 80/tcp` - puis retenter l'opération. Comparez la page alors obtenue au fichier se trouvant dans `/var/www/html/`.
- 7.3 - Nous voudrions maintenant servir notre propre contenu web plutôt que l'exemple de nginx. Créer un dossier `mywebsite` dans `/var/www/` et à l'intérier, créer un fichier `index.html` qui contient par exemple :
```html
<html>
Hello world !
</html>
```
Ensuite, modifier le fichier `/etc/nginx/sites-enabled/default` :  trouvez l'instruction à modifier pour servir le dossier `/var/www/mywebsite/` plutôt que `/var/www/html/`. Vérifiez ensuite que vos changements ne causent pas de problèmes grâce à `nginx -t`, puis si tout est ok, recharger le service avec `systemctl reload nginx`. Arrivez-vous maintenant à accéder à votre page web ?
- 7.4 - Modifier votre page web pour inclure une image (se renseigner sur la balise HTML `<img>`). Par exemple, des images de chatons peuvent être trouvées sur `https://placekitten.com/` et téléchargée sur le serveur à l'aide de la commande `wget`.
- 7.5 - Rendez-vous dans `/var/log/nginx/` et lancer une surveillance du log `access.log` à l'aide de `tail -f access.log`. Depuis votre navigateur, rechargez plusieurs fois la page de votre site et étudiez les lignes qui apparaissent dans votre console.
- 7.6 - Continuez de personnaliser votre page web. Par exemple, rajoutez un lien vers une autre page web se situant dans un sous-dossier de `mywebsite`.
- 7.7 - Que se passe-t-il si vous arrêter nginx avec `systemctl stop nginx` ?

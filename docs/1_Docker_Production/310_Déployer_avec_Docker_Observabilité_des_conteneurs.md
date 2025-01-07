---
title:  Déployer avec Docker Observabilité des conteneurs
weight: 38
---

## Objectifs pédagogiques
* Comprendre ce qu'on appelle observabilité
* Savoir comment utiliser des outils d'observabilité avec Docker

---

## Monitorer des conteneurs

- Avec Prometheus pour Docker et Docker Swarm
- Ou bien Netdata, un peu plus joli et configuré pour monitorer des conteneurs _out-of-the-box_

---

## Instruction `HEALTHCHECK`

`HEALTHCHECK` permet de vérifier si l'app contenue dans un conteneur est en bonne santé.

```shell
HEALTHCHECK CMD curl --fail http://localhost:5000/health || exit 1
```

```yaml
version: '3.4'
services:
  web:
    image: very-simple-web
    build:
      context: ./
      dockerfile: Dockerfile
    restart: unless-stopped
    ports:
      - "80:80"
    healthcheck:
      test: curl --fail http://localhost || exit 1
      interval: 60s
      retries: 5
      start_period: 20s
      timeout: 10s
```
---

### Du monitoring avec *cAdvisor* et *Prometheus*

Suivre ce tutoriel pour du monitoring des conteneurs Docker : <https://prometheus.io/docs/guides/cadvisor/> -->

---
## Gérer les logs des conteneurs

Avec Elasticsearch, Filebeat et Kibana… grâce aux labels sur les conteneurs Docker

## Une stack Elastic pour centraliser les logs

**L'utilité d'Elasticsearch est que, grâce à une configuration très simple de son module Filebeat, nous allons pouvoir centraliser les logs de tous nos conteneurs Docker.**

Pour ce faire, il suffit d'abord de télécharger une configuration de Filebeat prévue à cet effet :

```yaml

filebeat.config:
  modules:
    path: ${path.config}/modules.d/*.yml
    reload.enabled: false

filebeat.autodiscover:
  providers:
    - type: docker
      hints.enabled: true

processors:
- add_cloud_metadata: ~

output.elasticsearch:
  hosts: '${ELASTICSEARCH_HOSTS:elasticsearch:9200}'
  username: '${ELASTICSEARCH_USERNAME:}'
  password: '${ELASTICSEARCH_PASSWORD:}'

```

Rectifions qui possède ce fichier pour satisfaire une contrainte de sécurité de Filebeat :

```shell
sudo chown root filebeat.docker.yml
sudo chmod go-w filebeat.docker.yml
```

Enfin, créons un fichier `docker-compose.yml` pour lancer une stack Elasticsearch :

```yaml
services:
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:7.5.0
    environment:
      - discovery.type=single-node
      - xpack.security.enabled=false
    ports:
      - 9200:9200
    networks:
      - logging-network

  filebeat:
    image: docker.elastic.co/beats/filebeat:7.5.0
    user: root
    depends_on:
      - elasticsearch
    volumes:
      - type=bind,source=filebeat.docker.yml,target=/usr/share/filebeat/filebeat.yml,read_only=true
      - /var/lib/docker/containers:/var/lib/docker/containers:ro
      - /var/run/docker.sock:/var/run/docker.sock
    networks:
      - logging-network
    environment:
      - -strict.perms=false

  kibana:
    image: docker.elastic.co/kibana/kibana:7.5.0
    depends_on:
      - elasticsearch
    ports:
      - 5601:5601
    networks:
      - logging-network

networks:
  logging-network:
    driver: bridge
```
---

Démarrez les conteneurs.

Dans le conteneur filebeat lancez la commande pour configurer 
```shell
/usr/local/bin/docker-entrypoint setup -E setup.kibana.host=kibana:5601 \
> -E output.elasticsearch.hosts=["elasticsearch:9200"]
```

Il suffit ensuite de :
- se rendre sur Kibana (port `5601`)
- de configurer l'index en tapant `*` dans le champ indiqué, de valider
- et de sélectionner le champ `@timestamp`, puis de valider.

L'index nécessaire à Kibana est créé, vous pouvez vous rendre dans la partie Discover à gauche (l'icône boussole 🧭) pour lire vos logs.

Il est temps de faire un petit `docker stats` pour découvrir l'utilisation du CPU et de la RAM de vos conteneurs !

---
### _Avancé :_ Ajouter un nœud Elasticsearch

**À l'aide de la documentation Elasticsearch et/ou en adaptant de bouts de code Docker Compose trouvés sur internet, ajoutez et configurez un nœud Elastic.** 

Toujours à l'aide de la documentation Elasticsearch, vérifiez que ce nouveau nœud communique bien avec le premier.

---
title: Bonus 2 - Déployer dans Swarm
# sidebar_class_name: hidden
---

## TP déployer l'app d'exemple Docker

Pour se connecter au cluster: 

Créez le ficher `env` puis sourcez le (la passphrase ssh est la même que le mdp utilisateur):

```sh
ssh-add ~/.ssh/id_stagiaire
export DOCKER_HOST="ssh://root@49.13.22.7"
```

Déployez la stack Swarm d'exemple suivante en suivant le readme: https://github.com/dockersamples/example-voting-app


## Autre version avec deploy section:

Source : https://devopstuto-docker.readthedocs.io/en/latest/samples/labs/votingapp/votingapp.html


```yaml
version: "3"
services:

  redis:
        image: redis:alpine
        ports:
          - "6379"
        networks:
          - frontend
        deploy:
          replicas: 1
          update_config:
                parallelism: 2
                delay: 10s
          restart_policy:
                condition: on-failure
  db:
        image: postgres:9.4
        volumes:
          - db-data:/var/lib/postgresql/data
        networks:
          - backend
        deploy:
          placement:
                constraints: [node.role == manager]
  vote:
        image: dockersamples/examplevotingapp_vote:before
        ports:
          - 5000:80
        networks:
          - frontend
        depends_on:
          - redis
        deploy:
          replicas: 2
          update_config:
                parallelism: 2
          restart_policy:
                condition: on-failure
  result:
        image: dockersamples/examplevotingapp_result:before
        ports:
          - 5001:80
        networks:
          - backend
        depends_on:
          - db
        deploy:
          replicas: 1
          update_config:
                parallelism: 2
                delay: 10s
          restart_policy:
                condition: on-failure

  worker:
        image: dockersamples/examplevotingapp_worker
        networks:
          - frontend
          - backend
        deploy:
          mode: replicated
          replicas: 1
          labels: [APP=VOTING]
          restart_policy:
                condition: on-failure
                delay: 10s
                max_attempts: 3
                window: 120s
          placement:
                constraints: [node.role == manager]

  visualizer:
        image: dockersamples/visualizer:stable
        ports:
          - "8080:8080"
        stop_grace_period: 1m30s
        volumes:
          - "/var/run/docker.sock:/var/run/docker.sock"
        deploy:
          placement:
                constraints: [node.role == manager]

networks:
  frontend:
  backend:

volumes:
  db-data:
```
---
title: 'TP2 - Déployer des conteneurs'
draft: true
---



## Kubernetes Objects

<!-- TODO: Intégrer l'utile dans TODO_k8s.md et jeter le reste -->



### Installez l'extension VSCode Kubernetes

### Pods

`kubectl get pods -n kube-system`

`kubectl describe -n kube-system pod/kubernetes-dashboard-<xxxx-xx>`

`kubectl logs <pod>`

`kubectl attach -n kube-system -it pod/kubernetes-dashboard-<xxxx-xx>`

Go into a container:

`kubectl get pods -n kube-system`

`kubectl exec -it pod/monitoring-influxdb-grafana-<xxxx-xx> -- sh`


`kubectl top nodes`

## Installer une application avec Redis

Modèle pour déployer ma monsterstack

https://kubernetes.io/docs/tutorials/stateless-application/guestbook/

## Installer un wordpress pour le Persistent volume

https://kubernetes.io/docs/tutorials/stateful-application/mysql-wordpress-persistent-volume/

Marche bien


## Nginx ou Contour Ingress sur Digital Ocean

https://www.digitalocean.com/community/tutorials/how-to-set-up-an-nginx-ingress-with-cert-manager-on-digitalocean-kubernetes

### Ingress example avec nginx et microk8s

 Nous allons déployer un service

- Install Ingress 

microk8s.kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/mandatory.yaml

- Enable Ingress Addon

microk8s.enable ingress

4. Run a local Docker Registry

You can skip this step if you wanna host your image on a public/private repository.

docker run -p 5000:5000 registry

5. Clone Example Repository And Build Docker Image

git clone https://github.com/kendricktan/microk8s-ingress-example
cd microk8s-ingress-example

docker build . -t my-microk8s-app
docker tag my-microk8s-app localhost:5000/my-microk8s-app
docker push localhost:5000/my-microk8s-app

6. Run Applications And Ingress

microk8s.kubectl apply -f bar-deployment.yml
microk8s.kubectl apply -f foo-deployment.yml
microk8s.kubectl apply -f ingress.yml

7. Expose Deployments to Ingress

If you skip this step you'll get a 503 service unavailable

microk8s.kubectl expose deployment foo-app --type=LoadBalancer --port=8080
microk8s.kubectl expose deployment bar-app --type=LoadBalancer --port=8080

8. Testing Endpoint Out

curl -kL https://127.0.0.1/bar
curl -kL https://127.0.0.1/foo



## Run your container in pods


### Setup a diagnostic application container : KUARD

```
cd ~/Bureau
git clone https://github.com/kubernetes-up-and-running/kuard`
```

```bash
cd kuard
docker build -t kuard .
docker run -p 8080:8080 --name kuard kuard
```

```bash
docker tag kuard <your_hub_login>/kuard:0.1
docker login
docker push <your_hub_login>/kuard:0.1
```


`kubectl run kuard --generator=run-pod/v1  --image=<your_hub_login>/kuard:0.1`

`kubectl delete pod/kuard`

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: kuard
spec:
  containers:
    - image: gcr.io/kuar-demo/kuard-amd64:blue
      name: kuard
      ports:
        - containerPort: 8080
          name: http
          protocol: TCP
```
{{%expand "Réponse" %}}
```bash
kubectl apply -f kuard-pod.yaml`
```
{{% /expand%}}

`kubectl describe pods kuard`

`kubectl delete pod/kuard` ou à partir du fichier `kubectl delete -f kuard-pod.yml`

`kubectl cp $HOME/config.txt <pod-name>:/config.txt`



## Services et Déploiements

```bash
kubectl run alpaca-prod \
  --image=tecpi/kuard:0.1 \
  --replicas=3 \
  --port=8080 \
  --labels="ver=1,app=alpaca,env=prod"

kubectl expose deployment alpaca-prod

kubectl run bandicoot-prod \
  --image=tecpi/kuard:0.1 \
  --replicas=2 \
  --port=8080 \
  --labels="ver=2,app=bandicoot,env=prod"

kubectl expose deployment bandicoot-prod

kubectl get services -o wide
```
# Argocd Demo

## Requirements

To run this demo, you will need :

- [docker](https://www.docker.com/)
- [k3d](https://github.com/rancher/k3d)

## Quick start

Just run the `apply.sh` script, it will deploy everything

To acces to your web app, you need to modify your `/etc/hosts` file with the IP of the LB.

Retrieve the ip of the Load Balancer :

```
export KUBECONFIG=$(k3d get kubeconfig demo)
kubectl config use-context k3d-demo
kubectl -n traefik get svc
```

Then edit your /etc/hosts  nd add this line (replace the ip with the correct one) :

```
172.21.0.5       argocd.demo traefik.demo vote.demo result.demo
```

# Argocd Demo

## Requirements

To run this demo, you will need :

- [docker](https://www.docker.com/)
- [k3d](https://github.com/rancher/k3d)

## Quick start

先用docker pull 相关的image
执行如下命令导入到k3d
```
k3d image import -c demo ghcr.io/dexidp/dex:v2.27.0
k3d image import -c demo redis:5.0.10-alpine
k3d image import -c demo argoproj/argocd:latest
```

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

Wait for ArgoCD to be ready, then you can access to argocd at https://argocd.demo

The admin password is the name of the argocd-server pod (`kubectl -n argocd get pod -l app.kubernetes.io/name=argocd-server`)

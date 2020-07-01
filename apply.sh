#!/bin/bash

echo "Listing clusters..."
k3d_exists=$(k3d get cluster | grep demo | wc -l)

if [ "$k3d_exists" == "0" ]; then
    echo "Creating kubernetes cluster..."
    sopsd secrets/registries.enc.yml
    k3d create cluster demo -w 3 --no-lb --wait
    sleep 5
else
    echo "Kubernetes cluster demo already exists..."
fi

echo "Exporting kubectl config..."
export KUBECONFIG=$(k3d get kubeconfig demo)
kubectl config use-context k3d-demo

echo "--------------------------"
echo "         ARGOCD           "
echo "--------------------------"
kubectl apply -k traefik/dev
kubectl apply -k argocd/dev

echo "Waiting for traefik LoadBalancer IP..."
while lb_ip=$(kubectl -n traefik get svc traefik -o jsonpath='{.status.loadBalancer.ingress[0].ip}'); do
    if [ -z "$lb_ip" ]; then
        echo -n "."
        sleep 3
    else
        echo ""
        break
    fi

done
echo "LB IP is $lb_ip"

echo "Waiting for argocd-server to be ready..."
while pod_ready=$(kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server | grep "1/1" | wc -l); do
    if [ "$pod_ready" == "1" ]; then
        echo ""
        break;
    fi
    echo -n "."
    sleep 3
done
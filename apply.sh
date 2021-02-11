#!/bin/bash

echo "--------------------------"
echo "        KUBERNETES        "
echo "--------------------------"
echo "Listing clusters..."
k3d_exists=$(k3d cluster list | grep demo | wc -l | awk '{gsub(/^ +| +$/,"")} {print $0}')

if [ "$k3d_exists" == "0" ]; then
    echo "Creating kubernetes cluster..."
    k3d cluster create demo \
        --api-port 6550 \
        --agents 1 \
        --k3s-server-arg='-disable=traefik' \
        -p '80:80@loadbalancer' \
        -p '443:443@loadbalancer' \
        --wait
    sleep 5
else
    echo "Kubernetes cluster demo already exists..."
fi

echo "Exporting kubectl config..."
kubectl config use-context k3d-demo

echo "--------------------------"
echo "         TRAEFIK          "
echo "--------------------------"
kubectl apply -k traefik/dev

echo "Waiting for traefik LoadBalancer IP..."
while lb_ip=$(kubectl -n traefik get svc traefik-lb -o jsonpath='{.status.loadBalancer.ingress[0].ip}'); do
    if [ -z "$lb_ip" ]; then
        echo -n "."
        sleep 3
    else
        echo ""
        break
    fi

done
echo "LB IP is $lb_ip"
echo "Add this line in your /etc/hosts :"
echo "$lb_ip       argocd.demo traefik.demo vote.demo result.demo"


echo "--------------------------"
echo "         ARGOCD           "
echo "--------------------------"
kubectl apply -k argocd/dev
echo "Waiting for argocd-server to be ready..."
while pod_ready=$(kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server | grep "1/1" | wc -l); do
    if [ "$pod_ready" == "1" ]; then
        echo ""
        break;
    fi
    echo -n "."
    sleep 3
done
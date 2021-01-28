#!/bin/sh

echo "----------------------------------------Cleaning Up"
k3d cluster delete uat
# sudo rm -rf deploy/

echo "----------------------------------------Installing Cluster"
# --k3s-server-arg "--cluster-init" # for HA with etcd instead of DQlite
# --k3s-server-arg "--disable=traefik" \
# --image "docker.io/rancher/k3s:v1.20.2-k3s1" \
mkdir cluster-data
chown $(whoami): cluster-data
k3d cluster create --config k3d-config.yaml \
  --image "docker.io/rancher/k3s:v1.19.7-k3s1"
# k3d cluster create uat --agents 2 \
#     --image "docker.io/rancher/k3s:v1.19.7-k3s1" \
#     --k3s-server-arg "--cluster-init" \
#     --port 80:80@loadbalancer --port 443:443@loadbalancer \
#     --volume "$(pwd)/manifests/temp-pv.yaml:/var/lib/rancher/k3s/server/manifests/temp-pv.yaml" \
#     --volume "$(pwd)/manifests/temp-pvc.yaml:/var/lib/rancher/k3s/server/manifests/temp-pvc.yaml" \
#     --volume "$(pwd)/cluster-data:/data"

echo "----------------------------------------Copying kubeconfig"
k3d kubeconfig get uat > $(pwd)/tmp/k3d-uat-config.yaml
k3d kubeconfig get uat > $HOME/.kube/k3d-uat-config.yaml
chmod 700 $HOME/.kube/k3d-uat-config.yaml
export KUBECONFIG=$HOME/.kube/k3d-uat-config.yaml
kubectl config use-context k3d-uat

echo "----------------------------------------Installing Helms"
helm repo add t3n https://storage.googleapis.com/t3n-helm-charts
helm repo add k8s-at-home https://k8s-at-home.com/charts/
helm repo add jetstack https://charts.jetstack.io
helm repo add rancher-stable https://releases.rancher.com/server-charts/stable
helm repo update

kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0/aio/deploy/recommended.yaml

# helm install -f traefik-helm-values.yaml \
#    traefik traefik/traefik -n kube-system
helm install nginx t3n/nginx
helm install -f heimdall-helm-values.yaml \
  heimdall k8s-at-home/heimdall
sleep 5

echo "----------------------------------------Waiting for Traefik"
sleep 5
kubectl rollout status deploy/traefik -n kube-system
traefik_status="$(kubectl get deployment traefik -n kube-system -o jsonpath="{.status.availableReplicas}")"

if [ -z $traefik_status ]; then
  traefik_status=0
fi

echo $traefik_status

while [ "$traefik_status" -lt 1 ];
do
    echo "waiting for Traefik... $traefik_status"
    sleep 5
    traefik_status="$(kubectl get deployment traefik -n kube-system -o jsonpath="{.status.availableReplicas}")"
    echo $traefik_status
    if [ -z $traefik_status ]; then
      traefik_status=0
    fi    
done

echo "----------------------------------------External IP"
kubectl get service traefik -n kube-system -o=jsonpath='{.status.loadBalancer.ingress[0].ip}'


echo "----------------------------------------Applying Ingress"
kubectl apply -f nginx-ingress.yaml
sleep 2
kubectl apply -f heimdall-ingress.yaml
sleep 2
# kubectl apply -f k8s-dashboard-ingress.yaml
# sleep 2
kubectl apply -f traefik-dash-ingress.yaml
sleep 2

echo "----------------------------------------Cert Manager & RancherUI"

kubectl create ns cert-manager

helm install cert-manager jetstack/cert-manager -n cert-manager --set installCRDs=true
# wait for cert-manager deployment
kubectl rollout status deploy/cert-manager -n cert-manager
sleep 5

echo "----------------------------------------Cert Manager & RancherUI"

kubectl create ns cattle-system

helm install rancher rancher-stable/rancher \
  --version 2.5.5 \
  -n cattle-system --set hostname=rancher.kube.uat.io
kubectl rollout status deploy/rancher -n cattle-system  

echo "----------------------------------------"
kubectl get nodes -o wide

echo "----------------------------------------"
kubectl get ingress -A

echo "----------------------------------------"
kubectl get endpoints


# echo "----------------------------------------"
# kubectl get all -A

echo "----------------------------------------End"
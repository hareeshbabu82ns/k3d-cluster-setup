kubectl scale --replicas=5 deployment/traefik -n kube-system

# traefik_cmd="$(kubectl get deployment traefik -n kube-system -o jsonpath="{.status.availableReplicas}")"

traefik_status="$(kubectl get deployment traefik -n kube-system -o jsonpath="{.status.availableReplicas}")"

if [ -z $traefik_status ]; then
  traefik_status=0
fi

echo $traefik_status

while [ "$traefik_status" -lt 5 ];
do
    echo "waiting for Traefik... $traefik_status"
    sleep 5
    traefik_status="$(kubectl get deployment traefik -n kube-system -o jsonpath="{.status.availableReplicas}")"
    echo $traefik_status
    if [ -z $traefik_status ]; then
      traefik_status=0
    fi    
done

kubectl scale --replicas=2 deployment/traefik -n kube-system
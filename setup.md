### install

* [web](https://k3d.io/)
* [releases](https://github.com/rancher/k3d/releases)
* [CLI ref](https://rancher.com/docs/k3s/latest/en/installation/install-options/server-config/#k3s-server-cli-help)
* [K3D command ref](https://k3d.io/usage/commands/)
* [kubectl cheatsheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)

* installing
```sh
$> curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | TAG=v4.0.0 bash
```

* Open new Chrome window with web security disables for Rancher (Self Certificates)
```sh
$> open -na Google\ Chrome --args --disable-web-security --user-data-dir=/var/tmp/tchrome
```
### usage

```yaml k3d-config.yaml
apiVersion: k3d.io/v1alpha1
kind: Simple
name: uat # or dev
servers: 1
agents: 2
kubeAPI:
  hostIP: "0.0.0.0"
  hostPort: "6443"
image: rancher/k3s:v1.20.2-k3s1 # k3s:v1.19.7-k3s1 # k3s:latest
volumes:
  - volume: "/home/hareesh/dev/k3d-cluster-setup/cluster-data:/data"
    nodeFilters:
      - all
ports:
  - port: 80:80
    nodeFilters:
      - loadbalancer
  - port: 0.0.0.0:443:443
    nodeFilters:
      - loadbalancer
# env:
#   - envVar: bar=baz
#     nodeFilters:
#       - all
# labels:
#   - label: foo=bar
#     nodeFilters:
#       - server[0]
#       - loadbalancer
options:
  k3d:
    wait: true
    timeout: "60s"
    disableLoadbalancer: false
    disableImageVolume: false
  k3s:
    extraServerArgs:
      - --tls-san=0.0.0.0
      # - --disable=traefik
    extraAgentArgs: []
  kubeconfig:
    updateDefaultKubeconfig: true
    switchCurrentContext: true
```

```sh
$> k3d cluster create mycluster --config k3d-config.yaml

$> k3d kubeconfig get mycluster > ~/.kube/k3d-mycluster-config.yaml
$> export KUBECONFIG=~/.kube/k3d-mycluster-config.yaml
#OR
$> export KUBECONFIG=$(k3d kubeconfig write mycluster)


$> k3d list

$> k3d node create node -c uat --replicas=1 --role=agent
$> k3d node list

$> k3d cluster stop uat
$> k3d cluster delete uat
```

* get the `rancher` service account __certificate__ and __token__
```sh
$> kubectl get -n cattle-system sa
$> kubectl get secret/deploy-bot-token-76ffv -o jsonpath='{.data.ca\.crt}' && echo
$> kubectl get secret/deploy-bot-token-76ffv -o jsonpath='{.data.token}' | base64 --decode && echo
$> kubectl get secret/deploy-bot-token-76ffv -o yaml | egrep 'ca.crt:|token:'
```

# helm usage

```sh
# shows currect config values
$> helm show values <app> 
$> helm show values <app> > app-default-values.yaml

# overwrites the default config while installing
$> helm install -f config.yaml <name> <app>

# updates to new version or updates the given config values after installing
$> helm upgrade -f config.yaml <name>

# shows upgrade history
$> helm history <app> -n <namespace>

# rollback to specified rivision
$> helm rollback <app> <rivision>
```


```sh
$> curl -k -H "Host: heimdall.kube.terabits.io" https://192.168.86.40:1443
$> curl -k -H "Host: heimdall.kube.terabits.io" http://192.168.86.67:80

curl -k -H "Host: rancher.kube.uat.io" https://192.168.86.67
```

### Persisting data
* k3d uses `local-path-provider` 

* view the config map to see the path k3d uses
```sh
$> kctl get cm -A
$> kctl get cm local-path-config -n kube-system -o yaml
```

* default storage location `/var/lib/rancher/k3s/storage` within containers

* to start the cluster with `host system folder`
```sh
$> k3d create cluster --volume "$(pwd)/data:/data"
```

* can install HelmCharts from `/var/lib/rancher/k3s/manifests`
```sh
$> k3d create cluster --volume "$(pwd)/manifests:/var/lib/rancher/k3s/server/manifests"
```
### Updating Traefik config (default with Rancher)
* uses config map
```sh
$> kubectl get cm traefik -n kube-system -o yaml > tmp/traefik-default-cm.yaml
```
* update values 
```toml
[api]
  dashboard = true
```
```sh
$> kubectl apply -f tmp/traefik-default-cm.yaml
# test
$> kctl -n kube-system port-forward deployment.apps/traefik 8080
```

## Drone CLI
* find the api token from user profile
```sh
$> export DRONE_SERVER=https://drone.terabits.io
$> export DRONE_TOKEN=XXXXXXXXX
$> drone info
```

* validate deployment from local
```sh
$> export KUBERNETES_SERVER=https://rancher.dev.kube.terabits.io/k8s/clusters/local
$> export KUBERNETES_SERVER=https://192.168.86.50:41167
$> export KUBERNETES_CERT=
$> export KUBERNETES_TOKEN=

$> docker run --rm \
    -e PLUGIN_KUBERNETES_SERVER=$KUBERNETES_SERVER \
    -e PLUGIN_KUBERNETES_CERT=$KUBERNETES_CERT \
    -e PLUGIN_KUBERNETES_TOKEN=$KUBERNETES_TOKEN \
    -v $(pwd)/k8s:/data/k8s \
    sinlead/drone-kubectl apply -f /data/k8s/deployment-react-nginx.yaml

# --insecure-skip-tls-verify
```

* setup up per repo secrets
```sh
$> drone secret add user/repo --name docker_user --data random-data-here
$> drone secret add user/repo --name docker_pass --data $FROM_ENV_VARIABLE
$> drone secret add user/repo --name k8s_server --data $KUBERNETES_SERVER
$> drone secret add user/repo --name k8s_cert --data $KUBERNETES_CERT
$> drone secret add user/repo --name k8s_token --data $KUBERNETES_TOKEN
```
### install

* [web](https://k3d.io/)
* [releases](https://github.com/rancher/k3d/releases)
* [CLI ref](https://rancher.com/docs/k3s/latest/en/installation/install-options/server-config/#k3s-server-cli-help)
* [K3D command ref](https://k3d.io/usage/commands/)
* [kubectl cheatsheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)

* installing
```sh
$> curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | TAG=v4.0.0-rc.0 bash
```

* Open new Chrome window with web security disables for Rancher (Self Certificates)
```sh
$> open -na Google\ Chrome --args --disable-web-security --user-data-dir=/var/tmp/tchrome
```
### usage

```sh
$> k3d cluster create mycluster --agents 2 \
    --port 80:80@loadbalancer --port 443:443@loadbalancer

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

$> kctl get nodes -o wide
```
NAME               STATUS   ROLES                       AGE   VERSION        INTERNAL-IP   EXTERNAL-IP   OS-IMAGE   KERNEL-VERSION     CONTAINER-RUNTIME
k3d-uat-agent-0    Ready    <none>                      98m   v1.20.0+k3s2   172.27.0.3    <none>        Unknown    5.4.0-60-generic   containerd://1.4.3-k3s1
k3d-uat-agent-1    Ready    <none>                      98m   v1.20.0+k3s2   172.27.0.4    <none>        Unknown    5.4.0-60-generic   containerd://1.4.3-k3s1
k3d-uat-server-0   Ready    control-plane,etcd,master   98m   v1.20.0+k3s2   172.27.0.2    <none>        Unknown    5.4.0-60-generic   containerd://1.4.3-k3s1
```
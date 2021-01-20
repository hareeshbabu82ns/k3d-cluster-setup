### Manual SSL certificate
* create ssl
```sh
$> openssl req -x509 -newkey rsa:4096 -sha256 -nodes \
    -keyout tls.key -out tls.crt \
    -subj "/CN=kube.uat.io" -days 365
```

* create secret to add the ssl to kubernetes
```sh
$>  kubectl create secret tls kube-uat-tls \
      --cert=tls.crt --key=tls.key

$> kubectl get secret kube-uat-tls -o yaml
```

* update the ingress.yaml for the deployment
```yaml
spec:
  tls:
    - secretName: kube-uat-tls
      hosts:
        - kube.uat.io
```

* delete secret
```sh
$> kubectl delete secret kube-uat-tls
$> kubectl delete -f nginx-ingress.yaml
$> kubectl appaly -f nginx-ingress.yaml
```
---

### Auto provision SSL certificates using CertManager

* install cert-manager from helm if not already

* create new key
```sh
$> openssl genrsa -out ca.key 2048
```

* create signing key
```sh
$> openssl req -x509 -new -nodes -key ca.key -sha256 \
    -subj "/CN=kube.uat.io" -days 1024 \
    -out ca.crt -extensions v3_ca
```

* create secret into kubernetes
```sh
$> kubectl create secret tls uat-ca-key-pair --key=ca.key --cert=ca.crt
```

* create issuer per domain
```yaml
apiVersion: cert-manager.io/v1beta1
kind: Issuer
metadata:
  name: uat-ca-issuer
  namespace: default
spec:
  ca:
    secretName: uat-ca-key-pair
```

```sh
$> kubectl get issuer
```

* create `certifiate resource` for each app usage
```yaml
apiVersion: cert-manager.k8s.io/v1beta1
kind: Certificate
metadata:
  name: nginx-kube-uat-io
  namespace: default
spec:
  secretName: uat-ca-key-pair
  issuerRef:
    name: ca-issuer
    kind: Issuer
  commonName: kube.uat.io
  dnsNames:
    - nginx.kube.uat.io
```

```sh
$> kubectl get certifiate
$> kubectl describe certificate nginx-kube-uat-io
```

* look for created certificate secret and update to TLS of ingress
```sh
$> kubectl get secret
```

#### Troubleshooting
* order of resources for `describing`
  * issuer
  * certificate
  * certificate request
  * order
  * challenge


# K3D Setup

### installing
* run the setup command
```sh
$> chmod +x ./setup.sh
$> ./setup.sh
```

* setup secret for DNS01 cert-manager with letsencrypt
```sh
$> kubectl create secret generic route53-access-key --from-literal=access-key=XYZ
$> kubectl apply ./acme-signed-certs/acme-staging-issuer.yaml
$> kubectl apply ./acme-signed-certs/acme-staging-certificate.yaml # might take hours
```
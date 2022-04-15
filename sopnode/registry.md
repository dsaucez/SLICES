# Deploy docker registry

First it is needed to generate a certificate for the registry as it uses TLS.

## Certificate creation

Prepare a directory where to store the certificate and its associated key, e.g., `certs`
```bash
mkdir certs
```

```ini
#registry-service.conf
[ req ]
prompt = no
distinguished_name = dn
req_extensions = req_ext

[ dn ]
CN = registry-service
emailAddress = damien.saucez@inria.fr
O = Inria
OU = Diana
L = Sophia Antipolis
ST = 06
C = FR

[ req_ext ]
subjectAltName = DNS: registry-service
```

```ini
#v3.ext
subjectKeyIdentifier   = hash
authorityKeyIdentifier = keyid:always,issuer:always
basicConstraints       = CA:TRUE
keyUsage               = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment, keyAgreement, keyCertSign
subjectAltName         = DNS:registry-service
issuerAltName          = issuer:copy
```

```bash
openssl genrsa -out keypair.key 4096
```

```bash
openssl req -new -out registry-service.csr -newkey rsa:4096 -nodes -sha256 -keyout registry-service.key -config registry-service.conf 
```

Generate a CA signed certificate, assuming the CA certificate and key are in the `CA` directory.
```bash
openssl x509 -req -days 365 -in registry-service.csr -CA CA/ca.crt -CAkey CA/ca.key -CAcreateserial  -out registry-service.crt -extfile v3.ext
```

## Instantiate the registry
Launch the registry:
```bash
docker run -d --restart=always --name registry -v "$(pwd)"/certs:/certs -e REGISTRY_HTTP_ADDR=0.0.0.0:443 -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/registry-service.crt -e REGISTRY_HTTP_TLS_KEY=/certs/registry-service.key -p 5000:443 registry:2
```

Deploy the certificate to all docker hosts that will use the registry

```bash
mkdir -p /etc/docker/certs.d/registry-service:443
```

Copy the CA certificate as a CA file for the registry:

```bash
cp CA/ca.crt /etc/docker/certs.d/registry-service:443/ca.crt
```

In kubernetes it can be useful to deploy the certificate and keys in a secret

```bash
kubectl create secret tls registry-service-secret --cert=registry-service.crt --key=registry-service.key
```

## Use images from the registry

It is assumed here that `registry-service` resolves to an address listened by the registry.

To publish an image to the registry, first tag it

```bash
docker tag <image> registry-service:443/<image>
```
then push it to the registry

```bash
docker push registry-service:443/<image>
```

To use the image on a docker host:
```bash
docker run --rm -ti registry-service:443/<image>
```
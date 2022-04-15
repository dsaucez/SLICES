# Deploy docker registry

## Certificate creation

Prepare a directory where to store the certificate and its associated key, e.g., `certs`
```bash
mkdir certs
```

Generate the certificate

```bash
openssl req -x509 -newkey rsa:4096 -sha256 -days 3650 -nodes \
  -keyout certs/registry-service.key -out certs/registry-service.crt -extensions san -config \
  <(echo "[req]"; 
    echo distinguished_name=req; 
    echo "[san]"; 
    echo subjectAltName=DNS:registry-service,DNS:registry-service,IP:10.98.130.107
    ) \
  -subj "/CN=registry-service"
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

Copy the generated certificate as a CA file:

```bash
cp certs/registry-service.crt /etc/docker/certs.d/registry-service:443/ca.crt
```

## Use images from the registry

To publish an image to the registry, first tag it

```bash
docker tag <image> registry.example.com:5000/<image>
```
then push it to the registry

```bash
docker push registry.example.com:5000/<image>
```

To use the image on a docker host:
```bash
docker run --rm -ti registry.example.com:5000/<image>
```
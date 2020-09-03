# Building the image

```docker build -t esgf/idp-proxy .```

# Running a container

```
docker container run -d --name idp-proxy \
  -p 8080:8080 \
  -e KEYCLOAK_USER=admin \
  -e KEYCLOAK_PASSWORD=secret \
  esgf/idp-proxy
```

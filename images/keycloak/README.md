# Building the image

```docker build -t esgf/keycloak .```

# Running a container

```
docker container run -d --name keycloak \
  -p 8080:8080 \
  -e KEYCLOAK_USER=admin \
  -e KEYCLOAK_PASSWORD=secret \
  esgf/keycloak
```

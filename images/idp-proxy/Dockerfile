# ESGF styled CentOS 7 Keycloak server

FROM esgf/keycloak:latest

# Add ESGF styled IDP Proxy theme library
COPY https://github.com/ESGF/esgf-idp-proxy-theme/releases/download/0.1/esgf-idp-proxy-theme-0.1.jar /opt/jboss/keycloak/standalone/deployments/theme.jar

# TODO:
# Configure new realm
#RUN /opt/jboss/keycloak/bin/kcadm.sh create realms --server http://localhost:8080/auth --realm master --user admin --password admin -o -s realm=esgf -s enabled=true -s loginTheme=esgf -s accountTheme=esgf

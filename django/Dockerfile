#####
## Base image for serving Django apps as a self-contained unit (static files and all).
##
## This uses gunicorn for the WSGI server.
#####

# Use the smallest base image we can
FROM python:2.7-slim

# Ensure that Python outputs everything that's printed inside
# the application rather than buffering it.
ENV PYTHONUNBUFFERED 1

# Configure an unprivileged user for running gunicorn
ENV DJANGO_USER gunicorn
ENV DJANGO_GROUP gunicorn
ENV DJANGO_UID 1001
ENV DJANGO_GID 1001
RUN groupadd -g $DJANGO_GID $DJANGO_USER &&  \
    useradd -d /home/gunicorn -m -g $DJANGO_GROUP -s /sbin/nologin -u $DJANGO_UID $DJANGO_USER

# Install curl
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Use gosu for better sudo, as recommended here: https://docs.docker.com/engine/userguide/eng-image/dockerfile_best-practices/#user
ENV GOSU_VERSION 1.10
RUN curl -o /usr/local/bin/gosu -sSL "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-amd64" && \
    curl -o /usr/local/bin/gosu.asc -sSL "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-amd64.asc" && \
    export GNUPGHOME="$(mktemp -d)" && \
    gpg --keyserver keyserver.ubuntu.com --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 && \
    gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu && \
    rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc && \
    chmod +x /usr/local/bin/gosu && \
    gosu nobody true

# Install gunicorn and paste
RUN pip install gunicorn Paste PasteDeploy

# Install paste wrapper and env settings into site-packages
COPY python/*.py /usr/local/lib/python2.7/site-packages/

EXPOSE 8000

# Install startup script
COPY scripts/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

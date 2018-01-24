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

# Install gunicorn and paste
RUN pip install gunicorn Paste PasteDeploy

# Install paste wrapper and env settings into site-packages
COPY python/*.py /usr/local/lib/python2.7/site-packages/

# Install startup script
COPY scripts/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

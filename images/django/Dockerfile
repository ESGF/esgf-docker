#####
## Base image for Django applications
##
## Uses ONBUILD instructions to copy application code and pre-built wheels
## from a build stage
##
## This allows the final Django images to be free of build dependencies like
## git, compilers, devel packages, etc.
##
## This Dockerfile is used to build two images with python2 and python3 as the
## base image respectively
#####

ARG ESGF_REPOSITORY_BASE=esgfhub
ARG ESGF_IMAGES_VERSION=latest
ARG PYTHON_MAJOR_VERSION=3
FROM ${ESGF_REPOSITORY_BASE}/python${PYTHON_MAJOR_VERSION}:${ESGF_IMAGES_VERSION}

USER root

# Install gunicorn as WSGI server, whitenoise for serving static files and
# django-flexi-settings for smart handling of settings
# We have to use a different version of gunicorn and whitenoise depending on whether
# we are running Python 2 or 3
ARG PYTHON_MAJOR_VERSION=3
RUN GUNICORN_VERSION="$([ "$PYTHON_MAJOR_VERSION" -eq 2 ] && echo "19.10.0" || echo "20.0.4")" && \
    WHITENOISE_VERSION="$([ "$PYTHON_MAJOR_VERSION" -eq 2 ] && echo "4.1.4" || echo "5.0.1")" && \
    pip install --no-cache-dir \
      'django-flexi-settings==0.1.1' \
      "gunicorn==$GUNICORN_VERSION" \
      "whitenoise==$WHITENOISE_VERSION"

# Confiure Gunicorn and Django
ENV DJANGO_SETTINGS_MODULE flexi_settings.settings
ENV DJANGO_FLEXI_SETTINGS_ROOT /esg/django/settings.py
ENV DJANGO_SETTINGS_DIR /esg/django/settings.d
ENV DJANGO_STATIC_DIR /esg/django/staticfiles
COPY gunicorn.conf.py /etc/gunicorn/conf.py
COPY django-serve.sh /usr/local/bin/
COPY init.d/* $ESGF_INIT_DIR/
COPY settings.py $DJANGO_FLEXI_SETTINGS_ROOT
COPY settings.d/* $DJANGO_SETTINGS_DIR/
RUN mkdir -p $DJANGO_STATIC_DIR && \
    chown $ESGF_USER:$ESGF_GROUP $DJANGO_STATIC_DIR

# Install wheels and application from the builder
ONBUILD COPY --from=builder /build/wheelhouse /build/wheelhouse
ONBUILD COPY --from=builder /application /application
# Install the application, but only look for dependencies in the wheelhouse
ONBUILD RUN pip install --no-cache-dir --no-index --find-links /build/wheelhouse --editable /application
ONBUILD USER $ESGF_UID

# By default, run gunicorn
EXPOSE 8080
CMD ["/usr/local/bin/django-serve.sh"]

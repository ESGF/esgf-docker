#####
## Docker image for the Django auth service
#####

ARG ESGF_REPOSITORY_BASE=esgfdeploy
ARG ESGF_IMAGES_VERSION=latest
ARG GIT_REPOSITORY=https://github.com/cedadev/django-auth-service.git
ARG GIT_VERSION=b5f8c31817a1373828470b0899265be69455a6ec

FROM ${ESGF_REPOSITORY_BASE}/python-build:${ESGF_IMAGES_VERSION} as python-build

FROM ${ESGF_REPOSITORY_BASE}/conda:${ESGF_IMAGES_VERSION}

USER root

# Install gunicorn server, whitenoise to handle static files and 
# django-flexi-settings for smart handling of settings
RUN pip install --no-cache-dir \
      'gunicorn==20.0.4' \
      'django-flexi-settings==0.1.1' \
      'whitenoise==5.2.0'

# Install gunicorn config file
COPY gunicorn.conf.py /etc/gunicorn/conf.py
COPY wsgi-serve.sh /usr/local/bin/

# Configure Django to use the flexi settings module
ENV DJANGO_SETTINGS_MODULE flexi_settings.settings
# Install the default settings
ENV DJANGO_FLEXI_SETTINGS_ROOT /etc/django/settings.py
COPY conf /etc/django
# Make sure the settings directory exists
RUN mkdir -p /etc/django/settings.d

# Install init scripts and serving script
COPY django-serve.sh /usr/local/bin/
COPY init.d/* /docker-init.d/

# Use ONBUILD instructions to install and configure the application
COPY --from=python-build /build/wheelhouse /build/wheelhouse
#   Install the wheels that we copied
RUN pip install --no-deps /build/wheelhouse/*.whl
#   Install the app settings
COPY settings.d/* /etc/django/settings.d/
#   Make sure to run as the ESGF user
USER $ESGF_UID

# By default, serve the Django application on port 8080
EXPOSE 8080
CMD ["/usr/local/bin/django-serve.sh"]

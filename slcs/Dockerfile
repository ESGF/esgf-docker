#####
## Image for running the ESGF SLCS server
##
## To avoid including unnecessary build dependencies in the final image, we use
## a builder image to check out the code and build wheels for all our dependencies
#####

ARG ESGF_DJANGO_VERSION=latest

FROM python:2.7-slim AS esgf-slcs-build

# Install apt dependencies required for the build
#   git: for checking out the source code and pulling dependencies
#   build-essential: for gcc, required to build cryptography
#   libssl-dev: openssl header files, required to build cryptography
RUN apt-get update && \
    apt-get install -y git build-essential libssl-dev && \
    rm -rf /var/lib/apt/lists/*

# Clone the github repo and checkout the specified version
ARG ESGF_SLCS_GIT_VERSION=master
RUN git clone https://github.com/ESGF/esgf-slcs-server.git /application && \
    cd /application && \
    git checkout $ESGF_SLCS_GIT_VERSION && \
    rm -rf .git && \
    cd -

# Create wheels from the requirements
RUN mkdir /pip-wheels && \
    pip wheel --wheel-dir /pip-wheels -r /application/requirements.txt


#############
## Stage 2 ##
#############

FROM cedadev/esgf-django:${ESGF_DJANGO_VERSION}

# Copy the application and wheels from the build stage
COPY --from=esgf-slcs-build /application /application
COPY --from=esgf-slcs-build /pip-wheels  /pip-wheels

# Install the application + wheels (remove the wheels when we are done)
RUN pip install --no-index --find-links=/pip-wheels -r /application/requirements.txt && \
    pip install --no-deps -e /application && \
    rm -rf /pip-wheels

# Install configuration files
ENV ONLINECA_PASTEDEPLOY_FILE /opt/onlineca/onlineca.ini
COPY conf/settings.py /application/esgf_slcs_server/
# The Paste config file is a template that is interpolated at runtime with values
# from environment variables
COPY --chown=1001:1001 conf/onlineca.ini $ONLINECA_PASTEDEPLOY_FILE
# This is the script that does the interpolating
COPY scripts/configure-onlineca.py /django-init.d/

# Run as the named Django user
USER $DJANGO_USER

# The "command" is just the settings file to use
CMD ["esgf_slcs_server.settings"]

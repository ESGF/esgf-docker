#####
## This Dockerfile builds an image containing common configuration templates,
## and scripts that can then be copied into other container images
#####

# Use the lightest base image we can
FROM alpine

# Install gomplate (for templating) into the bin directory
ARG GOMPLATE_VERSION=v2.7.0
RUN apk --no-cache add curl && \
    mkdir -p /esg/bin && \
    curl -o /esg/bin/gomplate -fsSL https://github.com/hairyhenderson/gomplate/releases/download/${GOMPLATE_VERSION}/gomplate_linux-amd64-slim && \
    chmod 755 /esg/bin/gomplate
# Copy the scripts into the bin directory
COPY ./scripts  /esg/bin
# Create the default contents of /esg/config with the correct permissions
# Non-root users in the root group need to be able to write config files in downstream containers
# All the Java applications expect the password files to be present, even if they don't need the contents
RUN mkdir -p /esg/config && \
    echo "changeit" > /esg/config/.esgf_pass && \
    echo "changeit" > /esg/config/.esg_pg_pass && \
    chmod -R g+w /esg/config
# Copy the config templates as the defaults for /esg/config
COPY ./config  /esg/config/.defaults

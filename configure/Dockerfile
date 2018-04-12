#####
## This Dockerfile builds an image containing common configuration files, templates
## and scripts that can then be copied into other container images
#####

# Use the lightest base image we can
FROM alpine

COPY ./config  /esg/config
COPY ./scripts  /opt/esgf-docker/scripts

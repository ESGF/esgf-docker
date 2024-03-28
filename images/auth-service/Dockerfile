#####
## Docker image for the Django auth service
#####

ARG ESGF_REPOSITORY_BASE=esgfdeploy
ARG ESGF_IMAGES_VERSION=latest
ARG GIT_REPOSITORY=https://github.com/cedadev/django-auth-service.git
ARG GIT_VERSION=ff652b96d0b73639603f43b4770d0799ee886552

FROM ${ESGF_REPOSITORY_BASE}/python-build:${ESGF_IMAGES_VERSION} as python-build

FROM ${ESGF_REPOSITORY_BASE}/django:${ESGF_IMAGES_VERSION}

#####
## Docker image for the Django auth service
#####

ARG ESGF_REPOSITORY_BASE=esgfdeploy
ARG ESGF_IMAGES_VERSION=latest
ARG GIT_REPOSITORY=https://github.com/cedadev/django-auth-service.git
ARG GIT_VERSION=c0befb6001c813050dbc8e3ca503cd1c7c22f7f0

FROM ${ESGF_REPOSITORY_BASE}/python-build:${ESGF_IMAGES_VERSION} as python-build

FROM ${ESGF_REPOSITORY_BASE}/django:${ESGF_IMAGES_VERSION}

#####
## Docker image for the Django auth service
#####

ARG ESGF_REPOSITORY_BASE=esgfdeploy
ARG ESGF_IMAGES_VERSION=latest
ARG GIT_REPOSITORY=https://github.com/cedadev/django-auth-service.git
ARG GIT_VERSION=0.2.5

FROM ${ESGF_REPOSITORY_BASE}/python-build:${ESGF_IMAGES_VERSION} as python-build

FROM ${ESGF_REPOSITORY_BASE}/django:${ESGF_IMAGES_VERSION}

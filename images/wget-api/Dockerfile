#####
## Image for running wget-api
#####
# docker build -t <tag> --build-arg=ESGF_IMAGES_VERSION=future-architecture .

ARG ESGF_REPOSITORY_BASE=esgfdeploy
ARG ESGF_IMAGES_VERSION=latest

FROM centos:7.8.2003 as get_repo

WORKDIR /usr/local/esgf-wget
USER root

RUN yum install -y git && \
    git clone https://github.com/esgf/esgf-wget.git --branch devel /usr/local/esgf-wget

FROM ${ESGF_REPOSITORY_BASE}/base:${ESGF_IMAGES_VERSION}

USER root
RUN yum install -y python3 python3-pip  && \
    pip3 install gunicorn requests "django>=3.0,<3.1"

WORKDIR /wgetApi

COPY --from=get_repo /usr/local/esgf-wget/esgf_wget esgf_wget
COPY --from=get_repo /usr/local/esgf-wget/manage.py .

EXPOSE 8000
USER $ESGF_UID

ENTRYPOINT ["gunicorn", "-b", "0.0.0.0:8000", "esgf_wget.wsgi", "--worker-tmp-dir", "/dev/shm", "--workers", "2", "--threads", "2", "--worker-class", "gthread"]


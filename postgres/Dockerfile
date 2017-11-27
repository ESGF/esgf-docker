# ESGF node with postgres database

ARG ESGF_IMAGES_HUB=esgfhub
ARG ESGF_VERSION=devel
FROM $ESGF_IMAGES_HUB/esgf-node:$ESGF_VERSION
MAINTAINER Earth System Grid Federation <esgf-devel@lists.llnl.gov>

# Install postgres
RUN yum -y update \
    && yum -y install postgresql-server postgresql postgresql-contrib \
    && yum clean all

# Build the UTF-8 locale so postgres is UTF-8 enabled
RUN localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

# Copy ESGF sql schemas and data
COPY ./sqldata/ /usr/local/bin/

VOLUME /var/lib/pgsql/data
ENV PGDATA /var/lib/pgsql/data

# Copy the entrypoint script, which configures postgres before launching it
COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

EXPOSE 5432
CMD ["postgres", "-D", "/var/lib/pgsql/data", "-h", "0.0.0.0"]

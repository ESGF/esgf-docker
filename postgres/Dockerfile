#####
## PostgreSQL 8 container with ESGF databases pre-configured.
##
## In an ideal world, we would use an official PostgreSQL container as the parent,
## but because PostgreSQL 8 is EOL, there is not an official container for it.
#####

# Start from CentOS 6 because yum install postgresql gets us PostgreSQL 8
FROM centos:6

MAINTAINER Earth System Grid Federation <esgf-devel@lists.llnl.gov>

# Use gosu for better sudo, as recommended here: https://docs.docker.com/engine/userguide/eng-image/dockerfile_best-practices/#user
ENV GOSU_VERSION 1.10
RUN curl -o /usr/local/bin/gosu -sSL "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-amd64" && \
    curl -o /usr/local/bin/gosu.asc -sSL "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-amd64.asc" && \
    export GNUPGHOME="$(mktemp -d)" && \
    gpg --keyserver keyserver.ubuntu.com --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 && \
    gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu && \
    rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc && \
    chmod +x /usr/local/bin/gosu && \
    gosu nobody true

# Build the UTF-8 locale so postgres is UTF-8 enabled
RUN localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

# Install postgres
RUN yum -y update && \
    yum -y install postgresql-server postgresql postgresql-contrib && \
    yum clean all && \
    rm -rf /var/cache/yum/*

ENV PGDATA /var/lib/pgsql/data
VOLUME /var/lib/pgsql/data

# Copy ESGF sql schemas and data
COPY ./sqldata/ /usr/local/bin/

# Copy the entrypoint script, which configures postgres before launching it
COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

EXPOSE 5432
CMD ["postgres", "-h", "0.0.0.0"]

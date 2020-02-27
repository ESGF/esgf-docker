#####
## Base image for postgres databases
#####

ARG ESGF_REPOSITORY_BASE=esgfhub
ARG ESGF_IMAGES_VERSION=latest
FROM ${ESGF_REPOSITORY_BASE}/base:${ESGF_IMAGES_VERSION}

USER root

ENV ESG_INIT_DB_DIR $ESG_HOME/initdb.d
RUN mkdir -p $ESG_INIT_DB_DIR

ENV PGDATA /var/lib/pgsql/data
ENV PGPORT 5432

# Install postgresql package
# We want to run as the esg user, so need to change some permissions after installation
# We also munge the sample config files to be correct for our use case by default, i.e.
#   listen on all addresses and allow password-based auth
RUN yum makecache && \
    yum install -y postgresql-server && \
    yum clean all && \
    mkdir -p /var/lib/pgsql/data && \
    chown -R $ESG_USER:$ESG_GROUP /var/lib/pgsql /run/postgresql && \
    sed -ri "s!^#?(listen_addresses)\s*=\s*\S+.*!\1 = '*'!" /usr/share/pgsql/postgresql.conf.sample && \
    echo "host all all all md5" >> /usr/share/pgsql/pg_hba.conf.sample

# Install database initialisation script
COPY 01-initdb.sh $ESG_INIT_DIR/

# Run as the esg user by default
USER $ESG_UID
EXPOSE 5432
CMD ["postgres"]

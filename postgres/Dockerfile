# ESGF node with postgres database

ARG ESGF_IMAGES_HUB=esgfhub
ARG ESGF_VERSION=devel
FROM $ESGF_IMAGES_HUB/esgf-node:$ESGF_VERSION
MAINTAINER Earth System Grid Federation <esgf-devel@lists.llnl.gov>

# install and configure postgres
RUN yum -y update; yum clean all
RUN yum -y install postgresql-server postgresql postgresql-contrib; yum clean all

# copy postgres + ESGF scripts
ADD ./scripts/ /usr/local/bin/

# copy ESGF sql schemas and data
ADD ./sqldata/ /usr/local/bin/

# setup postgres
RUN /usr/local/bin/postgres_setup.sh initdb

# configuration
# log file: /var/lib/pgsql/data/pg_log/postgres.log
ADD ./conf/postgresql.conf /var/lib/pgsql/data/postgresql.conf
RUN chown -v postgres.postgres /var/lib/pgsql/data/postgresql.conf
RUN echo "host    all             all             0.0.0.0/0               md5" >> /var/lib/pgsql/data/pg_hba.conf

# load ESGF schemas into postgres database
RUN /usr/local/bin/postgres_setup_esgf.sh

# IMPORTANT: change connections to require encrypted password
RUN sed -i 's/ident/md5/g' /var/lib/pgsql/data/pg_hba.conf

# scripted commands use password in ~/.pgpass
RUN echo 'localhost:5432:cogdb:dbsuper:changeit' > /root/.pgpass
RUN echo 'localhost:5432:esgcet:dbsuper:changeit' >> /root/.pgpass
RUN chmod 0600 /root/.pgpass

EXPOSE 5432

# add supervisor configuration for postgres service
ADD ./conf/supervisord.postgres.conf /etc/supervisor/conf.d/supervisord.postgres.conf
CMD ["supervisord", "--nodaemon", "-c", "/etc/supervisord.conf"]

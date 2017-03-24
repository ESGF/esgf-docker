# ESGF node with postgres database

FROM esgfhub/esgf-node:1.1

MAINTAINER Luca Cinquini <luca.cinquini@jpl.nasa.gov>

# install and configure postgres
RUN yum -y update; yum clean all
RUN yum -y install postgresql-server postgresql postgresql-contrib; yum clean all

# postgres + ESGF scripts
ADD ./scripts/ /usr/local/bin/
RUN chmod +x /usr/local/bin/postgresql-setup.sh
RUN chmod +x /usr/local/bin/postgres_esgf.sh
RUN chmod +x /usr/local/bin/change_password.sh

# ESGF sql schemas and data
ADD ./sqldata/ /usr/local/bin/

# setup postgres
RUN /usr/local/bin/postgresql-setup.sh initdb

# configuration
ADD ./conf/postgresql.conf /var/lib/pgsql/data/postgresql.conf
RUN chown -v postgres.postgres /var/lib/pgsql/data/postgresql.conf
RUN echo "host    all             all             0.0.0.0/0               md5" >> /var/lib/pgsql/data/pg_hba.conf

# load ESGF schemas into postgres database
RUN /usr/local/bin/postgres_esgf.sh

# IMPORTANT: change connections to require encrypted password
RUN sed -i 's/ident/md5/g' /var/lib/pgsql/data/pg_hba.conf

# scripted commands use password in ~/.pgpass
RUN echo 'localhost:5432:cogdb:dbsuper:changeit' > /root/.pgpass
RUN echo 'localhost:5432:esgcet:dbsuper:changeit' >> /root/.pgpass
RUN chmod 0600 /root/.pgpass

EXPOSE 5432

# override deafult supervisor configuration
ADD ./conf/supervisord.conf /etc/supervisord.conf
ENTRYPOINT ["supervisord", "--nodaemon", "-c", "/etc/supervisord.conf"]

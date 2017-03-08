# ESGF node manager running with Apache httpd and mod_wsgi

FROM esgfhub/esgf-httpd:1.1

MAINTAINER Luca Cinquini <luca.cinquini@jpl.nasa.gov>

# use minimum esgf.properties file
COPY conf/esgf.properties /esg/config/esgf.properties

# apache configuration needed at installation
COPY conf/esgf-httpd.conf /etc/httpd/conf/esgf-httpd.conf

# postgres password
COPY conf/esg_pg_pass /esg/config/.esg_pg_pass

# error: /usr/local/bin/python: error while loading shared libraries: libpython2.7.so.1.0: cannot open shared object file: No such file or directory 
ENV LD_LIBRARY_PATH /usr/local/lib:/usr/local/bin/python
RUN ln -s /usr/local/lib/libpython2.7.so.1.0 /usr/lib/libpython2.7.so.1.0

# install node manager from GitHub repo
RUN cd /tmp && \
    git clone https://github.com/pchengi/nm-workspace && \
    ./nm-installer.sh

ENTRYPOINT ["apachectl", "-D", "FOREGROUND"]

# vsftp (Verty Secure File Transfer protocol) server installed on centOS

FROM centos:6

MAINTAINER Luca Cinquini <luca.cinquini@jpl.nasa.gov>

# install latest vsftp server
RUN yum -y update && \
    yum install -y vsftpd && \
    yum clean all

# use anonymous-only, read-only configuration
COPY conf/vsftpd.conf /etc/vsftpd/vsftpd.conf

EXPOSE 20 21

# start vsftp with a script so the container does not exit
ADD scripts/docker-entrypoint.sh   /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

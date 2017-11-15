# vsftp (Verty Secure File Transfer protocol) server installed on centOS

FROM centos:6
MAINTAINER Earth System Grid Federation <esgf-devel@lists.llnl.gov>

# install latest vsftp server
RUN yum -y update && \
    yum install -y vsftpd && \
    yum clean all

# use anonymous-only, read-only configuration
# configuration file: /etc/vsftpd/vsftpd.conf
# data directory: /var/ftp/pub
# log file: /var/log/xferlog
COPY conf/vsftpd.conf /etc/vsftpd/vsftpd.conf

EXPOSE 20 21
EXPOSE 12020 12021 12022 12023 12024 12025

# start vsftp with a script so the container does not exit

ADD scripts/docker-entrypoint.sh   /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]


from centos:6

MAINTAINER Frank Greguska <greguska@jpl.nasa.gov>


RUN yum clean all && \
    yum -y update && \
    yum -y install wget \
    git \
    sudo \
    epel-release
    
RUN yum -y install ansible

WORKDIR /usr/local/esgf-slcs-server

COPY production_all.yml /usr/local/esgf-slcs-server
COPY development.yml /usr/local/esgf-slcs-server
ENV SERVER_FQDN=www.my-slcs-server.com \
    APPLICATION_USER=waitress

VOLUME ["/usr/local/esgf-slcs-server/ca"]

# RUN git clone https://github.com/cedadev/esgf-slcs-server-playbook.git && \
#     ansible-playbook -i esgf-slcs-server-playbook/playbook/inventories/localhost -e "@/usr/local/esgf-slcs-server/production_all.yml" -e "application_user=${APPLICATION_USER}" -e "server_name=${SERVER_FQDN}" esgf-slcs-server-playbook/playbook/playbook.yml

WORKDIR /code
RUN git clone https://github.com/cedadev/esgf-slcs-server.git && chmod -R 777 /code
WORKDIR /usr/local/esgf-slcs-server
# RUN git clone https://github.com/cedadev/esgf-slcs-server-playbook.git && \
#     ansible-playbook -i esgf-slcs-server-playbook/playbook/inventories/localhost -e "@/usr/local/esgf-slcs-server/development.yml" esgf-slcs-server-playbook/playbook/playbook.yml


CMD ["/bin/bash"]
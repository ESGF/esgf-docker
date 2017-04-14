
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
ENV SERVER_FQDN=www.my-slcs-server.com \
    APPLICATION_USER=waitress

VOLUME ["/usr/local/esgf-slcs-server/ca"]

RUN git clone https://github.com/cedadev/esgf-slcs-server-playbook.git && \
    ansible-playbook -i esgf-slcs-server-playbook/playbook/inventories/localhost -e "@/usr/local/esgf-slcs-server/production_all.yml" -e "application_user=${APPLICATION_USER}" -e "server_name=${SERVER_FQDN}" esgf-slcs-server-playbook/playbook/playbook.yml
    
# RUN mkdir /etc/ansible/
# RUN echo '[local]\nlocalhost\n' > /etc/ansible/hosts
# RUN mkdir /opt/ansible/
# RUN git clone http://github.com/ansible/ansible.git /opt/ansible/ansible
# WORKDIR /opt/ansible/ansible
# RUN git submodule update --init
# ENV PATH /opt/ansible/ansible/bin:/bin:/usr/bin:/sbin:/usr/sbin
# ENV PYTHONPATH /opt/ansible/ansible/lib
# ENV ANSIBLE_LIBRARY /opt/ansible/ansible/library


CMD ["/bin/bash"]
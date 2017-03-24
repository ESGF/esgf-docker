# Docker image based on Centos 6 that includes:
# Oracle Java 8
# Python 2.7 + a few common Python packages
# Supervisor
# Also includes common, non-site specific ESGF env variables (ESGF_HOME).

FROM centos:6

MAINTAINER Luca Cinquini <luca.cinquini@jpl.nasa.gov>

# install dependencies with yum
RUN yum -y update && \
    yum groupinstall -y development && \
    yum install -y \
    yum-utils \
    bzip2-devel \
    git \
    lsof \
    which \
    hostname \
    openssl \
    openssl-devel \
    sqlite-devel \
    sudo \
    tar \
    wget \
    zlib-dev \
    sqlite-devel \
    freetype-devel \
    postgresql-devel \
    libjpeg-turbo-devel \
    yum clean all

# install additional epel repository
RUN yum -y install epel-release; yum clean all

# install Oracle Java 8
ENV JAVA_VERSION 8u31
ENV BUILD_VERSION b13
RUN wget --no-cookies --no-check-certificate --header "Cookie: oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/$JAVA_VERSION-$BUILD_VERSION/jdk-$JAVA_VERSION-linux-x64.rpm" -O /tmp/jdk-8-linux-x64.rpm
RUN yum -y install /tmp/jdk-8-linux-x64.rpm && \
    rm /tmp/jdk-8-linux-x64.rpm
RUN alternatives --install /usr/bin/java jar /usr/java/latest/bin/java 200000
RUN alternatives --install /usr/bin/javaws javaws /usr/java/latest/bin/javaws 200000
RUN alternatives --install /usr/bin/javac javac /usr/java/latest/bin/javac 200000
ENV JAVA_HOME /usr/java/latest

# install Python 2.7
# note: option "--enable-shared" is needed by mod_wsgi, will generate /usr/local/lib/libpython2.7.so.1.0
ENV PYTHON_VERSION 2.7.13
RUN cd /tmp && \
    wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz && \
    tar xvfz Python-${PYTHON_VERSION}.tgz && \
    cd Python-${PYTHON_VERSION} && \
    ./configure --prefix=/usr/local --enable-shared && \
    make && \
    make altinstall
RUN ln -s /usr/local/bin/python2.7 /usr/local/bin/python
ENV PATH=/usr/local/bin:$PATH
ENV LD_LIBRARY_PATH=/usr/local/lib:/usr/local/bin/python:$LD_LIBRARY_PATH

# install additional core Python packages
ENV PILLOW_VERSION 2.8.2
RUN cd /tmp
RUN wget --no-check-certificate https://bootstrap.pypa.io/ez_setup.py
RUN python ez_setup.py --insecure
RUN rm -rf ez_setup.py
RUN easy_install pip
RUN pip install virtualenv
RUN pip install wheel
RUN pip install --use-wheel Pillow==${PILLOW_VERSION}

# supervisor
# executable: /usr/local/bin/supervisord
# default supervisor configuration /etc/supervisord.conf :
# will look for additional service configurations in /etc/supervisor/conf.d/
RUN pip install supervisor
COPY conf/supervisord.conf /etc/supervisord.conf
RUN mkdir -p /etc/supervisor/conf.d/

# common directories
RUN mkdir -p /esg/config
RUN mkdir -p /esg/content

# common environment variables
# necessary to locate /esg/config/esgf.properties
ENV ESGF_HOME /esg

# start supervisor in non-daemon mode
#ENTRYPOINT ["supervisord", "--nodaemon", "-c", "/etc/supervisord.conf"]

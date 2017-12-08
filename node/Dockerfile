# Python 2.7 + a few common Python packages
# Supervisor
# Also includes common, non-site specific ESGF env variables (ESGF_HOME).

FROM centos:6

MAINTAINER Earth System Grid Federation <esgf-devel@lists.llnl.gov>

# install GPG keys
RUN rpm --import http://download.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-6
RUN rpm --import http://vault.centos.org/RPM-GPG-KEY-CentOS-6
RUN yum history new # That fix the warning 'Warning: RPMDB altered outside of yum'

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
# see download string at: http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html
# run scripts/get_oracle_jdk_linux_x64.sh to identify the correct URL

ENV JAVA_VERSION 8u152
ENV JAVA_BUILD_VERSION b16
ENV JAVA_HASH=aa0333dd3019491ca4f6ddbe78cdb6d0

RUN wget -q --no-cookies --no-check-certificate --header "Cookie: oraclelicense=accept-securebackup-cookie" \
    -O /tmp/jdk-8-linux-x64.rpm \
    "http://download.oracle.com/otn-pub/java/jdk/${JAVA_VERSION}-${JAVA_BUILD_VERSION}/${JAVA_HASH}/jdk-${JAVA_VERSION}-linux-x64.rpm"

RUN yum -y install /tmp/jdk-8-linux-x64.rpm && \
    rm /tmp/jdk-8-linux-x64.rpm
RUN alternatives --install /usr/bin/java jar /usr/java/latest/bin/java 200000
RUN alternatives --install /usr/bin/javaws javaws /usr/java/latest/bin/javaws 200000
RUN alternatives --install /usr/bin/javac javac /usr/java/latest/bin/javac 200000
ENV JAVA_HOME /usr/java/latest
ENV PATH=${JAVA_HOME}/bin:$PATH

# install Python 2.7
# note: option "--enable-shared" is needed by mod_wsgi, will generate /usr/local/lib/libpython2.7.so.1.0
ENV PYTHON_VERSION 2.7.13
RUN cd /tmp && \
    wget -q https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz && \
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
RUN wget -q --no-check-certificate https://bootstrap.pypa.io/ez_setup.py
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
# log file (from configuration): /tmp/supervisord.log
RUN pip install supervisor
COPY conf/supervisord.conf /etc/supervisord.conf
COPY conf/supervisord_noothers.conf /etc/supervisord_noothers.conf
RUN mkdir -p /etc/supervisor/conf.d/


# necessary to locate /esg/config/esgf.properties

### ARGS

ARG ESGF_REPO='http://distrib-coffee.ipsl.jussieu.fr/pub/esgf'

### Common ESGF environment variables
ENV ESGF_HOME='/esg'
ENV ESGF_REPO=$ESGF_REPO
ENV ESGF_BACKUP_DIR="$ESGF_HOME/backups"
ENV ESGF_LOG_DIR="$ESGF_HOME/log"
ENV ESGF_TOOL_DIR="$ESGF_HOME/tools"
ENV ESGF_CONFIG_DIR="$ESGF_HOME/config"
ENV ESGF_CONTENT_DIR="$ESGF_HOME/content"

# common ESGF directories
RUN mkdir -p "$ESGF_LOG_DIR"
RUN mkdir -p "$ESGF_TOOL_DIR"
RUN mkdir -p "$ESGF_CONFIG_DIR"
RUN mkdir -p "$ESGF_BACKUP_DIR"
RUN mkdir -p "ESGF_CONTENT_DIR"

# default command starts supervisor in non-daemon mode
# to be overridden by child images
# NOTE: do not use ENTRYPOINT as it would interfere with arguments to certificate generation
CMD ["supervisord", "--nodaemon", "-c", "/etc/supervisord.conf"]

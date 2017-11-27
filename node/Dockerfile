# Python 2.7 + a few common Python packages
# gosu - lightweight version of su without TTY and signal handling functionality 
# Also includes common, non-site specific ESGF env variables (ESGF_HOME).

FROM centos:6

MAINTAINER Earth System Grid Federation <esgf-devel@lists.llnl.gov>

# install dependencies with yum
RUN yum -y update \
    && yum groupinstall -y development \
    && yum install -y \
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
    && yum clean all

# install additional epel repository
RUN yum -y install epel-release && yum clean all

# install Oracle Java 8
# see download string at: http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html
# run scripts/get_oracle_jdk_linux_x64.sh to identify the correct URL
ENV JAVA_VERSION 8u152
ENV JAVA_BUILD_VERSION b16
ENV JAVA_HASH=aa0333dd3019491ca4f6ddbe78cdb6d0
RUN wget -q --no-cookies --no-check-certificate --header "Cookie: oraclelicense=accept-securebackup-cookie" \
      -O /tmp/jdk-8-linux-x64.rpm \
      "http://download.oracle.com/otn-pub/java/jdk/${JAVA_VERSION}-${JAVA_BUILD_VERSION}/${JAVA_HASH}/jdk-${JAVA_VERSION}-linux-x64.rpm" \
    && yum -y install /tmp/jdk-8-linux-x64.rpm \
    && rm /tmp/jdk-8-linux-x64.rpm \
    && alternatives --install /usr/bin/java jar /usr/java/latest/bin/java 200000 \
    && alternatives --install /usr/bin/javaws javaws /usr/java/latest/bin/javaws 200000 \
    && alternatives --install /usr/bin/javac javac /usr/java/latest/bin/javac 200000
ENV JAVA_HOME /usr/java/latest
ENV PATH=${JAVA_HOME}/bin:$PATH

# install Python 2.7
# note: option "--enable-shared" is needed by mod_wsgi, will generate /usr/local/lib/libpython2.7.so.1.0
ENV PYTHON_VERSION 2.7.13
RUN cd /tmp \
    && wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz \
    && tar xvfz Python-${PYTHON_VERSION}.tgz \
    && cd Python-${PYTHON_VERSION} \
    && ./configure --prefix=/usr/local --enable-shared \
    && make \
    && make altinstall \
    && ln -s /usr/local/bin/python2.7 /usr/local/bin/python
ENV PATH=/usr/local/bin:$PATH
ENV LD_LIBRARY_PATH=/usr/local/lib:/usr/local/bin/python:$LD_LIBRARY_PATH

# install additional core Python packages
ENV PILLOW_VERSION 2.8.2
RUN cd /tmp \
    && wget --no-check-certificate https://bootstrap.pypa.io/ez_setup.py \
    && python ez_setup.py --insecure \
    && rm -rf ez_setup.py \
    && easy_install pip \
    && pip install virtualenv \
    && pip install wheel \
    && pip install --use-wheel Pillow==${PILLOW_VERSION}

# Install gosu for easier command execution from root
ENV GOSU_VERSION 1.10
RUN curl -o /usr/local/bin/gosu -sSL "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-amd64" \
    && curl -o /usr/local/bin/gosu.asc -sSL "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-amd64.asc" \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --keyserver pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
    && rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu \
    && gosu nobody true

# common directories
RUN mkdir -p /esg/config
RUN mkdir -p /esg/content

# common environment variables
# necessary to locate /esg/config/esgf.properties
ENV ESGF_HOME /esg

# default command starts a shell, meaning that "docker run -it" drops you into a shell
CMD ["/bin/sh"]

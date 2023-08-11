#####
## Image for running THREDDS
#####

ARG ESGF_REPOSITORY_BASE=esgfdeploy
ARG ESGF_IMAGES_VERSION=latest
FROM ${ESGF_REPOSITORY_BASE}/jdk:${ESGF_IMAGES_VERSION}

ARG IVY_VERSION=2.3.0
ARG IVY_URL=https://archive.apache.org/dist/ant/ivy/$IVY_VERSION/apache-ivy-$IVY_VERSION-bin-with-deps.tar.gz
ARG IVY_SHA512=073b497e5e45fa5dcca5881180ccde0a
ARG PYTHON_MD5=d235bdfa75b8396942e360a70487ee00

# Install dependencies
RUN dnf makecache && \
    dnf install -y git ant openssl-devel && \
    dnf -y groupinstall "development tools" && \
    dnf clean all

RUN curl -fsSl -o Python-2.7.18.tgz https://www.python.org/ftp/python/2.7.18/Python-2.7.18.tgz
    #echo "$PYTHON_MD5 *Python-2.7.18.tgz" | md5sum --strict --check && \
RUN tar -xzf Python-2.7.18.tgz --strip-components=1
RUN ./configure --prefix=/usr/local --enable-shared --enable-unicode=ucs4
RUN make && make altinstall
ENV LD_LIBRARY_PATH=/usr/local/lib:/usr/local/bin/python2.7:\$LD_LIBRARY_PATH

RUN python2.7 -m ensurepip --upgrade

RUN which python2.7
RUN cp /usr/local/bin/python2.7 /usr/bin/python

RUN curl -fsSl -o ivy.tar.gz $IVY_URL && \
    # echo "$IVY_SHA512 *ivy.tar.gz" | md5sum --strict --check && \
    tar -xzf ivy.tar.gz --strip-components=1 && \
    java -jar ivy-$IVY_VERSION.jar

RUN pip2 install ez_setup

# Build esgf-node-manager
ARG ESGF_NODE_MANAGER_VERSION=15682f64212782a56eacdb356432e9e21d643e1d
RUN git clone https://github.com/ESGF/esgf-node-manager.git /src/esgf-node-manager && \
    pushd /src/esgf-node-manager && \
    git checkout $ESGF_NODE_MANAGER_VERSION && \
    popd
RUN pushd /src/esgf-node-manager && \
    ant make_dist publish_local && \
    popd

# Build esgf-security
ARG ESGF_SECURITY_VERSION=a510b3f4807a683e34e32ffae11ee45f6481fd59
RUN git clone https://github.com/ESGF/esgf-security.git /src/esgf-security && \
    pushd /src/esgf-security && \
    git checkout $ESGF_SECURITY_VERSION && \
    popd
RUN pushd /src/esgf-security && \
    ant clean_all make_dist publish_local && \
    popd

# # Build esg-search
ARG ESG_SEARCH_VERSION=fa1092dae808d15cc623ee5f4b274d94762ad171
RUN git clone https://github.com/ESGF/esg-search.git /src/esg-search && \
    pushd /src/esg-search && \
    git checkout $ESG_SEARCH_VERSION && \
    popd
RUN pushd /src/esg-search && \
    ant clean_all make_dist publish_local && \
    popd

# Unpack the esg-search war into /application
RUN mkdir /application && \
    pushd /application && \
    jar xvf /src/esg-search/dist/esg-search.war

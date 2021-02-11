#####
## Image for running THREDDS
#####

ARG ESGF_REPOSITORY_BASE=esgfdeploy
ARG ESGF_IMAGES_VERSION=latest
FROM ${ESGF_REPOSITORY_BASE}/jdk:${ESGF_IMAGES_VERSION}

# Install dependencies
RUN yum makecache && \
    yum install -y git ant ivy && \
    yum clean all

# Build esgf-node-manager
ARG ESGF_NODE_MANAGER_VERSION=15682f64212782a56eacdb356432e9e21d643e1d
RUN git clone https://github.com/ESGF/esgf-node-manager.git /src/esgf-node-manager && \
    pushd /src/esgf-node-manager && \
    git checkout $ESGF_NODE_MANAGER_VERSION && \
    popd
RUN pushd /src/esgf-node-manager && \
    ant clean_all make_dist publish_local && \
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

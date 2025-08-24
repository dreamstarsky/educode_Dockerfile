FROM ubuntu:24.04

LABEL maintainer="XKM" version="v2.0"

ARG S6_OVERLAY_VERSION="v3.2.1.0"
ARG S6_OVERLAY_ARCH="x86_64"
ARG CODE_SERVER_VERSION="4.101.1"
ARG UBUNTU_MIRROR="http://archive.ubuntu.com/ubuntu/"
ARG UBUNTU_SECURITY_MIRROR="http://security.ubuntu.com/ubuntu/"
ARG MINICONDA_MIRROR="https://repo.anaconda.com/miniconda"

# ban apt interative
ARG DEBIAN_FRONTEND=noninteractive

# for faster download
RUN sed -i.bak /etc/apt/sources.list.d/ubuntu.sources \
    -e "s|http://archive.ubuntu.com/ubuntu/|${UBUNTU_MIRROR}|" \
    -e "s|http://security.ubuntu.com/ubuntu/|${UBUNTU_SECURITY_MIRROR}|"

# update system 
# install packages 
# clean cache 
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    xz-utils \
    nano \
    vim \
    git \
    make \
    cmake \
    sudo \
    gdb \
    gcc \
    g++ \
    clang \
    clangd \
    clang-format \
    python3 \
    curl \
    jq \
    ssh \
    wget && \
    curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash && \
    apt-get install -y git-lfs && \
    apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/*

# install s6-overlay
RUN curl -o /tmp/s6-overlay-noarch.tar.xz -L "https://github.com/just-containers/s6-overlay/releases/download/${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz" && \
    tar -C / -xaf /tmp/s6-overlay-noarch.tar.xz && \
    curl -o /tmp/s6-overlay.tar.xz -L "https://github.com/just-containers/s6-overlay/releases/download/${S6_OVERLAY_VERSION}/s6-overlay-${S6_OVERLAY_ARCH}.tar.xz" && \
    tar -C / -xaf /tmp/s6-overlay.tar.xz && \
    rm -rf /tmp/*

# install code-server
RUN wget "https://github.com/coder/code-server/releases/download/v${CODE_SERVER_VERSION}/code-server_${CODE_SERVER_VERSION}_amd64.deb" -O /tmp/code-server.deb && \
    apt-get install -y /tmp/code-server.deb && \
    rm /tmp/code-server.deb

# add user ubuntu as sudoer
RUN echo 'ubuntu ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers.d/ubuntu-nopasswd

USER ubuntu

# install miniconda 
ARG CONDA_DIR=/home/ubuntu/miniconda3
ENV PATH=$CONDA_DIR/bin:$PATH

RUN mkdir -p $CONDA_DIR && \
    wget ${MINICONDA_MIRROR}/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh && \
    bash /tmp/miniconda.sh -b -u -p $CONDA_DIR && \
    rm /tmp/miniconda.sh && \
    conda clean -afy && \
    conda init bash

# install git-lfs
RUN git lfs install

USER root

COPY s6-services/ /etc/services.d/
EXPOSE 22 8080 

# code-server extensions
USER ubuntu
ARG EXTENSIONS=""
RUN code-server --install-extension cnbcool.cnb-welcome \
  && code-server --install-extension redhat.vscode-yaml \
  && code-server --install-extension dbaeumer.vscode-eslint \
  && code-server --install-extension waderyan.gitblame \
  && code-server --install-extension mhutchie.git-graph \
  && code-server --install-extension donjayamanne.githistory \
  && code-server --install-extension tencent-cloud.coding-copilot \
  && code-server --install-extension MS-CEINTL.vscode-language-pack-zh-hans
RUN [ -n "$EXTENSIONS" ] && echo "$EXTENSIONS" | xargs -n 1 code-server --install-extension || true

# config language
COPY create_languagepacks /tmp/create_languagepacks 
RUN /tmp/create_languagepacks && \
    sudo rm -f /tmp/create_languagepacks

USER root
ENTRYPOINT [ "/init" ] 



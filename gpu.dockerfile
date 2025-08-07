FROM nvcr.io/nvidia/cuda:12.8.0-cudnn-devel-ubuntu24.04

RUN echo 'PATH=/usr/local/nvidia/bin:/usr/local/cuda/bin:$PATH' >> /home/ubuntu/.bashrc && \
    echo 'LD_LIBRARY_PATH=/usr/local/nvidia/lib:/usr/local/nvidia/lib64:$LD_LIBRARY_PATH' >> /home/ubuntu/.bashrc

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
RUN [ -n "$EXTENSIONS" ] && echo "$EXTENSIONS" | xargs -n 1 code-server --install-extension || true

USER root
ENTRYPOINT [ "/init" ] 



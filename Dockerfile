FROM ubuntu:24.04

LABEL maintainer="XKM" version="v2.0"

ENV S6_OVERLAY_VERSION="v3.2.1.0"
ENV S6_OVERLAY_ARCH="x86_64"
ENV CODE_SERVER_VERSION="4.101.1"

# ban apt interative
ENV DEBIAN_FRONTEND=noninteractive

# for faster download
# RUN echo 'Acquire::http::Proxy "http://172.17.0.1:3142";' > /etc/apt/apt.conf.d/01proxy

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
RUN wget https://github.com/coder/code-server/releases/download/v${CODE_SERVER_VERSION}/code-server_${CODE_SERVER_VERSION}_amd64.deb -O /tmp/code-server.deb && \
    apt-get update && apt-get install -y /tmp/code-server.deb && \
    rm /tmp/code-server.deb

# add user ubuntu as sudoer
RUN echo 'ubuntu ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers.d/ubuntu-nopasswd

USER ubuntu

WORKDIR /home/ubuntu

# install miniconda 
ENV CONDA_DIR=/home/ubuntu/miniconda3
ENV PATH=$CONDA_DIR/bin:$PATH

RUN mkdir -p $CONDA_DIR && \
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh && \
    bash /tmp/miniconda.sh -b -u -p $CONDA_DIR && \
    rm /tmp/miniconda.sh && \
    conda clean -afy && \
    conda init bash

# install git-lfs
RUN git lfs install

USER root

COPY s6-services/ /etc/services.d/
EXPOSE 22 8080 

ENTRYPOINT [ "/init" ] 



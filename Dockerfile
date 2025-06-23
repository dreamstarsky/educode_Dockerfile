FROM ubuntu:22.04

LABEL maintainer="XKM" version="0.0"

# ban apt interative
ENV DEBIAN_FRONTEND=noninterative

# for faster download
RUN echo 'Acquire::http::Proxy "http://172.17.0.1:3142";' > /etc/apt/apt.conf.d/01proxy

# update system 
# install packages 
# clean cache 
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
	ca-certificates \ 
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
        wget \
    && apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/*


# add user ubuntu as sudoer
RUN useradd -m ubuntu && \ 
	echo 'ubuntu ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers.d/ubuntu-nopasswd

USER ubuntu

WORKDIR /home/ubuntu

# install miniconda 
ENV CONDA_DIR=/home/ubuntu/miniconda3
ENV PATH=$CONDA_DIR/bin:$PATH

RUN mkdir -p $CONDA_DIR && \
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh && \
    bash /tmp/miniconda.sh -b -u -p $CONDA_DIR && \
    rm /tmp/miniconda.sh && \
    conda clean -afy

RUN conda init bash

CMD ["/bin/bash"]




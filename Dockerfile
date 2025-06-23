FROM ubuntu:22.04

LABEL maintainer="XKM" version="0.0"

# ban apt interative
ENV DEBIAN_FRONTEND=noninterative

# update system 
# install sudo 
# clean cache 
RUN apt-get update && apt-get upgrade -y && \ 
	apt-get install -y sudo && \ 
	apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt-get/lists/*

# add user ubuntu as sudoer
RUN useradd -m ubuntu && \ 
	echo 'ubuntu ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers.d/ubuntu-nopasswd

USER ubuntu

WORKDIR /home/ubuntu

CMD ["/bin/bash"]




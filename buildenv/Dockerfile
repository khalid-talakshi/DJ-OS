# base image
FROM ubuntu

# working directory
WORKDIR /project

#update sudo
RUN apt-get update
RUN apt-get upgrade

# install nasm
RUN apt-get nasm

# install qemu
RUN  apt-get qemu
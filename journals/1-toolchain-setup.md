# Entry 1: Toolchain Setup
In order to start building our OS, we need to setup some tools to make it possible. An OS needs to compile assembly and run it in some sort of emulator. For this OS we will be using the x86 architecture. Why? Mainly the number of docs and tutorials I'll be pulling from, but also because I have worked in one using MIPS and while it is awesome, it was built from the ground up. So now let's set up our environment.

## Our tools
In order to build our OS, we will be using QEMU to run the OS and NASM to compile the assembly. However we are going to run this on a docker container, to not only learn how to use docker, but to use ubuntu for all of our stuff. We have created a folder called buildenv which will have our Dockerfile. Our base image will be ubuntu since I know how to work in it, and we will install nasm and qemu on this image. If you take a look at the Dockerfile you can see how we do this. 
```dockerfile
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
```
Next step is to build this image. All we have to do here is type this command: 
```
docker build -t coolk2000/ubuntu-os-env:1.0 ./buildenv
```
This builds an image for us to work off of. We will then run this in interactive mode by doing the following: 
```
docker run -it coolk2000/ubuntu-os-env:1.0
```
This is a very basic docker file for now, but we will add more stuff later. Finally we create our git vcs and post it to our repository! And that ends our setup (for now).
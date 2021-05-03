# base image
FROM randomdude/gcc-cross-x86_64-elf:latest

# working directory
WORKDIR /project

#update sudo
RUN apt-get update -y
RUN apt-get upgrade -y

# install nasm
RUN apt-get install nasm -y

# install qemu
RUN apt-get install qemu-system-x86 -y

# copy over source files to our image
COPY ./src .

# compile assembly
RUN nasm -f bin boot.asm -o os.iso

# run QEMU with binary
CMD ["qemu-system-x86_64", "-curses", "-drive", "format=raw,file=os.iso"]
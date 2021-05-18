FROM ubuntu:20.04

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
RUN apt-get update && apt-get install -y apt-utils

# Install and configure locale `en_US.UTF-8` (otherwise SAW sometimes fails to write to the
# console)
RUN apt-get update && apt-get install -y locales && \
    sed -i -e "s/# $en_US.*/en_US.UTF-8 UTF-8/" /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8
ENV LANG=en_US.UTF-8

RUN apt-get update && apt-get install -y wget unzip git cmake clang llvm python3-pip libncurses5 curl
RUN pip3 install wllvm # whole-program-llvm

WORKDIR /workdir

ADD ./scripts/install.sh /workdir/install.sh
RUN /workdir/install.sh

ENV PATH=/workdir/bin:$PATH

ENV CRYPTOLPATH=/workdir/cryptol-specs/:/workdir/spec

ENTRYPOINT ["./scripts/docker_entrypoint.sh"]

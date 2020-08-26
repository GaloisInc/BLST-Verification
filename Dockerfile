FROM ubuntu:20.04

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
RUN apt-get update --fix-missing # at the time of writing this, curl fails to install (404 not found) with running `apt-get update` with `--fix-missing`.
RUN apt-get install -y apt-utils

# Install and configure locale `en_US.UTF-8` (otherwise SAW sometimes fails to write to the
# console)
RUN apt-get install -y locales && \
    sed -i -e "s/# $en_US.*/en_US.UTF-8 UTF-8/" /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8
ENV LANG=en_US.UTF-8

RUN apt-get install -y wget unzip git cmake clang llvm python3-pip libncurses5
RUN apt-get install curl
RUN pip3 install wllvm # whole-program-llvm

WORKDIR /workdir

# add install.sh first to avoid re-installing everything when other scripts change
ADD ./scripts/install.sh /workdir/scripts/install.sh
RUN ./scripts/install.sh

ADD ./scripts/ /workdir/scripts/

ENV PATH=/workdir/bin:$PATH

ENTRYPOINT ["./scripts/docker_entrypoint.sh"]
